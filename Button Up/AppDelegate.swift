//
//  AppDelegate.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var appSettings = Settings()
    
    func resetAppToFirstController() {
        debugPrint("resetAppToFirstController called")
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as UIViewController
        self.window?.rootViewController = rootViewController
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Usually this is not overridden. Using the "did finish launching" method is more typical
        
        print("App Delegate: will finish launching")
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        print("App Delegate: did finish launching")
        
        if !appSettings.retreive() {
            // NO username/password is stored - go directly to settings screen
            print("Found no username/password")
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as UIViewController
            self.window?.rootViewController = rootViewController
        }
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("App Delegate: did become active")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        print("App Delegate: will resign active")
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("App Delegate: did enter background")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        print("App Delegate: will enter foreground")
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("App Delegate: will terminate")
    }

}

