module String.UnindentTest exposing (unindentTest)

import Expect
import Fuzz exposing (..)
import String
import String.Extra exposing (..)
import Test exposing (..)
import Tuple exposing (first)


unindentTest : Test
unindentTest =
    describe "unindent"
        [ fuzz multilineProducerString "It produces the same trimmed string" <|
            \s ->
                let
                    expected =
                        String.lines >> List.map String.trimLeft
                in
                unindent s
                    |> String.lines
                    |> List.map String.trimLeft
                    |> Expect.equal (expected s)
        , fuzz multilineProducerString "It produces at least one line with no leading whitespace" <|
            \s ->
                unindent s
                    |> String.lines
                    |> List.map (not << String.startsWith " ")
                    |> List.any ((==) True)
                    |> Expect.equal True
                    |> Expect.onFail "No lines with leading whitespace detected"
        , fuzz multilineProducer "All lines' length have been reduced by exactly the minimum indentation" <|
            \( s, spaces ) ->
                let
                    expected =
                        String.lines s
                            |> List.map String.length
                            |> List.map (\i -> i - spaces)
                in
                unindent s
                    |> String.lines
                    |> List.map String.length
                    |> Expect.equal expected
        ]


multilineProducerString : Fuzzer String
multilineProducerString =
    map (convertToMultiline >> first)
        (triple (intRange 0 10) (intRange 0 10) (intRange 0 10))


multilineProducer : Fuzzer ( String, Int )
multilineProducer =
    map convertToMultiline
        (triple (intRange 0 10) (intRange 0 10) (intRange 0 10))


convertToMultiline : ( Int, Int, Int ) -> ( String, Int )
convertToMultiline ( a, b, c ) =
    ( [ String.repeat a " " ++ "aaaa aaa "
      , String.repeat b " " ++ "aaaa aaa"
      , String.repeat c " " ++ "ccc  "
      ]
        |> String.join "\n"
    , min (min a b) c
    )
