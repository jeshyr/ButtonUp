//
//  Die.swift
//  Button Up
//
//  Created by Ricky Buchanan on 15/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

struct Die : CustomStringConvertible {
    var desc: String = "" // Description string sent from server
    var properties = [DieFlag]()
    var recipe: String = ""
    var skills = [Skill]()
    var sides: Int = 0
    var value: Int = 0
    var subDice = [DieSubDie]() // For twin die
    
    // This has to be called 'description' for the customstringconvertable protocol
    var description : String {
        // Return full recipe suitable for display on game detail page
        
        // Skills (abbreviated) go before the braces, eg
        // B(30) is a beserk dice
        // If it's just a number return the recipe
        // (6) becomes (6)
        // If there's a letter, it's a swing die and should have the number of sides after (each) recipe eg:
        // X becomes X=6
        // (V,V) becomes (V=6,V=6)
        // If there's a slash, it's an optional and should have a number of sides added, eg:
        // (20/2) becomes (2/20=2)
        
        // if die.properties.contains(DieFlag.Twin)
        print("Recipe: \(self.recipe), sides: \(self.sides), skills: \(self.skills)")
        return self.recipe
    }
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

