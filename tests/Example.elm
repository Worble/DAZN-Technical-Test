module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (Msg(..))
import Test exposing (..)


suite : Test
suite =
    describe "Update"
        [ describe "UpdateSearchText"
            -- Nest as many descriptions as you like.
            [ fuzz string "Updates the models search text" <|
                \word ->
                    Main.update (UpdateSearchText word) (Main.Model "" Nothing)
                        |> Expect.equal ( Main.Model word Nothing, Cmd.none )
            ]
        ]
