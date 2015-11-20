//
//  SettingsViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 20/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var appDelegate: AppDelegate!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
    }
    
    @IBAction func saveButtonTouchUp(sender: AnyObject) {
        // TODO should check for blanks here and other obvious errors
        
        print("Username is: \(usernameText.text)")
        print("Password is: \(passwordText.text)")
        
        let username = usernameText.text!
        let password = passwordText.text!
        
        print("app delegate: \(appDelegate)")
        appDelegate.appSettings.username = username
        appDelegate.appSettings.password = password
        
        appDelegate.appSettings.save()
        // TODO should go back to login screen here
        appDelegate.resetAppToFirstController()
    }
    
    
    
}
