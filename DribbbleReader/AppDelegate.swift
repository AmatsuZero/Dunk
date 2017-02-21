//
//  AppDelegate.swift
//  DribbbleReader
//
//  Created by naoyashiga on 2015/05/17.
//  Copyright (c) 2015年 naoyashiga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


        // Sets background to a blank/empty image
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        // Sets shadow (line below the bar) to a blank image
//        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
//        UINavigationBar.appearance().backgroundColor = UIColor.navigationBarBackgroundColor()

        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        //add 3D Touch Share
        if #available(iOS 9.0, *) {
            let share: UIApplicationShortcutIcon = UIApplicationShortcutIcon.init(type: .share)
            let shareLink: UIApplicationShortcutItem = UIApplicationShortcutItem.init(type: "share", localizedTitle: "分享", localizedSubtitle: "分享此应用", icon: share, userInfo: ["AppStoreLink":"https://itunes.apple.com/us/app/dunk-for-dribbble/id1003028105?mt=8"])
            UIApplication.shared.shortcutItems = [shareLink]
        } else {
            // Fallback on earlier versions
        }


        return true
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "share":
            if let url = URL.init(string: shortcutItem.userInfo?["AppStoreLink"] as! String) {
                UIApplication.shared.openURL(url)
            }
        default:
            return
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}