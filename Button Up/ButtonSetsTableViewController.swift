//
//  ButtonSetsTableViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 14/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class ButtonSetsTableViewController: UIViewController {
    
    let cellReuseIdentifier = "ButtonSetTableCell"
    
    var buttons = [String]()
    
    let client = ButtonClient.sharedInstance()

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO load list of active games
        client.loadButtonSetData(nil) { success, error in
            if success {
                print("wow...")
                //self.buttons = buttons!
                dispatch_async(dispatch_get_main_queue()) {
                    // self.gameTableView.reloadData()
                }
            } else {
                print("oops...")
            }
        }
        
    }
}

extension ButtonSetsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        let button = buttons[indexPath.row]
        
        cell.textLabel!.text = button
        cell.detailTextLabel!.text = button
        
        return(cell)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the game detail view */
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("GameDetailViewController") as! ButtonDetailViewController
//        controller.button = buttons[indexPath.row]
//        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}