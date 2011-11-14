{-# LANGUAGE CPP, QuasiQuotes #-}
module Game.LambdaHack.ConfigDefault
  ( configDefault
  ) where

import Game.LambdaHack.Utils.Multiline

-- Consider code.haskell.org/~dons/code/compiled-constants (dead link, BTW?)
-- as soon as the config file grows very big.

-- | The string containing the default configuration
-- included from file config.default (or config.bot).
-- Warning: cabal does not detect that the default config is changed,
-- so touching this file is needed to reinclude config and recompile.
configDefault :: String
configDefault = [multiline|

#ifdef STD

#include "../../config.bot"

#else

#include "../../config.default"

#endif

|]