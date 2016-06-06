module Router exposing (Router, match, (:~>), (:=>))


{-| Elm module for single page app routing

```elm
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
  , "/admin" :=> adminRouter
  ]


adminRouter =
  [ "/" :~> always AdminHome
  ]


main =
  show <|
    case match "/user/poying/article/123" of
      Home -> "Home"
      AdminHome -> "AdminHome"
      Article uid aid -> "Article " ++ uid  ++ " " ++ toString aid
      NotFound -> "NotFound"
```

@docs match

# Types
@docs Router

# Operators
@docs (:~>), (:=>)
-}


import Dict exposing (Dict)
import Regex exposing (Regex)


{-| -}
type alias Router a = List (Route a)


type alias Route a = (Path, Result a)


type alias Path = (List String, (Regex, Regex))


{-| -}
type alias Parameters = Dict String String


type Result a
  = Page (Parameters -> a)
  | NestRouter (Router a)


route : String -> Result a -> Route a
route urlPath result =
  (compile urlPath result, result)


{-|
```elm
"/article/:id" :~> \params -> Article << String.toInt << (Dict.get "id" params)
```
-}
(:~>) : String -> (Parameters -> a) -> Route a
(:~>) urlPath = route urlPath << page


infixl 8 :~>


{-|
```elm
"/admin" :=> adminRouter
```
-}
(:=>) : String -> Router a -> Route a
(:=>) urlPath = route urlPath << nest


infixl 8 :=>


page : (Parameters -> a) -> Result a
page = Page


nest : Router a -> Result a
nest = NestRouter


{-|
```elm
case match router NotFound "/article/3" of
  Article id -> show id
  NotFound -> show "NotFound"
```
-}
match : Router a -> a -> String -> a
match router notFound urlPath =
  case matchRouter Dict.empty router (removeTailSlash urlPath) of
    Just page -> page
    Nothing -> notFound


matchRouter : Parameters -> Router a -> String -> Maybe a
matchRouter params router urlPath =
  router
    |> List.filterMap (matchRoute params urlPath)
    |> List.head


matchRoute : Parameters -> String -> Route a -> Maybe a
matchRoute params urlPath ((names, (matchPathRe, getSuffixRe)), result) =
  let
    match = List.head <| Regex.find Regex.All matchPathRe urlPath
    values = case match of
      Just {submatches} -> submatches |> List.filterMap identity
      Nothing -> []
    suffix = Regex.replace Regex.All getSuffixRe (\_ -> "") urlPath
    newParams =
      List.map2 (,) names values
        |> Dict.fromList
        |> Dict.union params
  in
    case result of
      Page fn ->
        if match /= Nothing then
          Just <| fn newParams
        else
          Nothing
      NestRouter router ->
        if suffix /= urlPath then
          matchRouter newParams router suffix
        else
          Nothing


compile : String -> Result a -> (List String, (Regex, Regex))
compile path result =
  (path2names path, path2re path result)


path2re : String -> Result a -> (Regex, Regex)
path2re path result =
  let
    re = path
      |> removeTailSlash
      |> Regex.replace Regex.All (Regex.regex "/:[^/]+") (\_ -> "/([^/]+)")
    getSuffixRe = Regex.regex <| "^" ++ re
    matchPathRe = case result of
      Page _ -> Regex.regex <| "^" ++ re ++ "$"
      NestRouter _ -> getSuffixRe
  in
    (matchPathRe, getSuffixRe)


path2names : String -> List String
path2names path =
  path
   |> Regex.find Regex.All (Regex.regex "/:([^/]+)")
   |> List.filterMap (\{submatches} -> Maybe.withDefault Nothing (List.head submatches))


removeTailSlash : String -> String
removeTailSlash =
  Regex.replace Regex.All (Regex.regex "/+$") (\_ -> "")
