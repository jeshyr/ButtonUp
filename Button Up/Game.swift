//
//  Game.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

struct Game {
    // These may or may not be the logged in player's games
    
    // Object for a single game
    var description: String = ""
    var id: Int = 0
    var state: GameState = GameState.INVALID
    
    var round: Int = 0
    var timestamp = NSDate()

    var activePlayerIndex: Int? // Nil in inactive games
    var currentPlayerIndex = 0
    var actionLog = [GameLogMessage]()
    var chatEditable = NSDate() // TODO is this a timestamp?
    var chatLog = [GameLogMessage]()
    var skillsInfo = [Skill]()
    var maxWins: Int = 0
    var playerData = [GamePlayerData]()
    var playerWithInitiativeIndex: Int = 0
    var previousGameId: Int? = nil
    var validAttacks = [Attack]()
}

struct GamePlayerData {
    // Data about one player in a Game - may be anyone
    
    var id: Int = 0
    var name: String = ""
    var color = UIColor()
    var button = Button()

    var activeDice = [Die]()
    var capturedDice = [Die]()
    var outOfPlayDice = [Die]()

    var draws: Int = 0
    var losses: Int = 0
    var wins: Int = 0
    var roundScore: Int = 0
    var sideScore: Int = 0
    var canStillWin: Bool? = nil

    var hasDismissedGame: Bool = false
    var lastActionTime = NSDate()
    
    var optRequests = [Int:[Int]]() // Possible values for unchosen optional dice eg (10/12) or (4/12)
    var prevOptValues = [Int:[Int]]() // Only available while choosing dice in the second/subsequent round of a game with Optional values. 
        // May contain dictionary OR array - seen values include
        //prevOptValues: { // My dice, new values unchosen
        //    1 = 7;
        //    2 = 7;
        //    3 = 7;
        //    4 = 7;
        //}
        //
        //prevOptValues: ( // Oponent dice, new values chosen
        //    20,
        //    20,
        //    20,
        //    20
        //)
    var swingRequests = [DieSwing]()
    var prevSwingValues = [DieSwing]() // prevSwingValueArray WTF?
    
    var waitingOnAction: Bool = false
}

struct GameLogMessage {
    var player: String = ""
    var message: String = ""
    var timestamp = NSDate()
}

struct GameSummary {
    // These are almost always about games belonging to the logged in player, so "my" and "opponent" on the variables. For open games, "opponent" is the person proprosing the game and "my" is the one I'd play if I accepted the game.
    
    // Object for a single game
    var description: String = ""
    var id: Int = 0
    var state: GameState = GameState.INVALID
    var inactivity: String = ""
    var inactivityRaw: Int = 0 // What's this?
    var awaitingAction: Bool = false
    var myButton: String = "" // These should be enums too?
    var myColor = UIColor()
    var draws: Int = 0
    var losses: Int = 0
    var wins: Int = 0
    var targetWins: Int = 0
    var opponentButton: String = ""
    var opponentId: Int = 0
    var opponentName: String = ""
    var opponentColor = UIColor()
    
    var status: GameStatus = GameStatus.BROKEN
}



enum GameStatus: String {
    case OPEN
    case ACTIVE
    case COMPLETE
    case REJECTED
    case BROKEN
}

enum GameState: String {
    case START_GAME
    case APPLY_HANDICAPS // Never returned by API
    case CHOOSE_JOIN_GAME
    case SPECIFY_RECIPES // Never returned by API
    case SPECIFY_DICE
    case CHOOSE_AUXILIARY_DICE
    case CHOOSE_RESERVE_DICE
    case LOAD_DICE_INTO_BUTTONS // Never returned by API
    case ADD_AVAILABLE_DICE_TO_GAME // Never returned by API
    case DETERMINE_INITIATIVE // Never returned by API
    case REACT_TO_INITIATIVE

    case START_ROUND // Never returned by API
    case START_TURN
    case ADJUST_FIRE_DICE
    case COMMIT_ATTACK // Never returned by API
    case CHOOSE_TURBO_SWING // Never returned by API
    case END_TURN // Never returned by API
    case END_ROUND // Never returned by API
    case END_GAME
    case REJECTED
    case INVALID // Completed games have this (check GameStatus)
    
    var isActive: Bool {
        switch self {
        case GameState.START_ROUND:
            return true
        case GameState.START_TURN:
            return true
        case GameState.ADJUST_FIRE_DICE:
            return true
        case GameState.COMMIT_ATTACK:
            return true
        case GameState.CHOOSE_TURBO_SWING:
            return true
        case GameState.END_TURN:
            return true
        case GameState.END_ROUND:
            return true
        default:
            return false
        }
    }
}