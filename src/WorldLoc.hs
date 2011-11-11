module Game.LambdaHack.WorldLoc
  ( LevelId(..), levelName, levelNumber, WorldLoc
  ) where

import Data.Binary

import Game.LambdaHack.Loc

-- | Level ids are integers and (for now) ordered linearly.
newtype LevelId = LambdaCave Int
  deriving (Show, Eq, Ord)

instance Binary LevelId where
  put (LambdaCave n) = put n
  get = fmap LambdaCave get

-- | Name of a level.
levelName :: LevelId -> String
levelName (LambdaCave n) = "The Lambda Cave " ++ show n

-- | Depth of a level.
levelNumber :: LevelId -> Int
levelNumber (LambdaCave n) = n

-- | A world location is a level together with a location on that level.
type WorldLoc = (LevelId, Loc)
