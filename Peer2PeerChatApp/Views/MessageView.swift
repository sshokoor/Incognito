//
//  MessageView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseDatabase
import SDWebImageSwiftUI
import iActivityIndicator

struct MessageView: View {
    
    let topicId: String
    let topicTitle: String
    var senderId: String
    @State private var showToast = false
    @State private var toastMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var textMessage = ""
    @State private var messages: [Message] = []
    @State private var users: [User] = []
    let ref: DatabaseReference! = Database.database().reference()
    @ObservedObject private var keyboard = KeyboardInfo.shared
    @State private var messageDate = ""
    @State private var showLoadingBar = false
    @State private var showSheet = false
    
    var body: some View {
        ZStack {
            VStack {
                personDetailContent
                Divider()
                messageContent
                Spacer()
                Divider()
                messageSendContent
            }
            if messages.count == 0 {
                VStack {
                Image("sad_emoji")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                Text("No Message Found")
                    .font(.headline)
                    Text("share your view about \nthis topic by sending the messages")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top,5)
                }
                .frame(maxHeight: .infinity)
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
        .toast(isPresenting: $showToast){
            
            // `.alert` is the default displayMode
            AlertToast(displayMode: .hud, type: .regular, title: toastMessage)
            
            //Choose .hud to toast alert from the top of the screen
            //AlertToast(displayMode: .hud, type: .regular, title: "Message Sent!")
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            print("Users Sheet Dismissed")
        }, content: {
            UserView(
                users: users
            )
        })
        .onAppear {
            loadMessages()
            forNotification()
            loadTopicJoinedUsers()
        }
        .onDisappear {
            //Remove for notification
            ref
                .child("Users")
                .child(senderId)
                .updateChildValues(["notification": "nil"])
        }
    }
    
    var personDetailContent: some View {
        ZStack {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 20,
                            height: 20
                        )
                        .padding(.leading)
                }
                VStack(alignment: .center, spacing: 5) {
                    Text(topicTitle)
                        .font(.headline)
                        .padding(.leading,2)
                }
                Spacer()
                Menu {
                    Button {
                        leaveTopic()
                    } label: {
                        Image(systemName: "trash")
                        Text("Leave Topic")
                    }
                } label: {
                    Image("dots")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .scaledToFit()
                        .frame(width: 20, height: 40)
                }
                
                
            }
           
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    ForEach(users.indices, id: \.self) {index in
                        if index < 3 {
                        JoinedUsersRow(
                            index: index,
                            users: users
                        )
                        }
                    }
                }
                Text("\(users.count) People >")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .onTapGesture {
                showSheet.toggle()
            }
        }
        .foregroundColor(.black)
    .padding(.vertical, 5)
    }
    var messageSendContent: some View {
        HStack(alignment: .center, spacing: 10) {
            TextField("message...", text: $textMessage)
                .frame(height: 50)
                .padding(.leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(30)
            
            Image(systemName: "paperplane.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 40,
                    height: 40
                )
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 45))
                .onTapGesture {
                    if textMessage.count > 0 {
                        sendMessage(message: textMessage)
                    }
                }
        }
        .padding(.horizontal)
    }
    
    var messageContent: some View {
        ScrollView {
            ScrollViewReader { value in
                ForEach(0..<messages.count, id:\.self) {index in
                    MessageRow(
                        index: index,
                        senderId: senderId,
                        messages: $messages,
                        messageDate: $messageDate
                    )
                        .id(messages[index].id)
                }
                .onChange(of: messages.count) { _ in
                    value.scrollTo(messages.last?.id)
                }
            }
        }
        
    }
    
    func leaveTopic() {
        showLoadingBar = true
        ref
            .child("Topics")
            .child(topicId)
            .child(senderId)
            .removeValue(completionBlock: { (error, refer) in
                if error != nil {
                    toastMessage = error?.localizedDescription ?? "Error"
                    showToast.toggle()
                    showLoadingBar = false
                } else {
                    toastMessage = "Leave Topic Successful"
                    showToast.toggle()
                    showLoadingBar = false
                    presentationMode.wrappedValue.dismiss()
                }
            })
    }
    func loadMessages() {
        messages.removeAll()
        ref
            .child("Messages")
            .child(topicId)
            .observe(.childAdded, with: { (snapshot) in
                    
                    let restDict = snapshot.value as? NSDictionary
                    let message = restDict?["message"] as? String ?? ""
                    let messageId = restDict?["messageId"] as? String ?? ""
                    let userId = restDict?["userId"] as? String ?? ""
                    let time = restDict?["time"] as? String ?? ""
                    let date = restDict?["date"] as? String ?? ""
                    
                    ref
                        .child("Users")
                        .child(userId)
                        .observeSingleEvent(of: .value, with: { (user) in
                            // Get user value
                            let val = user.value as? NSDictionary
                            let name = val?["name"] as? String ?? ""
                            let image = val?["image"] as? String ?? ""
                            
                            messages.append(
                                Message(
                                    id: messageId,
                                    topicId: topicId,
                                    topicTitle: topicTitle,
                                    topicColor: Color(hex: "000000"),
                                    topicImage: "",
                                    userId: userId,
                                    userName: name,
                                    userImage: image,
                                    message: message,
                                    date: date,
                                    time: time
                                )
                            )
                            messages = messages.sorted(by: {
                                $0.date.compare($1.date) == .orderedAscending
                            })
                        })
//                }
            })
    }
    func sendMessage(message: String) {
        
        //Save Data to Database
        let date = getDate()
        let time = getTime()
        let messageId = ref.child("Messages").child(topicId).childByAutoId().key
        ref.child("Messages")
            .child(topicId)
            .child(messageId!)
            .setValue(
                [
                    "messageId": messageId,
                    "userId": senderId,
                    "message": message,
                    "date": date,
                    "time": time
                ]
            ) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    toastMessage = error.localizedDescription
                    showToast.toggle()
                } else {
                    //Message send successful
                    let userName = UserDefaults.standard.string(forKey: "name") ?? ""
                    let userImage = UserDefaults.standard.string(forKey: "image") ?? ""

                    //Send Notification
                  sendNotification(
                    messageId: messageId!,
                    userName: userName,
                    userImage: userImage
                  )
                        
                    
                }
            }
    }
    
    func sendNotification(messageId: String, userName: String, userImage: String) {

        ref
            .child("Topics")
            .child(topicId)
            .observeSingleEvent(of: .value, with: { snapshot in
            
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                guard let restDict = rest.value as? [String: Any] else { continue }
                
                let userid = restDict["userid"] as! String
                
                ref
                    .child("Users")
                    .child(userid)
                    .observeSingleEvent(of: .value, with: { (users) in
                        // Get user value
                        let value = users.value as? NSDictionary
                        let notification = value?["notification"] as? String ?? ""
                        let receiverId = value?["userid"] as? String ?? ""
                        
                        if notification != topicId {
                            //Send Notification
                            PushNotificationSender()
                                .sendPushNotification(
                                    to: receiverId,
                                    title: topicTitle,
                                    body: textMessage,
                                    sender_id: senderId,
                                    sender_name: userName,
                                    sender_pic: userImage
                                )
                            //Add Unseen Message
                            ref
                                .child("Unseen")
                                .child(topicId)
                                .child(receiverId)
                                .child(messageId)
                                .child("messageId")
                                .setValue(textMessage)
                        }
                        
                        textMessage = ""
                    })
            }
        })
    }
    func forNotification(){
        //Set for notification
        ref
            .child("Users")
            .child(senderId)
            .updateChildValues(["notification": topicId])
        //Removed unseen message
        ref
            .child("Unseen")
            .child(topicId)
            .child(senderId)
            .removeValue()
    }
    
    func loadTopicJoinedUsers(){
        ref
            .child("Topics")
            .child(topicId)
            .observeSingleEvent(of: .value, with: { snapshot in
                
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    guard let restDict = rest.value as? [String: Any] else { continue }
                    
                    let userid = restDict["userid"] as! String
                    
                    ref
                        .child("Users")
                        .child(userid)
                        .observeSingleEvent(of: .value, with: { (user) in
                            // Get user value
                            let value = user.value as? NSDictionary
                            let userid = value?["userid"] as? String ?? ""
                            let name = value?["name"] as? String ?? ""
                            let image = value?["image"] as? String ?? ""
                            let email = value?["email"] as? String ?? ""
                            users
                                .append(
                                    User(
                                        id: userid,
                                        name: name,
                                        email: email,
                                        image: image
                                    )
                                )
                            print("image",image)
                        }) { (error) in
                            
                        }
                }
            })
    }
    func getTime()->String{
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
    func getDate()->String{
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd MMM, yyyy"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(
            topicId: "",
            topicTitle: "",
            senderId: ""
        )
        
    }
}

