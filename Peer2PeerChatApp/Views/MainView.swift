//
//  MainView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseDatabase
import SDWebImageSwiftUI

struct MainView: View {
    
    @State private var textSearch = ""
    @State private var showLogoutSheet = false
    @State private var messages: [Message] = []
    @State private var image = ""
    let ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 15) {
                    
                    
                    Button {
                        showLogoutSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .rotationEffect(Angle(degrees: -90))
                    }
                    Spacer()
                    NavigationLink {
                        ProfileView()
                    } label: {
                        if image == "https://www.theexpertssolutions.com" {
                        Image("person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        } else {
                            WebImage(url: URL(string: image))
                                .resizable()
                                .placeholder(
                                    Image("user")
                                )
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
                .padding(.vertical,5)
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(
                            width: 15,
                            height: 15
                        )
                        .opacity(0.4)
                        .padding(.leading)
                    TextField("search...", text: $textSearch)
                        .searchable(text: $textSearch, prompt: "")
                                    
                }
                .frame(height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
                .padding(.horizontal)
                
                List {
                    ForEach(searchResults) { message in
                        ZStack {
                            NavigationLink {
                                MessageView(
                                    topicId: message.topicId,
                                    topicTitle: message.topicTitle,
                                    senderId: UserDefaults.standard.string(forKey: "user_id")!
                                )
                            } label: {
                                EmptyView()
                            }
                            .opacity(0)
                            ChatRow(
                                message: message,
                                ref: ref
                            )
                        }
                        
                    }
                    .listRowBackground(Color.white)
                    .listRowSeparator(Visibility.hidden)
                    
                }
                .searchable(text: $textSearch) {
                                ForEach(searchResults) { result in
                                    Text("Are you looking for \(result.topicTitle)?").searchCompletion(result.topicTitle)
                                }
                            }
                .listStyle(.plain)
                
            }
            if messages.count == 0 {
                VStack {
                    Image("sad_emoji")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    Text("No Topic Found")
                        .font(.headline)
                    Text("Tap on ADD button to \njoin the Topic")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top,5)
                }
                .frame(maxHeight: .infinity)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Spacer()
                    NavigationLink {
                        TopicView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.accentColor)
                            .padding()
                    }
                }
            }
            //Logout Sheet
            if showLogoutSheet {
                LogoutView(
                    isVisible: $showLogoutSheet
                )
                    .padding()
                    .transition(.slide)
                    .animation(.spring())
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadJoinedTopics()
            image = UserDefaults.standard.string(forKey: "image") ?? ""
            
        }
    }
    func loadJoinedTopics() {
        messages.removeAll()
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? ""
        for topic in Constant.TOPICS {
            ref
                .child("Topics")
                .child(topic.id)
                .queryOrdered(byChild: "userid")
                .queryEqual(toValue: user_id)
                .observe(.childAdded, with: { (snapshot) in
                    if snapshot.exists() {
                        let messageId = UUID().uuidString
                        messages.append(
                            Message(
                                id: messageId,
                                topicId: topic.id,
                                topicTitle: topic.topicTitle,
                                topicColor: topic.color,
                                topicImage: topic.imageName,
                                userId: "",
                                userName: "",
                                userImage: "",
                                message: "",
                                date: "",
                                time: ""
                            )
                        )
                    }
                    
                })
        }
    }
    var searchResults: [Message] {
           if textSearch.isEmpty {
               return messages
           } else {
               return messages.filter { $0.topicTitle.contains(textSearch) }
           }
       }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct ChatRow: View {
    
    let message: Message
    let ref: DatabaseReference
    @State private var unseenMessages = 0
    @State private var lastMessage = ""
    @State private var lastMessageTime = ""
    @State private var userImage = ""
    
    var body: some View {
        
        VStack {
            HStack {
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                    
                    Circle()
                        .fill(message.topicColor)
                        .frame(width: 50, height: 50)
                        .overlay {
                            Image(message.topicImage)
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .offset(x: -20, y: -20)
                    WebImage(url: URL(string: userImage))
                        .resizable()
                        .placeholder(
                            Image("user")
                        )
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    
                }
                .padding(.vertical, 15)
                .padding(.leading, 5)
                VStack(alignment: .leading, spacing: 5) {
                    Text(message.topicTitle)
                        .font(.headline)
                    Text(lastMessage)
                        .font(.caption)
                        .opacity(0.5)
                }
                Spacer()
                
                VStack(alignment: .center, spacing: 5) {
                    Text(lastMessageTime)
                        .font(.caption)
                        .opacity(0.5)
                    
                    Text("\(unseenMessages)")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(5)
                        .background(unseenMessages==0 ? Color.white: Color.accentColor)
                        .clipShape(Circle())
                    
                }
            }
            Divider()
                .padding(.leading, 70)
        }
        .onAppear {
            let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
            
            // For unseen messages
            var index = 0
            ref
                .child("Unseen")
                .child(message.topicId)
                .child(userId)
                .observe(.childAdded, with: { aaa in
                    if aaa.exists() {
                        index += 1
                        unseenMessages = index
                    }
                })
            // get last message and time
            ref
                .child("Messages")
                .child(message.topicId)
                .observe(.childAdded, with: { snapshot in
                    if snapshot.exists() {
  
                        let restDict = snapshot.value as? NSDictionary
                        let mes = restDict?["message"] as? String ?? ""
                        let userId = restDict?["userId"] as? String ?? ""
                        let time = restDict?["time"] as? String ?? ""
        
                            lastMessage = mes
                            lastMessageTime = time
                            ref
                                .child("Users")
                                .child(userId)
                                .observeSingleEvent(of: .value, with: { (user) in
                                    // Get user value
                                    let val = user.value as? NSDictionary
                                    let user_image = val?["image"] as? String ?? ""
                                    userImage = user_image
                                    
                                })
                            
                        
                    }
                })
            
        }
        
    }
}
