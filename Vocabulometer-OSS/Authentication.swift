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
    
    func signOut() -> Error? {
        do {
            try firebaseAuth.signOut()
        } catch {
            print(error.localizedDescription)
            return error
        }
        return nil
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            print(error.localizedDescription)
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
            print(error.localizedDescription)
            throw error
        }
    }
    
    func sendPasswordReset(withEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}

enum AuthenticationError: Error, LocalizedError {
    case invalidPasswordConfirmation
    var errorDescription: String? {
        switch self {
        case .invalidPasswordConfirmation:
            return "The password and the confirm password do not match."
        }
    }
}
