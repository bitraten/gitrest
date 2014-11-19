module Api where

import           Rest.Api

import qualified Api.Tiddler as Tiddler
import           ApiTypes    (GitRestApi)

api :: Api GitRestApi
api = [(mkVersion 0 0 1, Some1 gitRest)]

gitRest :: Router GitRestApi GitRestApi
gitRest =
  root -/ tiddler
  where
    tiddler = route Tiddler.resource
