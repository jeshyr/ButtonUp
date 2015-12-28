//
//  Client-Gameplay.swift
//  Button Up
//
//  Created by Ricky Buchanan on 20/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

// Client functions used for viewing or playing a single game

extension APIClient {

    // MARK: - Load a single game
    func tryLoadingGameData(gameSummary: GameSummary, var loadAttempts: Int, completionHandler: (game: Game?, success: Bool, message: String?) -> Void) {
        if loadAttempts != 0 {
            print("Loading game \(gameSummary.id) ... attempt #\(loadAttempts)")
        }
        
        self.loadGameData(gameSummary.id) { game, success, error in
            if success {
                if let game = game {
                    completionHandler(game: game, success: true, message: nil)
                } else {
                    print("Unknown error loading game data on attempt #\(loadAttempts)")
                    completionHandler(game: nil, success: false, message: "Unknown error loading game data on attempt #\(loadAttempts)")
                }
                
            } else {
                print("Error loading game data: \(error), attempt #\(loadAttempts)")
                loadAttempts += 1
                if loadAttempts < 4 {
                    self.tryLoadingGameData(gameSummary, loadAttempts: loadAttempts) { game, success, message in
                        completionHandler(game: game, success: success, message: message)
                    }
                } else {
                    print("Failed to load game after \(loadAttempts) attempts: giving up.")
                    completionHandler(game: nil, success: false, message: "Failed to load game after \(loadAttempts) attempts: giving up. Error: \(error)")
                }
            }
        }
    }
    
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
            
