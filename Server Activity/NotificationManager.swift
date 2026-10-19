//
//  NotificationManager.swift
//  Server Activity
//
//  Created by Mason Dehl on 10/19/26.
//
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .authorized, .provisional:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
    
    func sendNotification(players: [String], title: String) async {
        guard await requestAuthorizationIfNeeded() else { return }
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        
        var body: String = ""
        
        players.forEach({ player in
            body += (player + ", ")
        })
        
        body.removeLast()
        body.removeLast()
        
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "player-join-leave", content: content, trigger: nil)
        do {
            try await center.add(request)
        } catch {
            print("Scheduling failed: \(error)")
        }
    }
}
