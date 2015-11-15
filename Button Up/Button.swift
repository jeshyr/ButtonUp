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
    
    var id: Int = 0
    var setName: String = ""
    var dieSkills = [String]()
    var dieTypes = [String]()
    var hasUnimplementedSkill: Bool = false
    var isTournamentLegal: Bool = false
    var tags = [String]?()
}