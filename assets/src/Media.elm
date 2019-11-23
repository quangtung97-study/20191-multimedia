port module Media exposing
    ( Model
    , Msg
    , channelSubscriptions
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (Html, div, h2, text)
import Json.Encode as E
import PhoenixChannel exposing (Callback)
import VideoCall



-- PORTS


port requestMedia : () -> Cmd msg


port mediaReady : (E.Value -> msg) -> Sub msg


port mediaFailed : (( E.Value, E.Value ) -> msg) -> Sub msg



-- MODEL


type Model
    = Requesting
    | MediaOk VideoCall.Model
    | Error String String



-- UPDATE


init : ( Model, Cmd Msg )
init =
    ( Requesting, requestMedia () )


channelSubscriptions : List ( String, Callback Msg )
channelSubscriptions =
    VideoCall.channelSubscriptions
        |> PhoenixChannel.mapList VideoCall


type Msg
    = Ready
    | VideoCall VideoCall.Msg
    | Failed String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ready ->
            let
                ( videoCall, cmd ) =
                    VideoCall.init
            in
            ( MediaOk videoCall, Cmd.map VideoCall cmd )

        VideoCall videoCallMsg ->
            case model of
                MediaOk videoCall ->
                    let
                        ( newVideoCall, cmd ) =
                            VideoCall.update videoCallMsg videoCall
                    in
                    ( MediaOk newVideoCall, Cmd.map VideoCall cmd )

                _ ->
                    ( model, Cmd.none )

        Failed name message ->
            ( Error name message, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Requesting ->
            h2 [] [ text "Requesting media devices" ]

        MediaOk videoCall ->
            Html.map VideoCall (VideoCall.view videoCall)

        Error name message ->
            div []
                [ h2 [] [ text "Request media failed!!!" ]
                , h2 [] [ text (name ++ ": " ++ message) ]
                ]



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ mediaReady (\_ -> Ready)
        , mediaFailed
            (\( name, message ) ->
                Failed (E.encode 2 name) (E.encode 2 message)
            )
        , Sub.map VideoCall VideoCall.subscriptions
        ]
