import SwiftUI
import SwiftData

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var loginController: LoginController
    
    var body: some View {
        ZStack{
            Color("BackgroundColour")
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image("abbyLogo")
                    .resizable()
                    .frame(width:200, height: 150)
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Error banner
                if let error = loginController.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(10)
                }
                
                // Email Field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color("CardColour"))
                    .cornerRadius(10)
                
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color("CardColour"))
                    .cornerRadius(10)
                
                // Login Button
                Button {
                    Task {
                        await loginController.login(email: email, password: password)
                    }
                } label: {
                    if loginController.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(email.isEmpty || password.isEmpty ?  Color("BtnPressedColour") :Color("ButtonColour") )
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(email.isEmpty || password.isEmpty || loginController.isLoading)
                
                // Navigate to Create Account
                NavigationLink(destination: CreateAccountView(loginController: loginController)) {
                    Text("Don't have an account? Sign up")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(loginController: LoginController())
    }
}

