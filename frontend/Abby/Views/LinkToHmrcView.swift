//
//  LinkToHmrcView.swift
//  AbbyIOS
//
//  Created by Adam Brows on 15/03/2026.
//

import SwiftUI

struct LinkToHmrcView: View{
    @ObservedObject var loginController: LoginController
    
    var body: some View{
        NavigationStack{
            VStack{
                Image("abbyLogo")
                    .resizable()
                //.scaledToFit()
                    .frame(width:200, height: 150)
                Text("Link to HMRC")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        loginController.logout()
                }label:{
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .principal){
                Image("abbyLogo")
                    .resizable()
                    .padding(30)
                    .frame(width: 250, height: 200)
            }
            }
       
            
            Button("Connect to HMRC") {
                guard let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                      let window = windowScene.windows.first else {
                    return
                }
                loginController.startOAuthSession(presentationAnchor: window)
            }
            
            if let error = loginController.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
            }
        }
    }
}
