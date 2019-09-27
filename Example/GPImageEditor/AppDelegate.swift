//
//  AppDelegate.swift
//  GPImageEditor
//
//  Created by starfall-9000 on 09/10/2019.
//  Copyright (c) 2019 starfall-9000. All rights reserved.
//

import UIKit
import DTMvvm
import GPImageEditor

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let dependencyManager = DependencyManager.shared
        dependencyManager.registerDefaults()
        GPImageEditorConfigs.dependencyManager = dependencyManager
        GPImageEditorConfigs.apiDomain = "https://staging-api.gapo.vn/sticker/v1.2"
        GPImageEditorConfigs.stickersAPIPath = "/sticker"
        GPImageEditorConfigs.userToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjQ0NTc0In0.eyJpc3MiOiJhcGkuZ2Fwby52biIsImF1ZCI6ImFwaS5nYXBvLnZuIiwianRpIjoiNDQ1NzQiLCJpYXQiOjE1Njk0NzIyOTUsIm5iZiI6MTU2OTQ3MjI5NSwiZXhwIjoxNTcwMDc3MDk1LCJ1aWQiOjQ0NTc0LCJwZXJtaXNzaW9uIjowfQ.pWbKt3pwYb7Bfl0YLOklZB6vt2XAg-5ffDAdga7GYc1bJ3zMHUszjyQxtKywEQxP9OvAAP-bL-aak0h3D9XLXyRAnmIHNRIr9iW06vuj4EgqeVf_XRWf-QKDzL2Ahp96BhP88z3FsJEfK3ywEGCp9cE70NzMsgEHwHrZ_AV97tA"
        
        return true
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

