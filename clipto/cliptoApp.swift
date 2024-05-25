//
//  cliptoApp.swift
//  clipto
//
//  Created by Chef on 2/25/24.
//

import SwiftUI

@main
struct cliptoApp: App {    
    @StateObject private var appState = AppState()
    
    init() {
        requestNotificationAuthorization()
    }
    
    var body: some Scene {
        Settings {
            SettingsScreen()
        }
        MenuBarExtra(String(appState.currentNumber), systemImage: "1.circle") {
            SettingsLink {
                Label("Settings", systemImage: "house")
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

final class AppState: ObservableObject {
    var sharedBuffer: SharedBuffer = SharedBuffer()
    @Published var currentNumber: Int
    
    init(currentNumber: Int = 1) {
        self.currentNumber = currentNumber
    }
}
