module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (Msg(..))
import Test exposing (..)


suite : Test
suite =
    describe "Update"
        [ describe "UpdateSearchText"
            [ fuzz string "Updates the models search text" <|
                \word ->
                    Main.update (UpdateSearchText word) (Main.Model "" Nothing Nothing)
                        |> Expect.equal ( Main.Model word Nothing Nothing, Cmd.none )
            ]
        , describe "DismissError"
            [ fuzz string "Removes the model error text" <|
                \errorText ->
                    Main.update DismissError (Main.Model "" Nothing (Just errorText))
                        |> Expect.equal ( Main.Model "" Nothing Nothing, Cmd.none )
            ]
        ]
