//
//  ContentView.swift
//  Abby
//
//  Created Adam Bows on 13/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var loginController = LoginController()
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @State private var showSplash = true
    @State private var opacity = 1.0
    
    var body: some View {
        Group {
            if showSplash {
                // Splash screen
                ZStack {
                    Color("BackgroundColour")
                        .ignoresSafeArea()
                    VStack {
                        Image("abbyLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 350)
                    }
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.3)) {
                            self.opacity = 1.0
                        }
                        Task {
                            // Try to restore session from stored token
                            if loginController.hasStoredToken {
                                await loginController.restoreSession()
                            }
                            withAnimation {
                                self.showSplash = false
                            }
                        }
                    }
                }
            }else if !loginController.isLoggedIn {
                NavigationStack {
                    LoginView(loginController: loginController)
                }
                
            } else if !loginController.isLinkedToHMRC {
                LinkToHmrcView(loginController: loginController)
                
            } else {
                HomePageView(loginController: loginController)
            }
            
        }.preferredColorScheme(appAppearance == "light" ? .light : .dark)
    }
    
}
#Preview {
    ContentView()
}
