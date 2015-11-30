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
        
        // Preload existing values into text fields
        usernameText.text = appDelegate.appSettings.username
        passwordText.text = appDelegate.appSettings.password

    }
    
    @IBAction func saveButtonTouchUp(sender: AnyObject) {
        // TODO should check for blanks here and other obvious errors
        
        print("Username is: \(usernameText.text)")
        print("Password is: \(passwordText.text)")
        
        let username = usernameText.text!
        let password = passwordText.text!
        
        appDelegate.appSettings.username = username
        appDelegate.appSettings.password = password
        
        appDelegate.appSettings.save()
        appDelegate.resetAppToFirstController()
    }
}
