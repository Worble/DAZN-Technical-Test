module SearchResultTests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, intRange, list, string)
import Random
import SearchResult exposing (SearchResult)
import Test exposing (..)


suite : Test
suite =
    describe "SearchResult"
        [ describe "calculateNextPage"
            [ test "Returns 1 when SearchResult is Nothing" <|
                \_ ->
                    SearchResult.calculateNextPage Nothing
                        |> Expect.equal 1
            , fuzz (intRange 20 Random.maxInt) "Returns max page when SearchResult page is equal to or greater than totalPages" <|
                \page ->
                    let
                        searchResult =
                            SearchResult page [] 0 20
                    in
                    SearchResult.calculateNextPage (Just searchResult)
                        |> Expect.equal 20
            , fuzz (intRange 0 1000) "Returns page + 1 when SearchResult page is lower than totalPages" <|
                \page ->
                    let
                        searchResult =
                            SearchResult page [] 0 1001

                        expected =
                            page + 1
                    in
                    SearchResult.calculateNextPage (Just searchResult)
                        |> Expect.equal expected
            ]
        , describe "calculatePreviousPage"
            [ test "Returns 1 when SearchResult is Nothing" <|
                \_ ->
                    SearchResult.calculatePreviousPage Nothing
                        |> Expect.equal 1
            , fuzz (intRange -Random.maxInt 1) "Returns 1 when SearchResult page is equal to or less than than 1" <|
                \page ->
                    let
                        searchResult =
                            SearchResult page [] 0 1
                    in
                    SearchResult.calculatePreviousPage (Just searchResult)
                        |> Expect.equal 1

            , fuzz (intRange 2 Random.maxInt) "Returns page - 1 when SearchResult page is greater than 1" <|
                \page ->
                    let
                        searchResult =
                            SearchResult page [] 0 1

                        expected =
                            page - 1
                    in
                    SearchResult.calculatePreviousPage (Just searchResult)
                        |> Expect.equal expected
            ]
        ]
