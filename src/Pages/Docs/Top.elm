module Pages.Docs.Top exposing (Model, Msg, page)

import Element exposing (..)
import Generated.Docs.Params as Params
import Generated.Routes as Routes
import Http
import Spa.Page
import Ui
import Utils.Sidebar
import Utils.Spa exposing (Page)


page : Page Params.Top Model Msg model msg appMsg
page =
    Spa.Page.element
        { title = always "docs · elm-spa"
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { content : String
    }


init : Params.Top -> ( Model, Cmd Msg )
init _ =
    ( { content = "" }
    , Http.get
        { expect = Http.expectString FetchedContent
        , url = "/content/docs.md"
        }
    )



-- UPDATE


type Msg
    = FetchedContent (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedContent (Ok markdown) ->
            ( { model | content = markdown }
            , Cmd.none
            )

        FetchedContent (Err _) ->
            ( { model | content = "something is goofed" }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Utils.Spa.PageContext -> Model -> Element Msg
view context model =
    column [ width fill, alignTop, spacing 32 ]
        [ Ui.markdown model.content
        , case Utils.Sidebar.nextDocsSection context.route of
            Just nextSection ->
                nextSection
                    |> Tuple.second
                    |> (\route ->
                            ( "next up: " ++ Utils.Sidebar.prettify route
                            , Routes.toPath route
                            )
                       )
                    |> Ui.button

            Nothing ->
                Ui.button ( "checkout the guide?", "/guide" )
        ]
