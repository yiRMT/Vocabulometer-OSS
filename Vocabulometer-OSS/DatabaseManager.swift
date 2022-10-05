//
//  DatabaseManager.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class DatabaseManager {
    let auth = Authentication()
    let firestore = Firestore.firestore()
    let userDataCollection = "users"
    
    func checkUserDataStored() async throws {
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            let document = try await docRef.getDocument()
            let data = document.data()
            if document.exists {
                if let state = data?["wordList"] as? Bool {
                    if state {
                        return
                    } else {
                        throw DatabaseError.userWordlistNotStored
                    }
                }
            } else {
                throw DatabaseError.userDataNotStored
            }
        } catch {
            throw error
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
        let wordListField = [
            "wordList": false
        ]
        
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            docRef.setData(userDataField, merge: true)
            docRef.setData(wordListField, merge: true)
        } catch {
            throw error
        }
    }
    
    func updateDataOf(_ skill: Int) throws {
        do {
            let uid = try auth.checkAuthState()
            firestore.collection(userDataCollection).document(uid).updateData(["userinfo.skill": skill])
        } catch {
            throw error
        }
    }
    
    func setWordListState() throws {
        let data = [
            "wordList": true
        ]
        
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            docRef.setData(data, merge: true)
        } catch {
            throw error
        }
    }
}

enum DatabaseError: Error, LocalizedError {
    case userDataNotStored
    case userWordlistNotStored
    var errorDescription: String? {
        switch self {
        case .userDataNotStored:
            return "User data is not stored in Firestore."
        case .userWordlistNotStored:
            return "Wordlist is not stored in Firebase Storage."
        }
    }
}
