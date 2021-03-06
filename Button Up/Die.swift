//
//  Die.swift
//  Button Up
//
//  Created by Ricky Buchanan on 15/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

struct Die : CustomStringConvertible {
    var text: String = "" // Description string sent from server
    var properties = [Flag]()
    var recipe: String = ""
    var skills = [Skill]()
    var sides: Int = 0
    var minimum: Int { // lowest possible value of this die
        if self.properties.contains(Flag.Twin) {
            return 2
        } else if sides == 0 {
            return 0
        } else {
            return 1
        }
    }
    var value: Int = 0
    var subDice = [DieSubDie]() // For twin die
    
    // Recipe without skills, braces, or option/swing values
    var coreRecipe: String {
        do {
            let regExp = try NSRegularExpression(pattern: "\\((.+)\\)", options: NSRegularExpressionOptions.CaseInsensitive)
            let range = NSMakeRange(0, self.recipe.characters.count)
            let match = regExp.firstMatchInString(self.recipe, options: NSMatchingOptions(), range: range)
            
            if (match != nil) {
                let range = match!.rangeAtIndex(1) // First capture group
                let nsRecipe = self.recipe as NSString
                return nsRecipe.substringWithRange(range)
            } else {
                print("Die appears to have no core recipe: \(self.recipe)")
                return ""
            }
        } catch {
            print("Die::coreRecipe failed to create regular expression")
            return ""
        }
    }
    
    // Recipe without skills, braces, but WITH chosen option/swing values
    // Uses ? if no values chosen
    var expandedCoreRecipe: String {
        let rawCoreRecipe = self.coreRecipe // The bit inside the braces
        var sides = String(self.sides)

        if sides == "0" {
            sides = "?"
        }
        
        do {
            let range = NSMakeRange(0, rawCoreRecipe.characters.count)
            
            // If it's just an integer, return it unchanged - most common case
            // (6) becomes (6)
            let regExp = try NSRegularExpression(pattern: "^\\d+$", options: NSRegularExpressionOptions.CaseInsensitive)
            if regExp.numberOfMatchesInString(rawCoreRecipe, options: NSMatchingOptions(), range: range) > 0 {
                return rawCoreRecipe
                
            } else {
                // If there's a slash, it's an optional and should have a number of sides added, eg:
                // (20/2) becomes (2/20=2)
                let regExp = try NSRegularExpression(pattern: "^\\d+/\\d+$", options: NSRegularExpressionOptions.CaseInsensitive)
                if regExp.numberOfMatchesInString(rawCoreRecipe, options: NSMatchingOptions(), range: range) > 0 {
                    return "\(rawCoreRecipe)=\(sides)"
                } else {
                    // If there's a comma and digit(s), it's a plain twin die and we return it unchanged
                    let regExp = try NSRegularExpression(pattern: "^\\d+,\\d+$", options: NSRegularExpressionOptions.CaseInsensitive)
                    if regExp.numberOfMatchesInString(rawCoreRecipe, options: NSMatchingOptions(), range: range) > 0 {
                        return rawCoreRecipe
                        
                    } else {
                        // If there's a single letter, it's a swing die and should have the number of sides after (each) recipe eg:
                        // X becomes X=6
                        let regExp = try NSRegularExpression(pattern: "^[RSTUVWXYZ]$", options: NSRegularExpressionOptions.CaseInsensitive)
                        if regExp.numberOfMatchesInString(rawCoreRecipe, options: NSMatchingOptions(), range: range) > 0 {
                            return "\(rawCoreRecipe)=\(sides)"

                        } else {
                            // Last option - twin swing die
                            // (V,V) becomes (V=6,V=6)
                            
                            let regExp = try NSRegularExpression(pattern: "^([RSTUVWXYZ]),([RSTUVWXYZ])$", options: NSRegularExpressionOptions.CaseInsensitive)
                            let match = regExp.firstMatchInString(rawCoreRecipe, options: NSMatchingOptions(), range: range)
                                
                            if (match != nil) {
                                let nsCoreRecipe = rawCoreRecipe as NSString

                                var range = match!.rangeAtIndex(1) // First capture group
                                let opt1 = nsCoreRecipe.substringWithRange(range)
                                range = match!.rangeAtIndex(2) // Second capture group
                                let opt2 = nsCoreRecipe.substringWithRange(range)
                                var eachSides = ""
                                if sides == "?" {
                                    eachSides = "?" // Can't divide a question mark by two
                                } else {
                                    eachSides = "\(self.sides / 2)"
                                }
                                return "\(opt1)=\(eachSides),\(opt2)=\(eachSides)"
                            } else {
                                print("Die::expandedCoreRecipe failed to identify type of die \(rawCoreRecipe) - can't expand")
                                return rawCoreRecipe
                            }
                        }
                    }
                }
            }
        } catch {
            print("Die::expandedCoreRecipe failed to create regular expression")
            return rawCoreRecipe
        }
        
       
    }
    
