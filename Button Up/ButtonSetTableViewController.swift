//
//  ButtonSetTableViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 14/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class ButtonSetTableViewController: UITableViewController {
    
    let cellReuseIdentifier = "ButtonSetTableCell"
    
    var buttons = [Button]()
    var buttonSetName = ""

    @IBOutlet var buttonSetTableView: UITableView!
    
    let client = APIClient.sharedInstance()
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        // TODO load list of active games
        client.loadButtonData(buttonSetName, buttonName: nil) { buttons, success, error in
            if success {
                self.buttons = buttons!
                dispatch_async(dispatch_get_main_queue()) {
                    self.buttonSetTableView.reloadData()
                }
            } else {
                print("oops...")
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        let button = buttons[indexPath.row]
        
        cell.textLabel!.text = button.name
        cell.detailTextLabel!.text = button.recipe
        
        let artFilename = button.artFilename
        APIClient.sharedInstance().getImageData(artFilename, completionHandler: { (imageData, success, message) in
            if success {
                if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.imageView!.image = image
                    }
                }
            } else {
                print("Image request failed:")
                print(message)
            }
        })
        
        return(cell)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the Button detail view */
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ButtonDetailViewController") as! ButtonDetailViewController
        controller.button = buttons[indexPath.row]
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}