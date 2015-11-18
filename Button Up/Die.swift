//
//  Die.swift
//  Button Up
//
//  Created by Ricky Buchanan on 15/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

struct Die {
    var description: String = ""
    var properties = [DieFlag]()
    var recipe: String = ""
    var skills = [String]()
    var sides: Int = 0
    var value: Int = 0
    var subDice = [DieSubDie]() // For twin die
}

struct DieSubDie {
    // For contents of a twin die
    var sides: Int = 0
    var value: Int = 0
}

enum DieFlag: String {
    case WasJustCaptured
    case Twin
    case HasJustSplit
    case JustPerformedBerserkAttack
}

struct DieSwing {
    // Values specific to swing die
    var swingType: String = ""
    var value: Int? = 0 // value chosen by player (if set)
    var max: Int = 0 // Maximum allowed value
    var min: Int = 0 // Minimum allowed value
}