struct JoinedUsersRow: View {
    
    let index: Int
    let users: [User]
    
    var body: some View {
        HStack {
            
            WebImage(url: URL(string: users[index].image))
                .resizable()
                .placeholder(
                    Image("user")
                )
                .frame(width: 30, height: 30)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5)
                .offset(x: (index==0 && users.count==2) ? 5: 0)
                .offset(x: (index==1 && users.count==2) ? -10: 0)
                .offset(x: (index==0 && users.count==3) ? 15: 0)
                .offset(x: (index==1 && users.count==3) ? 0: 0)
                .offset(x: (index==2 && users.count==3) ? -15: 0)
        }
    }
}
struct MessageRow: View {
    
    let index: Int
    let senderId: String
    @Binding var messages: [Message]
    @Binding var messageDate: String
    @State private var date = ""
    
    var body: some View {
        VStack {
            if date != "" {
                Text(date)
                    .foregroundColor(.black)
                    .font(.caption2)
                    .padding(.horizontal,8)
                    .padding(.vertical,2)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(5)
            }
   
            HStack {
                if messages[index].userId == senderId {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(messages[index].message)
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .multilineTextAlignment(.trailing)
                        
                        Text(messages[index].time)
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor)
                    .cornerRadius(5)
        
                    WebImage(url: URL(string: messages[index].userImage))
                        .resizable()
                        .placeholder(
                            Image("user")
                        )
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                } else {
                    WebImage(url: URL(string: messages[index].userImage))
                        .resizable()
                        .placeholder(
                            Image("user")
                        )
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(messages[index].userName)
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.system(size: 10 ))
                            .padding(.leading, 2)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(messages[index].message)
                                .foregroundColor(.black)
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                            Text(messages[index].time)
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            if index == 0 {
                messageDate = messages[index].date
                date = messages[index].date
            }
            
            if messageDate != messages[index].date && index != 0 {
                messageDate = messages[index].date
                date = messages[index].date
            }
        }
    }
    
}
