//
//  ProfileView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import iActivityIndicator
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @State private var userId = ""
    @State private var textName = ""
    @State private var textEmail = ""
    @State private var textPassword = ""
    @State private var textPhoneNumber = ""
    @State private var textGender = "Male"
    @State private var textAddress = ""
    @State private var image = ""
    @State private var updatedImage = UIImage()
    @State private var isImageSelect = false
    @State private var selectedDOB = Date()
    @State private var showImageSheet = false
    
    @State private var showingAlert = false
    @State private var textAlertTitle = ""
    @State private var textAlertDescription = ""
    
    @State private var showLoadingBar = false
    @State private var showChangePasswordSheet = false
    let ref: DatabaseReference! = Database.database().reference()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                headerContent
                mainContent
                
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
            if showChangePasswordSheet {
                    UpdatePasswordView(
                        isVisible: $showChangePasswordSheet,
                        showingAlert: $showingAlert,
                        textAlertTitle: $textAlertTitle,
                        textAlertDescription: $textAlertDescription
                    )
                        .padding()
                        .transition(.slide)
                        .animation(.spring())
                
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(
            isPresented: $showingAlert
        ) {
            Alert(
                title: Text(self.textAlertTitle),
                message: Text(self.textAlertDescription),
                dismissButton: .default(Text("Ok"))
            )
        }
        .onAppear {
            textName = UserDefaults.standard.string(forKey: "name") ?? ""
            textEmail = UserDefaults.standard.string(forKey: "email") ?? ""
            textAddress = UserDefaults.standard.string(forKey: "address") ?? ""
            textPhoneNumber = UserDefaults.standard.string(forKey: "phone_number") ?? ""
            textGender = UserDefaults.standard.string(forKey: "gender") ?? ""
            textPassword = UserDefaults.standard.string(forKey: "password") ?? ""
            let dob = UserDefaults.standard.string(forKey: "dob") ?? ""
            if dob != "" {
                let dateFormatter = DateFormatter(format: "dd MM yyyy")
                selectedDOB = dob.toDate(dateFormatter: dateFormatter)! as Date
            }
            image = UserDefaults.standard.string(forKey: "image") ?? ""
            userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
        }
        
    }
    
    var headerContent: some View {
        ZStack {
            VStack {
                HStack {
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text("Back")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            showChangePasswordSheet.toggle()
                        }
                    } label: {
                        Text("Change Password")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    
                }
                .padding(.horizontal, 5)
                Spacer()
            }
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                
                Image("person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                WebImage(url: URL(string: image))
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                Image(uiImage: updatedImage)
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
            .onTapGesture {
                isImageSelect = false
                showImageSheet.toggle()
            }
            .sheet(isPresented: $showImageSheet) {
                print("Image Sheet Dismissed")
            } content: {
                ImagePicker(
                    selectedImage: $updatedImage,
                    isImageSelect: $isImageSelect
                )
            }
            
        }
        .frame(maxWidth: .infinity,maxHeight: 120)
        .background(Color.accentColor)
    }
    
    var mainContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Name
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.headline)
                    TextField("Name", text: $textName)
                        .accentColor(.black)
                    Divider()
                        .padding(.top,5)
                }
                .padding(.top)
                .padding(.horizontal)
                
                //Email
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.headline)
                    TextField("Email", text: $textEmail)
                        .accentColor(.black)
                    Divider()
                        .padding(.top,5)
                }
                .padding(.top)
                .padding(.horizontal)
                .disabled(true)
                
                //Phone Number
                VStack(alignment: .leading, spacing: 5) {
                    Text("Phone Number")
                        .font(.headline)
                    TextField("Phone number", text: $textPhoneNumber)
                        .accentColor(.black)
                    Divider()
                        .padding(.top,5)
                }
                .padding(.top)
                .padding(.horizontal)
                
                //Gender
                VStack(alignment: .leading, spacing: 5) {
                    Text("Gender")
                        .font(.headline)
                    HStack {
                        
                        Button {
                            textGender = "Male"
                        } label: {
                            Image(systemName: textGender == "Male" ? "circle.fill": "circle")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.accentColor)
                            Text("Male")
                                .foregroundColor(.black)
                                .font(.subheadline)
                            
                        }
                        Spacer()
                        Button {
                            textGender = "Female"
                        } label: {
                            Image(systemName: textGender == "Female" ? "circle.fill": "circle")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.accentColor)
                            Text("Female")
                                .foregroundColor(.black)
                                .font(.subheadline)
                        }
                        
                        
                        Spacer()
                    }
                    Divider()
                        .padding(.top,5)
                }
                .padding(.top)
                .padding(.horizontal)
                
                //Date Of Birth
                VStack(alignment: .leading, spacing: 5) {
                    Text("Date Of Birth")
                        .font(.headline)
                    //TextField("Date Of Birth", text: $textUserName)
                    DatePicker("", selection: $selectedDOB, displayedComponents: [.date])
                        .labelsHidden()
                    Divider()
                        .padding(.top,5)
                }
                .padding(.top)
                .padding(.horizontal)
                
                //Address
                VStack(alignment: .leading, spacing: 5) {
                    Text("Address")
                        .font(.headline)
                    TextField("Address", text: $textAddress)
                        .accentColor(.black)
                    Divider()
                        .padding(.top,5)
                }
                .padding(.top)
                .padding(.horizontal)
                
                //Button
                HStack(alignment: .center) {
                    Spacer()
                    Button {
                        showLoadingBar = true
                        update()
                    } label: {
                        Text("Save")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(width: 250, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(30)
                    }
                    .padding(.top)
                    Spacer()
                }
            }
        }
    }
    
    func update() {
        
        let dateFormatter = DateFormatter(format: "dd MM yyyy")
        
        if isImageSelect {
            //Upload Image
            let data = updatedImage.jpegData(compressionQuality: 0.5)! as NSData
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let storage = Storage.storage().reference().child("User Images").child(userId)
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
                        saveUser(
                            name: textName,
                            email: textEmail,
                            password: textPassword,
                            phoneNumber: textPhoneNumber,
                            dob: selectedDOB.toString(dateFormatter: dateFormatter)!,
                            gender: textGender,
                            address: textAddress,
                            userId: userId,
                            imageURL: profileImageUrl
                        )
                    }
                })
            })
        } else {
            //Save Data to Database
            saveUser(
                name: textName,
                email: textEmail,
                password: textPassword,
                phoneNumber: textPhoneNumber,
                dob: selectedDOB.toString(dateFormatter: dateFormatter)!,
                gender: textGender,
                address: textAddress,
                userId: userId,
                imageURL: image
            )
        }
        
        
    }
    
    func saveUser(name:String, email: String, password: String, phoneNumber: String, dob: String, gender: String, address: String, userId: String, imageURL: String) {
        
        ref.child("Users").child(userId).setValue(
            ["name": name,
             "email":email,
             "password":password,
             "phoneNumber":phoneNumber,
             "userid":userId,
             "dob":dob,
             "gender":gender,
             "address":address,
             "image":imageURL
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
                UserDefaults.standard.setValue(imageURL, forKey: "image")
                UserDefaults.standard.setValue(userId, forKey: "user_id")
                UserDefaults.standard.setValue(true, forKey: "is_login")
                showLoadingBar = false
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

