//
//  FileSystemUtils.swift
//  clipto
//
//  Created by Chef on 2/27/24.
//

import Foundation
import SwiftUI
import AppKit

func createDirectoryIfNeeded(at path: String) {
    let fileManager = FileManager.default
    let directoryURL = URL(fileURLWithPath: path)
    
    if !fileManager.fileExists(atPath: directoryURL.path) {
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error.localizedDescription)")
        }
    }
}

func securelyAccessURL(for directoryPath: String, withKey userDefaultsKey: String, completion: @escaping (URL?) -> Void) {
    if let bookmarkData = UserDefaults.standard.data(forKey: userDefaultsKey) {
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
                requestUserForDirectoryAccess(directoryPath: directoryPath, userDefaultsKey: userDefaultsKey, completion: completion)
            } else {
                if url.startAccessingSecurityScopedResource() {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        } catch {
            print("Error resolving bookmark: \(error)")
            completion(nil)
        }
    } else {
        requestUserForDirectoryAccess(directoryPath: directoryPath, userDefaultsKey: userDefaultsKey, completion: completion)
    }
}

func requestUserForDirectoryAccess(directoryPath: String, userDefaultsKey: String, completion: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.message = "Please grant access to the required directory"
    openPanel.prompt = "Grant Access"
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)

    openPanel.begin { response in
        if response == .OK, let selectedFolder = openPanel.url {
            do {
                let bookmarkData = try selectedFolder.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                UserDefaults.standard.set(bookmarkData, forKey: userDefaultsKey)
                if selectedFolder.startAccessingSecurityScopedResource() {
                    completion(selectedFolder)
                } else {
                    completion(nil)
                }
            } catch {
                print("Failed to save bookmark: \(error)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
}
