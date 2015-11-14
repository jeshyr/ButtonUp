//
//  ButtonSetsTableViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 14/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class ButtonSetsTableViewController: UITableViewController {
    
    let cellReuseIdentifier = "ButtonSetsTableCell"
    
    var buttonSets = [ButtonSet]()
    
    let client = APIClient.sharedInstance()
    
    @IBOutlet var buttonSetsTableView: UITableView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false

        // TODO load list of active games
        client.loadButtonSetData(nil) { buttonSets, success, error in
            if success {
                self.buttonSets = buttonSets!
                dispatch_async(dispatch_get_main_queue()) {
                    self.buttonSetsTableView.reloadData()
                }
            } else {
                print("oops...")
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        let buttonSet = buttonSets[indexPath.row]
        
        cell.textLabel!.text = "\(buttonSet.name) (\(buttonSet.numberOfButtons))"
        
        var detailText = ""
        if buttonSet.dieSkills.isEmpty {
            detailText = "(none)"
        } else {
            detailText = buttonSet.dieSkills.joinWithSeparator(", ")
        }
        cell.detailTextLabel!.text = detailText
        
        return(cell)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonSets.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the Button detail view */
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ButtonSetTableViewController") as! ButtonSetTableViewController
        controller.buttonSetName = buttonSets[indexPath.row].name

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}