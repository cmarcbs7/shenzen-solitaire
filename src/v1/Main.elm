module Main exposing (main)
{-| -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Core
import Html exposing (Html)
import Html.Events
import Time exposing (Posix)
import Random

----{ Local
import Menu
import Clock exposing (Clock)
import Board exposing (Board)
import Banner




------------------------------------------------------------------------------
-- Model
------------------------------------------------------------------------------


{-| Initial model -}
initModel : Model
initModel =
    { wouldBeAction = "Initialized model"  -- temp field
    , timeElapsed = Clock.fromInt 0
    , gameState = Inactive
    , wins = 0
    , losses = 0
    , deck = []  -- temp field
    , board = Board.init
    }

{-| Reset the model after a win -}
winModel : Model -> Model
winModel model =
    let
        wins = model.wins + 1
    in
        { initModel | wins = wins }

{-| Reset the model after a loss -}
lossModel : Model -> Model
lossModel model =
    let
        losses = model.losses + 1
    in
        { initModel | losses = losses }


------------------------------------------------------------------------------
-- Update
------------------------------------------------------------------------------

{-| Event messages -}
type Msg
    = NewGame
    | Tick
    | TogglePause
    | Deal Stack
    | Nil


----{ Decoders

keyDecoder_ : String -> Msg
keyDecoder_ key =
    if (key == "Escape" || key == " ") then
        TogglePause
    else if (key == "r" || key == "R") then
        NewGame
    else
        Nil


----{ Controller

{-| Update the model in response to event messages -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewGame ->
            handleNewGame model
        Deal cards ->
            handleDeal model cards
        TogglePause ->
            handleTogglePause model
        Tick ->
            handleTick model
        _ ->
            (model, Cmd.none)


----{ Message Handlers

{-| 'NewGame' message -}
handleNewGame : Model -> (Model, Cmd Msg)
handleNewGame model =
    case model.gameState of
        Won ->
            (winModel model, Cmd.none)
        Lost ->
            (lossModel model, Cmd.none)
        _ ->
            (initModel, Cmd.none)

{-| 'Deal < Stack >' message -}
handleDeal : Model -> Stack -> (Model, Cmd Msg)
handleDeal model cards =
    let
        newBoard = Board.deal cards
    in
        Debug.todo "implement"

{-| 'TogglePause' message -}
handleTogglePause : Model -> (Model, Cmd Msg)
handleTogglePause model =
    let
        newGS = handleTogglePause_ model.gameState
        newModel = { model | gameState = newGS }
    in
        (newModel, Cmd.none)

handleTogglePause_ : GameState -> GameState
handleTogglePause_ oldGS =
    case oldGS of
        Won     -> Inactive
        Lost    -> Inactive
        Paused  -> Active
        _       -> Paused

{-| 'Tick < Time.Posix >' message -}
handleTick : Model -> (Model, Cmd Msg)
handleTick model =  -- placeholder
    case model.gameState of
        Inactive ->
            (model, Random.generate Deal (Deck.new |> Deck.shuffle))
        Paused ->
            -- temp
            ({model | wouldBeAction = tmpFxn model.deck}, Cmd.none)
        _ ->
            let
                newTime = Clock.advance model.timeElapsed Clock.second
                newModel = { model | timeElapsed = newTime }
            in
                (newModel, Cmd.none)


------------------------------------------------------------------------------
-- View
------------------------------------------------------------------------------

{-| Produce a string of the time elapsed in the current game.

    pGameClock 607 == "00:10:07"
-}
pGameClock : Clock -> String
pGameClock elapsedTime =
    let
        maxTime = 99 * Clock.hour + 59 * (Clock.minute + Clock.second)
    in
        if (elapsedTime.abs > maxTime) then
            "99:59:59"
        else
            let
                f x = x |> String.fromInt |> String.padLeft 2 '0'
                hours = f elapsedTime.h
                minutes = f elapsedTime.min
                seconds = f elapsedTime.sec
            in
                String.concat [ hours, ":", minutes, ":", seconds ]

rGameClock : Clock -> Html Msg
rGameClock elapsedTime =
    let
        clockStr = pGameClock elapsedTime
    in
        Html.div []
            [ Html.div [ Html.Events.onClick NewGame ] [ Html.text clockStr ]
            ]

{-| Render the model -}
view : Model -> Html Msg
view model =
    case model.gameState of
        Paused ->
            viewMenu model
        Won ->
            viewWin
        Lost ->
            viewLoss
        _ ->
            viewBoard model

{-| Render the board -}
viewBoard : Model -> Html Msg
viewBoard model =
    Html.div []
        [ Html.text model.wouldBeAction
        , rGameClock model.timeElapsed
        ]

{-| Render the pause menu -}
viewMenu : Model -> Html Msg
viewMenu model =  -- todo
    Html.text "pause menu is open"

{-| -}
viewWin : Html Msg
viewWin =
    Html.text "Game Over: Win"

{-| -}
viewLoss : Html Msg
viewLoss =
    Html.text "Game Over: Loss"
