{-# LANGUAGE TemplateHaskell #-}
module Main where

import Prelude
import Data.Aeson.TH (deriveJSON, defaultOptions)

main :: IO ()
main = print "Example Template Haskell invocation for HLS tooling."

data Foo = Foo { foo :: Int }

$(deriveJSON defaultOptions 'Foo)