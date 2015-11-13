//
//  ButtonGame.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

struct ButtonGame {

    // Object for a single game
    var gameDescription: String
    var id: Int
    var state: String // TODO this should be an enum
    var inactivity: String // TODO this should be a time interval
    var inactivityRaw: Int // What's this?
    var awaitingAction: Bool
    var myButton: String // These should be enums too?
    var myColor: String // proper colour thingy
    var draws: Int
    var losses: Int
    var wins: Int
    var targetWins: Int
    var oponentButton: String
    var oponentId: Int
    var oponentName: String
    var oponentColor: String // Color
    
    var status: String // ??
    
}
    