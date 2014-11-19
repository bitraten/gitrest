module Api.Tiddler (resource) where

import           Control.Monad.Reader (ReaderT, asks)
import           Control.Monad.Trans  (lift, liftIO)
import qualified Data.FileStore       as FS

import           Rest
import qualified Rest.Resource        as R

import           ApiTypes
import           Type.Tiddler

type WithTiddler = ReaderT Title GitRestApi

-- TODO: Auth for private tiddlers and creation
resource :: Resource GitRestApi WithTiddler Title () Void
resource = mkResourceReader
    { R.name    = "tiddler"
    , R.schema  = withListing () $ named [("title", singleBy id)]
    , R.list    = const list
    , R.get     = Just get
    , R.remove  = Just remove
    }

get :: Handler WithTiddler -- add secureHandler?
get = mkIdHandler (jsonO . someO) $ \_ title ->
  liftIO . readTiddlerFromFS title =<< (lift . lift) (asks filestore)

-- TODO: handle NotFound
readTiddlerFromFS :: Title -> FS.FileStore -> IO Tiddler
readTiddlerFromFS title fs = FS.retrieve fs title Nothing

-- TODO: consider range
list :: ListHandler GitRestApi
list = mkListing (jsonO . someO) $ \_ -> liftIO .
          readTiddlers =<< asks filestore

readTiddlers :: FS.FileStore -> IO [Tiddler]
readTiddlers fs = do titles <- FS.index fs
                     tiddlers <- mapM (`readTiddlerFromFS` fs) titles
                     return $ map skinnyTiddler tiddlers

remove :: Handler WithTiddler
remove = mkIdHandler id $ \_ title -> liftIO .
            deleteTiddler title =<< (lift . lift) (asks filestore)

-- TODO
author :: FS.Author
author = FS.Author "name" "mail@example.com"

-- TODO: Extend description / Catch Exception
deleteTiddler :: FilePath -> FS.FileStore -> IO ()
deleteTiddler title fs = FS.delete fs title author "Deletion by API"
