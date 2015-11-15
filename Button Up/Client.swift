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
    
    func loadGameData(gameId: Int, completionHandler: (game: Game?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadGameData",
            "game": "\(gameId)"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            
            guard success else {
                print("error: \(message)")
                completionHandler(game: nil, success: false, message: message)
                return
            }
            
            print(result)
            var newGame = Game()

            guard let activePlayerIndexObj = result!["activePlayerIdx"] else {
                print("Can't find activePlayerIdx: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find activePlayerIdx: \(result)")
                return
            }
            if let activePlayerIndex = activePlayerIndexObj as? Int? {
                newGame.activePlayerIndex = activePlayerIndex
            } else {
                newGame.activePlayerIndex = nil
            }
            
            guard let currentPlayerIndex = result!["currentPlayerIdx"] as! Int? else {
                print("Can't find currentPlayerIdx: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find currentPlayerIdx: \(result)")
                return
            }
            newGame.currentPlayerIndex = currentPlayerIndex

            guard let description = result!["description"] as! String? else {
                print("Can't find description: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find description: \(result)")
                return
            }
            newGame.description = description
            
            guard let gameActionLog = result!["gameActionLog"] as! [[String: AnyObject]]? else {
                print("Can't find gameActionLog: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find gameActionLog: \(result)")
                return
            }
            newGame.actionLog = self.parseGameLog(gameActionLog)
            
            guard let chatEditable = result!["gameChatEditable"] as! Double? else {
                print("Can't find gameChatEditable: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find gameChatEditable: \(result)")
                return
            }
            newGame.chatEditable = NSDate(timeIntervalSince1970: chatEditable)
            
            guard let gameChatLog = result!["gameChatLog"] as! [[String: AnyObject]]? else {
                print("Can't find gameChatLog: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find gameChatLog: \(result)")
                return
            }
            newGame.chatLog = self.parseGameLog(gameChatLog)
            
            guard let gameId = result!["gameId"] as! Int? else {
                print("Can't find gameId: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find gameId: \(result)")
                return
            }
            newGame.id = gameId
           
            guard let gameSkillsInfoDictionaryObj = result!["gameSkillsInfo"] else {
                print("Can't find gameSkillsInfo: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find gameSkillsInfo: \(result)")
                return
            }
            if let gameSkillsInfoDictionary = gameSkillsInfoDictionaryObj as? [String: AnyObject]? {
                for (skill, skillDictionary) in gameSkillsInfoDictionary! {
                    var newButtonSkill = GameButtonSkillInfo()
                    newButtonSkill.name = skill

                    newButtonSkill.code = skillDictionary["code"] as! String
                    newButtonSkill.description = skillDictionary["description"] as! String
                    // TODO find an example of a button with interactions
                    // newButtonSkill.interactions =
                    
                    newGame.skillsInfo.append(newButtonSkill)
                }
            }
            
            guard let gameState = result!["gameState"] as! String? else {
                print("Can't find gameState: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find gameState: \(result)")
                return
            }
            guard let validState = GameState(rawValue: gameState) else {
                print("Invalid game state: \(gameState) in  \(result)")
                completionHandler(game: nil, success: false, message: "Invalid game state: \(gameState) in  \(result)")
                return
            }
            newGame.state = validState
            
            guard let maxWins = result!["maxWins"] as! Int? else {
                print("Can't find maxWins: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find maxWins: \(result)")
                return
            }
            newGame.maxWins = maxWins
            
            guard let playerDataArray = result!["playerDataArray"] as! [[String: AnyObject]]? else {
                print("Can't find playerDataArray: \(result)")
                completionHandler(game: nil, success: false, message: "Can't find playerDataArray: \(result)")
                return
            }
            newGame.playerData = self.parseGamePlayerData(playerDataArray) { game, success, message in
                completionHandler(game: game, success: success, message: message)
            }

            completionHandler(game: newGame, success: true, message: nil)
        }
    }
    
    func parseGamePlayerData(playerDataDictionaryArray: [[String: AnyObject]], completionHandler: (game: Game?, success: Bool, message: String?) -> Void) -> [GamePlayerData] {
        var playerDataArray = [GamePlayerData]()
        
        for playerDataDictionary in playerDataDictionaryArray {
            var newPlayerData = GamePlayerData()

            
            guard let activeDieArray = playerDataDictionary["activeDieArray"] as! [[String: AnyObject]]? else {
                
                print("Can't find activeDieArray: \(playerDataDictionary)")
                    completionHandler(game: nil, success: false, message: "Can't find activeDieArray: \(playerDataDictionary)")
                return playerDataArray
            }

            for activeDie in activeDieArray {
                print("---")
                print(activeDie)
                var newDie = Die()
                
                guard let description = activeDie["description"] as! String? else {
                    print("Can't find description: \(activeDie)")
                    completionHandler(game: nil, success: false, message: "Can't find description: \(activeDie)")
                    return playerDataArray
                }
                newDie.description = description
                
                
                guard let recipe = activeDie["recipe"] as! String? else {
                    print("Can't find recipe: \(activeDie)")
                    completionHandler(game: nil, success: false, message: "Can't find recipe: \(activeDie)")
                    return playerDataArray
                }
                newDie.recipe = recipe
                
                guard let value = activeDie["value"] as! Int? else {
                    print("Can't find value: \(activeDie)")
                    completionHandler(game: nil, success: false, message: "Can't find value: \(activeDie)")
                    return playerDataArray
                }
                newDie.value = value
                
                guard let sides = activeDie["sides"] as! Int? else {
                    print("Can't find sides: \(activeDie)")
                    completionHandler(game: nil, success: false, message: "Can't find sides: \(activeDie)")
                    return playerDataArray
                }
                newDie.sides = sides

                
                guard let skills = activeDie["skills"] as! [String]? else {
                    print("Can't find skills: \(activeDie)")
                    completionHandler(game: nil, success: false, message: "Can't find skills: \(activeDie)")
                    return playerDataArray
                }
                newDie.skills = skills

                guard let properties = activeDie["properties"] as! [String]? else {
                    print("Can't find properties: \(activeDie)")
                    completionHandler(game: nil, success: false, message: "Can't find properties: \(activeDie)")
                    return playerDataArray
                }
                for property in properties {
                    guard let validProperty = DieFlag(rawValue: property) else {
                        print("Invalid game property: \(property) in  \(activeDie)")
                        completionHandler(game: nil, success: false, message: "Invalid game property: \(property) in  \(activeDie)")
                        return playerDataArray
                    }
                    newDie.properties.append(validProperty)
                }
                
                // TODO parse subdie arrays for twin die here
                print(newDie)
                
                newPlayerData.activeDice.append(newDie)
            }

          
            
            playerDataArray.append(newPlayerData)
        }
        return playerDataArray
    }
    
    func parseGameLog(gameLogDictionaryArray: [[String: AnyObject]]) -> [GameLogMessage] {
        var newLog = [GameLogMessage]()
        
        for gameLogDictionary in gameLogDictionaryArray {
            var newLogMessage = GameLogMessage()
            
            newLogMessage.message = gameLogDictionary["message"] as! String
            newLogMessage.player = gameLogDictionary["player"] as! String
            // FIXME TIMEZONES
            newLogMessage.timestamp = NSDate(timeIntervalSince1970:gameLogDictionary["timestamp"] as! Double)
            
            newLog.append(newLogMessage)
        }
        return newLog
    }
    
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

    // Completed games are finished but not dismissed - the ones which show up on the game overview page still
    func loadCompletedGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadCompletedGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            //print("in loadCompletedGames completion handler")
            
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            var games = [GameSummary]()
            //print(result)
            
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
            
            //print(games)
            completionHandler(gameSummaries: games, success: true, message: nil)
        }
    }

    func loadActiveGames(completionHandler: (gameSummaries: [GameSummary]?, success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadActiveGames"
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            //print("in loadActiveGames completion handler")
            
            guard success else {
                print("error: \(message)")
                completionHandler(gameSummaries: nil, success: false, message: message)
                return
            }
            
            // Parse dictionary of arrays into array of games
            var games: [GameSummary] = [GameSummary]()
            //print(result)
            
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
            
            //print(games)
            completionHandler(gameSummaries: games, success: true, message: nil)
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