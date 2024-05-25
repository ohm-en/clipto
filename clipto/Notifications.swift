//
//  Notifications.swift
//  clipto
//
//  Created by Chef on 2/27/24.
//

import Foundation
import UserNotifications

func scheduleNotification(withTitle title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Trigger now
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}

func requestNotificationAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notification permission granted.")
        } else if let error = error {
            print("Notification permission error: \(error.localizedDescription)")
        }
    }
}
