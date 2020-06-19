//
//  AppDelegate.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import FBSDKCoreKit
import GoogleSignIn
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            let options: UNAuthorizationOptions = [.sound, .badge, .alert]
            
            current.requestAuthorization(options: options) { (granted, error) in
                if error != nil {
                    
                } else {
                    Messaging.messaging().delegate = self
                    current.delegate = self
                    
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let types: UIUserNotificationType = [.sound, .badge, .alert]
            let setting = UIUserNotificationSettings(types: types, categories: nil)
            
            application.registerUserNotificationSettings(setting)
            application.registerForRemoteNotifications()
        }
        
        let viewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let menuViewController = SideMenuViewController()
        let menuNavigationController = SideMenuNavigationController(rootViewController: menuViewController)
        SideMenuManager.default.leftMenuNavigationController = menuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: navigationController.view)
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID

        return true
    }
    
    func application(_ application: UIApplication,open url:URL,sourceApplication: String?,annotation: Any) -> Bool {
        var handled = false
        
        if url.absoluteString.contains("fb") {
            handled = ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            handled = GIDSignIn.sharedInstance()!.handle(url)
        }
        
        
        return handled    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFirebase()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = true
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        connectToFirebase()
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func connectToFirebase() {
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate, MessagingDelegate {
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        
        completionHandler([.sound, .badge, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
    }
}
