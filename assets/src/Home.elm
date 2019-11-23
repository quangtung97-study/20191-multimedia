module Home exposing (main)

import Browser
import Html exposing (Html, div)
import Json.Encode as E
import Media
import PhoenixChannel


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Flags =
    ()


type alias Model =
    { phoenix : PhoenixChannel.Model Msg
    , media : Media.Model
    }



-- UPDATE


type Msg
    = Media Media.Msg
    | DefaultChannelEvent String E.Value


init : Flags -> ( Model, Cmd Msg )
init _ =
    let
        ( media, mediaCmd ) =
            Media.init

        ( phoenix, phoenixCmd ) =
            Media.channelSubscriptions
                |> PhoenixChannel.mapList Media
                |> PhoenixChannel.init
    in
    ( { phoenix = phoenix
      , media = media
      }
    , Cmd.batch
        [ Cmd.map Media mediaCmd
        , phoenixCmd
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Media mediaMsg ->
            let
                ( media, cmd ) =
                    Media.update mediaMsg model.media
            in
            ( { model | media = media }, Cmd.map Media cmd )

        DefaultChannelEvent _ _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.map Media (Media.view model.media)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Media Media.subscriptions
        , PhoenixChannel.subscriptions model.phoenix
            (\event data -> DefaultChannelEvent event data)
        ]
