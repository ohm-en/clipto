//
//  ClipboardUtility.swift
//  clipto
//
//  Created by Chef on 2/27/24.
//

import AppKit

func getClipboard() -> String {
    return NSPasteboard.general.string(forType: .string) ?? ""
}

func setClipboard(_ string: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
}
