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
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func signUp(withEmail email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
