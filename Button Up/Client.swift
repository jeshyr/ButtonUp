//
//  ButtonConvenience.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

extension APIClient {
    
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

            //print(result)
            var buttons = [Button]()
            
            guard let parsedSetArray = result as! [AnyObject]? else {
                print("Can't find array of buttons in \(result)")
                completionHandler(buttons: nil, success: false, message: "Can't find array of buttons in \(result)")
                return
            }
            
            for parsedSet in parsedSetArray {
                var button = Button()
                
                guard let artFilename = parsedSet["artFilename"] as! String? else {
                    print("Can't find artFilename in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find artFilename in \(parsedSet)")
                    return
                }
                button.artFilename = artFilename
                
                guard let buttonId = parsedSet["buttonId"] as! Int? else {
                    print("Can't find buttonId in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find buttonId in \(parsedSet)")
                    return
                }
                button.id = buttonId
                
                guard let buttonName = parsedSet["buttonName"] as! String? else {
                    print("Can't find buttonName in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find buttonName in \(parsedSet)")
                    return
                }
                button.name = buttonName

                guard let buttonSet = parsedSet["buttonSet"] as! String? else {
                    print("Can't find buttonSet in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find buttonSet in \(parsedSet)")
                    return
                }
                button.setName = buttonSet
                
                guard let dieSkills = parsedSet["dieSkills"] as! [String]? else {
                    print("Can't find dieSkills in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find dieSkills in \(parsedSet)")
                    return
                }
                button.dieSkills = dieSkills
                
                guard let dieTypes = parsedSet["dieTypes"] as! [String]? else {
                    print("Can't find dieTypes in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find dieTypes in \(parsedSet)")
                    return
                }
                button.dieTypes = dieTypes
                
                guard let hasUnimplementedSkill = parsedSet["hasUnimplementedSkill"] as! Bool? else {
                    print("Can't find hasUnimplementedSkill in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find hasUnimplementedSkill in \(parsedSet)")
                    return
                }
                button.hasUnimplementedSkill = hasUnimplementedSkill
                
                guard let isTournamentLegal = parsedSet["isTournamentLegal"] as! Bool? else {
                    print("Can't find isTournamentLegal in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find isTournamentLegal in \(parsedSet)")
                    return
                }
                button.isTournamentLegal = isTournamentLegal
                
                guard let recipe = parsedSet["recipe"] as! String? else {
                    print("Can't find recipe in \(parsedSet)")
                    completionHandler(buttons: nil, success: false, message: "Can't find recipe in \(parsedSet)")
                    return
                }
                button.recipe = recipe
                
                if let tags = parsedSet["tags"] as! [String]? {
                    button.tags = tags
                } else {
                    button.tags = nil
                }

                buttons.append(button)
            }
            
