//
//  UserView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/21/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserView: View {
    
    let users: [User]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                List {
                    ForEach(users) { user in
                        UserRow(
                            user: user
                        )
                    }
                    .listRowBackground(Color.white)
                    .listRowSeparatorTint(Color.white)
                    
                }
                .listStyle(.plain)
            }
            
        }
        .padding()
        .background(Color.white)
        
    }
}


struct UserView_Previews: PreviewProvider {
    @State static var users: [User] = []
    static var previews: some View {
        UserView(
            users: users
        )
    }
}

struct UserRow: View {
    
    let user: User
    
    var body: some View {
        
        VStack {
            HStack {
                WebImage(url: URL(string: user.image))
                    .resizable()
                    .placeholder(
                        Image("user")
                    )
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    //Text(user.email)
                        //.foregroundColor(.black)
                        //.font(.caption)
                        //.multilineTextAlignment(.leading)
                        //.fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            Divider()
                .padding(.leading, 70)
        }
    }
}
