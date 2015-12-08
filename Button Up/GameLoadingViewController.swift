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
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
        }
        
        var controller: UIViewController
        switch game.state {
        case .START_GAME:
            // The game hasn't started yet
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The game has not started yet."
            
        case .CHOOSE_JOIN_GAME:
            // Waiting for opponent to join game
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state) and that's not implemented, sorry!"
            
        case .SPECIFY_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state) and that's not implemented, sorry!"
            
        case .CHOOSE_AUXILIARY_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state) and that's not implemented, sorry!"
            
           
        case .CHOOSE_RESERVE_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state) and that's not implemented, sorry!"
            
        case .REACT_TO_INITIATIVE:
            // Waiting for someone to move
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state) and that's not implemented, sorry!"
            
        case .START_TURN:
            // Waiting for someone to move
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
            (controller as! GameDetailViewController).game = game
            
        case .ADJUST_FIRE_DICE:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state) and that's not implemented, sorry!"
            
        case .END_GAME:
            // Games which are finished but not dismissed
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! GameDetailViewController
            (controller as! GameDetailViewController).game = game
            
        case .REJECTED:
            // Website just takes you to a screen that says "This game is rejected"
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "This game has been rejected."
            
        case .INVALID:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "The current game state is \(game.state), sorry!"
            
        default:
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameMessageOnlyViewController") as! GameMessageOnlyViewController
            (controller as! GameMessageOnlyViewController).message = "There's something wrong with this game - it has an unknown game state."
        }
        
        let nc = self.navigationController!
        dispatch_async(dispatch_get_main_queue()) {
            nc.popViewControllerAnimated(false) // Take ourselves out of the stack
            nc.pushViewController(controller, animated: true)
        }
    }
}

