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
    , lastSearchedText : String
    , searchResult : Maybe SearchResult
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchText = ""
      , lastSearchedText = ""
      , searchResult = Nothing
      , error = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | UpdateSearchText String
    | PerformSearch
    | ReceiveSearchMoviesResult (Result Http.Error SearchResult)
    | DismissError
    | MovieSearchPreviousPage
    | MovieSearchNextPage


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateSearchText query ->
            ( { model | searchText = query }, Cmd.none )

        PerformSearch ->
            ( { model | lastSearchedText = model.searchText }, searchMovies model.searchText 1 )

        ReceiveSearchMoviesResult (Ok result) ->
            ( { model | searchResult = Just result }, Cmd.none )

        ReceiveSearchMoviesResult (Err _) ->
            ( { model | error = Just "Whoops! Something went wrong, please try again later." }, Cmd.none )

        DismissError ->
            ( { model | error = Nothing }, Cmd.none )

        MovieSearchPreviousPage ->
            let
                page =
                    SearchResult.calculatePreviousPage model.searchResult
            in
            ( model, searchMovies model.lastSearchedText page )

        MovieSearchNextPage ->
            let
                page =
                    SearchResult.calculateNextPage model.searchResult
            in
            ( model, searchMovies model.lastSearchedText page )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- HTTP


searchMovies : String -> Int -> Cmd Msg
searchMovies query page =
    Http.get (toSearchMovieUrl query page) SearchResult.searchResultsDecoder
        |> Http.send ReceiveSearchMoviesResult


toSearchMovieUrl : String -> Int -> String
toSearchMovieUrl query page =
    Url.crossOrigin "https://api.themoviedb.org"
        [ "3", "search", "movie" ]
        [ Url.string "api_key" "7bf3ac61a7810c5c951dbae19c1a2943"
        , Url.string "language" "en-US"
        , Url.int "page" page
        , Url.string "include_adult" "false"
        , Url.string "query" query
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ displayError model.error
        , displaySearch model
        , displayMovieSearchResults model.searchResult
        ]


displayError : Maybe String -> Html Msg
displayError maybeError =
    case maybeError of
        Just error ->
            div [ onClick DismissError ] [ text error ]

        Nothing ->
            text ""


displaySearch : Model -> Html Msg
displaySearch model =
    div [ class "movie-search" ]
        [ h1 [] [ text "Search for movies" ]
        , input [ type_ "text", placeholder "Type a name", onInput UpdateSearchText, onEnter PerformSearch ] []
        , button
            [ type_ "button"
            , onClick PerformSearch
            , disabled
                (if String.isEmpty model.searchText then
                    True

                 else
                    False
                )
            ]
            [ text "Search" ]
        ]


displayMovieSearchResults : Maybe SearchResult -> Html Msg
displayMovieSearchResults maybeSearchResult =
    case maybeSearchResult of
        Just searchResult ->
            if List.isEmpty searchResult.result then
                text "No results found for that criteria"

            else
                div []
                    [ div [ class "movies-container" ] (List.map displayMovie searchResult.result)
                    , if searchResult.page > 1 then
                        button [ onClick MovieSearchPreviousPage ] [ text "Previous Page" ]

                      else
                        text ""
                    , if searchResult.page < searchResult.totalPages then
                        button [ onClick MovieSearchNextPage ] [ text "Next Page" ]

                      else
                        text ""
                    ]

        Nothing ->
            text ""


displayMovie : MovieResult -> Html Msg
displayMovie movie =
    div [ class "movie" ]
        [ div [ class "movie__img" ]
            [ case movie.posterPath of
                Just path ->
                    img [ src ("https://image.tmdb.org/t/p/original" ++ path), alt movie.title ] []

                Nothing ->
                    text "NO IMAGE AVAILABLE"
            ]
        , div [ class "movie__information" ]
            [ h3 [] [ text movie.title ]
            , div [] [ text movie.overview ]
            , br [] []
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
