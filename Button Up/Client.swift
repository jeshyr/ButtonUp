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
                if let newDie = self.parseDieData(capturedDie) {                newPlayerData.capturedDice.append(newDie)
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
    
    // MARK: - Adjust Fire Dice
    
    func adjustFire(gameId: Int, roundNumber: Int, timestamp: String, action: String, completionHandler: (success: Bool, message: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "adjustFire",
            "game": String(gameId),
            "roundNumber": String(roundNumber),
            "timestamp": timestamp,
            "action": action
        ]
        
        APIClient.sharedInstance().request(jsonBody) { result, success, message in
            guard success else {
                print("error: \(message)")
                completionHandler(success: false, message: message)
                return
            }
            
            completionHandler(success: success, message: nil)
        }
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