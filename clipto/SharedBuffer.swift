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

class SharedBuffer: ObservableObject, Codable {
    @Published var sharedBuffer: String
    
    enum CodingKeys: CodingKey {
        case sharedBuffer
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sharedBuffer = try container.decode(String.self, forKey: .sharedBuffer)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sharedBuffer, forKey: .sharedBuffer)
    }

    func save(to directory: String = directory, fileName: String = fileName) {
        createDirectoryIfNeeded(at: directory)
        
        securelyAccessURL(for: directory, withKey: userDefaultsBookmarkKey) { permittedURL in
            do {
                if let url = permittedURL {
                    let path = url.appendingPathComponent(fileName)
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(self)
                    try data.write(to: path, options: [.atomicWrite, .completeFileProtection])
                    url.stopAccessingSecurityScopedResource()
                } else {
                    print("Access to the directory was not granted or failed.")
                }
            } catch {
                print("Failed to save: \(error)")
                scheduleNotification(withTitle: "Save Failed", body: "Failed to save your data due to: \(error.localizedDescription)")
            }
        }
    }
    
    func load(from directory: String = directory, fileName: String = fileName) {
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
                let loadedData = try decoder.decode(Self.self, from: data)
                
                DispatchQueue.main.async {
                    self.sharedBuffer = loadedData.sharedBuffer
                }
            } catch {
                print("Failed to load: \(error)")
                scheduleNotification(withTitle: "Load Failed", body: "Failed to load your data due to: \(error.localizedDescription)")
            }
        }
    }
    
    init(sharedBuffer: String = "") {
        self.sharedBuffer = sharedBuffer
        
        KeyboardShortcuts.onKeyUp(for: .copyToShareBuffer) { [self] in
            let clipboard = getClipboard()
            self.sharedBuffer = clipboard
            self.save()
        }
        
        KeyboardShortcuts.onKeyUp(for: .pasteShareBuffer) { [self] in
            load()
            setClipboard(self.sharedBuffer)
        }
    }
}
