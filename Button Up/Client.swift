//
//  Client.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

// All the client functions NOT for viewing/playing a single game

extension APIClient {
    
    // MARK: - Load data for one or more buttons
    func loadButtonData(buttonSet: String?, buttonName: String?, completionHandler: (buttons: [Button]?, success: Bool, message: String?) -> Void) {
        var jsonBody: [String: String] = [
            "type": "loadButtonData"
        ]
        
        if buttonSet != nil {
            jsonBody["buttonSet"] = buttonSet
        }
        if buttonName != nil {
            jsonBody["buttonName"] = buttonName
        }
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(buttons: nil, success: false, message: message)
                return
            }
            
            guard let parsedSetArray = result as! [AnyObject]? else {
                print("Can't find array of buttons in \(result)")
                completionHandler(buttons: nil, success: false, message: "Can't find array of buttons in \(result)")
                return
            }
            
            let buttons = self.parseButtonData(parsedSetArray)
            
            completionHandler(buttons: buttons, success: true, message: nil)
            return
        }
    }
    
    func parseButtonData(dataArray: [AnyObject]) -> [Button]? {
        
        var buttons = [Button]()
        
        for data in dataArray {
            var button = Button()
            
            guard let artFilename = data["artFilename"] as? String else {
                print("Can't find artFilename in \(data)")
                return nil
            }
            button.artFilename = artFilename
            
            guard let buttonId = data["buttonId"] as? Int else {
                print("Can't find buttonId in \(data)")
                return nil
            }
            button.id = buttonId
            
            guard let buttonName = data["buttonName"] as? String else {
                print("Can't find buttonName in \(data)")
                return nil
            }
            button.name = buttonName
            
            guard let buttonSet = data["buttonSet"] as? String else {
                print("Can't find buttonSet in \(data)")
                return nil
            }
            button.setName = buttonSet
            
            /* If loading multiple buttons, dieSkills will be an array of strings. If a single button, dieSkills will be a dictionary of dictionaries. */
            guard let dieSkills = data["dieSkills"] else {
                print("Can't find dieSkills in \(data)")
                return nil
            }
            button.dieSkills = self.parseSkills(dieSkills!)
            
            /* If loading multiple buttons, dieTypes will be an array of strings. If a single button, dieTypes will be a dictionary of dictionaries. */
            guard let dieTypes = data["dieTypes"] else {
                print("Can't find dieTypes in \(data)")
                return nil
            }
            button.dieTypes = self.parseButtonDieTypes(dieTypes!)
            
            /* FlavorText is only exposed if loading a single button at a time */
            if let flavorText = data["flavorText"] as? String {
                button.flavor = flavorText
            }
            
            /* specialText is only exposed if loading a single button at a time */
            if let specialText = data["specialText"] as? String {
                button.special = specialText
                print("Found specialText on button \(buttonName): \(specialText)")
            }
            
            guard let hasUnimplementedSkill = data["hasUnimplementedSkill"] as? Bool else {
                print("Can't find hasUnimplementedSkill in \(data)")
                return nil
            }
            button.hasUnimplementedSkill = hasUnimplementedSkill
            
            guard let isTournamentLegal = data["isTournamentLegal"] as? Bool else {
                print("Can't find isTournamentLegal in \(data)")
                return nil
            }
            button.isTournamentLegal = isTournamentLegal
            
            guard let recipe = data["recipe"] as? String else {
                print("Can't find recipe in \(data)")
                return nil
            }
            button.recipe = recipe
            
            if let tags = data["tags"] as? [String] {
                button.tags = tags
                // print("Found tags on button \(buttonName): \(tags)")
                
            } else {
                button.tags = nil
            }
            
            buttons.append(button)
        }
        
        return buttons

    }
    
    // Games and Buttons and Die all have Skills
    func parseSkills(skillData: AnyObject?) -> [Skill] {
        var newSkills = [Skill]()
        
        if let skillArray = skillData as? [String] {
            // skill array - skill names only
            for skill in skillArray {
                guard let newDieSkill = Skill(skill: skill) else {
                    print("Found unknown skill name: \(skill)")
                    return newSkills
                }
                newSkills.append(newDieSkill)
            }
        } else if let skillsDictionaries = skillData as? [String: AnyObject] {
            // skill dictionary - full skill data
            for (skillName, skillDictionary) in skillsDictionaries {
                guard var newSkill = Skill(skill: skillName) else {
                    print("Found unknown skill name: \(skillName)")
                    return newSkills
                }
                
                if let description = skillDictionary["description"] as? String {
                    newSkill.text = description
                }
                
                if let interactions = skillDictionary["interacts"] as? [String: String] {
                    newSkill.interactions = interactions
                }
                
                newSkills.append(newSkill)
                
            }
        } else {
            // No die skill - return empty array
        }
        return newSkills
    }
    
    func parseButtonDieTypes(dieTypeData: AnyObject) -> [ButtonDieTypes] {
        var newDieTypes = [ButtonDieTypes]()
        
        if let dieTypeArray = dieTypeData as? [String] {
            // Die type array - die type names only
            for dieType in dieTypeArray {
                var newDieType = ButtonDieTypes()
                newDieType.name = dieType
                newDieTypes.append(newDieType)
            }
        } else if let dieTypeDictionaries = dieTypeData as? [String: AnyObject] {
            // Die type dictionary - full die type data
            for (dieTypeName, dieTypeDict) in dieTypeDictionaries {
                var newDieType = ButtonDieTypes()
                newDieType.name = dieTypeName
                newDieType.code = dieTypeDict["code"] as? String
                newDieType.description = dieTypeDict["description"] as? String
                if let swingMin = dieTypeDict["swingMin"] as? Int {
                    newDieType.swingMin = swingMin
                }
                if let swingMax = dieTypeDict["swingMax"] as? Int {
                    newDieType.swingMax = swingMax
                }
                newDieTypes.append(newDieType)
            }
        } else {
            // No die types
        }
        return newDieTypes
    }
    
    func loadButtonSetData(buttonSet: String?, completionHandler: (buttonSets: [ButtonSet]?, success: Bool, message: String?) -> Void) {
        var jsonBody: [String: String] = [
            "type": "loadButtonSetData"
        ]
        
        if buttonSet != nil {
            jsonBody["buttonSet"] = buttonSet
        }
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(buttonSets: nil, success: false, message: message)
                return
            }
            
            //print(result)
            var buttonSets = [ButtonSet]()
            
            guard let parsedSetArray = result as! [AnyObject]? else {
                print("Can't find array of button sets in \(result)")
                completionHandler(buttonSets: nil, success: false, message: "Can't find array of button sets in \(result)")
                return
            }
            
            for parsedSet in parsedSetArray {
                var buttonSet = ButtonSet()
                
                guard let setName = parsedSet["setName"] as! String? else {
                    print("Can't find set name in \(parsedSet)")
                    completionHandler(buttonSets: nil, success: false, message: "Can't find set name in \(parsedSet)")
                    return
                }
                buttonSet.name = setName
                
                guard let numberOfButtons = parsedSet["numberOfButtons"] as! Int? else {
                    print("Can't find numberOfButtons in \(parsedSet)")
                    completionHandler(buttonSets: nil, success: false, message: "Can't find numberOfButtons in \(parsedSet)")
                    return
                }
                buttonSet.numberOfButtons = numberOfButtons
                
                guard let onlyHasUnimplementedButtons = parsedSet["onlyHasUnimplementedButtons"] as! Bool? else {
                    print("Can't find onlyHasUnimplementedButtons in \(parsedSet)")
                    completionHandler(buttonSets: nil, success: false, message: "Can't find onlyHasUnimplementedButtons in \(parsedSet)")
                    return
                }
                buttonSet.onlyHasUnimplementedButtons = onlyHasUnimplementedButtons
                
                guard let dieSkills = parsedSet["dieSkills"] as! [String]? else {
                    print("Can't find dieSkills in \(parsedSet)")
                    completionHandler(buttonSets: nil, success: false, message: "Can't find dieSkills in \(parsedSet)")
                    return
                }
                buttonSet.dieSkills = dieSkills
                
                
                guard let dieTypes = parsedSet["dieTypes"] as! [String]? else {
                    print("Can't find dieTypes in \(parsedSet)")
                    completionHandler(buttonSets: nil, success: false, message: "Can't find dieTypes in \(parsedSet)")
                    return
                }
                buttonSet.dieTypes = dieTypes
                
                buttonSets.append(buttonSet)
            }
            
            completionHandler(buttonSets: buttonSets, success: true, message: nil)
            return
        }
    }

    // MARK: - Load game summaries
    func loadNewGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadNewGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            self.parseGameSummaryArrays(result) { games, success, message in
                completionHandler(gameSummaries: games, success: success, message: message)
                return
            }
        }
    }
    
    func loadRejectedGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadRejectedGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            self.parseGameSummaryArrays(result) { games, success, message in
                completionHandler(gameSummaries: games, success: success, message: message)
                return
            }
        }
    }
    
    func loadCompletedGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadCompletedGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            self.parseGameSummaryArrays(result) { games, success, message in
                completionHandler(gameSummaries: games, success: success, message: message)
                return
            }
        }
    }

    func loadActiveGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadActiveGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            self.parseGameSummaryArrays(result) { games, success, message in
                completionHandler(gameSummaries: games, success: success, message: message)
                return
            }
        }
    }
    
    func parseGameSummaryArrays(result: AnyObject?, completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
    
        // Parse dictionary of arrays into array of games
        var games: [GameSummary] = [GameSummary]()
        
        guard let gameDescriptionArray = result!["gameDescriptionArray"] as! [String]? else {
            print("Can't parse gameDescriptionArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse gameDescriptionArray: \(result)")
            return
        }
        for description in gameDescriptionArray {
            var newGame = GameSummary()
            newGame.description = description
            games.append(newGame)
        }
        
        guard let gameIdArray = result!["gameIdArray"] as! [Int]? else {
            print("Can't parse gameIdArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse gameIdArray: \(result)")
            return
        }
        for (index, id) in gameIdArray.enumerate() {
            games[index].id = id
        }
        
        guard let gameStateArray = result!["gameStateArray"] as! [String]? else {
            print("Can't parse gameStateArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse gameStateArray: \(result)")
            return
        }
        for (index, state) in gameStateArray.enumerate() {
            guard let validState = GameState(rawValue: state) else {
                print("Invalid game state: \(state) in game \(games[index].id)")
                completionHandler(gameSummaries: nil, success: false, message: "Invalid game state: \(state) in game \(games[index].id)")
                return
            }
            games[index].state = validState
        }
        
        guard let inactivityArray = result!["inactivityArray"] as! [String]? else {
            print("Can't parse inactivityArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse inactivityArray: \(result)")
            return
        }
        for (index, inactivity) in inactivityArray.enumerate() {
            games[index].inactivity = inactivity
        }
        
        guard let inactivityRawArray = result!["inactivityRawArray"] as! [Int]? else {
            print("Can't parse inactivityRawArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse inactivityRawArray: \(result)")
            return
        }
        for (index, inactivityRaw) in inactivityRawArray.enumerate() {
            games[index].inactivityRaw = inactivityRaw
        }
        
        guard let isAwaitingActionArray = result!["isAwaitingActionArray"] as! [Int]? else {
            print("Can't parse isAwaitingActionArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse isAwaitingActionArray: \(result)")
            return
        }
        for (index, isAwaitingAction) in isAwaitingActionArray.enumerate() {
            if isAwaitingAction == 1 {
                games[index].awaitingAction = true
            } else {
                games[index].awaitingAction = false
            }
        }
        
        guard let myButtonNameArray = result!["myButtonNameArray"] as! [String]? else {
            print("Can't parse myButtonNameArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse myButtonNameArray: \(result)")
            return
        }
        for (index, myButton) in myButtonNameArray.enumerate() {
            games[index].myButton = myButton
        }
        
        guard let nDrawsArray = result!["nDrawsArray"] as! [Int]? else {
            print("Can't parse nDrawsArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse nDrawsArray: \(result)")
            return
        }
        for (index, draws) in nDrawsArray.enumerate() {
            games[index].draws = draws
        }
        
        guard let nLossesArray = result!["nLossesArray"] as! [Int]? else {
            print("Can't parse nLossesArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse nLossesArray: \(result)")
            return
        }
        for (index, losses) in nLossesArray.enumerate() {
            games[index].losses = losses
        }
        
        guard let nWinsArray = result!["nWinsArray"] as! [Int]? else {
            print("Can't parse nWinsArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse nWinsArray: \(result)")
            return
        }
        for (index, wins) in nWinsArray.enumerate() {
            games[index].wins = wins
        }
        
        guard let nTargetWinsArray = result!["nTargetWinsArray"] as! [Int]? else {
            print("Can't parse nTargetWinsArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse nTargetWinsArray: \(result)")
            return
        }
        for (index, targetWins) in nTargetWinsArray.enumerate() {
            games[index].targetWins = targetWins
        }
        
        guard let opponentButtonNameArray = result!["opponentButtonNameArray"] as! [String]? else {
            print("Can't parse opponentButtonNameArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse opponentButtonNameArray: \(result)")
            return
        }
        for (index, opponentButton) in opponentButtonNameArray.enumerate() {
            games[index].opponentButton = opponentButton
        }
        
        guard let opponentColorArray = result!["opponentColorArray"] as! [String]? else {
            print("Can't parse opponentColorArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse opponentColorArray: \(result)")
            return
        }
        for (index, opponentColor) in opponentColorArray.enumerate() {
            games[index].opponentColor = APIClient.hexStringToUIColor(opponentColor)
        }
        
        guard let playerColorArray = result!["playerColorArray"] as! [String]? else {
            print("Can't parse playerColorArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse playerColorArray: \(result)")
            return
        }
        for (index, myColor) in playerColorArray.enumerate() {
            games[index].myColor = APIClient.hexStringToUIColor(myColor)
        }
        
        guard let opponentIdArray = result!["opponentIdArray"] as! [Int]? else {
            print("Can't parse opponentIdArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse opponentIdArray: \(result)")
            return
        }
        for (index, opponentId) in opponentIdArray.enumerate() {
            games[index].opponentId = opponentId
        }
        
        guard let opponentNameArray = result!["opponentNameArray"] as! [String]? else {
            print("Can't parse opponentNameArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse opponentNameArray: \(result)")
            return
        }
        for (index, opponentName) in opponentNameArray.enumerate() {
            games[index].opponentName = opponentName
        }
        
        guard let statusArray = result!["statusArray"] as! [String]? else {
            print("Can't parse statusArray")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse statusArray: \(result)")
            return
        }
        for (index, status) in statusArray.enumerate() {
            guard let validStatus = GameStatus(rawValue: status) else {
                print("Invalid game status: \(status) in game \(games[index].id)")
                completionHandler(gameSummaries: nil, success: false, message: "Invalid game status: \(status) in game \(games[index].id)")
                return
            }
            games[index].status = validStatus
        }
        
        completionHandler(gameSummaries: games, success: true, message: nil)
        return
    }
    
    // MARK: - Offered Games
    
    func acceptNewGame(gameId: Int, accept: Bool, completionHandler: (success: Bool, message: String?) -> Void) {
        var jsonBody: [String: String] = [
            "type": "reactToNewGame",
            "gameId": String(gameId),
        ]
        if accept {
            jsonBody["action"] = "accept"
        } else {
            jsonBody["action"] = "reject"
        }
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(success: false, message: message)
                return
            }
            
            completionHandler(success: success, message: nil)
        }
    }
    
    // MARK: - Open Games
    
    func joinOpenGame(gameId: Int, buttonName: String?, completionHandler: (success: Bool, message: String?) -> Void) {
        var jsonBody: [String: String] = [
            "type": "joinOpenGame",
            "gameId": String(gameId)
        ]
        if buttonName != nil {
            jsonBody["buttonName"] = buttonName
        }
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(success: false, message: message)
                return
            }
            
            completionHandler(success: success, message: nil)
        }
    }
    
    func loadOpenGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadOpenGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            self.parseOpenGameArrays(result) { games, success, message in
                completionHandler(gameSummaries: games, success: success, message: message)
                return
            }
        }
    }
    
    func parseOpenGameArrays(result: AnyObject?, completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        
        var games: [GameSummary] = [GameSummary]()
        
        guard let openGameArray = result!["games"] as! [[String: AnyObject]]? else {
            print("Can't parse openGameArrays")
            completionHandler(gameSummaries: nil, success: false, message: "Can't parse openGameArrays: \(result)")
            return
        }
        for openGameData in openGameArray {
            var newGame = GameSummary()
            
            guard let challengerButton = openGameData["challengerButton"] as? String else {
                print("Can't find challengerButton in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find challengerButton in open games \(openGameData)")
                return
            }
            newGame.opponentButton = challengerButton
            
            guard let challengerColor = openGameData["challengerColor"] as? String else {
                print("Can't find challengerColor in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find challengerColor in open games \(openGameData)")
                return
            }
            newGame.opponentColor = APIClient.hexStringToUIColor(challengerColor)
            
            
            guard let challengerId = openGameData["challengerId"] as? Int else {
                print("Can't find challengerId in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find challengerId in open games \(openGameData)")
                return
            }
            newGame.opponentId = challengerId
            
            guard let challengerName = openGameData["challengerName"] as? String else {
                print("Can't find challengerName in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find challengerName in open games \(openGameData)")
                return
            }
            newGame.opponentName = challengerName
            
            guard let description = openGameData["description"] as? String else {
                print("Can't find description in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find description in open games \(openGameData)")
                return
            }
            newGame.description = description
            
            guard let gameId = openGameData["gameId"] as? Int else {
                print("Can't find gameId in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find gameId in open games \(openGameData)")
                return
            }
            newGame.id = gameId

            guard let targetWins = openGameData["gameId"] as? Int else {
                print("Can't find targetWins in open games \(openGameData)")
                completionHandler(gameSummaries: nil, success: false, message: "Can't find targetWins in open games \(openGameData)")
                return
            }
            newGame.targetWins = targetWins

            // Victim button can be unspecified
            if let victimButton = openGameData["victimButton"] as? String  {
                newGame.myButton = victimButton
            } else {
                newGame.myButton = ""
            }
         
            games.append(newGame)
        }
        
        completionHandler(gameSummaries: games, success: true, message: nil)
        return
        
    }
    
    // MARK: - Dismissing
    func dismissGame(gameId: Int, completionHandler: (success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "dismissGame",
            "gameId": String(gameId)
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            completionHandler(success: success, message: message)
            return
        }
    }
 
    // MARK: - Logins
    
    // Check if we're logged in, if not then log in.
    func loginIfNeeded(username: String, password: String, completionHandler: (success: Bool, message: String?) -> Void) {
        let jsonBody : [String:String] = [
            "type": "loadPlayerName",
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            // If this call succeeds, we must be logged in. We don't care about the actual values returned - only the success.
            if success {
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                let username = appDelegate!.appSettings.username

                if let newUsername = result!["userName"] as? String {
                    if username.caseInsensitiveCompare(newUsername) == NSComparisonResult.OrderedSame {
                        // Same person. All good.
                        completionHandler(success: true, message: message)
                        return
                    } else {
                        // Wrong user is logged in. Do the login again.
                        debugPrint("User logged in is \(newUsername), current user is \(username) - logging new user in now.")
                        self.login(username, password: password) { success, message in
                            completionHandler(success: success, message: message)
                            return
                        }
                    }
                }
            } else {
                self.login(username, password: password) { success, message in
                    completionHandler(success: success, message: message)
                    return
                }
            }
        }
    }

    // Note: More polite to only log in when necessary, max of 6 clients from one player can be logged in at once. Use loginIfNeeded instead of this.
    func login(username: String, password: String, completionHandler: (success: Bool, message: String?) -> Void) {
       
        let jsonBody : [String:String] = [
            "type": "login",
            "username": username,
            "password": password
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            // No result expected for login
            completionHandler(success: success, message: message)
            return
        }
    }

    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.successor())
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}