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
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Game"
        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        client.loadGameData(gameSummary!.id) { game, success, error in
            if success {
                self.game = game
                //dispatch_async(dispatch_get_main_queue()) {
                //    self.gameTableView.reloadData()
                //}
            } else {
                print("oops...")
            }
        }
    }
    
}