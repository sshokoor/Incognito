//
//  TopicView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseDatabase
import iActivityIndicator

struct TopicView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var alertType: AlertTypes = .join
    @State private var showAlert = false
    @State private var goToMessageView = false
    @State private var showLoadingBar = false
    @State private var selectedTopicId = ""
    @State private var selectedTopicTitle = ""
    @State private var selectedSenderId = ""
    let ref: DatabaseReference! = Database.database().reference()
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    enum AlertTypes {
        case join
        case joined
        case error
        case already
    }
    
    var body: some View {
        ZStack {
            VStack {
                NavigationLink(isActive: $goToMessageView) {
                    MessageView(
                        topicId: selectedTopicId,
                        topicTitle: selectedTopicTitle,
                        senderId: selectedSenderId
                    )
                } label: {
                    EmptyView()
                }
                
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        
                        Text("Back")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                }
                VStack {
                    Text("Select Topic")
                        .foregroundColor(.black)
                        .font(.title2)
                        .fontWeight(.bold)
                    Divider()
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(Constant.TOPICS) { topic in
                            TopicSingleView(
                                topicId: topic.id,
                                imageName: topic.imageName,
                                topicTitle: topic.topicTitle,
                                createDate: topic.createDate,
                                color: topic.color,
                                ref: ref
                            )
                                .onTapGesture {
                                    selectedTopicId = topic.id
                                    selectedTopicTitle = topic.topicTitle
                                    checkAlreadyJoined(
                                        topicId: topic.id
                                    )
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if showLoadingBar {
                iActivityIndicator()
                    .style(.arcs(width: 5))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            getAlert()
        }
    }
    
    func getAlert() -> Alert{
        switch(alertType) {
        case .join:
            return Alert(
                title: Text("Do you want to join the topic?"),
                primaryButton: .default(Text("Yes"),
                                        action: {
                                            addUserToTopic(
                                                topicId: selectedTopicId
                                            )
                                        }
                                       ),
                secondaryButton: .cancel()
            )
        case .joined:
            return Alert(
                title: Text("Congratulation"),
                message: Text("You have successful joined the topic"),
                dismissButton: .default(Text("Ok"))
            )
            
        case .error:
            return Alert(
                title: Text("Ooops"),
                message: Text("Facing issue to join topic. try again."),
                dismissButton: .default(Text("Ok"))
            )
        case .already:
            return Alert(
                title: Text("Ooops!"),
                message: Text("You already joined the topic."),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    func addUserToTopic(topicId: String) {
        showLoadingBar = true
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
        
        //Save Data to Database
        ref
            .child("Topics")
            .child(topicId)
            .child(userId)
            .setValue(
                ["userid": userId
                ]
            ) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    showLoadingBar=false
                    alertType = .error
                    showAlert.toggle()
                    
                } else {
                    showLoadingBar = false
                    selectedTopicId = topicId
                    selectedSenderId = userId
                    goToMessageView.toggle()
                }
            }
    }

    func checkAlreadyJoined(topicId: String) {
        showLoadingBar = true
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
        ref
            .child("Topics")
            .child(topicId)
            .queryOrdered(byChild: "userid")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                showLoadingBar = false
                if snapshot.exists() {
                    alertType = .already
                    showAlert.toggle()
                } else {
                    alertType = .join
                    showAlert.toggle()
                }

            })
    }
}

struct TopicView_Previews: PreviewProvider {
    static var previews: some View {
        TopicView()
    }
}

struct TopicSingleView: View {
    
    let topicId: String
    let imageName: String
    let topicTitle: String
    let createDate: String
    let color: Color
    let ref: DatabaseReference
    @State private var joinedBy = "None"
    
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(imageName)
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            Text(topicTitle)
                .font(.headline)
            
            Text(createDate)
                .font(.caption2)
                .foregroundColor(.gray)

        }
        .frame(width: 150, height: 160)
        .background(Color.white)
        .cornerRadius(5)
        .padding()
        .shadow(radius: 5)
    }
}