    // This has to be called 'description' for the CustomStringConvertible protocol
    var description : String {
        // Return full recipe suitable for display on game detail page
        let core = self.expandedCoreRecipe
        var skillStringPrefix = ""
        var skillStringPostfix = ""

        for skill in self.skills {
            
            switch skill.description {
            case "Mood":
                skillStringPostfix += skill.short
            default:
                skillStringPrefix += skill.short
            }
        }
        
        //print("Recipe: \(self.recipe), sides: \(self.sides), skills: \(self.skills), coreRecipe: \(self.coreRecipe), expandedCoreRecipe: \(core)")
        return "\(skillStringPrefix)(\(core))\(skillStringPostfix)"
    }
    
    func hasSkill(skillText: String) -> Bool {
        // This is ugly and I'm sure there's a better way to do it but I can't think of it just now.
        for skill in skills {
            if skill.description == skillText {
                return true
            }
        }
        return false
    }
    
    func asView(active: Bool) -> DieView {
        let newButton = DieView()
        if self.properties.contains(Flag.Twin) {
            if !self.subDice.isEmpty {
                newButton.dieValue.setTitle("\(self.subDice[0].value),\(self.subDice[1].value)", forState: UIControlState.Normal)
            } else {
                newButton.dieValue.setTitle("\(self.value)", forState: UIControlState.Normal)
            }
        } else {
            newButton.dieValue.setTitle("\(self.value)", forState: UIControlState.Normal)
        }
        
        newButton.dieLabel.text = self.description
        if active {
            if self.properties.contains(Flag.IsAttacker) || self.properties.contains(Flag.IsAttackTarget) {
                // Active fire-adjust dice are red
                newButton.dieValue.newBackingColor(UIColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1.0))
            } else if self.properties.contains(Flag.Disabled) || self.properties.contains(Flag.Dizzy) {
                // Disabled/Dizzy dice can't be used this turn (eg Focus die you just turned down) - they're grey
                newButton.dieValue.newBackingColor(UIColor.lightGrayColor())
            }
        } else {
            // Inactive dice are grey or mostly grey
            if self.properties.contains(Flag.IsAttacker) || self.properties.contains(Flag.IsAttackTarget) {
                newButton.dieValue.newBackingColor(UIColor(red: 0.85, green: 0.5, blue: 0.5, alpha: 1.0))
            } else {
                newButton.dieValue.newBackingColor(UIColor.lightGrayColor())
            }
        }
        return newButton
    }

}

struct DieSubDie {
    // For contents of a twin die
    var sides: Int = 0
    var value: Int = 0
}

struct DieSwing {
    // Values specific to swing die
    var swingType: String = ""
    var value: Int? = 0 // value chosen by player (if set)
    var max: Int = 0 // Maximum allowed value
    var min: Int = 0 // Minimum allowed value
}

