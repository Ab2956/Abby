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
    @State private var showSplash = true
    @State private var opacity = 1.0
    
    var body: some View {
        if showSplash {
            // Splash screen
            ZStack {
                Color(UIColor.gray)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            // If there's already a stored token, skip login
                            if loginController.hasStoredToken {
                                loginController.isLoggedIn = true
                            }
                            self.showSplash = false
                        }
                    }
                }
            }
        } else if loginController.isLoggedIn {
            HomePageView(loginController: loginController)
        } else {
            NavigationStack {
                LoginView(loginController: loginController)
            }
        }
    }
}

#Preview {
    ContentView()
}
