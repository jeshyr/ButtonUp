//
//  ViewController.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    let client = ButtonClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let username = "jeshyr"
        let password = "xqEC8wu3VuZcMJ"
        
        client.login(username, password: password) { success, error in
            if success {
                print("Logged in!")
            } else {
                print("login error:")
                print(error)
            }
        }
    }
    
}

