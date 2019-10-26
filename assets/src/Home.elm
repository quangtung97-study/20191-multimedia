module Home exposing (main)

import Browser
import Html exposing (Html, div)
import Json.Encode as E
import PhoenixChannel
import VideoCall


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Flags =
    ()


type alias Model =
    { videoCall : VideoCall.Model
    }


type Msg
    = VideoCallMsg VideoCall.Msg
    | RecvMessage String E.Value


init : Flags -> ( Model, Cmd Msg )
init _ =
    let
        ( videoModel, videoCmd ) =
            VideoCall.init
    in
    ( { videoCall = videoModel
      }
    , Cmd.batch
        [ Cmd.map VideoCallMsg videoCmd
        , PhoenixChannel.init
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        VideoCallMsg videoMsg ->
            let
                ( videoModel, cmd ) =
                    VideoCall.update videoMsg model.videoCall
            in
            ( { model | videoCall = videoModel }, Cmd.map VideoCallMsg cmd )

        RecvMessage event data ->
            let
                ( videoModel, videoCmd ) =
                    VideoCall.handleChannelEvent model.videoCall event data
            in
            ( { model | videoCall = videoModel }, Cmd.map VideoCallMsg videoCmd )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Sub.map VideoCallMsg VideoCall.subscriptions
        , PhoenixChannel.subscriptions (\event data -> RecvMessage event data)
        ]


view : Model -> Html Msg
view model =
    div []
        [ Html.map VideoCallMsg (VideoCall.view model.videoCall)
        ]
