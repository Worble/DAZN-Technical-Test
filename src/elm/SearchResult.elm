module SearchResult exposing (MovieResult, SearchResult, calculateNextPage, calculatePreviousPage, movieResultDecoder, searchResultsDecoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)


type alias MovieResult =
    { posterPath : Maybe String
    , adult : Bool
    , overview : String
    , releaseDate : String
    , genreIds : List Int
    , id : Int
    , originalTitle : String
    , originalLanguage : String
    , title : String
    , backdropPath : Maybe String
    , popularity : Float
    , voteCount : Int
    , video : Bool
    , voteAverage : Float
    }


type alias SearchResult =
    { page : Int
    , result : List MovieResult
    , totalResults : Int
    , totalPages : Int
    }


searchResultsDecoder : Decode.Decoder SearchResult
searchResultsDecoder =
    Decode.succeed SearchResult
        |> required "page" Decode.int
        |> required "results" (Decode.list movieResultDecoder)
        |> required "total_results" Decode.int
        |> required "total_pages" Decode.int


movieResultDecoder : Decode.Decoder MovieResult
movieResultDecoder =
    Decode.succeed MovieResult
        |> optional "poster_path" (Decode.maybe Decode.string) Nothing
        |> required "adult" Decode.bool
        |> required "overview" Decode.string
        |> required "release_date" Decode.string
        |> required "genre_ids" (Decode.list Decode.int)
        |> required "id" Decode.int
        |> required "original_title" Decode.string
        |> required "original_language" Decode.string
        |> required "title" Decode.string
        |> optional "backdrop_path" (Decode.maybe Decode.string) Nothing
        |> required "popularity" Decode.float
        |> required "vote_count" Decode.int
        |> required "video" Decode.bool
        |> required "vote_average" Decode.float


calculateNextPage : Maybe SearchResult -> Int
calculateNextPage maybeSearchResult =
    case maybeSearchResult of
        Just searchResult ->
            if searchResult.page < searchResult.totalPages then
                searchResult.page + 1

            else
                searchResult.totalPages

        Nothing ->
            1


calculatePreviousPage : Maybe SearchResult -> Int
calculatePreviousPage maybeSearchResult =
    case maybeSearchResult of
        Just searchResult ->
            if searchResult.page > 1 then
                searchResult.page - 1

            else
                1

        Nothing ->
            1
