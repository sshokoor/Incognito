//
//  LoginView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseMessaging
import FirebaseDatabase
import iActivityIndicator

struct LoginView: View {
    
    @State private var textEmail = ""
    @State private var textPassword = ""
    
    @State private var isLoginSuccessful = false
    @State private var showLoadingBar = false
    
    @State private var showingAlert = false
    @State private var textAlertTitle = ""
    @State private var textAlertDescription = ""
    
    let ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    NavigationLink(isActive: $isLoginSuccessful) {
                        MainView()
                    } label: {
                        EmptyView()
                    }
                    
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    Text("Incognito")
                        .foregroundColor(.accentColor)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Connect with people\n and discuss about topics")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    MyTextField(
                        heading: "Email",
                        hint: "enter email",
                        image: "envelope",
                        value: $textEmail
                    )
                        .padding(.top,40)
                    MyTextField(
                        heading: "Password",
                        hint: "enter password",
                        image: "eye.slash",
                        value: $textPassword
                    )
                        .padding(.top,10)
                    
                    NavigationLink {
                        ForgotPasswordView()
                    } label: {
                        Text("Forgot Password?")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    Button {
                        if textEmail == ""{
                            
                            showingAlert = true
                            textAlertTitle = "Ooops!"
                            textAlertDescription = "Please enter email."
                            
                        } else if textPassword == ""{
                            showingAlert = true
                            textAlertTitle = "Ooops!"
                            textAlertDescription = "Please enter password."
                        } else {
                            showLoadingBar = true
                            login(
                                email: textEmail,
                                password: textPassword
                            )
                        }
                    } label: {
                        Image("ic_button")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.accentColor)
                            .frame(
                                width: 230,
                                height: 50
                            )
                            .overlay(
                                Text("Sign In")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                            .padding(.top)
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                            .font(.caption)
                            .foregroundColor(.black)
                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("Create Account")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                        
                        
                    }
                }
                .padding()
                .background(Color("LightGray"))
                .cornerRadius(20)
                .padding()
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
        .alert(
            isPresented: $showingAlert
        ) {
            Alert(
                title: Text(self.textAlertTitle),
                message: Text(self.textAlertDescription),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    func login(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error
            {
                showLoadingBar=false
                showingAlert=true
                textAlertTitle="Ooops!"
                textAlertDescription=error.localizedDescription
                return
            }
            guard user != nil else { return }
            
            ref.child("Users").child((user?.user.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let name = value?["name"] as? String ?? ""
                let gender = value?["gender"] as? String ?? ""
                let dob = value?["dob"] as? String ?? ""
                let image = value?["image"] as? String ?? ""
                let address = value?["address"] as? String ?? ""
                let phonenumber = value?["phoneNumber"] as? String ?? ""
                
                UserDefaults.standard.setValue(name, forKey: "name")
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(address, forKey: "address")
                UserDefaults.standard.setValue(phonenumber, forKey: "phone_number")
                UserDefaults.standard.setValue(gender, forKey: "gender")
                UserDefaults.standard.setValue(password, forKey: "password")
                UserDefaults.standard.setValue(dob, forKey: "dob")
                UserDefaults.standard.setValue(image, forKey: "image")
                UserDefaults.standard.setValue(user?.user.uid, forKey: "user_id")
                UserDefaults.standard.setValue(true, forKey: "is_login")
                UserDefaults.standard.synchronize()
                

                Messaging.messaging().subscribe(toTopic: (user?.user.uid)!) { error in
                        print("Subscribed to ferchapp topic")
                    }
                
                
                isLoginSuccessful = true
            }) { (error) in
                showLoadingBar = false
                showingAlert = true
                textAlertTitle = "Ooops!"
                textAlertDescription=error.localizedDescription
            }
            
            
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct MyTextField: View {
    
    let heading: String
    let hint: String
    let image: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text(heading)
                .foregroundColor(.accentColor)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.leading, 5)
            HStack(spacing: 0) {
                Image(systemName: image)
                if heading == "Password" || heading == "New Password" || heading == "Confirm Password" {
                    SecureField(hint, text: $value)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                } else {
                    TextField(hint, text: $value)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
            }
            .padding()
            .background(
                Image("ic_textfield")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.gray)
            )
            
        }
        
    }
}
