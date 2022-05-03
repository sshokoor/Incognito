//
//  Peer2PeerChatAppApp.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseDatabase

@main
struct Peer2PeerChatAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
