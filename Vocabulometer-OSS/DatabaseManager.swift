//
//  DatabaseManager.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/24.
//

import Foundation
import FirebaseFirestore

class DatabaseManager {
    let auth = Authentication()
    let firestore = Firestore.firestore()
    let userDataCollection = "users"
    
    func checkUserDataStored() async -> Bool {
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            let document = try await docRef.getDocument()
            if document.exists {
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    func getUserInfoData() async throws -> UserInfo {
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            let document = try await docRef.getDocument()
            let data = document.data()
            var userInfo = UserInfo(age: 20, nativeLanguage: "Japanese", gender: "Male", skill: 4)
            
            if let userData = data?["userinfo"] as? [String: Any] {
                if let userAge = userData["age"] as? Int {
                    userInfo.age = userAge
                    print("User age: \(userAge)")
                }
                if let userNativeLanguage = userData["native"] as? String {
                    userInfo.nativeLanguage = userNativeLanguage
                    print("User native language: \(userNativeLanguage)")
                }
                if let userGender = userData["gender"] as? String {
                    userInfo.gender = userGender
                    print("User gender: \(userGender)")
                }
                if let userSkill = userData["skill"] as? Int {
                    userInfo.skill = userSkill
                    print("User skill: \(userSkill)")
                }
            }
            
            return userInfo
        } catch {
            throw error
        }
    }
    
    // Set user info
    func storeUserInfo(of userInfoData: UserInfo) throws {
        let userDataField = [
            "userinfo": [
                "age": userInfoData.age,
                "native": userInfoData.nativeLanguage,
                "gender": userInfoData.gender,
                "skill": userInfoData.skill
            ]
        ]
        
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            docRef.setData(userDataField, merge: true)
        } catch {
            throw error
        }
    }
}

enum DatabaseError: Error, LocalizedError {
    case userDataNotStored
    var errorDescription: String? {
        switch self {
        case .userDataNotStored:
            return "User data is not stored in Firestore."
        }
    }
}
