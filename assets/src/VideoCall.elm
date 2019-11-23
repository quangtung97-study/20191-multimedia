port module VideoCall exposing
    ( Model
    , Msg(..)
    , channelSubscriptions
    , init
    , subscriptions
    , update
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html, button, div, input, text, video)
import Html.Attributes exposing (autoplay, class, id, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Json.Encode as E
import PhoenixChannel exposing (Callback)



-- PORTS


port setUpYourStream : () -> Cmd msg


port startRTC : Int -> Cmd msg


port startPassiveRTC : Int -> Cmd msg


port gotOffer : (E.Value -> msg) -> Sub msg


port gotRemoteOffer : E.Value -> Cmd msg


port gotAnswer : (E.Value -> msg) -> Sub msg


port gotRemoteAnswer : E.Value -> Cmd msg


port gotICE : (E.Value -> msg) -> Sub msg


port gotRemoteICE : E.Value -> Cmd msg



-- MODEL


type Status
    = Requesting
    | Accepting
    | Connecting
    | Conntected
    | Error String


type alias SessionId =
    Int


type alias Model =
    { sessions : Dict SessionId Status
    , sessionList : List SessionId
    , inputSessionId : String
    }


contains : SessionId -> List SessionId -> Bool
contains sessionId list =
    List.any (\id -> id == sessionId) list


insert : SessionId -> List SessionId -> List SessionId
insert sessionId list =
    if contains sessionId list then
        list

    else
        list ++ [ sessionId ]


sessionMap : Model -> (SessionId -> Status -> a) -> List a
sessionMap model f =
    List.filterMap
        (\sessionId ->
            Dict.get sessionId model.sessions
                |> Maybe.map (f sessionId)
        )
        model.sessionList


insertSession : Model -> SessionId -> Status -> Model
insertSession model sessionId status =
    { model | sessions = Dict.insert sessionId status model.sessions }


updateSession : Model -> SessionId -> Status -> Model
updateSession model sessionId status =
    { model
        | sessions =
            Dict.update sessionId
                (\_ -> Just status)
                model.sessions
    }


removeSession : Model -> SessionId -> Model
removeSession model sessionId =
    { model | sessions = Dict.remove sessionId model.sessions }


type PortMsg
    = GotOffer E.Value
    | GotAnswer E.Value
    | GotICE E.Value


type ChannelMsg
    = GotRemoteRequestConnect E.Value
    | GotRemoteAcceptConnect E.Value
    | GotRemoteRejectConnect E.Value
    | GotRemoteOffer E.Value
    | GotRemoteAnswer E.Value
    | GotRemoteICE E.Value


type ControlMsg
    = ConnectClicked
    | InputSessionIdChanged String
    | AcceptConnect SessionId
    | RejectConnect SessionId


type Msg
    = PortMsg PortMsg
    | ChannelMsg ChannelMsg
    | ControlMsg ControlMsg



-- UPDATE


init : ( Model, Cmd Msg )
init =
    ( { sessions = Dict.empty
      , sessionList = []
      , inputSessionId = ""
      }
    , setUpYourStream ()
    )


encodeSessionsId : SessionId -> E.Value
encodeSessionsId sessionId =
    E.object
        [ ( "sessionId", E.int sessionId )
        ]


decodeSessionId : D.Decoder Int
decodeSessionId =
    D.field "sessionId" D.int


sendRequestConnect : SessionId -> Cmd Msg
sendRequestConnect sessionId =
    PhoenixChannel.send "requestConnect" (encodeSessionsId sessionId)


sendAcceptConnect : SessionId -> Cmd Msg
sendAcceptConnect sessionId =
    PhoenixChannel.send "acceptConnect" (encodeSessionsId sessionId)


sendRejectConnect : SessionId -> Cmd Msg
sendRejectConnect sessionId =
    PhoenixChannel.send "rejectConnect" (encodeSessionsId sessionId)


sendMsg : String -> E.Value -> Cmd Msg
sendMsg event data =
    PhoenixChannel.send event data


handleRemoteRequestConnect : Model -> E.Value -> ( Model, Cmd Msg )
handleRemoteRequestConnect model data =
    case D.decodeValue decodeSessionId data of
        Ok fromId ->
            ( { model
                | sessions = Dict.insert fromId Accepting model.sessions
                , sessionList = insert fromId model.sessionList
              }
            , Cmd.none
            )

        Err _ ->
            ( model, Cmd.none )


handleRemoteAcceptConnect : Model -> E.Value -> ( Model, Cmd Msg )
handleRemoteAcceptConnect model data =
    case D.decodeValue decodeSessionId data of
        Ok fromId ->
            ( updateSession model fromId Connecting, startRTC fromId )

        Err _ ->
            ( model, Cmd.none )


handleRemoteRejectConnect : Model -> E.Value -> ( Model, Cmd Msg )
handleRemoteRejectConnect model data =
    case D.decodeValue decodeSessionId data of
        Ok fromId ->
            ( removeSession model fromId, Cmd.none )

        Err _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ControlMsg controlMsg ->
            case controlMsg of
                ConnectClicked ->
                    case String.toInt model.inputSessionId of
                        Just toId ->
                            ( { model
                                | inputSessionId = ""
                                , sessions = Dict.insert toId Requesting model.sessions
                                , sessionList = insert toId model.sessionList
                              }
                            , sendRequestConnect toId
                            )

                        Nothing ->
                            ( model, Cmd.none )

                InputSessionIdChanged s ->
                    ( { model | inputSessionId = s }, Cmd.none )

                AcceptConnect fromId ->
                    ( updateSession model fromId Connecting
                    , Cmd.batch
                        [ sendAcceptConnect fromId
                        , startPassiveRTC fromId
                        ]
                    )

                RejectConnect fromId ->
                    ( removeSession model fromId, sendRejectConnect fromId )

        PortMsg portMsg ->
            case portMsg of
                GotOffer data ->
                    ( model, sendMsg "offer" data )

                GotAnswer data ->
                    ( model, sendMsg "answer" data )

                GotICE data ->
                    ( model, sendMsg "ice" data )

        ChannelMsg channelMsg ->
            case channelMsg of
                GotRemoteRequestConnect data ->
                    handleRemoteRequestConnect model data

                GotRemoteAcceptConnect data ->
                    handleRemoteAcceptConnect model data

                GotRemoteRejectConnect data ->
                    handleRemoteRejectConnect model data

                GotRemoteOffer data ->
                    ( model, gotRemoteOffer data )

                GotRemoteAnswer data ->
                    ( model, gotRemoteAnswer data )

                GotRemoteICE data ->
                    ( model, gotRemoteICE data )



-- VIEW


viewOtherVideo : SessionId -> Status -> Html Msg
viewOtherVideo sessionId status =
    case status of
        Requesting ->
            div [ class "video" ] [ text "Waiting for Accepting ..." ]

        Accepting ->
            div [ class "video" ]
                [ button
                    [ onClick <| ControlMsg (AcceptConnect sessionId)
                    ]
                    [ text "Accept" ]
                , button
                    [ onClick <| ControlMsg (RejectConnect sessionId)
                    ]
                    [ text "Reject" ]
                ]

        Connecting ->
            video
                [ class "video"
                , id ("theirs:" ++ String.fromInt sessionId)
                , autoplay True
                ]
                []

        Conntected ->
            video
                [ class "video"
                , id ("theirs:" ++ String.fromInt sessionId)
                , autoplay True
                ]
                []

        Error msg ->
            div [ class "video" ] [ text <| "Error: " ++ msg ]


viewOtherVideos : Model -> List (Html Msg)
viewOtherVideos model =
    sessionMap model viewOtherVideo


view : Model -> Html Msg
view model =
    div []
        ([ div []
            [ input
                [ placeholder "SessionId"
                , onInput (ControlMsg << InputSessionIdChanged)
                , value model.inputSessionId
                ]
                []
            , button [ onClick (ControlMsg ConnectClicked) ] [ text "Connect" ]
            ]
         , video [ class "video", id "yours", autoplay True ] []
         ]
            ++ viewOtherVideos model
        )


channelSubscriptions : List ( String, Callback Msg )
channelSubscriptions =
    [ ( "remoteRequestConnect", ChannelMsg << GotRemoteRequestConnect )
    , ( "remoteAcceptConnect", ChannelMsg << GotRemoteAcceptConnect )
    , ( "remoteRejectConnect", ChannelMsg << GotRemoteRejectConnect )
    , ( "remoteOffer", ChannelMsg << GotRemoteOffer )
    , ( "remoteAnswer", ChannelMsg << GotRemoteAnswer )
    , ( "remoteICE", ChannelMsg << GotRemoteICE )
    ]


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ gotOffer (PortMsg << GotOffer)
        , gotAnswer (PortMsg << GotAnswer)
        , gotICE (PortMsg << GotICE)
        ]
