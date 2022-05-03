//
//  ForgotPasswordView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseAuth
import iActivityIndicator

struct ForgotPasswordView: View {
    
    @State private var textEmail = ""
    @State private var showLoadingBar = false
    
    @State private var showingAlert = false
    @State private var textAlertTitle = ""
    @State private var textAlertDescription = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
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
                Spacer()
            }
            VStack {
                
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                Text("Forgot Password")
                    .foregroundColor(.accentColor)
                    .font(.title)
                    .fontWeight(.bold)
                MyTextField(
                    heading: "Email",
                    hint: "enter email",
                    image: "envelope",
                    value: $textEmail
                )
                    .padding(.top,20)
                
                Button {
                    if self.textEmail==""{
                        showingAlert=true
                        textAlertTitle="Ooops!"
                        textAlertDescription="please enter email."
                        
                    } else {
                        showLoadingBar = true
                        forgotPassword(email: self.textEmail)
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
                            Text("Submit")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                        .padding(.top)
                }
                
                
                
            }
            .padding()
            .background(Color("LightGray"))
            .cornerRadius(20)
            .padding()
            
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
    
    func forgotPassword(email:String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error
            {
                showLoadingBar=false
                showingAlert=true
                textAlertTitle="Ooops!"
                textAlertDescription=error.localizedDescription
                return
            } else {
                showLoadingBar=false
                self.showingAlert=true
                self.textAlertTitle="Congratulation!"
                self.textAlertDescription="Reset password mail sent to \(email)."
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
