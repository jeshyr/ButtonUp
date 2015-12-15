//
//  ChooseJoinGameViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 15/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class ChooseJoinGameViewController: UIViewController {
    
    // From seague
    var gameSummary: GameSummary?
    
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(gameSummary)
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Join Game"
        
        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        self.displayGame()
    }
    
    func displayGame() {
        var p1Button = Button()
        var p2Button = Button()
        
        // Button Images
        client.loadButtonData(nil, buttonName: gameSummary!.myButton) { buttons, success, error in
            if success {
                p1Button = buttons![0]
                self.client.getImageData(p1Button.artFilename) { imageData, success, message in
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
                }
            } else {
                print("Failed to load button data for \(self.gameSummary!.myButton): \(error)")
            }
        }
        
        client.loadButtonData(nil, buttonName: gameSummary!.opponentButton) { buttons, success, error in
            if success {
                p2Button = buttons![0]
                self.client.getImageData(p2Button.artFilename) { imageData, success, message in
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
                }
            } else {
                print("Failed to load button data for \(self.gameSummary!.opponentButton): \(error)")
            }
        }
        
        
        // Text details of game
        let p1WLT = "Rounds: \(gameSummary!.targetWins)"
        
        dispatch_async(dispatch_get_main_queue()) {
            self.p1View.backgroundColor = self.gameSummary!.myColor
            self.p1NameButton.setTitle("Name: \(self.appDelegate!.appSettings.username)", forState: UIControlState.Normal)
            self.p1ButtonButton.setTitle("Button: \(self.gameSummary!.myButton)", forState: UIControlState.Normal)
            
            self.p1ButtonRecipeTextLabel.text = p1Button.recipe
            self.p1WLTLabel.text = p1WLT
            
            self.p2View.backgroundColor = self.gameSummary!.opponentColor
            self.p2NameButton.setTitle("Name: \(self.gameSummary!.opponentName)", forState: UIControlState.Normal)
            self.p2ButtonButton.setTitle("Button: \(self.gameSummary!.opponentButton)", forState: UIControlState.Normal)
            self.p2ButtonRecipeTextLabel.text = p2Button.recipe
        }
    }

    @IBAction func acceptButtonTouchUp(sender: AnyObject) {
        let id = gameSummary!.id
        
        print("Trying to accept \(id)")
        client.acceptNewGame(id, accept: true) { success, message in
            if success {
                print("Success!")
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController!.popViewControllerAnimated(true)
                }
            } else {
                print("Failed to accept game \(id): \(message).")
            }
        }
    }
    
    @IBAction func rejectButtonTouchUp(sender: AnyObject) {
        let id = gameSummary!.id
        
        print("Trying to accept \(id)")
        client.acceptNewGame(id, accept: false) { success, message in
            if success {
                print("Success!")
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController!.popViewControllerAnimated(true)
                }
            } else {
                print("Failed to reject game \(id): \(message).")
            }
        }
    }
    
    @IBAction func nameTouchUp(sender: AnyObject) {
    }
    
    @IBAction func buttonTouchUp(sender: UIButton) {
        var buttonName: String
        if (sender == p1ButtonButton) || (sender == p1ButtonImageButton)  {
            buttonName = (gameSummary?.myButton)!
        } else {
            buttonName = (gameSummary?.opponentButton)!
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
