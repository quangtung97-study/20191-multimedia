port module PhoenixChannel exposing
    ( Callback
    , Model
    , init
    , mapList
    , send
    , subscriptions
    )

import Dict exposing (Dict)
import Json.Encode as E



-- PORTS


port sendMessage : ( String, E.Value ) -> Cmd msg


port subscribeOn : String -> Cmd msg


port recvMessage : (( String, E.Value ) -> msg) -> Sub msg



-- MODEL


type alias Callback msg =
    E.Value -> msg


type alias Model msg =
    Dict String (Callback msg)



-- APIS


map : (a -> b) -> Callback a -> Callback b
map f callback value =
    value |> callback |> f


mapList : (a -> b) -> List ( String, Callback a ) -> List ( String, Callback b )
mapList f callbacks =
    List.map (\( event, callback ) -> ( event, map f callback )) callbacks



-- UPDATE


init : List ( String, Callback msg ) -> ( Model msg, Cmd msg )
init callbacks =
    ( Dict.fromList callbacks
    , Cmd.batch <|
        List.map (\( event, _ ) -> subscribeOn event) callbacks
    )


send : String -> E.Value -> Cmd msg
send name data =
    sendMessage ( name, data )



-- SUBSCRIPTIONS


subscriptions : Model msg -> (String -> E.Value -> msg) -> Sub msg
subscriptions callbacks defaultCallback =
    let
        onRecv ( event, data ) =
            case Dict.get event callbacks of
                Just callback ->
                    callback data

                Nothing ->
                    defaultCallback event data
    in
    recvMessage onRecv
