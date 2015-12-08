//
//  GameLoadingViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 8/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class GameLoadingViewController: UIViewController {
    
    // Passed in from segue
    var gameSummary: GameSummary?
    
    let client = APIClient.sharedInstance()
    var appDelegate: AppDelegate!
    
    var loadAttempts = 0

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.tabBarController?.tabBar.hidden = false
        self.navigationItem.title = "Game Loading"

        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        activityIndicator.startAnimating()
        
        tryLoadingGameData()
    }
    
    func tryLoadingGameData() {
        print("Loading ... attempt #\(self.loadAttempts)")
        
        client.loadGameData(gameSummary!.id) { game, success, error in
            if success {
                self.loadAttempts = 0
                
                if let game = game {
                    self.loadGameDetailViewController(game)
                } else {
                    print("Unknown error loading game data on attempt #\(self.loadAttempts)")
                }
                
            } else {
                print("Error loading game data: \(error), attempt #\(self.loadAttempts)")
                self.loadAttempts += 1
                if self.loadAttempts < 4 {
                    self.tryLoadingGameData()
                }
            }
        }
    }

    func loadGameDetailViewController(game: Game) {
        
        self.activityIndicator.stopAnimating()
        /* Push the game detail view */
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
        controller.game = game

        let nc = self.navigationController!
        nc.popViewControllerAnimated(false) // Take ourselves out of the stack
        nc.pushViewController(controller, animated: true)
        
    }
    
    
}

