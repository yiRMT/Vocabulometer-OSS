//
//  Authentication.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/15.
//

import Foundation
import FirebaseAuth

class Authentication {
    let auth = Auth.auth()
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            try await auth.signIn(withEmail: email, password: password)
        } catch {
            throw error
        }
    }
    
    func signUp(withEmail email: String, password: String, repassword: String) async throws {
        do {
            if password != repassword {
                throw AuthenticationError.invalidPasswordConfirmation
            } else {
                try await auth.createUser(withEmail: email, password: password)
            }
        } catch {
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            UserDefaults.standard.set(false, forKey: "status")
            NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
        } catch {
            throw error
        }
    }
    
    func sendPasswordReset(withEmail email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw error
        }
    }
    
    func checkAuthState() throws -> String {
        if let user = auth.currentUser {
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
