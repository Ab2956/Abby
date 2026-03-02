import SwiftUI
import SwiftData

struct LoginView : View{
    @State private var email = ""
    @State private var password = ""
    @State private var vrn = ""
    
    let apiServices = ApiServices.shared
    let loginController = LoginController()
    
    var body : some View{
        Text("Login")
        VStack(spacing: 20){
            Text("Welcome back!")
                .font(.largeTitle)
                .fontWeight(.bold)
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                        
                        // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                        
                        // Login Button
            Button {
                Task {
                    await loginController.login(email: email, password: password)
                }
                
            } label: {
                Text("Login")
                .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                       
            Spacer()
            }
            .padding()
        }
    }

#Preview{
    LoginView()
}

