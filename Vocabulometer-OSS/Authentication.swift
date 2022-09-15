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
    
    func signOut() {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
