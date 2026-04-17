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
            ZStack{
                Color("BackgroundColour")
                    .ignoresSafeArea()
                VStack{
                    VStack{
                        Image("abbyLogo")
                            .resizable()
                        //.scaledToFit()
                            .frame(width:200, height: 150)
                        Text("Link to HMRC")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                    }
                    Spacer()
                
                    
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading){
                            Button {
                                loginController.logout()
                            }label:{
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    VStack{
                        Button("Connect to HMRC") {
                            
                            guard let windowScene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                                  let window = windowScene.windows.first else {
                                return
                            }
                            
                            loginController.startOAuthSession(presentationAnchor: window)
                        }
                        .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("ButtonColour"))
                                .foregroundColor(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        
                        if let error = loginController.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding()
            }
        }
        
    }
}
#Preview {
    LinkToHmrcView(loginController: LoginController())
}
