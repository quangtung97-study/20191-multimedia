port module VideoCall exposing
    ( Model
    , Msg(..)
    , handleChannelEvent
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (Html, button, div, input, text, video)
import Html.Attributes exposing (autoplay, class, id, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as D
import Json.Encode as E
import PhoenixChannel


port initUserMedia : () -> Cmd msg


port startRTC : () -> Cmd msg


port gotOffer : (E.Value -> msg) -> Sub msg


port gotRemoteOffer : E.Value -> Cmd msg


port gotAnswer : (E.Value -> msg) -> Sub msg


port gotRemoteAnswer : E.Value -> Cmd msg


port gotICE : (E.Value -> msg) -> Sub msg


port gotRemoteICE : E.Value -> Cmd msg


type Status
    = NotConnected
    | Connecting Int
    | Conntected Int
    | Error String


type alias Model =
    { status : Status
    , sessionId : String
    }


type Msg
    = ConnectClicked
    | GotOffer E.Value
    | GotAnswer E.Value
    | GotICE E.Value
    | GotRemoteOffer E.Value
    | GotRemoteAnswer E.Value
    | GotRemoteICE E.Value
    | SessionIdChanged String


init : ( Model, Cmd Msg )
init =
    ( { status = NotConnected
      , sessionId = ""
      }
    , initUserMedia ()
    )


encode : Int -> E.Value -> E.Value
encode sessionId offer =
    E.object
        [ ( "sessionId", E.int sessionId )
        , ( "data", offer )
        ]


sendEncodedMsg : Model -> String -> E.Value -> ( Model, Cmd Msg )
sendEncodedMsg model event data =
    case model.status of
        NotConnected ->
            ( model, Cmd.none )

        Connecting id ->
            ( model, PhoenixChannel.send event (encode id data) )

        Conntected id ->
            ( model, PhoenixChannel.send event (encode id data) )

        Error _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnectClicked ->
            case String.toInt model.sessionId of
                Just id ->
                    ( { model | sessionId = "", status = Connecting id }, startRTC () )

                Nothing ->
                    ( model, Cmd.none )

        GotOffer offer ->
            sendEncodedMsg model "offer" offer

        GotAnswer answer ->
            sendEncodedMsg model "answer" answer

        GotICE ice ->
            sendEncodedMsg model "ice" ice

        GotRemoteOffer _ ->
            ( model, Cmd.none )

        GotRemoteAnswer _ ->
            ( model, Cmd.none )

        GotRemoteICE _ ->
            ( model, Cmd.none )

        SessionIdChanged s ->
            ( { model | sessionId = s }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input [ placeholder "SessionId", onInput SessionIdChanged, value model.sessionId ] []
            , button [ onClick ConnectClicked ] [ text "Connect" ]
            ]
        , video [ class "video", id "yours", autoplay True ] []
        , video [ class "video", id "theirs", autoplay True ] []
        ]


decodeSessionId : D.Decoder Int
decodeSessionId =
    D.field "sessionId" D.int


handleChannelEvent : Model -> String -> E.Value -> ( Model, Cmd Msg )
handleChannelEvent model event data =
    if event == "requestedConnection" then
        case D.decodeValue decodeSessionId data of
            Ok sessionId ->
                ( { model | status = Connecting sessionId }, Cmd.none )

            Err _ ->
                ( model, Cmd.none )

    else if event == "remoteOffer" then
        ( model, gotRemoteOffer data )

    else if event == "remoteAnswer" then
        ( model, gotRemoteAnswer data )

    else if event == "remoteICE" then
        ( model, gotRemoteICE data )

    else
        ( model, Cmd.none )


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ gotOffer GotOffer
        , gotAnswer GotAnswer
        , gotICE GotICE
        ]
