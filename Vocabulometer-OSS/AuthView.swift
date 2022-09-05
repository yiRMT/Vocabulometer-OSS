//
//  AuthView.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/04.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("Splash")
                    .resizable()
                    .scaledToFit()
                    .padding(.all)
                
                SignInView()
                    .padding(.all)
                
                NavigationLink {
                    VStack {
                        Image("Splash")
                            .resizable()
                            .scaledToFit()
                            .padding(.all)
                        
                        SignUpView().padding(.all)
                        
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
        AuthView()
    }
}

struct SignInView: View {
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
                // action
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
        SignInView()
    }
}

struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var isPasswordVisible = false
    @State var isConfirmVisible = false
    
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
                    TextField("Confirm Password", text: $password)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                } else {
                    SecureField("Confirm Password", text: self.$password)
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
                // action
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
        SignUpView()
    }
}
