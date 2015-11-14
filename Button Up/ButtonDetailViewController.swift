//
//  ButtonDetailViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 14/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class ButtonDetailViewController: UIViewController {
    
    @IBOutlet weak var buttonTitleLabel: UILabel!
    @IBOutlet weak var buttonRecipeLabel: UILabel!
    @IBOutlet weak var buttonFlavorText: UILabel!
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var buttonSkillsTable: UITableView!
    
    // Passed in from segue
    var button: Button?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Button"
        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        if let button = button {
            buttonTitleLabel.text = button.name
            buttonRecipeLabel.text = button.recipe
            buttonFlavorText.text = "oops..."
        }
    }
    
}