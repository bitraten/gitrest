{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module ApiTypes where

import           Control.Applicative  (Applicative)
import           Control.Monad.Reader (MonadReader, ReaderT (..))
import           Control.Monad.Trans  (MonadIO)
import           Data.FileStore       (FileStore)

data ServerData = ServerData { filestore :: FileStore }

newtype GitRestApi a = GitRestApi { unGitRestApi :: ReaderT ServerData IO a }
  deriving ( Applicative
           , Functor
           , Monad
           , MonadIO
           , MonadReader ServerData
           )

runGitRestApi :: ServerData -> GitRestApi a -> IO a
runGitRestApi serverdata = flip runReaderT serverdata . unGitRestApi
