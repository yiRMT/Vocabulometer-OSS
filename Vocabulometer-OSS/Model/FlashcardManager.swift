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
        /// URLの生成
        guard let url = URL(string: "https://script.google.com/macros/s/AKfycbzt9lEf3151KgLRjbaOu5sdTn4hBBY1Y9ZgLxVIiyBALA37Xe5sPQnn3KWeVTCl1tow/exec?text=\(word)&source=en&target=ja") else {
            /// 文字列が有効なURLでない場合の処理
            return
        }
        
        /// URLリクエストの生成
        let request = URLRequest(url: url)
        
        /// URLにアクセス
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Accessing")
            
            if let data = data {    // ①データ取得チェック
                print("Checking data")
                /// ②JSON→Responseオブジェクト変換
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(Response.self, from: data) else {
                    print("Json decode エラー")
                    return
                }

                print(decodedResponse.translated)
                /// ③書籍情報をUIに適用
                DispatchQueue.main.async {
                    self.translatedResult = decodedResponse.translated
                    completion()
                }
            } else {
                 /// ④データが取得できなかった場合の処理
                 print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()      // タスク開始処理（必須）
    }
    
    func translateWordWithDeepL(word: String, completion: @escaping () -> Void) {
        print("Checking translation")
        /// URLの生成
        
        guard let url = URL(string: "https://api.deepl.com/v2/translate?auth_key=2c1055ac-4792-7f39-4a6d-e4a77e5763ec&text=\(word)&target_lang=ja&source_lang=en") else {
            /// 文字列が有効なURLでない場合の処理
            return
        }
        
        /// URLリクエストの生成
        let request = URLRequest(url: url)
        
        /// URLにアクセス
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Accessing")
            
            if let data = data {    // ①データ取得チェック
                print("Checking data")
                /// ②JSON→Responseオブジェクト変換
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(DeepLResponse.self, from: data) else {
                    print("Json decode エラー")
                    return
                }

                print(decodedResponse.translations[0].text)
                /// ③書籍情報をUIに適用
                DispatchQueue.main.async {
                    self.translatedResult = decodedResponse.translations[0].text
                    completion()
                }
            } else {
                 /// ④データが取得できなかった場合の処理
                 print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()      // タスク開始処理（必須）
    }
    
    /// APIから取得する戻り値の型
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
