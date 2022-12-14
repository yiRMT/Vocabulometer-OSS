//
//  FlashcardManager.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/08.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FlashcardManager {
    let auth = AuthenticationManager()
    let database = DatabaseManager()
    let uid = Auth.auth().currentUser?.uid
    let firestore = Firestore.firestore()
    
    var cardsData = [String:[String:Any]]()
    var isUpdating = true
    
    /// Get cards data from Firestore
    func getCards() async throws {
        do {
            let uid = try auth.checkAuthState()
            let docRef =  firestore.collection(database.userDataCollection).document(uid)
            let documentSnapshot = try await docRef.getDocument()
            let data = documentSnapshot.data()
            if let originalData = data?["original"] as? [String:[String:Any]] {
                /*
                 [
                    word : [
                        remember : 0,
                        repetition : 0,
                        translatedWord : "..."
                        view : true
                    ],
                    ...
                 ]
                 */
                cardsData = originalData
            }

        } catch {
            throw error
        }
    }
        
    var articleFlashcardsData = [String:[String:Any]]()
    var isArticleFlashcardsUpdating = true
    
    func getArticleFlashcards(completion: @escaping () -> Void) {
        let userData =  firestore.collection(database.userDataCollection).document(uid!)
        userData.getDocument { userSnapshots, error in
            if let err = error {
                print("Error: \(err)")
                return
            } else if let userSnapshots = userSnapshots {
                let results = userSnapshots.data()
                if let originalData = results?["unknownwords"] as? [String:[String:Any]] {
                    /*
                     [
                        word : [
                            remember : 0,
                            repetition : 0,
                            translatedWord : "..."
                            view : true
                        ],
                        ...
                     ]
                     */
                    DispatchQueue.main.async {
                        self.articleFlashcardsData = originalData
                    }
                }
            }
            DispatchQueue.main.async {
                self.isArticleFlashcardsUpdating = false
                completion()
            }
        }
    }
    
    var videoFlashCardsData = [String:[String:Any]]()
    var isVideoFlashcardsUpdating = true
    
    func getVideoFlashcards() async throws {
        do {
            let uid = try auth.checkAuthState()
            let docRef = firestore.collection(database.userDataCollection).document(uid)
            let documentSnapshot = try await docRef.getDocument()
            let data = documentSnapshot.data()
            if let originalData = data?["videoUnknownwords"] as? [String:[String:Any]] {
                /*
                    [
                        word : [
                            remember : 0,
                            repetition : 0,
                            translatedWord : "..."
                            view : true
                        ],
                        ...
                    ]
                */
                videoFlashCardsData = originalData
            }
        } catch {
            throw error
        }
    }
    
    func getVideoFlashcards(completion: @escaping () -> Void) {
        let userData =  firestore.collection(database.userDataCollection).document(uid!)
        userData.getDocument { userSnapshots, error in
            if let err = error {
                print("Error: \(err)")
                return
            } else if let userSnapshots = userSnapshots {
                let results = userSnapshots.data()
                if let originalData = results?["videoUnknownwords"] as? [String:[String:Any]] {
                    /*
                     [
                        word : [
                            remember : 0,
                            repetition : 0,
                            translatedWord : "..."
                            view : true
                        ],
                        ...
                     ]
                     */
                    DispatchQueue.main.async {
                        self.videoFlashCardsData = originalData
                    }
                }
            }
            DispatchQueue.main.async {
                self.isVideoFlashcardsUpdating = false
                completion()
            }
        }
    }
    
    var multiFlashCardsData = [String:[String:Any]]()
    var isMultiFlashcardsUpdating = true
    
    func getMultiFlashcards(completion: @escaping () -> Void) {
        let userData =  firestore.collection(database.userDataCollection).document(uid!)
        userData.getDocument { userSnapshots, error in
            if let err = error {
                print("Error: \(err)")
                return
            } else if let userSnapshots = userSnapshots {
                let results = userSnapshots.data()
                if let originalData = results?["multiUnknownwords"] as? [String:[String:Any]] {
                    /*
                     [
                        word : [
                            remember : 0,
                            repetition : 0,
                            translatedWord : "..."
                            view : true
                        ],
                        ...
                     ]
                     */
                    DispatchQueue.main.async {
                        self.multiFlashCardsData = originalData
                    }
                }
            }
            DispatchQueue.main.async {
                self.isMultiFlashcardsUpdating = false
                completion()
            }
        }
    }
    
    var translatedResult = ""
    
    func translateWord(word: String, completion: @escaping () -> Void) {
        print("Checking translation")
        /// URL?????????
        guard let url = URL(string: "https://script.google.com/macros/s/AKfycbzt9lEf3151KgLRjbaOu5sdTn4hBBY1Y9ZgLxVIiyBALA37Xe5sPQnn3KWeVTCl1tow/exec?text=\(word)&source=en&target=ja") else {
            /// ?????????????????????URL????????????????????????
            return
        }
        
        /// URL????????????????????????
        let request = URLRequest(url: url)
        
        /// URL???????????????
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Accessing")
            
            if let data = data {    // ??????????????????????????????
                print("Checking data")
                /// ???JSON???Response????????????????????????
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(Response.self, from: data) else {
                    print("Json decode ?????????")
                    return
                }

                print(decodedResponse.translated)
                /// ??????????????????UI?????????
                DispatchQueue.main.async {
                    self.translatedResult = decodedResponse.translated
                    completion()
                }
            } else {
                 /// ??????????????????????????????????????????????????????
                 print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()      // ?????????????????????????????????
    }
    
    func translateWordWithDeepL(word: String, completion: @escaping () -> Void) {
        print("Checking translation")
        /// URL?????????
        
        guard let url = URL(string: "https://api.deepl.com/v2/translate?auth_key=2c1055ac-4792-7f39-4a6d-e4a77e5763ec&text=\(word)&target_lang=ja&source_lang=en") else {
            /// ?????????????????????URL????????????????????????
            return
        }
        
        /// URL????????????????????????
        let request = URLRequest(url: url)
        
        /// URL???????????????
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Accessing")
            
            if let data = data {    // ??????????????????????????????
                print("Checking data")
                /// ???JSON???Response????????????????????????
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(DeepLResponse.self, from: data) else {
                    print("Json decode ?????????")
                    return
                }

                print(decodedResponse.translations[0].text)
                /// ??????????????????UI?????????
                DispatchQueue.main.async {
                    self.translatedResult = decodedResponse.translations[0].text
                    completion()
                }
            } else {
                 /// ??????????????????????????????????????????????????????
                 print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()      // ?????????????????????????????????
    }
    
    /// API?????????????????????????????????
    struct Response: Codable {
        var translated: String
    }
     
    struct DeepLResponse: Codable {
        var translations: [Result]
        struct Result: Codable {
            var detected_source_language: String
            var text: String
        }
    }
}
