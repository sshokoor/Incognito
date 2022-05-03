//
//  IntroScreensView.swift
//  Peer2PeerChatApp
//
//  Created by Josh on 2/6/22.
//

import SwiftUI

struct IntroScreensView: View {
    
    @State private var selectedScreen = 0
    @State private var goToLoginView = false
    @Namespace var namespace
    
    var body: some View {
        VStack {
            
            //Navigation link for MainView
            NavigationLink(
                isActive: $goToLoginView
            ) {
                LoginView()
            } label: {
                Text("")
            }
            
            
            HStack {
                Spacer()
                Text("SKIP")
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        //Hide Intro Screen at the start of the app
                        UserDefaults.standard.set(true, forKey: "is_show_intro_screen")
                        //Go To Main View
                        goToLoginView.toggle()
                    }
            }
            TabView(selection: $selectedScreen) {
                ForEach(Constant.INTROS.indices, id:\.self){index in
                    SingleIntroScreenView(
                        image: Constant.INTROS[index].image,
                        title: Constant.INTROS[index].title,
                        description: Constant.INTROS[index].description
                    )
                        .tag(index)
                }
                
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                Image(systemName: "arrowtriangle.backward.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black)
                    .opacity(selectedScreen==0 ? 0.5: 1.0) // change button color if first screen is shown
                    .onTapGesture {
                        //Check first screen is not showing
                        if selectedScreen > 0 {
                            //withAnimation animate screens while changing on button click
                            withAnimation {
                                selectedScreen -= 1
                            }
                        }
                    }
                
                Spacer()
                
                
                //Show screens circle
                HStack {
                    ForEach(Constant.INTROS.indices, id:\.self){index in
                        if selectedScreen == index {
                            Circle()
                                .frame(width: 7, height: 7)
                                .foregroundColor(Color.accentColor)
                                .matchedGeometryEffect(id: "dot", in: namespace)
                        } else {
                            Circle()
                                .frame(width: 7, height: 7)
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    
                }
                
                Spacer()
                Image(systemName: "arrowtriangle.forward.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        
                        //Hide Intro Screen at the start of the app
                        if selectedScreen == 2 {
                            UserDefaults.standard.set(true, forKey: "is_show_intro_screen")
                            //Go To Main View
                            goToLoginView.toggle()
                        }
                        
                        //Check last screen is not showing
                        if selectedScreen < Constant.INTROS.count-1 {
                            //withAnimation animate screens while changing on button click
                            withAnimation {
                                selectedScreen += 1
                            }
                        }
                        
                    }
                
            }
        }
        .padding()
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

struct IntroScreensView_Previews: PreviewProvider {
    static var previews: some View {
        IntroScreensView()
    }
}

struct SingleIntroScreenView: View {
    
    let image: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            Text(title)
                .foregroundColor(.black)
                .fontWeight(.bold)
                .font(.headline)
            Text(description)
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}
