//
//  PermissionsModel.swift
//  Board
//
//  Created by 정호길 on 2023/03/25.
//

import SwiftUI
import AppTrackingTransparency

final class PermissionsModel: ObservableObject {
    @Published var notificationPermissionGranted = false
    @Published var attPermissionGranted = false
    
    static let shared = PermissionsModel()
    
    private init() {}
    
    func requestNotificationPermission() async {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            
            getNotificationSettings()
        } catch {
            debugPrint("request notification permission error")
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else {
                DispatchQueue.main.async {
                    self.notificationPermissionGranted = false
                }
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                DispatchQueue.main.async {
                    self.notificationPermissionGranted = true
                }
            }
        }
    }
    
    func requestATTPermission() async {
        try? await Task.sleep(for: .seconds(1))
        
        if await ATTrackingManager.requestTrackingAuthorization() == .authorized {
            await MainActor.run {
                self.attPermissionGranted = true
            }
        } else {
            await MainActor.run {
                self.attPermissionGranted = false
            }
        }
    }
}
