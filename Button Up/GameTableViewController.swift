//
//  GameTableViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class GameTableViewController: UIViewController {

    let cellReuseIdentifier = "GameTableCell"
    
    @IBOutlet var gameTableView: UITableView!
    let client = ButtonClient.sharedInstance()
    var games: [ButtonGame] = [ButtonGame]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO load list of active games
        client.loadActiveGames() { activeGames, success, error in
            if success {
                self.games = activeGames!
                dispatch_async(dispatch_get_main_queue()) {
                    self.gameTableView.reloadData()
                }
            } else {
                print("oops...")
            }
        }
        
    }
}

extension GameTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        let game = games[indexPath.row]
        
        cell.textLabel!.text = "\(game.myButton) vs. \(game.opponentButton)"
        cell.detailTextLabel!.text = game.description
    
        return(cell)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the game detail view */
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
        controller.game = games[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}