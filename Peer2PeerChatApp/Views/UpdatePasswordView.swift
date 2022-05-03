//
//  UpdatePasswordView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import iActivityIndicator

struct UpdatePasswordView: View {
    
    @Binding var isVisible: Bool
    @Binding var showingAlert: Bool
    @Binding var textAlertTitle: String
    @Binding var textAlertDescription: String
    
    @State private var textPassword = ""
    @State private var textNewPassword = ""
    @State private var textConfirmNewPassword = ""
    
    @State private var showLoadingBar = false
    let ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        ZStack {
            VStack{
                HStack {
                    Button {
                        withAnimation {
                            isVisible.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                    Text("Forgot Passowrd")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                MyTextField(
                    heading: "Password",
                    hint: "previous password",
                    image: "eye.slash",
                    value: $textPassword
                )
                    .padding(.top,10)
                MyTextField(
                    heading: "New Password",
                    hint: "new password",
                    image: "eye.slash",
                    value: $textNewPassword
                )
                    .padding(.top,10)
                MyTextField(
                    heading: "Confirm Password",
                    hint: "confirm new password",
                    image: "eye.slash",
                    value: $textConfirmNewPassword
                )
                    .padding(.top,10)
                
                Button {
                    let pass = UserDefaults.standard.string(forKey: "password") ?? ""
                    if textPassword == "" {
                        showingAlert = true
                        textAlertTitle = "Ooops!"
                        textAlertDescription = "Please enter previous password."
                        
                    } else if pass != textPassword{
                        showingAlert = true
                        textAlertTitle = "Ooops!"
                        textAlertDescription = "Please enter correct previous password"
                    } else if textNewPassword == ""{
                        showingAlert = true
                        textAlertTitle = "Ooops!"
                        textAlertDescription = "Please enter new password."
                    } else if textConfirmNewPassword == ""{
                        showingAlert = true
                        textAlertTitle = "Ooops!"
                        textAlertDescription = "Please enter confirm new password."
                    } else if textNewPassword != textConfirmNewPassword{
                        showingAlert = true
                        textAlertTitle = "Ooops!"
                        textAlertDescription = "new password not match."
                    } else {
                        showLoadingBar = true
                        updatePassword()
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
                            Text("Update Password")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                        .padding(.top)
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
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    func updatePassword() {
        
        Auth.auth().currentUser?.updatePassword(to: textNewPassword) { (error) in
            if error != nil {
                showLoadingBar=false
                showingAlert=true
                textAlertTitle="Ooops!"
                textAlertDescription=error!.localizedDescription
            } else {
                let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
                ref.child("Users").child(userId).setValue(
                    ["password":textNewPassword]
                ) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        showLoadingBar=false
                        showingAlert=true
                        textAlertTitle="Ooops!"
                        textAlertDescription=error.localizedDescription
                    } else {
                        UserDefaults.standard.setValue(textNewPassword, forKey: "password")
                        
                        showLoadingBar = false
                        isVisible = false
                    }
                    
                }
            }
        }
        
    }
}

struct UpdatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatePasswordView(
            isVisible: .constant(true),
            showingAlert: .constant(false),
            textAlertTitle: .constant(""),
            textAlertDescription: .constant("")
        )
    }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}
