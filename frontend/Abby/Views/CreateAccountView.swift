//
//  CreateAccountView.swift
//  Abby
//
//  Created by Adam Brows on 15/02/2026.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var vrn = ""
    @State private var localError: String?
    
    @ObservedObject var loginController: LoginController
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Error banner
            if let error = localError ?? loginController.errorMessage {
                Text(error)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(10)
            }
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            TextField("VAT Registration Number (VRN)", text: $vrn)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            Button {
                localError = nil
                guard password == confirmPassword else {
                    localError = "Passwords do not match."
                    return
                }
                guard password.count >= 6 else {
                    localError = "Password must be at least 6 characters."
                    return
                }
                Task {
                    await loginController.createAccount(
                        email: email,
                        password: password,
                        vrn: vrn
                    )
                }
            } label: {
                if loginController.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(formValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!formValid || loginController.isLoading)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up")
    }
    
    private var formValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !vrn.isEmpty
    }
}

#Preview {
    NavigationStack {
        CreateAccountView(loginController: LoginController())
    }
}
