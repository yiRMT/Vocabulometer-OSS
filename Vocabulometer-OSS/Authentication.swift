//
//  Authentication.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/15.
//

import Foundation
import FirebaseAuth

class Authentication {
    let firebaseAuth = Auth.auth()
    
    func signOut() throws {
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.set(false, forKey: "status")
            NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw error
        }
    }
    
    func signUp(withEmail email: String, password: String, repassword: String) async throws {
        do {
            if password != repassword {
                throw AuthenticationError.invalidPasswordConfirmation
            } else {
                try await Auth.auth().createUser(withEmail: email, password: password)
            }
        } catch {
            throw error
        }
    }
    
    func sendPasswordReset(withEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw error
        }
    }
    
    func checkAuthState() throws -> String {
        if let user = firebaseAuth.currentUser {
            return user.uid
        } else {
            throw AuthenticationError.noUserIsSignedIn
        }
    }
}

enum AuthenticationError: Error, LocalizedError {
    case invalidPasswordConfirmation
    case noUserIsSignedIn
    var errorDescription: String? {
        switch self {
        case .invalidPasswordConfirmation:
            return "The password and the confirm password do not match."
        case .noUserIsSignedIn:
            return "No user is signed in."
        }
    }
}
