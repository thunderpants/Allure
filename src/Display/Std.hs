module Display.Std
  (displayId, startup, shutdown, display, nextEvent, Session) where

import qualified Data.List as L
import qualified Data.ByteString.Char8 as BS
import qualified System.IO as SIO

import Geometry
import qualified Keys as K (Key(..))
import qualified Color

displayId :: String
displayId = "std"

type Session = ()

startup :: (Session -> IO ()) -> IO ()
startup k = k ()

shutdown :: Session -> IO ()
shutdown _session = return ()

display :: Area -> Session -> (Loc -> (Color.Attr, Char)) -> String -> String
           -> IO ()
display ((y0,x0), (y1,x1)) _session f msg status =
  let fLine y = let (as, cs) = unzip [ f (y, x) | x <- [x0..x1] ]
                in  ((y, as), BS.pack cs)
      memo  = L.map fLine [y0..y1]
      chars = L.map snd memo
      bs    = [BS.pack msg, BS.pack "\n",
               BS.unlines chars, BS.pack status, BS.pack "\n", BS.pack "\n"]
  in mapM_ BS.putStr bs

keyTranslate :: Char -> K.Key
keyTranslate e =
  case e of
    '\ESC' -> K.Esc
    '\n'   -> K.Return
    '\r'   -> K.Return
    '\t'   -> K.Tab
    -- a tweak for bots: don't let them give up the fight (nor write files)
    -- TODO: make configurable
    'Q'    -> K.Esc
    'X'    -> K.Esc
    -- a tweak for bots: disable purely UI commands; make descending easier
    -- TODO: make configurable
    'R'    -> K.Char '>'
    'O'    -> K.Char '>'
    'T'    -> K.Char '>'
    'I'    -> K.Char '>'
    'V'    -> K.Char '>'
    'P'    -> K.Char '>'
    'D'    -> K.Char '>'
    '?'    -> K.Char '>'
    -- a tweak for bots: don't let them move to shallower levels (or win)
    -- TODO: make configurable
    '<'    -> K.Esc
    -- No KP_ keys in std, but the bot can use the vi keys,
    -- so number keys are interpreted as hero selection:
    c      -> K.Char c

nextEvent :: Session -> IO K.Key
nextEvent _session = do
  e <- BS.hGet SIO.stdin 1
  let c = BS.head e
  if c == '\n' -- let \n mark the end of input and \r issue the K.Return command
    then nextEvent _session
    else return $ keyTranslate c