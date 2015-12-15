//
//  OpenGameDetailViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class OpenGameDetailViewController: UIViewController {
    
    // From seague
    var gameSummary: GameSummary?
    
    var game: Game?
    
    let client = APIClient.sharedInstance()
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var p1View: UIView!
    @IBOutlet weak var p1ButtonImageButton: UIButton!
    @IBOutlet weak var p1ButtonRecipeTextLabel: UILabel!
    @IBOutlet weak var p1ButtonButton: UIButton!
    @IBOutlet weak var p1NameButton: UIButton!
    @IBOutlet weak var p1WLTLabel: UILabel!
    
    @IBOutlet weak var p2View: UIView!
    @IBOutlet weak var p2ButtonImageButton: UIButton!
    @IBOutlet weak var p2ButtonRecipeTextLabel: UILabel!
    @IBOutlet weak var p2ButtonButton: UIButton!
    @IBOutlet weak var p2NameButton: UIButton!
    
    
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(game)
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Open Game"
        
        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        client.tryLoadingGameData(gameSummary!, loadAttempts: 0) { game, success, message in
            if success {
                self.game = game
                self.displayGame()
            } else {
                print(message)
            }
        }
    }
    
    func displayGame() {
        let game = self.game
        
        let p1 = game?.playerData[0]
        let p2 = game?.playerData[1]
        
        // No joining your own game
        if appDelegate!.appSettings.username.caseInsensitiveCompare(p1!.name) == NSComparisonResult.OrderedSame {
            dispatch_async(dispatch_get_main_queue()) {
                self.joinButton.enabled = false
            }
        }

        // Button Images
        APIClient.sharedInstance().getImageData(p1?.button.artFilename, completionHandler: { (imageData, success, message) in
            if success {
                if let image = UIImage(data: imageData!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.p1ButtonImageButton.imageView?.contentMode = .ScaleAspectFit
                        self.p1ButtonImageButton.imageView?.image = image
                    }
                }
            } else {
                print("Image request failed:")
                print(message)
            }
        })
        if !(p2!.button.artFilename.isEmpty) {
            APIClient.sharedInstance().getImageData(p2?.button.artFilename, completionHandler: { (imageData, success, message) in
                if success {
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.p2ButtonImageButton.imageView?.contentMode = .ScaleAspectFit
                            self.p2ButtonImageButton.imageView?.image = image
                        }
                    }
                } else {
                    print("Image request failed:")
                    print(message)
                }
            })
        }
        
        // Text details of game
        let p1WLT = "Rounds: \(game!.maxWins)"
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.p1View.backgroundColor = p1?.color
            self.p1NameButton.setTitle("Challenger: \(p1!.name)", forState: UIControlState.Normal)
            self.p1ButtonButton.setTitle("Button: \(p1!.button.name)", forState: UIControlState.Normal)
            
            self.p1ButtonRecipeTextLabel.text = p1!.button.recipe
            self.p1WLTLabel.text = p1WLT
            
            self.p2View.backgroundColor = p2?.color
            self.p2NameButton.setTitle("Name: (waiting for opponent)", forState: UIControlState.Normal)
            if p2!.button.name.isEmpty {
                self.p2ButtonButton.setTitle("Button: (any button)", forState: UIControlState.Normal)
                self.p2ButtonRecipeTextLabel.text = "(any button)"
            } else {
                self.p2ButtonButton.setTitle("Button: \(p2!.button.name)", forState: UIControlState.Normal)
                self.p2ButtonRecipeTextLabel.text = p2!.button.recipe
            }
            
        }
    }
    
    @IBAction func joinButtonTouchUp(sender: AnyObject) {
        let id = game!.id
        // If button is not specified, need to prompt user to choose
        
        print("Trying to join \(id)")
        client.joinOpenGame(id, buttonName: nil) { success, message in
            if success {
                print("Success!")
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.navigationController!.popViewControllerAnimated(true)
//                }
            } else {
                print("Failed to join game \(id): \(message).")
            }
        }
    }
    
    @IBAction func nameTouchUp(sender: AnyObject) {
    }
    
    @IBAction func buttonTouchUp(sender: UIButton) {
        var buttonName: String
        let p1 = game?.playerData[1]
        let p2 = game?.playerData[0]
        if (sender == p1ButtonButton) || (sender == p1ButtonImageButton)  {
            buttonName = p1!.button.name
        } else {
            buttonName = p2!.button.name
        }
        client.loadButtonData(nil, buttonName: buttonName) { buttons, success, error in
            if success {
                /* Push the Button detail view onto the button sets tab then display */
                dispatch_async(dispatch_get_main_queue()) {
                    self.tabBarController?.selectedIndex = 2
                    let buttonSetsNavigationController = self.tabBarController?.selectedViewController as! UINavigationController
                    let buttonDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ButtonDetailViewController") as! ButtonDetailViewController
                    buttonDetailViewController.button = buttons![0]
                    buttonSetsNavigationController.pushViewController(buttonDetailViewController, animated:false)
                }
            } else {
                print("Failed loading button data for \(buttonName) - can't push detail view")
            }
        }
        
    }
    
}
