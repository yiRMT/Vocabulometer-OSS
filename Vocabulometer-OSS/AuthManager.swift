//
//  Auth.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/06.
//

import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var uid = ""
    
    init() {
        Task {
            await checkAuthState()
        }
    }
    
    func checkAuthState() async {
        Auth.auth().addStateDidChangeListener({ auth, user  in
            DispatchQueue.main.async {
                if let user = user {
                    self.isSignedIn = true
                    self.uid = user.uid
                } else {
                    self.isSignedIn = false
                }
            }
        })
    }
    
    func signIn(withEmail email: String, password: String) async throws -> Error? {
        if (email != "" || password != "") {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                print(result.user.uid)
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.uid = result.user.uid
                }
            } catch {
                return error
            }
        }
        return nil
    }
    
    func signUp(withEmail email: String, password: String, confirmPassword: String) async throws -> Error? {
        if password == confirmPassword {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                print(result.user.uid)
            } catch {
                return error
            }
        }
        return nil
    }
    
    func signOut() -> Error? {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
        } catch {
            return error
        }
        return nil
    }
}
