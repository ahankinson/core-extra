module String.DasherizeTest exposing (dasherizeTest)

import Char
import Expect
import Fuzz exposing (..)
import String exposing (replace)
import String.Extra exposing (..)
import String.TestData as TestData
import Test exposing (..)


dasherizeTest : Test
dasherizeTest =
    describe "dasherize"
        [ fuzz string "It is a lowercased string" <|
            \s ->
                dasherize s
                    |> String.toLower
                    |> Expect.equal (dasherize s)
        , fuzz asciiString "It replaces spaces and underscores with a dash" <|
            \s ->
                let
                    expected =
                        String.toLower
                            >> String.trim
                            >> replace "  " " "
                            >> replace " " "-"
                            >> replace "\t" "-"
                            >> replace "\n" "-"
                            >> replace "_" "-"
                            >> replace "--" "-"
                            >> replace "--" "-"
                in
                dasherize (String.toLower s)
                    |> String.toLower
                    |> Expect.equal (expected s)
        , fuzz TestData.randomStrings "It puts dash before every single uppercase character" <|
            \s ->
                dasherize s
                    |> Expect.equal (replaceUppercase s |> String.toLower)
        ]


replaceUppercase : String -> String
replaceUppercase string =
    string
        |> String.toList
        |> List.map
            (\c ->
                if Char.isUpper c then
                    "-" ++ String.fromChar c

                else
                    String.fromChar c
            )
        |> String.concat
