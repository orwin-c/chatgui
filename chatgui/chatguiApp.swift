//
//  chatguiApp.swift
//  chatgui
//
//  Created by Owen Cheng on 9/7/25.
//

import SwiftUI
import AppKit

@main
struct chatguiApp: App {
    @StateObject private var chatManager = ChatManager()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(chatManager)
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
