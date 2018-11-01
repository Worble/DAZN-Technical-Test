module MainTests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (Msg(..))
import Test exposing (..)


suite : Test
suite =
    describe "Main"
        [ describe "Update"
            [ describe "UpdateSearchText"
                [ fuzz string "Updates the models search text" <|
                    \word ->
                        Main.update (UpdateSearchText word) (Main.Model "" "" Nothing Nothing Nothing)
                            |> Expect.equal ( Main.Model word "" Nothing Nothing Nothing, Cmd.none )
                ]
            , describe "DismissError"
                [ fuzz string "Removes the model error text" <|
                    \errorText ->
                        Main.update DismissError (Main.Model "" "" Nothing Nothing (Just errorText))
                            |> Expect.equal ( Main.Model "" "" Nothing Nothing Nothing, Cmd.none )
                ]
            , describe "UpdateYear"
                [ fuzz int "Sets the year to the string passed" <|
                    \yearInt ->
                        let
                            yearString =
                                String.fromInt yearInt
                        in
                        Main.update (UpdateYear yearString) (Main.Model "" "" Nothing Nothing Nothing)
                            |> Expect.equal ( Main.Model "" "" (Just yearInt) Nothing Nothing, Cmd.none )
                , test "Sets the year to Nothing when the year is not an int" <|
                    \_ ->
                        Main.update (UpdateYear "Test") (Main.Model "" "" Nothing Nothing Nothing)
                            |> Expect.equal ( Main.Model "" "" Nothing Nothing Nothing, Cmd.none )
                ]
            ]
        , describe "validInput"
            [ fuzz string "Returns true when given any string" <|
                \input ->
                    let
                        model =
                            Main.Model ("a" ++ input) "" Nothing Nothing Nothing

                        --fuzzy strings apparently like to be empty, so we're just preprending 'a' on there to ensure a result
                    in
                    Main.validInput model
                        |> Expect.true "Expected input to be valid"
            , test "Returns false when the given string is empty" <|
                \_ ->
                    let
                        model =
                            Main.Model "" "" Nothing Nothing Nothing
                    in
                    Main.validInput model
                        |> Expect.false "Expected input to be invalid"
            ]
        ]
