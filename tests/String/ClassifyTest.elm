module String.ClassifyTest exposing (classifyTest)

import Char
import Expect
import Fuzz exposing (..)
import Regex
import String exposing (replace, uncons)
import String.Extra exposing (..)
import String.TestData as TestData
import Test exposing (..)
import Tuple exposing (first, second)


classifyTest : Test
classifyTest =
    describe "classify"
        [ fuzz string "It does not contain non-word characters" <|
            \string ->
                classify string
                    |> Regex.contains (Regex.fromString "[\\W]" |> Maybe.withDefault Regex.never)
                    |> Expect.equal False
                    |> Expect.onFail "Non word characters detected"
        , fuzz TestData.randomStrings "It starts with an uppercase letter" <|
            \string ->
                string
                    |> classify
                    |> uncons
                    |> Maybe.map first
                    |> Expect.equal (string |> String.trim |> String.toUpper |> uncons |> Maybe.map first)
        , fuzz validWords "It is camelized once replaced non word charactes with a compatible string" <|
            \string ->
                string
                    |> classify
                    |> uncons
                    |> Maybe.map second
                    |> Expect.equal (string |> replace "." "-" |> camelize |> uncons |> Maybe.map second)
        ]


validWords : Fuzzer String
validWords =
    Fuzz.listOfLengthBetween 0
        10
        (Fuzz.map Char.fromCode
            (Fuzz.oneOf
                [ Fuzz.intRange 45 46
                , Fuzz.constant 95
                , Fuzz.intRange 97 122
                , Fuzz.intRange 65 90
                ]
            )
        )
        |> Fuzz.map String.fromList
