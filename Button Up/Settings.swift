//
//  Settings.swift
//  Button Up
//
//  Created by Ricky Buchanan on 20/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation


class Settings: NSObject {

    var username = ""
    var password = ""
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.setObject(username, forKey: "username")
        defaults.setObject(password, forKey: "password")
    }
    
    func retreive() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        var userSuccess: Bool
        var passSuccess: Bool
        
        if (defaults.stringForKey("username") != nil) {
            self.username = defaults.stringForKey("username")!
            userSuccess = true
        } else {
            userSuccess = false
        }
        if (defaults.stringForKey("password") != nil) {
            self.password = defaults.stringForKey("password")!
            passSuccess = true
        } else {
            passSuccess = false
        }

        return userSuccess && passSuccess
    }

//     TODO Not sure what the point of this is?
    func register() {
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.registerDefaults([
            "username": username,
            "password": password
            ])
    }

}

