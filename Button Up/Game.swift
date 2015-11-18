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

    var activePlayerIndex: Int? // Nill in inactive games
    var currentPlayerIndex = 0
    var actionLog = [GameLogMessage]()
    var chatEditable = NSDate() // TODO is this a timestamp?
    var chatLog = [GameLogMessage]()
    var skillsInfo = [GameButtonSkillInfo]()
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
    var lastActionTime = NSDate() // timestamp?
    
    var optRequests = [String]() // optRequestArray WTF?
    var prevOptValues = [String]() // prevOptValueArray WTF?
    var swingRequests = [DieSwing]() 
    var prevSwingValues = [String]() // prevSwingValueArray WTF?
    
    var waitingOnAction: Bool = false
}


struct GameLogMessage {
    var player: String = ""
    var message: String = ""
    var timestamp = NSDate()
}

struct GameButtonSkillInfo {
    var name: String = ""
    var code: String = "" // Are they always 1 letter?
    var description: String = ""
    var interactions = [String]() // Maybe?
}


struct GameSummary {
    // These are always about games belonging to the logged in player, so "my" and "oponent" on the variables
    
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
    case APPLY_HANDICAPS
    case CHOOSE_JOIN_GAME
    case SPECIFY_RECIPES
    case CHOOSE_AUXILIARY_DICE
    case CHOOSE_RESERVE_DICE
    case LOAD_DICE_INTO_BUTTONS
    case ADD_AVAILABLE_DICE_TO_GAME
    case SPECIFY_DICE
    case DETERMINE_INITIATIVE
    case REACT_TO_INITIATIVE
    case START_ROUND
    case START_TURN
    case ADJUST_FIRE_DICE
    case COMMIT_ATTACK
    case CHOOSE_TURBO_SWING
    case END_TURN
    case END_ROUND
    case END_GAME
    case REJECTED
    case INVALID
    
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