//
//  LogoutView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LogoutView: View {
    
    @Binding var isVisible: Bool
    @State private var isLogout = false
    
    var body: some View {
        VStack {
            NavigationLink(isActive: $isLogout) {
                LoginView()
            } label: {
                EmptyView()
            }
            Text("Logout")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .font(.title)
            
            Text("Are you sure to logout?")
                .foregroundColor(.gray)
                .font(.headline)
            
            HStack(spacing: 20) {
                Button {
                    try? Auth.auth().signOut()
                    
                    let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
                    Messaging.messaging().unsubscribe(fromTopic: userId)
                    
                    UserDefaults.standard.removeObject(forKey: "is_login")
                    UserDefaults.standard.removeObject(forKey: "user_id")
                    UserDefaults.standard.removeObject(forKey: "name")
                    UserDefaults.standard.removeObject(forKey: "email")
                    UserDefaults.standard.removeObject(forKey: "address")
                    UserDefaults.standard.removeObject(forKey: "phone_number")
                    UserDefaults.standard.removeObject(forKey: "gender")
                    UserDefaults.standard.removeObject(forKey: "password")
                    UserDefaults.standard.removeObject(forKey: "dob")
                    UserDefaults.standard.removeObject(forKey: "image")
                    UserDefaults.standard.removeObject(forKey: "user_id")
                    UserDefaults.standard.removeObject(forKey: "is_login")
                    
                    isLogout.toggle()
                } label: {
                    Text("Yes")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 30)
                        .background(Color.red)
                        .cornerRadius(5)
                }
                
                Button {
                    withAnimation {
                        isVisible.toggle()
                    }
                } label: {
                    Text("No")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 30)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                }

            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LogoutView_Previews: PreviewProvider {
    static var previews: some View {
        LogoutView(isVisible: .constant(false))
    }
}
