//
//  ButtonDetailViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 14/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class ButtonDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var buttonTitleLabel: UILabel!
    @IBOutlet weak var buttonRecipeLabel: UILabel!
    @IBOutlet weak var buttonFlavorText: UILabel!
    @IBOutlet weak var buttonImage: UIImageView!
    @IBOutlet weak var buttonSkillsTable: UITableView!
    
    let cellReuseIdentifier = "SkillsTableCell"
    
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        if indexPath.section == 0 {
            let dieSkill = button?.dieSkills[indexPath.row]
            cell.textLabel!.text = dieSkill
        } else {
            let dieType = button?.dieTypes[indexPath.row]
            cell.textLabel!.text = dieType
        }

        return(cell)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Die Skills"
        } else {
            return "Die Types"
        }
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let skills = button?.dieSkills {
                return skills.count
            } else {
                return 0
            }
        } else {
            if let types = button?.dieTypes {
                return types.count
            } else {
                return 0
            }
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//
//        // No details for these yet
////        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ButtonDetailViewController") as! ButtonDetailViewController
////        controller.button = buttons[indexPath.row]
////        
////        self.navigationController!.pushViewController(controller, animated: true)
//    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 100
//    }
}