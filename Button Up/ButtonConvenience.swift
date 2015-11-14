//
//  ButtonConvenience.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

extension ButtonClient {
    
    func loadButtonSetData(buttonSet: String?, completionHandler: (success: Bool, message: String?) -> Void) {
        var jsonBody: [String: String] = [
            "type": "loadButtonSetData"
        ]
        
        if buttonSet != nil {
            jsonBody["buttonSet"] = buttonSet
        }
        
        ButtonClient.sharedInstance().request(jsonBody) { result, success, message in
            print("in loadButtonSetData completion handler")
            
            print(result)
            completionHandler(success: true, message: nil)

        }
    }


    func loadActiveGames(completionHandler: (games: [ButtonGame]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadActiveGames"
        ]
        
        ButtonClient.sharedInstance().request(jsonBody) { result, success, message in
            //print("in loadActiveGames completion handler")
            
            guard success else {
                print("error: \(message)")
                completionHandler(games: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            var games: [ButtonGame] = [ButtonGame]()
            //print(result)
            
            guard let gameDescriptionArray = result!["gameDescriptionArray"] as! [String]? else {
                print("Can't parse gameDescriptionArray")
                completionHandler(games: nil, success: false, message: "Can't parse gameDescriptionArray: \(result)")
                return
            }
            for description in gameDescriptionArray {
                var newGame = ButtonGame()
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
                games[index].opponentColor = ButtonClient.hexStringToUIColor(opponentColor)
            }
            
            guard let playerColorArray = result!["playerColorArray"] as! [String]? else {
                print("Can't parse playerColorArray")
                completionHandler(games: nil, success: false, message: "Can't parse playerColorArray: \(result)")
                return
            }
            for (index, myColor) in playerColorArray.enumerate() {
                games[index].myColor = ButtonClient.hexStringToUIColor(myColor)
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
        
        ButtonClient.sharedInstance().request(jsonBody) { result, success, message in
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