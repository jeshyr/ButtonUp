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
    
    let client = ButtonClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        
        let username = "jeshyr"
        let password = "xqEC8wu3VuZcMJ"
        
        loggingInTextLabel.text = "Logging \(username) in ..."
        
        client.login(username, password: password) { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.debugTextLabel.text = "Logged in!"
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                self.displayError("Login error: \(error)")
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

