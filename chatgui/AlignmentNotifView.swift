//
//  AlignmentNotifView.swift
//  chatgui
//
//  Created by Owen Cheng on 10/22/25.
//
import Foundation
import SwiftUI

struct AlignmentNotifView: View {
    @Binding var visible: Bool
    @Binding var isRelevant: Bool
    @EnvironmentObject var chatManager: ChatManager
    
    var body: some View {
        
        HStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("This message doesn't seem relevant.")
            HStack {
                Button(action: { visible = false; isRelevant = true; chatManager.addChat(Chat(title: "New Chat"))}) {
                    Text("New Chat")
                }
                Button(action: { visible = false; isRelevant = true }) {
                    Text("Dismiss")
                }
            }
        }
        .padding()
        .glassEffect()
    }
}


