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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Active Game"
        //self.navigationItem.backBarButtonItem!.title = "Back"
    }
    
}