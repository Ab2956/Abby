//
//  ProfileView.swift
//  AbbyIOS
//
//  Created by Adam Brows on 15/03/2026.
//

import SwiftUI

struct ProfileView: View{
    @ObservedObject var userService: UserServices = .shared
    @ObservedObject var loginController :LoginController
    
    var body: some View{
        ZStack{
            Color("BackgroundColour")
                .ignoresSafeArea()
            VStack(spacing: 24){
                VStack(){
                    Image("abbyLogo")
                        .resizable()
                        .frame(width:200, height: 150)
                    
                    Text("Profile")
                        .font(.largeTitle)
                }
                .padding(.top,10)
                
                VStack(spacing: 12){
                    Text("Name: \(userService.userName)")
                    Text("Email: \(userService.userEmail)")
                    Text("VRN: \(userService.userVrn)")
                    
                    Spacer()
                    
                    Button(action: {
                        loginController.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.bottom,10)
                }
                .padding()
                .onAppear {
                    Task { await userService.fetchUserInfo() }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top,10)
            .padding(.horizontal)
        }
    }
}

