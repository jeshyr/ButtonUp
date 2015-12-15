//
//  LoginViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loggingInTextLabel: UILabel!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    var appDelegate: AppDelegate!
    
    let client = APIClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        
        let username = appDelegate.appSettings.username
        let password = appDelegate.appSettings.password
        
        loggingInTextLabel.text = "Logging \(username) in ..."
        
        client.loginIfNeeded(username, password: password) { success, error in
            if success {
                debugPrint("viewWillAppear/loginIfNeeded completion handler")
                dispatch_async(dispatch_get_main_queue(), {
                    self.debugTextLabel.text = "Logged in!"
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                // login failed - assume it's a username/password error
                print("Login failed: \(error)")
                self.displayError("Login error: \(error)")
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        activityIndicator.stopAnimating()
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        })
    }
    
}

