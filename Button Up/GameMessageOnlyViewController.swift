//
//  GameMessageOnlyViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 8/12/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class GameMessageOnlyViewController: UIViewController {

    // Passed in from segue
    var message: String?
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messageLabel.text = self.message!
    }

}
