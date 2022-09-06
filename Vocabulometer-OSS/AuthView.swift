//
//  AuthView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/04.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack {
                Image("Splash")
                    .resizable()
                    .scaledToFit()
                    .padding(.all)
                
                SignInView(authManager: authManager)
                    .padding(.all)
                
                NavigationLink {
                    VStack {
                        Image("Splash")
                            .resizable()
                            .scaledToFit()
                            .padding(.all)
                        
                        SignUpView(authManager: authManager).padding(.all)
                        
                        Spacer()
                    }
                } label: {
                    Text("Create a new account")
                }
                
                Spacer()
            }
            .navigationTitle("Sign in")
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(authManager: AuthManager())
    }
}

struct SignInView: View {
    @ObservedObject var authManager: AuthManager
    @State var email = ""
    @State var password = ""
    @State var isPasswordVisible = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
            
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                } else {
                    SecureField("Password", text: self.$password)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: self.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                }
            }.padding(.bottom)
            
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    
                }
            }.padding(.bottom)
            
            Button {
                Task {
                    if let error = try await authManager.signIn(withEmail: email, password: password) {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Sign in")
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(authManager: AuthManager())
    }
}

struct SignUpView: View {
    @ObservedObject var authManager: AuthManager
    
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var isPasswordVisible = false
    @State var isConfirmVisible = false
    @State var result = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
            
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                } else {
                    SecureField("Password", text: self.$password)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: self.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                }
            }.padding(.bottom)
            
            HStack {
                if isConfirmVisible {
                    TextField("Confirm Password", text: $confirmPassword)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                } else {
                    SecureField("Confirm Password", text: self.$confirmPassword)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button {
                    isConfirmVisible.toggle()
                } label: {
                    Image(systemName: self.isConfirmVisible ? "eye.slash.fill" : "eye.fill")
                }
            }.padding(.bottom)
            
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    
                }
            }.padding(.bottom)
            
            Button {
                Task {
                    if let error = try await authManager.signUp(withEmail: email, password: password, confirmPassword: confirmPassword) {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Sign up")
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            
        }
        .navigationTitle("Sign up")
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(authManager: AuthManager())
    }
}
