//
//  Skill.swift
//  Button Up
//
//  Created by Ricky Buchanan on 23/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

struct Skill : CustomStringConvertible {
    var value: String = "" // Full name
    var text: String = ""  // Long textual description of skill's attributes
    // Example of interactions:
    //    interacts =     {
    //    Ornery = "Dice with both Ornery and Mood Swing have their sizes randomized during ornery rerolls";
    //    };
    var interactions = [String: String]()
    
    var short: String {
        // Return one-character version of Skill
        return nameToCharacter[self.value]!

    }
    
    // This has to be called 'description' for the CustomStringConvertible protocol
    var description: String {
        // Return full name of skill
        return self.value
    }
    
    init?(skill: String) {
        if skill.isEmpty {
            return nil
        } else if skill.characters.count > 1 {
            // Full name initialisation
            if nameToCharacter[skill] == nil {
                return nil
            } else {
                self.value = skill
            }
        } else {
            // Single character
            if characterToName[skill] == nil {
                return nil
            } else {
                self.value = characterToName[skill]!
            }
        }
    }
    
    let nameToCharacter = [
        "Auxiliary"    : "+",
        "Berserk"      : "B",
        "Boom"         : "b",
        "Chance"       : "c",
        "Doppelganger" : "D",
        "Fire"         : "F",
        "Focus"        : "f",
        "Insult"       : "I",
        "Konstant"     : "k",
        "Mad"          : "&",
        "Maximum"      : "M",
        "Mighty"       : "H",
        "Mood"         : "?",
        "Morphing"     : "m",
        "Null"         : "n",
        "Ornery"       : "o",
        "Poison"       : "p",
        "Queer"        : "q",
        "Radioactive"  : "%",
        "Rage"         : "G",
        "Reserve"      : "r",
        "Shadow"       : "s",
        "Slow"         : "w",
        "Speed"        : "z",
        "Stealth"      : "d",
        "Stinger"      : "g",
        "TimeAndSpace" : "^",
        "Trip"         : "t",
        "Turbo"        : "!",
        "Value"        : "v",
        "Warrior"      : "`",
        "Weak"         : "h"
    ]
    
    // This is not so elegant, having two dictionaries, but it's more efficient and we look up both ways a lot
    let characterToName = [
        "+" : "Auxiliary",
        "B" : "Berserk",
        "b" : "Boom",
        "c" : "Chance",
        "D" : "Doppelganger",
        "F" : "Fire",
        "f" : "Focus",
        "I" : "Insult",
        "k" : "Konstant",
        "&" : "Mad",
        "M" : "Maximum",
        "H" : "Mighty",
        "?" : "Mood",
        "m" : "Morphing",
        "n" : "Null",
        "o" : "Ornery",
        "p" : "Poison",
        "q" : "Queer",
        "%" : "Radioactive",
        "G" : "Rage",
        "r" : "Reserve",
        "s" : "Shadow",
        "w" : "Slow",
        "z" : "Speed",
        "d" : "Stealth",
        "g" : "Stinger",
        "^" : "TimeAndSpace",
        "t" : "Trip",
        "!" : "Turbo",
        "v" : "Value",
        "`" : "Warrior",
        "h" : "Weak"
    ]

}