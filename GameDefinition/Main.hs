{-# OPTIONS_GHC -fno-warn-orphans #-}
-- Copyright (c) 2008--2011 Andres Loeh, 2010--2014 Mikolaj Konarski
-- This file is a part of the computer game Allure of the Stars
-- and is released under the terms of the GNU Affero General Public License.
-- For license and copyright information, see the file LICENSE.
--
-- | The main source code file of Allure of the Stars. Here the knot of engine
-- code pieces and the Allure-specific content defintions is tied,
-- resulting in an executable game.
module Main ( main ) where

import qualified Content.ActorKind
import qualified Content.CaveKind
import qualified Content.FactionKind
import qualified Content.ItemKind
import qualified Content.ModeKind
import qualified Content.PlaceKind
import qualified Content.RuleKind
import qualified Content.TileKind
import Game.LambdaHack.Client
import Game.LambdaHack.Client.Action.ActionType
import Game.LambdaHack.Common.Action (MonadAtomic (..))
import Game.LambdaHack.Common.AtomicCmd
import Game.LambdaHack.Common.AtomicSem
import qualified Game.LambdaHack.Common.Kind as Kind
import Game.LambdaHack.Server
import Game.LambdaHack.Server.Action.ActionType
import Game.LambdaHack.Server.AtomicSemSer

-- | The game-state semantics of atomic game commands
-- as computed on the server.
instance MonadAtomic ActionSer where
  execAtomic = atomicSendSem

-- | The game-state semantics of atomic game commands
-- as computed on clients. Special effects (@SfxAtomic@) don't modify state.
instance MonadAtomic (ActionCli c d) where
  execAtomic (CmdAtomic cmd) = cmdAtomicSem cmd
  execAtomic (SfxAtomic _) = return ()

-- | Tie the LambdaHack engine clients and server code
-- with the Allure-specific content defintions and run the game.
main :: IO ()
main =
  let copsSlow = Kind.COps
        { coactor   = Kind.createOps Content.ActorKind.cdefs
        , cocave    = Kind.createOps Content.CaveKind.cdefs
        , cofaction = Kind.createOps Content.FactionKind.cdefs
        , coitem    = Kind.createOps Content.ItemKind.cdefs
        , comode    = Kind.createOps Content.ModeKind.cdefs
        , coplace   = Kind.createOps Content.PlaceKind.cdefs
        , corule    = Kind.createOps Content.RuleKind.cdefs
        , cotile    = Kind.createOps Content.TileKind.cdefs
        }
  in mainSer copsSlow executorSer $ exeFrontend executorCli executorCli