//
//  BoardApp.swift
//  Board
//
//  Created by 정호길 on 2022/10/08.
//

import SwiftUI
import GoogleMobileAds
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import AppTrackingTransparency

@main
struct BoardApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase

    @StateObject private var accountModel = AccountModel()
    @StateObject private var boardModel = BoardModel()
    @StateObject private var navigationModel = NavigationModel.shared
    @StateObject private var permissionModel = PermissionsModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(boardModel: boardModel)
                .environmentObject(accountModel)
                .environmentObject(navigationModel)
                .environmentObject(permissionModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()

        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await PermissionsModel.shared.requestNotificationPermission()
        }
        // [END register_for_notifications]
        GADMobileAds.sharedInstance().start()
        
        return true
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - Firebase registration token: \(String(describing: fcmToken))")
        if fcmToken != nil {
            do {
                try KeychainItem(service: "com.semo.board", account: "FirebaseToken").saveItem(fcmToken!)
            } catch let error {
                print("fcm save error: \(error)")
                fatalError()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
                                        -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        //print(notification.request.identifier)
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        //print(userInfo)
        // Change this to your preferred presentation option
        return [[.banner, .badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if userInfo["postId"] != nil {
            let postId = Post.ID(userInfo["postId"] as! String)!

            Task { @MainActor in
                if postId == NavigationModel.shared.path.last {
                    NavigationModel.shared.path.removeLast()
                    for await _ in NavigationModel.shared.objectWillChangeSequence { break }
                }
                NavigationModel.shared.path.append(postId)
                for await _ in NavigationModel.shared.objectWillChangeSequence { break }
            }
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
}
