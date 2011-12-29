module Game.LambdaHack.Content.RuleKind
  ( RuleKind(..), ruvalidate
  ) where

import Game.LambdaHack.Geometry
import Game.LambdaHack.Content.TileKind
import Game.LambdaHack.Loc

data RuleKind = RuleKind
  { rsymbol           :: Char
  , rname             :: String
  , rfreq             :: Int
    -- Check whether one location is accessible from another.
    -- Precondition: the two locations are next to each other.
  , raccessible       :: X -> Loc -> TileKind -> Loc -> TileKind -> Bool
  , rtitle            :: String
  }

instance Show RuleKind where
  show _ = "A game ruleset specification." -- TODO

ruvalidate :: [RuleKind] -> [RuleKind]
ruvalidate _ = [] -- TODO