            completionHandler(buttons: buttons, success: true, message: nil)
        }
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
        }
    }


    func loadActiveGames(completionHandler: (games: [Game]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadActiveGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            //print("in loadActiveGames completion handler")
            
            guard success else {
                print("error: \(message)")
                completionHandler(games: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            var games: [Game] = [Game]()
            //print(result)
            
            guard let gameDescriptionArray = result!["gameDescriptionArray"] as! [String]? else {
                print("Can't parse gameDescriptionArray")
                completionHandler(games: nil, success: false, message: "Can't parse gameDescriptionArray: \(result)")
                return
            }
            for description in gameDescriptionArray {
                var newGame = Game()
                newGame.description = description
                games.append(newGame)
            }
            
            guard let gameIdArray = result!["gameIdArray"] as! [Int]? else {
                print("Can't parse gameIdArray")
                completionHandler(games: nil, success: false, message: "Can't parse gameIdArray: \(result)")
                return
            }
            for (index, id) in gameIdArray.enumerate() {
                games[index].id = id
            }
            
            guard let gameStateArray = result!["gameStateArray"] as! [String]? else {
                print("Can't parse gameStateArray")
                completionHandler(games: nil, success: false, message: "Can't parse gameStateArray: \(result)")
                return
            }
            for (index, state) in gameStateArray.enumerate() {
                guard let validState = gameState(rawValue: state) else {
                    print("Invalid game state: \(state) in game \(games[index].id)")
                    completionHandler(games: nil, success: false, message: "Invalid game state: \(state) in game \(games[index].id)")
                    return
                }
                games[index].state = validState
            }
            
            guard let inactivityArray = result!["inactivityArray"] as! [String]? else {
                print("Can't parse inactivityArray")
                completionHandler(games: nil, success: false, message: "Can't parse inactivityArray: \(result)")
                return
            }
            for (index, inactivity) in inactivityArray.enumerate() {
                games[index].inactivity = inactivity
            }
            
            guard let inactivityRawArray = result!["inactivityRawArray"] as! [Int]? else {
                print("Can't parse inactivityRawArray")
                completionHandler(games: nil, success: false, message: "Can't parse inactivityRawArray: \(result)")
                return
            }
            for (index, inactivityRaw) in inactivityRawArray.enumerate() {
                games[index].inactivityRaw = inactivityRaw
            }
            
            guard let isAwaitingActionArray = result!["isAwaitingActionArray"] as! [Int]? else {
                print("Can't parse isAwaitingActionArray")
                completionHandler(games: nil, success: false, message: "Can't parse isAwaitingActionArray: \(result)")
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
                completionHandler(games: nil, success: false, message: "Can't parse myButtonNameArray: \(result)")
                return
            }
            for (index, myButton) in myButtonNameArray.enumerate() {
                games[index].myButton = myButton
            }
            
            guard let nDrawsArray = result!["nDrawsArray"] as! [Int]? else {
                print("Can't parse nDrawsArray")
                completionHandler(games: nil, success: false, message: "Can't parse nDrawsArray: \(result)")
                return
            }
            for (index, draws) in nDrawsArray.enumerate() {
                games[index].draws = draws
            }
            
            guard let nLossesArray = result!["nLossesArray"] as! [Int]? else {
                print("Can't parse nLossesArray")
                completionHandler(games: nil, success: false, message: "Can't parse nLossesArray: \(result)")
                return
            }
            for (index, losses) in nLossesArray.enumerate() {
                games[index].losses = losses
            }
            
            guard let nWinsArray = result!["nWinsArray"] as! [Int]? else {
                print("Can't parse nWinsArray")
                completionHandler(games: nil, success: false, message: "Can't parse nWinsArray: \(result)")
                return
            }
            for (index, wins) in nWinsArray.enumerate() {
                games[index].wins = wins
            }
            
            guard let nTargetWinsArray = result!["nTargetWinsArray"] as! [Int]? else {
                print("Can't parse nTargetWinsArray")
                completionHandler(games: nil, success: false, message: "Can't parse nTargetWinsArray: \(result)")
                return
            }
            for (index, targetWins) in nTargetWinsArray.enumerate() {
                games[index].targetWins = targetWins
            }
            
            guard let opponentButtonNameArray = result!["opponentButtonNameArray"] as! [String]? else {
                print("Can't parse opponentButtonNameArray")
                completionHandler(games: nil, success: false, message: "Can't parse opponentButtonNameArray: \(result)")
                return
            }
            for (index, opponentButton) in opponentButtonNameArray.enumerate() {
                games[index].opponentButton = opponentButton
            }

            guard let opponentColorArray = result!["opponentColorArray"] as! [String]? else {
                print("Can't parse opponentColorArray")
                completionHandler(games: nil, success: false, message: "Can't parse opponentColorArray: \(result)")
                return
            }
            for (index, opponentColor) in opponentColorArray.enumerate() {
                games[index].opponentColor = APIClient.hexStringToUIColor(opponentColor)
            }
            
            guard let playerColorArray = result!["playerColorArray"] as! [String]? else {
                print("Can't parse playerColorArray")
                completionHandler(games: nil, success: false, message: "Can't parse playerColorArray: \(result)")
                return
            }
            for (index, myColor) in playerColorArray.enumerate() {
                games[index].myColor = APIClient.hexStringToUIColor(myColor)
            }
            
            guard let opponentIdArray = result!["opponentIdArray"] as! [Int]? else {
                print("Can't parse opponentIdArray")
                completionHandler(games: nil, success: false, message: "Can't parse opponentIdArray: \(result)")
                return
            }
            for (index, opponentId) in opponentIdArray.enumerate() {
                games[index].opponentId = opponentId
            }
            
            guard let opponentNameArray = result!["opponentNameArray"] as! [String]? else {
                print("Can't parse opponentNameArray")
                completionHandler(games: nil, success: false, message: "Can't parse opponentNameArray: \(result)")
                return
            }
            for (index, opponentName) in opponentNameArray.enumerate() {
                games[index].opponentName = opponentName
            }

            guard let statusArray = result!["statusArray"] as! [String]? else {
                print("Can't parse statusArray")
                completionHandler(games: nil, success: false, message: "Can't parse statusArray: \(result)")
                return
            }
            for (index, status) in statusArray.enumerate() {
                guard let validStatus = gameStatus(rawValue: status) else {
                    print("Invalid game status: \(status) in game \(games[index].id)")
                    completionHandler(games: nil, success: false, message: "Invalid game status: \(status) in game \(games[index].id)")
                    return
                }
                games[index].status = validStatus
            }
            
            //print(games)
            completionHandler(games: games, success: true, message: nil)
        }
    }
   

    func login(username: String, password: String, completionHandler: (success: Bool, message: String?) -> Void) {
        
        let jsonBody : [String:String] = [
            "type": "login",
            "username": username,
            "password": password
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            // print("in login completion handler")
            // No result expected for login
            completionHandler(success: success, message: message)
            
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