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
    @State private var isActive = false
    @State private var opacity = 1.0
    
    var body: some View {
        if isActive {
            LoginView()
        } else {
            ZStack{
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
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}
#Preview{
    ContentView()
}
