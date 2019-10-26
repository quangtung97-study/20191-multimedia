port module PhoenixChannel exposing
    ( init
    , send
    , subscriptions
    )

import Json.Encode as E


port sendMessage : ( String, E.Value ) -> Cmd msg


port subscribeOn : String -> Cmd msg


port recvMessage : (( String, E.Value ) -> msg) -> Sub msg


init : Cmd msg
init =
    Cmd.batch
        [ subscribeOn "test"
        , subscribeOn "requestedConnection"
        , subscribeOn "remoteOffer"
        , subscribeOn "remoteAnswer"
        , subscribeOn "remoteICE"
        ]


send : String -> E.Value -> Cmd msg
send name data =
    sendMessage ( name, data )


subscriptions : (String -> E.Value -> msg) -> Sub msg
subscriptions onReceived =
    recvMessage (\( name, data ) -> onReceived name data)
