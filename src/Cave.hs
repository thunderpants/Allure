module Game.LambdaHack.Cave
  ( Cave(..), SecretMapXY, ItemMapXY, TileMapXY, buildCave )
  where

import Control.Monad
import qualified Data.Map as M
import qualified Data.List as L

import Game.LambdaHack.Geometry
import Game.LambdaHack.Area
import Game.LambdaHack.AreaRnd
import Game.LambdaHack.Item
import Game.LambdaHack.Random
import Game.LambdaHack.Content.TileKind
import qualified Game.LambdaHack.Tile as Tile
import qualified Game.LambdaHack.Kind as Kind
import Game.LambdaHack.Content.CaveKind

type SecretMapXY = M.Map (X, Y) Tile.SecretStrength

type ItemMapXY = M.Map (X, Y) Item

type TileMapXY = M.Map (X, Y) (Kind.Id TileKind)

-- TODO: dmonsters :: [(X, Y), actorKind]  -- ^ fixed monsters on the level
data Cave = Cave
  { dkind     :: !(Kind.Id CaveKind)  -- ^ the kind of the cave
  , dsecret   :: SecretMapXY
  , ditem     :: ItemMapXY
  , dmap      :: TileMapXY
  , dmeta     :: String
  }
  deriving Show

buildCave :: Int -> Kind.Id CaveKind -> Rnd Cave
buildCave n ci =
  let CaveKind{clayout} = Kind.getKind ci
  in case clayout of
       CaveRogue -> caveRogue n ci
       CaveEmpty -> caveEmpty n ci
       CaveNoise -> caveNoise n ci

-- | Cave consisting of only one, empty room.
caveEmpty :: Int -> Kind.Id CaveKind -> Rnd Cave
caveEmpty _ ci =
  let CaveKind{cxsize, cysize} = Kind.getKind ci
      room = (1, 1, cxsize - 2, cysize - 2)
      dmap = digRoom True room M.empty
      cave = Cave
        { dkind = ci
        , dsecret = M.empty
        , ditem = M.empty
        , dmap
        , dmeta = "empty room"
        }
  in return cave

-- | Cave consisting of only one room with randomly distributed pillars.
caveNoise :: Int -> Kind.Id CaveKind -> Rnd Cave
caveNoise _ ci = do
  let CaveKind{cxsize, cysize} = Kind.getKind ci
      room = (1, 1, cxsize - 2, cysize - 2)
      em = digRoom True room M.empty
  nri <- rollDice (fromIntegral (cysize `div` 5), 3)
  lxy <- replicateM (cxsize * nri) $ xyInArea (1, 1, cxsize - 2, cysize - 2)
  let insertRock lm xy = M.insert xy Tile.wallId lm
      dmap = L.foldl' insertRock em lxy
      cave = Cave
        { dkind = ci
        , dsecret = M.empty
        , ditem = M.empty
        , dmap
        , dmeta = "noise room"
        }
  return cave

-- | If the room has size 1, it is at most a start of a corridor.
digRoom :: Bool -> Room -> TileMapXY -> TileMapXY
digRoom dl (x0, y0, x1, y1) lmap
  | x0 == x1 && y0 == y1 = lmap
  | otherwise =
  let floorDL = if dl then Tile.floorLightId else Tile.floorDarkId
      rm =
        [ ((x, y), floorDL) | x <- [x0..x1], y <- [y0..y1] ]
        ++ [ ((x, y), Tile.wallId)
           | x <- [x0-1, x1+1], y <- [y0..y1] ]
        ++ [ ((x, y), Tile.wallId)
           | x <- [x0-1..x1+1], y <- [y0-1, y1+1] ]
  in M.union (M.fromList rm) lmap

