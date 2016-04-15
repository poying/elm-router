module Main where


import Result
import String
import Dict exposing (Dict)
import Router exposing ((:~>), (:=>))
import Router.Parameter exposing ((/:), int, string)
import Graphics.Element exposing (show)


type Page
  = Home
  | Article String Int
  | AdminHome
  | NotFound


match =
  Router.match router NotFound


router =
  [ "/" :~> always Home
  , "/user/:uid/article/:aid" :~> always Article /: string "uid" /: int "aid"
  -- nested router
  , "/admin/:uid" :=> adminRouter
  ]


adminRouter =
  [ "/a/:aid" :~> always Article /: string "uid" /: int "aid"
  ]


main =
  show <|
    case match "/admin/poying/a/123" of
      Home -> "Home"
      AdminHome -> "AdminHome"
      Article uid aid -> "Article " ++ uid  ++ " " ++ toString aid
      NotFound -> "NotFound"
