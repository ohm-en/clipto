//
//  SharedBuffer.swift
//  clipto
//
//  Created by Chef on 2/27/24.
//

import Foundation
import KeyboardShortcuts

let directory = "/Users/Shared/.cache"
let fileName = "ClipToShared.json"
let userDefaultsBookmarkKey = "com.clipTo.sharedFolderBookmark"

struct Buffer: Codable {
  let sharedText: String
}

class SharedBuffer: ObservableObject {
    func save(_ contents: String, to directory: String = directory, fileName: String = fileName, callback: @escaping
    () -> Void) {
        createDirectoryIfNeeded(at: directory)
        let buffer = Buffer(sharedText: contents)
        
        securelyAccessURL(for: directory, withKey: userDefaultsBookmarkKey) { permittedURL in
            do {
                if let url = permittedURL {
                    let path = url.appendingPathComponent(fileName)
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(buffer)
                    try data.write(to: path, options: [.atomicWrite, .completeFileProtection])
                    url.stopAccessingSecurityScopedResource()
                    callback()
                } else {
                    print("Access to the directory was not granted or failed.")
                }
            } catch {
                print("Failed to save: \(error)")
                scheduleNotification(withTitle: "Save Failed", body: "Failed to save your data due to: \(error.localizedDescription)")
            }
        }
    }
    
    func load(from directory: String = directory, fileName: String = fileName, callback: @escaping (_: String) -> Void) {
        securelyAccessURL(for: directory, withKey: userDefaultsBookmarkKey) { permittedURL in
            do {
                guard let url = permittedURL else {
                    return
                }
                
                let fileURL = url.appendingPathComponent(fileName)
                
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    return
                }
                
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let loadedData = try decoder.decode(Buffer.self, from: data)
                
                callback(loadedData.sharedText)
            } catch {
                print("Failed to load: \(error)")
                scheduleNotification(withTitle: "Load Failed", body: "Failed to load your data due to: \(error.localizedDescription)")
            }
        }
    }
    
    init() {
        KeyboardShortcuts.onKeyUp(for: .copyToShareBuffer) { [self] in
            let clipboard = getClipboard()
            self.save(clipboard) {
                scheduleNotification(withTitle: "Set Shared Buffer", body: clipboard)
            }
        }
        
        KeyboardShortcuts.onKeyUp(for: .pasteShareBuffer) { [self] in
            self.load() { sharedBuffer in
                scheduleNotification(withTitle: "Retrieved Shared Buffer", body: sharedBuffer)
                setClipboard(sharedBuffer)
            }
        }
    }
}