{-
Rogue cave is generated by an algorithm inspired by the original Rogue,
as follows:

  * The available area is divided into a 3 by 3 grid
    where each of the 9 grid cells has approximately the same size.

  * In each of the 9 grid cells one room is placed at a random location.
    The minimum size of a room is 2 by 2 floor tiles. A room is surrounded
    by walls, and the walls still have to fit into the assigned grid cells.

  * Rooms that are on horizontally or vertically adjacent grid cells
    may be connected by a corridor. Corridors consist of 3 segments of straight
    lines (either "horizontal, vertical, horizontal" or "vertical, horizontal,
    vertical"). They end in openings in the walls of the room they connect.
    It is possible that one or two of the 3 segments have length 0, such that
    the resulting corridor is L-shaped or even a single straight line.

  * Corridors are generated randomly in such a way that at least every room
    on the grid is connected, and a few more might be. It is not sufficient
    to always connect all adjacent rooms.
-}
-- | Cave generated by an algorithm inspired by the original Rogue,
caveRogue :: Int -> Kind.Id CaveKind -> Rnd Cave
caveRogue n ci = do
    let cfg@CaveKind{cxsize, cysize} = Kind.getKind ci
    lgrid@(gx, gy) <- levelGrid cfg
    lminroom <- minRoomSize cfg
    let gs = grid lgrid (0, 0, cxsize - 1, cysize - 1)
    -- grid locations of "no-rooms"
    nrnr <- noRooms cfg lgrid
    nr   <- replicateM nrnr $ xyInArea (0, 0, gx - 1, gy - 1)
    rs0  <- mapM (\ (i, r) -> do
                              r' <- if i `elem` nr
                                      then mkRoom (border cfg) (1, 1) r
                                      else mkRoom (border cfg) lminroom r
                              return (i, r')) gs
    let rooms :: [Area]
        rooms = L.map snd rs0
    dlrooms <- mapM (\ r -> darkRoomChance cfg n
                            >>= \ c -> return (r, not c)) rooms
               :: Rnd [(Area, Bool)]
    let rs = M.fromList rs0
    connects <- connectGrid lgrid
    addedConnects <- replicateM
                       (extraConnects cfg lgrid)
                       (randomConnection lgrid)
    let allConnects = L.nub (addedConnects ++ connects)
    cs <- mapM
           (\ (p0, p1) -> do
                           let r0 = rs M.! p0
                               r1 = rs M.! p1
                           connectRooms r0 r1) allConnects
    let lrooms = L.foldr (\ (r, dl) m -> digRoom dl r m) M.empty dlrooms
        lcorridors = M.unions (L.map digCorridors cs)
        lrocks =
          M.fromList [ ((x, y), Tile.wallId) | x <- [0..cxsize - 1], y <- [0..cysize - 1] ]
        lm = M.union (M.unionWith mergeCorridor lcorridors lrooms) lrocks
    -- convert openings into doors
    (dmap, secretMap) <- do
      let f (l, le) o@((x, y), t) =
                  case t of
                    _ | Tile.isOpening t ->
                      do
                        -- openings have a certain chance to be doors;
                        -- doors have a certain chance to be open; and
                        -- closed doors have a certain chance to be
                        -- secret
                        rb <- doorChance cfg
                        ro <- doorOpenChance cfg
                        if not rb
                          then return (o : l, le)
                          else if ro
                               then return (((x, y), Tile.doorOpenId) : l, le)
                               else do
                                 rsc <- doorSecretChance cfg
                                 if not rsc
                                   then return (((x, y), Tile.doorClosedId) : l, le)
                                   else do
                                     rs1 <- rollDice (csecretStrength cfg)
                                     return (((x, y), Tile.doorSecretId) : l, M.insert (x, y) (Tile.SecretStrength rs1) le)
                    _ -> return (o : l, le)
      (l, le) <- foldM f ([], M.empty) (M.toList lm)
      return (M.fromList l, le)
    let cave = Cave
          { dkind = ci
          , dsecret = secretMap
          , ditem = M.empty
          , dmap
          , dmeta = show allConnects
          }
    return cave

type Corridor = [(X, Y)]
type Room = Area

-- | Create a random room according to given parameters.
mkRoom :: Int ->      -- ^ border columns
          (X, Y) ->    -- ^ minimum size
          Area ->     -- ^ this is an area, not the room itself
          Rnd Room    -- ^ this is the upper-left and lower-right corner of the room
mkRoom bd (xm, ym) (x0, y0, x1, y1) =
  do
    (rx0, ry0) <- xyInArea (x0 + bd, y0 + bd, x1 - bd - xm + 1, y1 - bd - ym + 1)
    (rx1, ry1) <- xyInArea (rx0 + xm - 1, ry0 + ym - 1, x1 - bd, y1 - bd)
    return (rx0, ry0, rx1, ry1)

digCorridors :: Corridor -> TileMapXY
digCorridors (p1:p2:ps) =
  M.union corPos (digCorridors (p2:ps))
  where
    corXY  = fromTo p1 p2
    corPos = M.fromList $ L.zip corXY (repeat Tile.floorDarkId)
digCorridors _ = M.empty

mergeCorridor :: Kind.Id TileKind -> Kind.Id TileKind -> Kind.Id TileKind
mergeCorridor _ t | Tile.isWalkable t = t
mergeCorridor _ t | Tile.isUnknown t  = Tile.floorDarkId
mergeCorridor _ _                     = Tile.openingId
