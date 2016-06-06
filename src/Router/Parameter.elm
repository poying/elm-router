module Router.Parameter exposing ((/:), int, float, string)


{-|
@docs (/:)

@docs int, float, string
-}


import String
import Dict exposing (Dict)


type alias Parameters = Dict String String


type alias Decoder a = Parameters -> a


{-| -}
(/:) : (Parameters -> b -> a) -> Decoder b -> Decoder a
(/:) decoderA decoderB params =
  (decoderA params) (decoderB params)


infixl 9 /:


{-| -}
int : String -> Parameters -> Int
int paramName =
  Maybe.withDefault 0
    << Result.toMaybe
    << String.toInt
    << Maybe.withDefault ""
    << Dict.get paramName


{-| -}
string : String -> Parameters -> String
string paramName =
  Maybe.withDefault "" << Dict.get paramName


{-| -}
float : String -> Parameters -> Float
float paramName =
  Maybe.withDefault 0.0
    << Result.toMaybe
    << String.toFloat
    << Maybe.withDefault ""
    << Dict.get paramName
