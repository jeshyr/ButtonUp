//
//  GameDetailViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class GameDetailViewController: UIViewController {
    
    // Passed in from segue
    var gameSummary: GameSummary?
    
    var game: Game?
    
    let client = APIClient.sharedInstance()
    var appDelegate: AppDelegate!
    
    var p1DieButtons = [DieView]()
    var p2DieButtons = [DieView]()
    
    @IBOutlet weak var p1View: UIView!
    @IBOutlet weak var p1StackView: UIStackView!
    @IBOutlet weak var p1ButtonImageButton: UIButton!
    @IBOutlet weak var p1ButtonRecipeTextLabel: UILabel!
    @IBOutlet weak var p1ButtonButton: UIButton!
    @IBOutlet weak var p1NameButton: UIButton!
    @IBOutlet weak var p1ScoreLabel: UILabel!
    @IBOutlet weak var p1WLTLabel: UILabel!
    @IBOutlet weak var p1CapturedLabel: UILabel!
    @IBOutlet weak var p1DieStack: UIStackView!
    
    @IBOutlet weak var p2View: UIView!
    @IBOutlet weak var p2StackView: UIStackView!
    @IBOutlet weak var p2ButtonImageButton: UIButton!
    @IBOutlet weak var p2ButtonRecipeTextLabel: UILabel!
    @IBOutlet weak var p2ButtonButton: UIButton!
    @IBOutlet weak var p2NameButton: UIButton!
    @IBOutlet weak var p2ScoreLabel: UILabel!
    @IBOutlet weak var p2WLTLabel: UILabel!
    @IBOutlet weak var p2CapturedLabel: UILabel!
    @IBOutlet weak var p2DieStack: UIStackView!
    
    @IBOutlet weak var beatPeopleUpButton: UIButton!
    
    //MARK: - Lifecycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.tabBarController?.tabBar.hidden = true
        
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

    //MARK: - Game Display
    
    func displayGame() {
        let game = self.game
        
        let p1 = game?.playerData[0]
        let p2 = game?.playerData[1]
        let activePlayerIndex = game!.activePlayerIndex
    
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
        
        // Text details of game
        let p1Score = "Score: \(p1!.roundScore) (\(p1!.sideScore))"
        let p1WLT = "W/L/T: \(p1!.wins)/\(p1!.losses)/\(p1!.draws) (\(game!.maxWins))"
        var p1Captured = ""
        for captured in (p1?.capturedDice)! {
            if p1Captured.isEmpty {
                p1Captured = "Captured: " + captured.description
            } else {
                p1Captured = p1Captured + ", " + captured.description
            }
        }
        if p1Captured.isEmpty {
            p1Captured = "Captured: (none)"
        }
        
        let p2Score = "Score: \(p2!.roundScore) (\(p2!.sideScore))"
        let p2WLT = "W/L/T: \(p2!.wins)/\(p2!.losses)/\(p2!.draws) (\(game!.maxWins))"
        var p2Captured = ""
        for captured in (p2?.capturedDice)! {
            if p2Captured.isEmpty {
                p2Captured = "Captured: " + captured.description
            } else {
                p2Captured = p2Captured + ", " + captured.description
            }
        }
        if p2Captured.isEmpty {
            p2Captured = "Captured: (none)"
        }
        
        // Navigation bar at top
        if activePlayerIndex == 0 {
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationItem.title = "Your Move"
                self.beatPeopleUpButton.enabled = true
            }
        } else if activePlayerIndex == 1 {
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationItem.title = "Their Move"
                self.beatPeopleUpButton.enabled = false
            }
        } else if activePlayerIndex == nil {
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationItem.title = "(Inactive game)"
                self.beatPeopleUpButton.enabled = false
            }
        }
        
        // Delete any old buttons hanging around
        self.p1DieButtons = []
        self.p2DieButtons = []
        
        dispatch_async(dispatch_get_main_queue()) {
            // Dice - if we create these outside the main thread they don't update properly
            for die in (p1?.activeDice)! {
                self.p1DieButtons.append(self.createDieButtonFromDie(die, active: (activePlayerIndex == 0)))
            }
            for die in (p2?.activeDice)! {
                self.p2DieButtons.append(self.createDieButtonFromDie(die, active: (activePlayerIndex == 0)))
            }
            
            self.p1View.backgroundColor = p1?.color
            self.p1NameButton.setTitle("Name: \(p1!.name)", forState: UIControlState.Normal)
            self.p1ButtonButton.setTitle("Button: \(p1!.button.name)", forState: UIControlState.Normal)
            
            self.p1ButtonRecipeTextLabel.text = p1!.button.recipe
            self.p1ScoreLabel.text = p1Score
            self.p1WLTLabel.text = p1WLT
            self.p1CapturedLabel.text = p1Captured
            
            for oldDie in self.p1DieStack.arrangedSubviews {
                self.p1DieStack.removeArrangedSubview(oldDie) // Remove from stack
                oldDie.removeFromSuperview()                  // Kill alltogether
            }
            for dieButton in self.p1DieButtons {
                self.p1DieStack.addArrangedSubview(dieButton)
            }
            
            self.p2View.backgroundColor = p2?.color
            self.p2NameButton.setTitle("Name: \(p2!.name)", forState: UIControlState.Normal)
            self.p2ButtonButton.setTitle("Button: \(p2!.button.name)", forState: UIControlState.Normal)
            
            self.p2ButtonRecipeTextLabel.text = p2!.button.recipe
            self.p2ScoreLabel.text = p2Score
            self.p2WLTLabel.text = p2WLT
            self.p2CapturedLabel.text = p2Captured
            for oldDie in self.p2DieStack.arrangedSubviews {
                self.p2DieStack.removeArrangedSubview(oldDie) // Remove from stack
                oldDie.removeFromSuperview()                  // Kill alltogether
            }
            for dieButton in self.p2DieButtons {
                self.p2DieStack.addArrangedSubview(dieButton)
            }
            
        }
    }
    
    func createDieButtonFromDie(die: Die, active: Bool) -> DieView {
        let newButton = die.asView(active)
        newButton.dieValue.addTarget(self, action: "dieTouchUp:", forControlEvents: .TouchUpInside)
        return newButton
    }
    
    // MARK: - Actions
    
    func dieTouchUp(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    @IBAction func beatPeopleUpTouchUp(sender: AnyObject) {
        var p1DieSelectStatus = [Bool]()
        var p2DieSelectStatus = [Bool]()
        
        for die in self.p1DieButtons {
            if die.dieValue.selected {
                p1DieSelectStatus.append(true)
            } else {
                p1DieSelectStatus.append(false)
            }
        }
        for die in self.p2DieButtons {
            if die.dieValue.selected {
                p2DieSelectStatus.append(true)
            } else {
                p2DieSelectStatus.append(false)
            }
        }
        
        print(p1DieSelectStatus)
        print(p2DieSelectStatus)
        
        client.submitTurn(game!, attackType: Attack.Default, p1DieSelectStatus: p1DieSelectStatus, p2DieSelectStatus: p2DieSelectStatus) { success, message in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController!.popViewControllerAnimated(true)
                }
            } else {
                print("Failed to make move: \(message!)")
            }
        }
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