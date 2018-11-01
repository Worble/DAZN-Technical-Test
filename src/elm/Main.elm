module Main exposing (Model, Msg(..), main, update)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { searchText : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "Hello World", Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | UpdateSearchText String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateSearchText query ->
            ( { model | searchText = query }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ displaySearch
        ]


displaySearch : Html Msg
displaySearch =
    div [ class "movie-search" ]
        [ h1 [] [ text "Search for movies" ]
        , input [ type_ "text", placeholder "Type a name", onInput UpdateSearchText ] []
        , button [ type_ "button" ] [ text "Search" ]
        ]
