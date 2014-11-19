{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}
module Type.Tiddler where

import           Data.Aeson
import qualified Data.FileStore         as FS
import           Data.HashMap.Strict    (delete)
import           Data.JSON.Schema.Types hiding (Object)
import           Data.Typeable          (Typeable)

type Title = String

data Tiddler = Tiddler {fields :: Object}
  deriving Typeable

instance JSONSchema Tiddler -- TODO: Hmm.
  where schema _ = Map Any

instance ToJSON Tiddler
  where toJSON = Object . fields

-- TODO: Abstract Tiddler implementation?
instance FS.Contents (Tiddler)
  where fromByteString bs = case decode bs of
                              Just (Object o) -> Tiddler o
                              _               -> error "Parsing error" --TODO
        toByteString      = encode

skinnyTiddler :: Tiddler -> Tiddler
skinnyTiddler t = Tiddler (delete "text" $ fields t)
