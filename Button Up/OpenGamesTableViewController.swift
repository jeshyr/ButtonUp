//
//  OpenGamesTableViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 11/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class OpenGamesTableViewController: UITableViewController {

    let cellReuseIdentifier = "OpenGamesTableCell"
    
    @IBOutlet var gameTableView: UITableView!
    
    let client = APIClient.sharedInstance()
    var games: [GameSummary] = [GameSummary]()
    
    override func viewDidLoad() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("reloadTableData"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        reloadTableData()
    }
    
    func reloadTableData() {
        client.loadOpenGames() { openGames, success, error in
            if success {
                print("success loading open games")
                self.games = openGames!
                dispatch_async(dispatch_get_main_queue()) {
                    self.gameTableView.reloadData()
                }
            } else {
                print("Error loading open games: \(error)")
            }
        }
        
        refreshControl?.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        let game = games[indexPath.row]
        
        cell.textLabel!.text = "\(game.myButton) vs. \(game.opponentButton)"
        cell.detailTextLabel!.text = game.description
        
        return(cell)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the open game detail view */
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OpenGameDetailViewController") as! OpenGameDetailViewController
//        controller.gameSummary = games[indexPath.row]
//        self.navigationController!.pushViewController(controller, animated: true)
    }

}