            if let result = result {
                if let game = self.parseGameData(result as! [String : AnyObject]) {
                    completionHandler(game: game, success: true, message: nil)
                    return
                } else {
                    completionHandler(game: nil, success: false, message: "Failure to parse game data")
                    return
                }
            } else {
                print("no data returned: \(message)")
                completionHandler(game: nil, success: false, message: message)
                return
            }
        }
    }
    
    func parseGameData(data: [String: AnyObject]) -> Game? {
        //print(data)
        var game = Game()
        
        guard let activePlayerIndexObj = data["activePlayerIdx"] else {
            print("Can't find activePlayerIdx: \(data)")
            return nil
        }
        if let activePlayerIndex = activePlayerIndexObj as? Int {
            game.activePlayerIndex = activePlayerIndex
        } else {
            game.activePlayerIndex = nil
        }
        
        guard let currentPlayerIndex = data["currentPlayerIdx"] as? Int else {
            print("Can't find currentPlayerIdx: \(data)")
            return nil
        }
        game.currentPlayerIndex = currentPlayerIndex
        
        guard let description = data["description"] as? String else {
            print("Can't find description: \(data)")
            return nil
        }
        game.description = description
        
        guard let gameActionLog = data["gameActionLog"] as? [[String: AnyObject]] else {
            print("Can't find gameActionLog: \(data)")
            return nil
        }
        game.actionLog = self.parseGameLog(gameActionLog)
        
        guard let chatEditable = data["gameChatEditable"] as? Double else {
            print("Can't find gameChatEditable: \(data)")
            return nil
        }
        game.chatEditable = NSDate(timeIntervalSince1970: chatEditable)
        
        guard let gameChatLog = data["gameChatLog"] as? [[String: AnyObject]] else {
            print("Can't find gameChatLog: \(data)")
            return nil
        }
        game.chatLog = self.parseGameLog(gameChatLog)
        
        guard let gameId = data["gameId"] as? Int else {
            print("Can't find gameId: \(data)")
            return nil
        }
        game.id = gameId
        
        guard let gameSkillsInfoDictionaryObj = data["gameSkillsInfo"] else {
            print("Can't find gameSkillsInfo: \(data)")
            return nil
        }
        game.skillsInfo = self.parseSkills(gameSkillsInfoDictionaryObj)
        
        guard let gameState = data["gameState"] as? String else {
            print("Can't find gameState: \(data)")
            return nil
        }
        guard let validState = GameState(rawValue: gameState) else {
            print("Invalid game state: \(gameState) in  \(data)")
            return nil
        }
        game.state = validState
        
        guard let maxWins = data["maxWins"] as? Int else {
            print("Can't find maxWins: \(data)")
            return nil
        }
        game.maxWins = maxWins
        
        guard let playerDataArray = data["playerDataArray"] as? [[String: AnyObject]] else {
            print("Can't find playerDataArray: \(data)")
            return nil
        }
        
        guard let parsedPlayerData = self.parseGamePlayerDataArray(playerDataArray) else {
            return nil
        }
        game.playerData = parsedPlayerData
        
        if validState.isActive {
            guard let playerWithInitiativeIdx = data["playerWithInitiativeIdx"] as? Int else {
                print("Can't find playerWithInitiativeIdx: \(data)")
                return nil
            }
            game.playerWithInitiativeIndex = playerWithInitiativeIdx
        }
        
        guard let previousGameId = data["previousGameId"] else {
            print("Can't find previousGameId: \(data)")
            return nil
        }
        if let previousGameIdInt = previousGameId as? Int {
            game.previousGameId = previousGameIdInt
        }
        
        guard let roundNumber = data["roundNumber"] as? Int else {
            print("Can't find roundNumber: \(data)")
            return nil
        }
        game.round = roundNumber
        
        guard let timestamp = data["timestamp"] as? Double else {
            print("Can't find timestamp: \(data)")
            return nil
        }
        //newGame.timestamp = NSDate(timeIntervalSince1970:timestamp)
        game.timestamp = String(format: "%.0f", timestamp)
        
        guard let validAttackTypeArray = data["validAttackTypeArray"] as? [String] else {
            print("Can't find validAttackTypeArray: \(data)")
            return nil
        }
        for validAttackType in validAttackTypeArray {
            guard let validValidAttackType = Attack(rawValue: validAttackType) else {
                print("Invalid attack type: \(validAttackType) in  \(validAttackTypeArray)")
                return nil
            }
            game.validAttacks.append(validValidAttackType)
        }
        
        // Sort the array so that if our user is one of the players they are always the first member. This simplifies display code.
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let username = appDelegate!.appSettings.username
        
        if username.caseInsensitiveCompare(game.playerData[1].name) == NSComparisonResult.OrderedSame {
            // Our user is second in the array - flip it (always two players)
            game.playerData = game.playerData.reverse()
            
            // Then reverse all the things that point to the playerData array
            if game.activePlayerIndex == 1 {
                game.activePlayerIndex = 0
            } else if game.activePlayerIndex == 0 {
                game.activePlayerIndex = 1
            }
            if game.currentPlayerIndex == 1 {
                game.currentPlayerIndex = 0
            } else if game.currentPlayerIndex == 0 {
                game.currentPlayerIndex = 1
            }
            if game.playerWithInitiativeIndex == 1 {
                game.playerWithInitiativeIndex = 0
            } else if game.playerWithInitiativeIndex == 0 {
                game.playerWithInitiativeIndex = 1
            }
            
            // And tell the interface we did
            game.playerDataFlipped = true
        }
        return game
    }
    
    func parseGamePlayerDataArray(playerDataDictionaryArray: [[String: AnyObject]]) -> [GamePlayerData]? {
        var playerDataArray = [GamePlayerData]()
        
        for playerDataDictionary in playerDataDictionaryArray {
            var newPlayerData = GamePlayerData()
            
            guard let activeDieArray = playerDataDictionary["activeDieArray"] as! [[String: AnyObject]]? else {
                print("Can't find activeDieArray: \(playerDataDictionary)")
                return nil
            }
            for activeDie in activeDieArray {
                if let newDie = self.parseDieData(activeDie) {
                    newPlayerData.activeDice.append(newDie)
                } else {
                    print("Can't parse active die data: \(activeDie)")
                    return nil
                }
            }
            
            guard let buttonData = playerDataDictionary["button"] as! [String: AnyObject]? else {
                print("Can't find button: \(playerDataDictionary)")
                return nil
            }
            
            guard let artFilename = buttonData["artFilename"] as! String? else {
                print("Can't find artFilename: \(buttonData)")
                return nil
            }
            newPlayerData.button.artFilename = artFilename
            
            guard let name = buttonData["name"] as! String? else {
                print("Can't find name: \(buttonData)")
                return nil
            }
            newPlayerData.button.name = name
            
            guard let recipe = buttonData["recipe"] as! String? else {
                print("Can't find recipe: \(buttonData)")
                return nil
            }
            newPlayerData.button.recipe = recipe
            
            guard let canStillWin = playerDataDictionary["canStillWin"] else {
                print("Can't find canStillWin: \(playerDataDictionary)")
                return nil
            }
            if let canStillWinBool = canStillWin as? Bool {
                newPlayerData.canStillWin = canStillWinBool
            }
            
            guard let capturedDieArray = playerDataDictionary["capturedDieArray"] as! [[String: AnyObject]]? else {
                print("Can't find capturedDieArray: \(playerDataDictionary)")
                return nil
            }
            for capturedDie in capturedDieArray {
                if let newDie = self.parseDieData(capturedDie) {
                    newPlayerData.capturedDice.append(newDie)
                } else {
                    print("Can't parse captured die data: \(capturedDie)")
                    return nil
                }
            }
            
            guard let gameScoreArray = playerDataDictionary["gameScoreArray"] as! [String: Int]? else {
                print("Can't find gameScoreArray: \(playerDataDictionary)")
                return nil
            }
            guard let gameScoreD = gameScoreArray["D"] else {
                print("Can't find D: \(gameScoreArray)")
                return nil
            }
            newPlayerData.draws = gameScoreD
            
            guard let gameScoreL = gameScoreArray["L"] else {
                print("Can't find L: \(gameScoreArray)")
                return nil
            }
            newPlayerData.losses = gameScoreL
            
            guard let gameScoreW = gameScoreArray["W"] else {
                print("Can't find W: \(gameScoreArray)")
                return nil
            }
            newPlayerData.wins = gameScoreW
            
            guard let hasDismissedGame = playerDataDictionary["hasDismissedGame"] as! Bool? else {
                print("Can't find hasDismissedGame: \(playerDataDictionary)")
                return nil
            }
            newPlayerData.hasDismissedGame = hasDismissedGame
            
            guard let lastActionTime = playerDataDictionary["lastActionTime"] as! Double? else {
                print("Can't find lastActionTime: \(playerDataDictionary)")
                return nil
            }
            newPlayerData.lastActionTime = NSDate(timeIntervalSince1970:lastActionTime)
            
            guard let outOfPlayDieArray = playerDataDictionary["outOfPlayDieArray"] as! [[String: AnyObject]]? else {
                print("Can't find outOfPlayDieArray: \(playerDataDictionary)")
                return nil
            }
            for outOfPlayDie in outOfPlayDieArray {
                if let newDie = self.parseDieData(outOfPlayDie) {
                    newPlayerData.outOfPlayDice.append(newDie)
                } else {
                    print("Can't parse out of play die data: \(outOfPlayDie)")
                    return nil
                }
            }
            
            guard let playerColor = playerDataDictionary["playerColor"] as! String? else {
                print("Can't find playerColor: \(playerDataDictionary)")
                return nil
            }
            newPlayerData.color = APIClient.hexStringToUIColor(playerColor)
            
            // Open games have missing playerId and playerName
            if let playerId = playerDataDictionary["playerId"] as? Int {
                newPlayerData.id = playerId
            }
            
            if let playerName = playerDataDictionary["playerName"] as? String {
                newPlayerData.name = playerName
            }
            
            guard let optRequestArray = playerDataDictionary["optRequestArray"] else {
                print("Can't find optRequestArray: \(playerDataDictionary)")
                return nil
            }
            if let optRequests = optRequestArray as? [String:[String]] {
                for (key, valueArray) in optRequests {
                    let keyInt = Int(key)!
                    for value in valueArray {
                        let valueInt = Int(value)!
                        if newPlayerData.optRequests[keyInt] == nil {
                            newPlayerData.optRequests[keyInt] = [valueInt]
                        } else {
                            newPlayerData.optRequests[keyInt]!.append(valueInt)
                        }
                    }
                }
            }
            // print("optRequests: \(newPlayerData.optRequests)")
            
            // TODO check parsing of PrevOptValues in more situations
            guard let prevOptValueArray = playerDataDictionary["prevOptValueArray"] else {
                
                print("Can't find prevOptValueArray: \(playerDataDictionary)")
                return nil
            }
            if let prevOptRequests = prevOptValueArray as? [String:[String]] {
                for (key, valueArray) in prevOptRequests {
                    let keyInt = Int(key)!
                    for value in valueArray {
                        let valueInt = Int(value)!
                        if newPlayerData.prevOptValues[keyInt] == nil {
                            newPlayerData.prevOptValues[keyInt] = [valueInt]
                        } else {
                            newPlayerData.prevOptValues[keyInt]!.append(valueInt)
                        }
                    }
                }
            } else if let prevOptRequests = prevOptValueArray as? [[String]] {
                for (keyInt, valueArray) in prevOptRequests.enumerate() {
                    for value in valueArray {
                        let valueInt = Int(value)!
                        if newPlayerData.prevOptValues[keyInt] == nil {
                            newPlayerData.prevOptValues[keyInt] = [valueInt]
                        } else {
                            newPlayerData.prevOptValues[keyInt]!.append(valueInt)
                        }
                    }
                }
            }
            
            guard let prevSwingValueArray = playerDataDictionary["prevSwingValueArray"]  else {
                print("Can't find prevSwingValueArray: \(playerDataDictionary)")
                return nil
            }
            if let prevSwingRequestDictionary = prevSwingValueArray as? [String: AnyObject] {
                if let newPrevSwingRequests = parseSwingDieData(prevSwingRequestDictionary) {
                    newPlayerData.prevSwingValues = newPrevSwingRequests
                } else {
                    print("Can't parse prev swing die data: \(prevSwingRequestDictionary)")
                    return nil
                }
            }
            
            guard let roundScoreRaw = playerDataDictionary["roundScore"]  else {
                print("Can't find roundScore: \(playerDataDictionary)")
                return nil
            }
            // Games that haven't started have nil as their API roundScore
            if let roundScore = roundScoreRaw as? Int {
                newPlayerData.roundScore = roundScore
            }
            
            guard let sideScoreRaw = playerDataDictionary["sideScore"]  else {
                print("Can't find sideScore: \(playerDataDictionary)")
                return nil
            }
            // Games that haven't started have nil as their API sideScore
            if let sideScore = sideScoreRaw as? Int {
                newPlayerData.sideScore = sideScore
            }
            
            guard let swingRequests = playerDataDictionary["swingRequestArray"]  else {
                print("Can't find swingRequestArray: \(playerDataDictionary)")
                return nil
            }
            if let swingRequestDictionary = swingRequests as? [String: AnyObject] {
                if let newSwingRequests = parseSwingDieData(swingRequestDictionary) {
                    newPlayerData.swingRequests = newSwingRequests
                } else {
                    print("Can't parse swing requests: \(swingRequestDictionary)")
                    return nil
                }
            }
            
            guard let waitingOnAction = playerDataDictionary["waitingOnAction"] as! Bool? else {
                print("Can't find waitingOnAction: \(playerDataDictionary)")
                return nil
            }
            newPlayerData.waitingOnAction = waitingOnAction
            
            playerDataArray.append(newPlayerData)
        }
        
        return playerDataArray
        
    }
    
    func parseDieData(dieData: [String: AnyObject]) -> Die? {
        var newDie = Die()
        var isTwinDie = false
        
        /* Required parameters */
        guard let recipe = dieData["recipe"] as! String? else {
            print("Can't find recipe: \(dieData)")
            return nil
        }
        newDie.recipe = recipe
        
        guard let properties = dieData["properties"] as! [String]? else {
            print("Can't find properties: \(dieData)")
            return nil
        }
        for property in properties {
            guard let validProperty = Flag(rawValue: property) else {
                print("Invalid die flag: \(property) in  \(dieData)")
                return nil
            }
            if validProperty == Flag.Twin {
                isTwinDie = true
            }
            newDie.properties.append(validProperty)
        }
        
        /* Optional values */
        guard let sidesRaw = dieData["sides"] else {
            print("Can't find sides: \(dieData)")
            return nil
        }
        // Swing die with unchosen values won't have a number of sides
        if let sides = sidesRaw as? Int {
            newDie.sides = sides
        }
        
        // Nothing has a value until the game starts
        if let value = dieData["value"] as? Int {
            newDie.value = value
        } else {
            newDie.value = 0
        }
        
        if let description = dieData["description"] as! String? {
            newDie.text = description
        }
        
        if let skills = dieData["skills"] as! [String]? {
            for skill in skills {
                newDie.skills.append(Skill(skill: skill)!)
            }
        }
        
        if isTwinDie {
            if let subDieArray = dieData["subdieArray"] as! [[String: Int]]? {
                for subDie in subDieArray {
                    var newSubDie = DieSubDie()
                    newSubDie.sides = subDie["sides"]!
                    newSubDie.value = subDie["value"]!
                    newDie.subDice.append(newSubDie)
                }
            }
        }
        
        return newDie
    }
    
    func parseSwingDieData(dieDataDictionary: [String: AnyObject]) -> [DieSwing]? {
        var newDice = [DieSwing]()
        
        for (name, values) in dieDataDictionary {
            var newDie = DieSwing()
            newDie.swingType = name
            if var valueArray = values as? [Int] {
                newDie.min = valueArray[0]
                newDie.max = valueArray[1]
            }
            newDice.append(newDie)
        }
        
        return newDice
    }
    
    func parseGameLog(gameLogDictionaryArray: [[String: AnyObject]]) -> [GameLogMessage] {
        var newLog = [GameLogMessage]()
        
        for gameLogDictionary in gameLogDictionaryArray {
            var newLogMessage = GameLogMessage()
            
            newLogMessage.message = gameLogDictionary["message"] as! String
            newLogMessage.player = gameLogDictionary["player"] as! String
            newLogMessage.timestamp = NSDate(timeIntervalSince1970:gameLogDictionary["timestamp"] as! Double)
            newLog.append(newLogMessage)
        }
        return newLog
    }
    
    // MARK: - Submit Turn
    
    func submitTurn(game: Game, attackType: Attack, p1DieSelectStatus: [Bool], p2DieSelectStatus: [Bool], completionHandler: (success: Bool, message: String?) -> Void)  {
        // type=submitTurn&game=9027&attackerIdx=1&defenderIdx=0&dieSelectStatus%5BplayerIdx_1_dieIdx_0%5D=false&dieSelectStatus%5BplayerIdx_1_dieIdx_1%5D=true&dieSelectStatus%5BplayerIdx_1_dieIdx_2%5D=false&dieSelectStatus%5BplayerIdx_0_dieIdx_0%5D=false&dieSelectStatus%5BplayerIdx_0_dieIdx_1%5D=true&dieSelectStatus%5BplayerIdx_0_dieIdx_2%5D=false&attackType=Default&chat=&roundNumber=3&timestamp=1450604463
        var jsonBody: [String: String] = [
            "type": "submitTurn",
            "game": String(game.id),
            "roundNumber": String(game.round),
            "timestamp": game.timestamp,
            "attackType": attackType.rawValue,
            "chat": ""
        ]
        
        if game.playerDataFlipped {
            jsonBody["attackerIdx"] = String(1)
            jsonBody["defenderIdx"] = String(0)
        } else {
            jsonBody["attackerIdx"] = String(0)
            jsonBody["defenderIdx"] = String(1)
        }
        
        for (index, selected) in p1DieSelectStatus.enumerate() {
            var prefix = ""
            let suffix = "]"
            if game.playerDataFlipped {
                prefix = "dieSelectStatus[playerIdx_1_dieIdx_"
            } else {
                prefix = "dieSelectStatus[playerIdx_0_dieIdx_"
            }
            jsonBody[prefix + String(index) + suffix] = String(selected)
        }
        for (index, selected) in p2DieSelectStatus.enumerate() {
            var prefix = ""
            let suffix = "]"
            if game.playerDataFlipped {
                prefix = "dieSelectStatus[playerIdx_0_dieIdx_"
            } else {
                prefix = "dieSelectStatus[playerIdx_1_dieIdx_"
            }
            jsonBody[prefix + String(index) + suffix] = String(selected)
        }
        
        debugPrint(jsonBody)
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(success: false, message: message)
                return
            }
            
            completionHandler(success: success, message: nil)
        }
    }
    
    // MARK: - Adjust Fire Dice
    
    func adjustFire(game: Game, action: String, dieIdxArray: [Int], dieValueArray: [Int], completionHandler: (success: Bool, message: String?) -> Void) {
        var jsonBody: [String: String] = [
            "type": "adjustFire",
            "game": String(game.id),
            "roundNumber": String(game.round),
            "timestamp": game.timestamp,
            "action": action // "cancel" or "turndown"
        ]
        
        if action == "turndown" {
            jsonBody["dieIdxArray[]"] = dieIdxArray.map({"\($0)"}).joinWithSeparator(",") // indices of the dice to adjust from the game array
            jsonBody["dieValueArray[]"] = dieValueArray.map({"\($0)"}).joinWithSeparator(",") // new values of those dice
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

}