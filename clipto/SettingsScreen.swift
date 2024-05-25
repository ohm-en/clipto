//
//  SettingsScreen.swift
//  clipto
//
//  Created by Chef on 2/26/24.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsScreen: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Paste Share Buffer", name: .pasteShareBuffer)
            KeyboardShortcuts.Recorder("Copy To Share Buffer", name: .copyToShareBuffer)
        }
    }
}
