//
//  ButtonGame.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit


struct ButtonGame {

    // Object for a single game
    var description: String = ""
    var id: Int = 0
    var state: gameState = gameState.INVALID
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
    
    var status: gameStatus = gameStatus.BROKEN
    
}

enum gameStatus: String {
    case OPEN
    case ACTIVE
    case COMPLETE
    case REJECTED
    case BROKEN
}

enum gameState: String {
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
}
    