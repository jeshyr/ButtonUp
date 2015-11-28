//
//  Button.swift
//  Button Up
//
//  Created by Ricky Buchanan on 14/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit


struct Button {
    // May have only these first three properties, or might have all
    var name: String = ""
    var artFilename: String = ""
    var recipe: String = ""
    
    var flavor: String = ""
    var id: Int = 0
    var setName: String = ""
    var dieSkills = [Skill]()
    var dieTypes = [ButtonDieTypes]()
    var hasUnimplementedSkill: Bool = false
    var isTournamentLegal: Bool = false
    var special: String = "" // WTF? only exposed in name-only requests
    var tags = [String]?()
}

/* Types of die involved in this button. Only name is non-optional */
struct ButtonDieTypes {
    var name: String = ""
    var code: String? = nil
    var description: String? = nil
    var swingMin: Int? = nil
    var swingMax: Int? = nil
}

/* Skills of die involved in this button. Only name is non-optional */
struct ButtonDieSkills {
    var name: String = ""
    var code: String? = nil
    var description: String? = nil
    // Example of interactions:
    //    interacts =     {
    //    Ornery = "Dice with both Ornery and Mood Swing have their sizes randomized during ornery rerolls";
    //    };
    var interactions = [String: String]()
}