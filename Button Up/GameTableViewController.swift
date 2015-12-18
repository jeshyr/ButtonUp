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
    var rejectedGames: [GameSummary] = [GameSummary]()
    
    override func viewDidLoad() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("reloadTableData"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        self.reloadTableData()
        
    }
    
    func reloadTableData() {
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
        
        // Load rejected but not dismissed games
        client.loadRejectedGames() { rejectedGames, success, error in
            if success {
                self.rejectedGames = rejectedGames!
                dispatch_async(dispatch_get_main_queue()) {
                    self.gameTableView.reloadData()
                }
            } else {
                print("Can't load rejected but not dismissed games: \(error)")
            }
        }
        
        refreshControl?.endRefreshing()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        var game = GameSummary()
        if indexPath.section == 0 {
            if indexPath.row < games.count {
                game = games[indexPath.row]
                cell.textLabel!.text = game.title
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
                cell.backgroundColor = UIColor.whiteColor()
            }

        } else if indexPath.section == 1 {
            if indexPath.row < newGames.count {
                game = newGames[indexPath.row]
                cell.textLabel!.text = game.title
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
                cell.backgroundColor = UIColor.whiteColor()

            }
        } else if indexPath.section == 2 {
            if indexPath.row < rejectedGames.count {
                game = rejectedGames[indexPath.row]
                cell.textLabel!.text = game.title
                cell.detailTextLabel!.text = game.description
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            } else {
                cell.textLabel!.text = "(none)"
                cell.detailTextLabel!.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.whiteColor()
            }
        } else {
            if indexPath.row < completedGames.count {
                game = completedGames[indexPath.row]
                cell.textLabel!.text = game.title
                cell.detailTextLabel!.text = game.description
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            } else {
                cell.textLabel!.text = "(none)"
                cell.detailTextLabel!.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.whiteColor()
            }
        }
        
        return(cell)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row < games.count {
                loadGameViewController(games[indexPath.row])
            } else {
                return
            }
            
        } else if indexPath.section == 1 {
            if indexPath.row < newGames.count {
                loadGameViewController(newGames[indexPath.row])
            } else {
                return
            }
            
        } else if indexPath.section == 2 {
            if indexPath.row < rejectedGames.count {
                loadGameViewController(rejectedGames[indexPath.row])
            } else {
                return
            }
        } else {
            if indexPath.row < completedGames.count {
                loadGameViewController(completedGames[indexPath.row])
            } else {
                return
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Active"
        case 1:
            return "New"
        case 2:
            return "Rejected"
        case 3:
            return "Completed"
        default:
            return "Error"
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return max(games.count, 1)
        } else if section == 1 {
            return max(newGames.count, 1)
        } else if section == 2 {
            return max(rejectedGames.count, 1)
        } else {
            return max(completedGames.count, 1)
        }
    }
    
    func loadGameViewController(gameSummary: GameSummary) {
        var controller: UIViewController
        switch gameSummary.state {
        case .START_GAME:
            // The game hasn't started yet
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The game has not started yet."
            
        case .CHOOSE_JOIN_GAME:
            // Waiting for opponent to join game
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseJoinGameViewController") as! ChooseJoinGameViewController
            (controller as! ChooseJoinGameViewController).gameSummary = gameSummary
            
        case .SPECIFY_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(gameSummary.state) and that's not implemented, sorry!"
            print(gameSummary)
            
        case .CHOOSE_AUXILIARY_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(gameSummary.state) and that's not implemented, sorry!"
            print(gameSummary)
            
        case .CHOOSE_RESERVE_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(gameSummary.state) and that's not implemented, sorry!"
            print(gameSummary)
            
        case .REACT_TO_INITIATIVE:
            // Waiting for someone to turn down focus dice
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(gameSummary.state) and that's not implemented, sorry!"
            print(gameSummary)
            
            
        case .START_TURN:
            // Waiting for someone to move
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
            (controller as! GameDetailViewController).gameSummary = gameSummary
            
        case .ADJUST_FIRE_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameAdjustFireViewController") as! GameAdjustFireViewController
            (controller as! GameAdjustFireViewController).gameSummary = gameSummary
            
        case .END_GAME:
            // Games which are finished but not dismissed
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameCompletedViewController") as! GameCompletedViewController
            (controller as! GameCompletedViewController).gameSummary = gameSummary
            
        case .REJECTED:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameRejectedViewController") as! GameRejectedViewController
            (controller as! GameRejectedViewController).gameSummary = gameSummary
            
        case .INVALID:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(gameSummary.state), sorry!"
            
        default:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "There's something wrong with this game - it has an unknown game state."
            print(gameSummary)
        }
        
        let nc = self.navigationController!
        dispatch_async(dispatch_get_main_queue()) {
            nc.pushViewController(controller, animated: true)
        }
    }

    
}