module Main where
import           Data.FileStore
import           Network.Wai.Handler.Warp
import           Rest.Driver.Wai          (apiToApplication)
import           System.Environment

import           Api                      (api)
import           ApiTypes                 (ServerData (..), runGitRestApi)

readPath :: [String] -> FilePath
readPath (p:_) = p
readPath _     = error "Please specify storage-location."

main :: IO ()
main = do args <- getArgs
          let path = readPath args
          let serverdata = ServerData $ gitFileStore path
          putStrLn "Starting warp server on http://localhost:3000"
          run 3000 $
            apiToApplication (runGitRestApi serverdata) api
