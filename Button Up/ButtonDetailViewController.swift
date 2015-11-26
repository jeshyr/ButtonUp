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
    
    // TODO this should reload single button data and re-update the UI because a few things (flavour text, etc.) are only exposed when you load one button at a time
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
        
        self.navigationItem.title = "Button"
        //self.navigationItem.backBarButtonItem!.title = "Back"
        
        if let button = button {
            buttonTitleLabel.text = button.name
            buttonRecipeLabel.text = button.recipe
            if !button.flavor.isEmpty {
                buttonFlavorText.text = button.flavor
            } else {
                buttonFlavorText.text = "(no flavor text)"
            }
        }
        
        if let artFilename = button?.artFilename {
            APIClient.sharedInstance().getImageData(artFilename, completionHandler: { (imageData, success, message) in
                if success {
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.buttonImage.image = image
                        }
                    }
                } else {
                    print("Image request failed:")
                    print(message)
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        if indexPath.section == 0 {
            if indexPath.row < button?.dieSkills.count {
                cell.textLabel!.text = button?.dieSkills[indexPath.row].description
            } else {
                cell.textLabel!.text = "(none)"
            }
        } else {
            if indexPath.row < button?.dieTypes.count {
                cell.textLabel!.text = button?.dieTypes[indexPath.row].name
            } else {
                cell.textLabel!.text = "(none)"
            }
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
                return max((button?.dieSkills.count)!, 1)
        } else {
            return max((button?.dieTypes.count)!, 1)
        }
    }
    

}