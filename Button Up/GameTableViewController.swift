//
//  GameTableViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class GameTableViewController: UITableViewController {

    let cellReuseIdentifier = "GameTableCell"
    
    @IBOutlet var gameTableView: UITableView!
    let client = APIClient.sharedInstance()
    var games: [GameSummary] = [GameSummary]()
    var newGames: [GameSummary] = [GameSummary]()
    var completedGames: [GameSummary] = [GameSummary]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        // load list of active games
        client.loadActiveGames() { activeGames, success, error in
            if success {
                self.games = activeGames!
                dispatch_async(dispatch_get_main_queue()) {
                    self.gameTableView.reloadData()
                }
            } else {
                print("Can't load list of active games: \(error)")
            }
        }
        
        // load list of new games
        client.loadNewGames() { newGames, success, error in
            if success {
                self.newGames = newGames!
                dispatch_async(dispatch_get_main_queue()) {
                    self.gameTableView.reloadData()
                }
            } else {
                print("Can't load list of new games: \(error)")
            }
        }
        
        // Load completed but not dismissed games
        client.loadCompletedGames() { completedGames, success, error in
            if success {
                self.completedGames = completedGames!
                dispatch_async(dispatch_get_main_queue()) {
                    self.gameTableView.reloadData()
                }
            } else {
                print("Can't load completed but not dismissed games: \(error)")
            }
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        var game = GameSummary()
        if indexPath.section == 0 {
            if indexPath.row < games.count {
                game = games[indexPath.row]
                cell.textLabel!.text = "You (\(game.myButton)) vs. \(game.opponentName)(\(game.opponentButton))"
                cell.detailTextLabel!.text = game.description
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
                if game.awaitingAction {
                    cell.backgroundColor = game.myColor
                } else {
                    cell.backgroundColor = game.opponentColor
                }
            } else {
                cell.textLabel!.text = "(none)"
                cell.detailTextLabel!.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
        } else if indexPath.section == 1 {
            if indexPath.row < games.count {
                game = games[indexPath.row]
                cell.textLabel!.text = "You (\(game.myButton)) vs. \(game.opponentName)(\(game.opponentButton))"
                cell.detailTextLabel!.text = game.description
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
                if game.awaitingAction {
                    cell.backgroundColor = game.myColor
                } else {
                    cell.backgroundColor = game.opponentColor
                }
            } else {
                cell.textLabel!.text = "(none)"
                cell.detailTextLabel!.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
        } else {
            if indexPath.row < completedGames.count {
                game = completedGames[indexPath.row]
                cell.textLabel!.text = "\(game.myButton) vs. \(game.opponentButton)"
                cell.detailTextLabel!.text = game.description
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            } else {
                cell.textLabel!.text = "(none)"
                cell.detailTextLabel!.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
        }
        
        return(cell)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var game = GameSummary()

        if indexPath.section == 0 {
            if indexPath.row < games.count {
                game = games[indexPath.row]
                /* Push the game detail view */
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
                controller.gameSummary = game
                self.navigationController!.pushViewController(controller, animated: true)
                
            } else {
                return
            }
            
        } else if indexPath.section == 1 {
            if indexPath.row < newGames.count {
                game = newGames[indexPath.row]
                // TODO - can't view game details for these - fix that
            } else {
                return
            }
            
        } else {
            if indexPath.row < completedGames.count {
                game = completedGames[indexPath.row]
                /* Push the game detail view */
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
                controller.gameSummary = game
                self.navigationController!.pushViewController(controller, animated: true)
                
            } else {
                return
            }
        }


    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Active"
        } else if section == 1 {
            return "New"
        } else {
            return "Completed"
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return max(games.count, 1)
        } else if section == 1 {
            return max(newGames.count, 1)
        } else {
            return max(completedGames.count, 1)
        }
    }
    
}