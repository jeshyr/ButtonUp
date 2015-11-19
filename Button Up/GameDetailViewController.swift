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
    var game: Game?
    var gameSummary: GameSummary?
    let client = APIClient.sharedInstance()
    var p1DieButtons = [DieButton]()
    var p2DieButtons = [DieButton]()
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Game"
        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        client.loadGameData(gameSummary!.id) { game, success, error in
            if success {
                self.game = game
                let p1 = game?.playerData[1]
                let p2 = game?.playerData[0]
                
                // Button Images
                APIClient.sharedInstance().getImageData(p1?.button.artFilename, completionHandler: { (imageData, success, message) in
                    if success {
                        if let image = UIImage(data: imageData!) {
                            dispatch_async(dispatch_get_main_queue()) {
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
                        p1Captured = "Dice captured: " + captured.recipe
                    } else {
                        p1Captured = p1Captured + ", " + captured.recipe
                    }
                }
                if p1Captured.isEmpty {
                    p1Captured = "Dice captured: (none)"
                }
                
                let p2Score = "Score: \(p2!.roundScore) (\(p2!.sideScore))"
                let p2WLT = "W/L/T: \(p2!.wins)/\(p2!.losses)/\(p2!.draws) (\(game!.maxWins))"
                var p2Captured = ""
                for captured in (p2?.capturedDice)! {
                    if p2Captured.isEmpty {
                        p2Captured = "Dice captured: " + captured.recipe
                    } else {
                        p2Captured = p2Captured + ", " + captured.recipe
                    }
                }
                if p2Captured.isEmpty {
                    p2Captured = "Dice captured: (none)"
                }
                
                // Dice
                for die in (p1?.activeDice)! {
                    self.p1DieButtons.append(self.createDieButtonFromDie(die))
                }
                for die in (p2?.activeDice)! {
                    self.p2DieButtons.append(self.createDieButtonFromDie(die))
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.p1View.backgroundColor = p1?.color
                    self.p1NameButton.setTitle("Name: \(p1!.name)", forState: UIControlState.Normal)
                    self.p1ButtonButton.setTitle("Button: \(p1!.button.name)", forState: UIControlState.Normal)

                    self.p1ButtonRecipeTextLabel.text = p1!.button.recipe
                    self.p1ScoreLabel.text = p1Score
                    self.p1WLTLabel.text = p1WLT
                    self.p1CapturedLabel.text = p1Captured
                    for dieButton in self.p1DieButtons {
                        self.p1DieStack.addArrangedSubview(dieButton)
                    }
                    self.p1DieStack.removeArrangedSubview(self.p1DieStack.arrangedSubviews[0])
                    
                    self.p2View.backgroundColor = p2?.color
                    self.p2NameButton.setTitle("Name: \(p2!.name)", forState: UIControlState.Normal)
                    self.p2ButtonButton.setTitle("Button: \(p2!.button.name)", forState: UIControlState.Normal)

                    self.p2ButtonRecipeTextLabel.text = p2!.button.recipe
                    self.p2ScoreLabel.text = p2Score
                    self.p2WLTLabel.text = p2WLT
                    self.p2CapturedLabel.text = p2Captured
                    for dieButton in self.p2DieButtons {
                        self.p2DieStack.addArrangedSubview(dieButton)
                    }
                    self.p2DieStack.removeArrangedSubview(self.p2DieStack.arrangedSubviews[0])

                }
            } else {
                print("oops...")
            }
        }
        
    }
    
    func createDieButtonFromDie(die: Die) -> DieButton {
        let newButton = DieButton()
        if die.properties.contains(DieFlag.Twin) {
            if !die.subDice.isEmpty {
                // subDie array that aren't empty always have two values at least currently
                newButton.setTitle("\(die.subDice[0].value),\(die.subDice[1].value)", forState: UIControlState.Normal)
            } else {
                newButton.setTitle("\(die.value)", forState: UIControlState.Normal)
            }
        } else {
            newButton.setTitle("\(die.value)", forState: UIControlState.Normal)
        }
        return newButton
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
                /* Push the Button detail view */
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ButtonDetailViewController") as! ButtonDetailViewController
                controller.button = buttons![0]
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController!.pushViewController(controller, animated: true)
                }
            } else {
                print("Failed loading button data for \(buttonName) - can't push detail view")
            }
        }
        
    }
    
}