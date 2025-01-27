{-# LANGUAGE OverloadedStrings #-}

module Control.Distributed.Fork.AWS.Lambda.Internal.Constants where

--------------------------------------------------------------------------------
import Data.Text (Text)

--------------------------------------------------------------------------------
hsMainName :: String
hsMainName = "hs-main"

handlerPyName :: String
handlerPyName = "handler.py"

envAnswerQueueUrl :: Text
envAnswerQueueUrl = "ANSWER_QUEUE_URL"

envAnswerBucketUrl :: Text
envAnswerBucketUrl = "ANSWER_BUCKET_URL"
