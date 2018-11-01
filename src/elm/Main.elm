module Main exposing (Model, Msg(..), main, searchMovies, update)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import SearchResult exposing (MovieResult, SearchResult)
import Url.Builder as Url


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
    , searchResult : Maybe SearchResult
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "Hello World" Nothing, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | UpdateSearchText String
    | PerformSearch
    | ReceiveSearchMoviesResult (Result Http.Error SearchResult)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateSearchText query ->
            ( { model | searchText = query }, Cmd.none )

        PerformSearch ->
            ( model, searchMovies model.searchText )

        ReceiveSearchMoviesResult (Ok result) ->
            ( { model | searchResult = Just result }, Cmd.none )

        ReceiveSearchMoviesResult (Err _) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- HTTP


searchMovies : String -> Cmd Msg
searchMovies query =
    Http.get (toSearchMovieUrl query) SearchResult.searchResultsDecoder
        |> Http.send ReceiveSearchMoviesResult


toSearchMovieUrl : String -> String
toSearchMovieUrl query =
    Url.crossOrigin "https://api.themoviedb.org"
        [ "3", "search", "movie" ]
        [ Url.string "api_key" "7bf3ac61a7810c5c951dbae19c1a2943"
        , Url.string "language" "en-US"
        , Url.int "page" 1
        , Url.string "include_adult" "false"
        , Url.string "query" query
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ displaySearch
        , displayMovieSearchResults model.searchResult
        ]


displaySearch : Html Msg
displaySearch =
    div [ class "movie-search" ]
        [ h1 [] [ text "Search for movies" ]
        , input [ type_ "text", placeholder "Type a name", onInput UpdateSearchText, onEnter PerformSearch ] []
        , button [ type_ "button", onClick PerformSearch ] [ text "Search" ]
        ]


displayMovieSearchResults : Maybe SearchResult -> Html Msg
displayMovieSearchResults maybeSearchResult =
    case maybeSearchResult of
        Just searchResult ->
            if List.isEmpty searchResult.result then
                text "No results found for that criteria"

            else
                div []
                    [ div [] (List.map displayMovie searchResult.result)
                    ]

        Nothing ->
            text ""


displayMovie : MovieResult -> Html Msg
displayMovie movie =
    div []
        [ div []
            [ h3 [] [ text movie.title ]
            , div [] [ text movie.overview ]
            , div [] [ text ("Release Date: " ++ movie.releaseDate) ]
            ]
        ]



--A quick helper function to grab when the user hits the enter button on the keyboard


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg

            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)
