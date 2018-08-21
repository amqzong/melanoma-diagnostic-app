//
//  AppDelegate.swift
//  Created by Amanda Zong on 7/18/17
//  Credits: Camera App Swift Tutorial by Brian Advent (https://www.youtube.com/watch?v=Zv4cJf5qdu0)


import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let appKey = "3arl7p4g4c9zzwa"      // Set your own app key value here.
        let appSecret = "tabey6xlk8v1y5z"   // Set your own app secret value here.
        
        let dropboxSession = DBSession(appKey: appKey, appSecret: appSecret, root: kDBRootDropbox)
        DBSession.setShared(dropboxSession)
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if DBSession.shared().handleOpen(url as URL!) {
            if DBSession.shared().isLinked() {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didLinkToDropboxAccountNotification"), object: nil)
                return true
            }
        }
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

