//
//  ButtonConvenience.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

extension ButtonClient {

    func loadActiveGames(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let jsonBody: [String: String] = [
            "type": "loadActiveGames"
        ]
        
        ButtonClient.sharedInstance().request(jsonBody) { result, error in
            print("in loadActiveGames completion handler")
            
            guard error == nil else {
                print("error: \(error)")
                completionHandler(success: false, errorString: error!.description)
                return
            }
            
            guard let status = result!["status"] as! String? else {
                print("Can't parse dictionary")
                completionHandler(success: false, errorString: "Can't parse dictionary: \(result)")
                return
            }
            
            if status == "ok" {
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Can't parse login result: \(result)")
            }
        }
    }
   

    func login(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let jsonBody : [String:String] = [
            "type": "login",
            "username": username,
            "password": password
        ]
        
        ButtonClient.sharedInstance().request(jsonBody) { result, error in
            // print("in login completion handler")
            
            guard error == nil else {
                print("error: \(error)")
                completionHandler(success: false, errorString: error!.description)
                return
            }
            
            guard let status = result!["status"] as! String? else {
                print("Can't parse dictionary")
                completionHandler(success: false, errorString: "Can't parse dictionary: \(result)")
                return
            }
            
            if status == "ok" {
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Can't parse login result: \(result)")
            }
        }
    }

}