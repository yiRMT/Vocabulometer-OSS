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
    private let auth = AuthenticationManager()
    private let firestore = Firestore.firestore()
    
    let userDataCollection = "users"
    var isUserDataStored = false
    
    // MARK: User info
    
    /// Check if user info and word list are stored in Firebase
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
                        throw UserInfoError.userWordlistNotStored
                    }
                }
            } else {
                throw UserInfoError.userDataNotStored
            }
        } catch {
            throw error
        }
    }
    
    /// Get user info from Firestore
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
    
    /// Initialize user info
    /// - Parameter userInfoData: a stuct which contains user's age, native language, etc...
    func storeUserInfo(of userInfoData: UserInfo, isHomeView: Bool) throws {
        let userDataField = [
            "userinfo": [
                //"participant": self.participantID,
                "age": userInfoData.age,
                "native": userInfoData.nativeLanguage,
                "gender": userInfoData.gender,
                //"economy": self.economy,
                //"entertainment": self.entertainment,
                //"environment": self.environment,
                //"lifestyle": self.lifestyle,
                //"politics": self.politics,
                //"science": self.science,
                //"sport": self.sport,
                "skill": userInfoData.skill
            ],
            "wordList": isHomeView
        ] as [String : Any]
        
        let videoDataField: [String : Any] = [
            "data": []
        ]
        
        do {
            let uid = try auth.checkAuthState()
            let userDocRef = firestore.collection(userDataCollection).document(uid)
            userDocRef.setData(userDataField, merge: true)
            if !isHomeView {
                let videoDocRef = firestore.collection(userDataCollection).document(uid).collection("download").document("videos")
                videoDocRef.setData(videoDataField, merge: true)
            }
        } catch {
            throw error
        }
    }
    
    /// Update skill data in user info
    /// - Parameter skill: English skill level
    func updateDataOf(_ skill: Int) throws {
        do {
            let uid = try auth.checkAuthState()
            firestore.collection(userDataCollection).document(uid).updateData(["userinfo.skill": skill])
        } catch {
            throw error
        }
    }
    
    /// Set a flag when word list is generated
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
    
    // MARK: Learning statistics
    /// How many words have you read? How many words have you gained?
    
    var statsData = [String:Int]()
    var statsNewData = [String:Int]()
    
    func getStatsData() async throws {
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(userDataCollection).document(uid)
            let documentSnapshot = try await docRef.getDocument()
            let data = documentSnapshot.data()
            if let statsData = data?["stats"] as? [String:Int] {
                self.statsData = statsData
            }
            if let statsNewData = data?["statsNew"] as? [String:Int] {
                self.statsNewData = statsNewData
            }
        } catch {
            throw error
        }
    }
}

enum UserInfoError: Error, LocalizedError {
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
