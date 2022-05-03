//
//  RegisterView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import iActivityIndicator
import FirebaseMessaging

struct RegisterView: View {
    
    @State private var textName = ""
    @State private var textEmail = ""
    @State private var textPassword = ""
    @State private var textGender = "Male"
    @State private var image = UIImage()
    @State private var showImageSheet = false
    @State private var isImageSelect = false
    
    @State private var isRegisterSuccessful = false
    @State private var showLoadingBar = false
    
    @State private var showingAlert = false
    @State private var textAlertTitle = ""
    @State private var textAlertDescription = ""
    
    let ref: DatabaseReference! = Database.database().reference()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationLink(isActive: $isRegisterSuccessful) {
                    MainView()
                } label: {
                    EmptyView()
                }
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        
                    Text("Back")
                        .font(.subheadline)
                    Spacer()
                }
                .padding()
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        
                        Text("Create an account")
                            .foregroundColor(.accentColor)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Connect with people\n and discuss about topics")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        
                        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                            Image("person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .background(Color.white)
                                .frame(width: 100, height: 100)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.accentColor)
                                .frame(width: 25, height: 25)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.top,40)
                        .onTapGesture {
                            isImageSelect = false
                            showImageSheet.toggle()
                        }
                        .sheet(isPresented: $showImageSheet) {
                            print("Image Sheet Dismissed")
                        } content: {
                            ImagePicker(
                                selectedImage: $image,
                                isImageSelect: $isImageSelect
                            )
                        }

                        MyTextField(
                            heading: "Name",
                            hint: "enter name",
                            image: "person",
                            value: $textName
                        )
                            .padding(.top,10)
                        MyTextField(
                            heading: "Email",
                            hint: "enter email",
                            image: "envelope",
                            value: $textEmail
                        )
                            .padding(.top,10)
                        MyTextField(
                            heading: "Password",
                            hint: "enter password",
                            image: "eye.slash",
                            value: $textPassword
                        )
                            .padding(.top,10)
                        VStack(alignment: .leading, spacing: 5) {
                       
                            Text("Gender")
                                .foregroundColor(.accentColor)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.leading, 5)
                            HStack {
                             
                                Button {
                                    textGender = "Male"
                                } label: {
                                    Image(systemName: textGender == "Male" ? "circle.fill": "circle")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.accentColor)
                                    Text("Male")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                    
                                }
                                Spacer()
                                Button {
                                    textGender = "Female"
                                } label: {
                                    Image(systemName: textGender == "Female" ? "circle.fill": "circle")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.accentColor)
                                    Text("Female")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                }

                            
                                Spacer()
                            }
                            .padding()
                           
                        }
                        .padding(.top,10)
                        Button {
                            if textName == ""{
                                
                                showingAlert = true
                                textAlertTitle = "Ooops!"
                                textAlertDescription = "Please enter name."
                            
                            } else if textEmail == ""{
                                showingAlert = true
                                textAlertTitle = "Ooops!"
                                textAlertDescription = "Please enter email."
                            } else if textPassword == ""{
                                showingAlert = true
                                textAlertTitle = "Ooops!"
                                textAlertDescription = "Please enter password."
                            } else {
                                showLoadingBar = true
                                register(
                                    name: textName,
                                    email: textEmail,
                                    password: textPassword,
                                    phoneNumber: "",
                                    dob: "",
                                    gender: textGender,
                                    address: ""
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
                                    Text("Create Account")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                                .padding(.top)
                        }

                        
                        HStack {
                        Text("Already have an account?")
                            .font(.caption)
                            .foregroundColor(.black)
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Login")
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
    
    func register(name:String, email: String, password: String, phoneNumber: String, dob: String, gender: String, address: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            guard let user = authResult?.user, error == nil else {
              
                showLoadingBar=false
                showingAlert=true
                textAlertTitle="Ooops!"
                textAlertDescription=error!.localizedDescription
                return
            }
            
            if isImageSelect {
            
            //Upload Image
            let data = image.jpegData(compressionQuality: 0.1)! as NSData
            let metaData = StorageMetadata()
                    metaData.contentType = "image/jpg"

            let storage = Storage.storage().reference().child("User Images").child(user.uid)
            storage.putData(data as Data, metadata: metaData).observe(.success, handler: { (snapshot) in
                storage.downloadURL(completion: { (url, error) in
                    if error != nil {
                        showLoadingBar=false
                        showingAlert=true
                        textAlertTitle="Ooops!"
                        textAlertDescription=error!.localizedDescription
                        return
                    }
                    if let profileImageUrl = url?.absoluteString {
                       
                        //Save Data to Database
                        ref.child("Users").child(user.uid).setValue(
                            ["name": name,
                             "email":email,
                             "password":password,
                             "phoneNumber":phoneNumber,
                             "userid":user.uid,
                             "dob":dob,
                             "gender":gender,
                             "address":address,
                             "image":profileImageUrl,
                             "notification":"nil"
                            ]
                        ) {
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                showLoadingBar=false
                                showingAlert=true
                                textAlertTitle="Ooops!"
                                textAlertDescription=error.localizedDescription
                            } else {
                                UserDefaults.standard.setValue(name, forKey: "name")
                                UserDefaults.standard.setValue(email, forKey: "email")
                                UserDefaults.standard.setValue(address, forKey: "address")
                                UserDefaults.standard.setValue(phoneNumber, forKey: "phone_number")
                                UserDefaults.standard.setValue(gender, forKey: "gender")
                                UserDefaults.standard.setValue(password, forKey: "password")
                                UserDefaults.standard.setValue(dob, forKey: "dob")
                                UserDefaults.standard.setValue(profileImageUrl, forKey: "image")
                                UserDefaults.standard.setValue(user.uid, forKey: "user_id")
                                UserDefaults.standard.setValue(true, forKey: "is_login")
                                UserDefaults.standard.synchronize()
                                Messaging.messaging().subscribe(toTopic: user.uid) { error in
                                    print("Subscribed to ferchapp topic")
                                }
                                
                                isRegisterSuccessful=true
                            }
                          }
                        
                    }
                })
            })
            
        } else {
            //Save Data to Database
            ref.child("Users").child(user.uid).setValue(
                [
                    "name": name,
                    "email":email,
                    "password":password,
                    "phoneNumber":phoneNumber,
                    "userid":user.uid,
                    "dob":dob,
                    "gender":gender,
                    "address":address,
                    "image":"https://www.theexpertssolutions.com",
                    "notification":"nil"
                ]
            ) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    showLoadingBar=false
                    showingAlert=true
                    textAlertTitle="Ooops!"
                    textAlertDescription=error.localizedDescription
                } else {
                    UserDefaults.standard.setValue(name, forKey: "name")
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue(address, forKey: "address")
                    UserDefaults.standard.setValue(phoneNumber, forKey: "phone_number")
                    UserDefaults.standard.setValue(gender, forKey: "gender")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    UserDefaults.standard.setValue(dob, forKey: "dob")
                    UserDefaults.standard.setValue("https://www.theexpertssolutions.com", forKey: "image")
                    UserDefaults.standard.setValue(user.uid, forKey: "user_id")
                    UserDefaults.standard.setValue(true, forKey: "is_login")
                    UserDefaults.standard.synchronize()
                    
                    Messaging.messaging().subscribe(toTopic: user.uid) { error in
                        print("Subscribed to ferchapp topic")
                    }
                    
                    isRegisterSuccessful=true
                    
                }
              }
        }
            
        }
        
        
    }
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
