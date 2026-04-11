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
        Image("abbyLogo")
            .resizable()
            .frame(width:200, height: 150)
        
        Text("Profile")
            .font(.largeTitle)
            .padding()
        
        VStack{
            Text("Name: \(userService.userName)")
            Text("Email: \(userService.userEmail)")

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
        }
        .padding()
        .onAppear {
            Task { await userService.fetchUserInfo() }
        }
    }
}
