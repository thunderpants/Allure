module StrategyState where

import Data.List as L
import Data.Map as M
import Data.Set as S
import qualified Data.IntMap as IM
import Data.Maybe
import Control.Monad

import Geometry
import Level
import Movable
import MovableState
import MovableKind
import Random
import Perception
import Strategy
import State

strategy :: Actor -> State -> Perceptions -> Strategy Dir
strategy actor
         oldState@(State { scursor = cursor,
                           splayer = pl,
                           stime   = time,
                           slevel  = Level { lname = ln,
                                             lsmell = nsmap,
                                             lmap = lmap } })
         per =
    strategy
  where
    -- TODO: set monster targets and then prefer targets to other heroes
    Movable { mkind = mk, mloc = me, mdir = mdir } = getActor actor oldState
    delState = deleteActor actor oldState
    -- If the player is a monster, monsters spot and attack him when adjacent.
    ploc = if isAHero pl || creturnLn cursor /= ln
           then Nothing
           else Just $ mloc $ getPlayerBody delState
    onlyTraitor = onlyMoves (maybe (const False) (==) ploc) me
    -- If no heroes on the level, monsters go at each other. TODO: let them
    -- earn XP by killing each other to make this dangerous to the player.
    hs = L.map (\ (i, m) -> (AHero i, mloc m)) $
         IM.assocs $ lheroes $ slevel delState
    ms = L.map (\ (i, m) -> (AMonster i, mloc m)) $
         IM.assocs $ lmonsters $ slevel delState
    foes = if L.null hs then ms else hs
    -- We assume monster sight is actually infravision, so light has no effect.
    foeVisible = L.filter (\ (a, l) ->
                            actorReachesActor a actor l me per pl) foes
    foeDist = L.map (\ (_, l) -> (distance (me, l), l)) foeVisible
    -- Below, "foe" is the hero (or a monster) at floc, attacked by the actor.
    floc = case foeVisible of
             [] -> Nothing
             _  -> Just $ snd $ L.minimum foeDist
    onlyFoe        = onlyMoves (maybe (const False) (==) floc) me
    towardsFoe     = case floc of
                       Nothing -> const mzero
                       Just loc ->
                         let foeDir = towards (me, loc)
                         in  only (\ x -> distance (foeDir, x) <= 1)
    lootHere       = (\ x -> not $ L.null $ titems $ lmap `at` x)
    onlyLoot       = onlyMoves lootHere me
    onlyKeepsDir   = only (\ x -> maybe True (\ d -> distance (d, x) <= 2) mdir)
    onlyUnoccupied = onlyMoves (unoccupied (levelMonsterList delState)) me
    -- Monsters don't see doors more secret than that. Enforced when actually
    -- opening doors, too, so that monsters don't cheat.
    openableHere   = openable (niq mk) lmap
    onlyOpenable   = onlyMoves openableHere me
    accessibleHere = accessible lmap me
    onlySensible   = onlyMoves (\ l -> accessibleHere l || openableHere l) me
    greedyMonster  = niq mk < 5
    steadyMonster  = niq mk >= 5
    pushyMonster   = not $ nsight mk
    smells         =
      L.map fst $
      L.sortBy (\ (_, s1) (_, s2) -> compare s2 s1) $
      L.filter (\ (_, s) -> s > 0) $
      L.map (\ x -> (x, nsmap ! (me `shift` x) - time `max` 0)) moves

    strategy =
      onlySensible $
        onlyTraitor moveFreely
        .| onlyFoe moveFreely
        .| (greedyMonster && lootHere me) .=> wait
        .| moveTowards
    moveTowards =
      (if pushyMonster then id else onlyUnoccupied) $
        nsight mk .=> towardsFoe moveFreely
        .| lootHere me .=> wait
        .| nsmell mk .=> foldr (.|) reject (L.map return smells)
        .| onlyOpenable moveFreely
        .| moveFreely
    moveFreely = onlyLoot moveRandomly
                 .| steadyMonster .=> onlyKeepsDir moveRandomly
                 .| moveRandomly

onlyMoves :: (Dir -> Bool) -> Loc -> Strategy Dir -> Strategy Dir
onlyMoves p l = only (\ x -> p (l `shift` x))

moveRandomly :: Strategy Dir
moveRandomly = liftFrequency $ uniform moves

wait :: Strategy Dir
wait = return (0,0)
