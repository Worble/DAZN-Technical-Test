module Main exposing (Model, Msg(..), main, searchMovies, update, validInput)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy as Lazy exposing (..)
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
    , year : Maybe Int
    , searchResult : Maybe SearchResult
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { searchText = ""
      , lastSearchedText = ""
      , year = Nothing
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
    | UpdateYear String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateSearchText query ->
            ( { model | searchText = query }, Cmd.none )

        PerformSearch ->
            ( { model | lastSearchedText = model.searchText }, searchMovies model.searchText 1 model.year)

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
            ( model, searchMovies model.lastSearchedText page model.year )

        MovieSearchNextPage ->
            let
                page =
                    SearchResult.calculateNextPage model.searchResult
            in
            ( model, searchMovies model.lastSearchedText page model.year )

        UpdateYear yearString ->
            let
                year =
                    String.toInt yearString
            in
            ( { model | year = year }, Cmd.none )


validInput : Model -> Bool
validInput model =
    let
        textValid =
            not (String.isEmpty model.searchText)
    in
    textValid



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- HTTP


searchMovies : String -> Int -> Maybe Int -> Cmd Msg
searchMovies query page maybeYear =
    Http.get (toSearchMovieUrl query page maybeYear) SearchResult.searchResultsDecoder
        |> Http.send ReceiveSearchMoviesResult


toSearchMovieUrl : String -> Int -> Maybe Int -> String
toSearchMovieUrl query page maybeYear =
    let
        baseQueries =
            [ Url.string "api_key" "7bf3ac61a7810c5c951dbae19c1a2943"
            , Url.string "language" "en-US"
            , Url.int "page" page
            , Url.string "include_adult" "false"
            , Url.string "query" query
            ]

        queries =
            case maybeYear of
                Just year ->
                    Url.string "year" (String.fromInt year) :: baseQueries

                Nothing ->
                    baseQueries
    in
    Url.crossOrigin "https://api.themoviedb.org"
        [ "3", "search", "movie" ]
        queries



-- VIEW
{-
   Our main view entry point; it largely points to other functions that cover the rendering of the application.
   Here we use `lazy` so that we can cut down on rendering time; functions with called with `lazy` won't be
   reevaluated unless their input changes.
-}


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ lazy displayError model.error
        , lazy displaySearch model
        , lazy displayMovieSearchResults model.searchResult
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
        , input
            [ class "input"
            , type_ "text"
            , placeholder "Type a name"
            , onInput UpdateSearchText
            , onEnter
                (if validInput model then
                    PerformSearch

                 else
                    NoOp
                )
            ]
            []
        , input
            [ class "input"
            , type_ "number"
            , placeholder "Enter a year"
            , onInput UpdateYear
            , onEnter
                (if validInput model then
                    PerformSearch

                 else
                    NoOp
                )
            ]
            []
        , button
            [ class "btn btn__primary"
            , type_ "button"
            , onClick PerformSearch
            , disabled
                (if validInput model then
                    False

                 else
                    True
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
                div [ class "movies-results" ]
                    [ div [ class "movies-results__button-container" ]
                        [ displayPreviousPageButton searchResult
                        , displayNextPageButton searchResult
                        ]
                    , div [ class "movies-results__container" ] (List.map displayMovie searchResult.result)
                    , div [ class "movies-results__button-container" ]
                        [ displayPreviousPageButton searchResult
                        , displayNextPageButton searchResult
                        ]
                    ]

        Nothing ->
            text ""


displayPreviousPageButton : SearchResult -> Html Msg
displayPreviousPageButton searchResult =
    if searchResult.page > 1 then
        button [ class "btn btn__secondary", onClick MovieSearchPreviousPage ] [ text "Previous Page" ]

    else
        text ""


displayNextPageButton : SearchResult -> Html Msg
displayNextPageButton searchResult =
    if searchResult.page < searchResult.totalPages then
        button [ class "btn btn__secondary", onClick MovieSearchNextPage ] [ text "Next Page" ]

    else
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
