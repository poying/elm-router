module RouterTest where


import Router exposing ((:~>), (:=>))
import Router.Parameter exposing ((/:), int, string, float)
import Sloth exposing (..)
import Sloth.Assertion exposing (..)


type Page
  = Root
  | OneParameter Int
  | MultiParameters Int Int
  | StringParameter String
  | IntParameter Int
  | FloatParameter Float
  | NestedRouter
  | NestedRouterWithParameters Int Int
  | NotFound


match = Router.match router NotFound


router =
  [ "/" :~> always Root
  , "/article/:id" :~> always OneParameter /: int "id"
  , "/user/:uid/article/:aid" :~> always MultiParameters /: int "uid" /: int "aid"
  , "/str/:str" :~> always StringParameter /: string "str"
  , "/int/:int" :~> always IntParameter /: int "int"
  , "/float/:float" :~> always FloatParameter /: float "float"
  , "/nested" :=> nestedRouter1
  , "/nested/user/:uid" :=> nestedRouter2
  ]


nestedRouter1 =
  [ "/router" :~> always NestedRouter
  ]


nestedRouter2 =
  [ "/article/:aid" :~> always NestedRouterWithParameters /: int "uid" /: int "aid"
  ]


tests =
  start
    `describe` "Router"
      `it` "root" =>
        ((match "/") `shouldBe` Root)
      `it` "one parameter" =>
        ((match "/article/1") `shouldBe` (OneParameter 1))
      `it` "multi parameters" =>
        ((match "/user/2/article/123") `shouldBe` (MultiParameters 2 123))
      `it` "string parameter" =>
        ((match "/str/poying") `shouldBe` (StringParameter "poying"))
      `it` "int parameter" =>
        ((match "/int/123") `shouldBe` (IntParameter 123))
      `it` "float parameter" =>
        ((match "/float/2.1") `shouldBe` (FloatParameter 2.1))
      `it` "nested router" =>
        ((match "/nested/router") `shouldBe` NestedRouter)
      `it` "nested router with multi parameters" =>
        ((match "/nested/user/222/article/321") `shouldBe` (NestedRouterWithParameters 222 321))
