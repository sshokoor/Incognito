//
//  ContentView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isNavigationActive = false
    @State private var navigateView = "intro"
    
    var body: some View {
        
        NavigationView {
            NavigationLink(
                isActive: $isNavigationActive
            ) {
                if navigateView == "intro" {
                    IntroScreensView()
                } else if navigateView == "login" {
                    LoginView()
                } else {
                    MainView()
                }
            } label: {
                VStack {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .frame(width: 200, height: 200)
                    Text("Incognito")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue
                    .main
                    .asyncAfter(
                        deadline: .now()+2
                    ) {
                        let is_show_intro_screen = UserDefaults.standard.bool(forKey: "is_show_intro_screen")
                        let is_login = UserDefaults.standard.bool(forKey: "is_login")
                        if is_login {
                            navigateView = "main"
                        } else {
                            if is_show_intro_screen {
                                navigateView = "login"
                            }
                        }
                        isNavigationActive.toggle()
                    }
            }
            
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
