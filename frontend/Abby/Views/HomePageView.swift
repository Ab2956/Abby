//
//  HomePageView.swift
//  Abby
//
//  Created by Adam Brows on 07/12/2025.
//

import SwiftUI

struct HomePageView: View {
    @ObservedObject var loginController: LoginController
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Abby")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You are logged in.")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        loginController.logout()
                    }
                }
            }
        }
    }
}

#Preview {
    HomePageView(loginController: LoginController())
}
