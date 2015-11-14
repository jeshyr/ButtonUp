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
    var artFilename: String = ""
    var id: Int = 0
    var name: String = ""
    var setName: String = ""
    var dieSkills = [String]()
    var dieTypes = [String]()
    var hasUnimplementedSkill: Bool = false
    var isTournamentLegal: Bool = false
    var recipe: String = ""
    var tags = [String]?()
}