//
//  WordListGenerator.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/24.
//

import Foundation
import SwiftyJSON
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import NaturalLanguage

class WordListGenerator {
    let firestoreCollection = DatabaseManager().userDataCollection
    let originalAPIManager = OriginalAPIManager()
    let auth = Authentication()
    let database = DatabaseManager()
    let storage = Storage.storage()
    
    var listlength: Int = 0
    var key = [String]()
    var threshold: Int = 0
    var skill: Int = 4
    var range: Int = 0
        
    var nameList = [String]()
    var wordFreqListKey = [String]()
    var wordFamily = [String : String]()

    var dataSource = [[String:Any]]()
    
    var checkList = [String]()
    
    var isLoading = true
    
    func generateWordList(of userSkill: Int) async throws {
        skill = userSkill
        print("Generate wordlist level: \(skill)")
        
        do {
            // Load WordFrequency.json
            let url = Bundle.main.url(forResource: "WordFrequency", withExtension: "json")
            let data = try Data(contentsOf: url!)
            var wordFrequencyList = try JSON(data: data)

            // Load WordFrequencyKey.json
            let keyUrl = Bundle.main.url(forResource: "WordFrequencyKey", withExtension: "json")
            let keyData = try Data(contentsOf: keyUrl!)
            let keyJson = try JSON(data: keyData)
            
            listlength = wordFrequencyList.count
            
            for index in 0 ..< listlength {
                key.append(keyJson[index].stringValue)
            }
            
            threshold = Int(round(Double(listlength) * (Double(skill) - 2) * 0.05))
            range = Int(round(Double(listlength) * 0.01))
            
            let posA = threshold - Int(round(Double(range)/2))
            let posB = threshold + Int(round(Double(range)/2))
            
            for index in (posA..<posB+1).reversed() {
                wordFrequencyList[key[index]]["understand"] = JSON(0.8)
                wordFrequencyList[key[index]]["read"] = JSON(false)
            }
            
            var prob1 = 0.81
            var count1 = 0
            
            for index in (0..<posA+1).reversed() {
                wordFrequencyList[key[index]]["understand"] = JSON(prob1)
                wordFrequencyList[key[index]]["read"] = JSON(false)
                count1 = count1 + 1
                if count1 > range {
                    if prob1 < 1 {
                        prob1 = round((prob1 + 0.01) * 1000) / 1000
                    }
                    count1 = 0
                }
            }
            
            print(wordFrequencyList[key[threshold]])
            
            var prob2 = 0.79
            var count2 = 0
            
            for index in posB..<listlength {
                wordFrequencyList[key[index]]["understand"] = JSON(prob2)
                wordFrequencyList[key[index]]["read"] = JSON(false)
                count2 = count2 + 1
                if(count2 > range){
                  if(prob2 > 0){
                    prob2 = round((prob2 - 0.01) * 1000) / 1000
                  }
                  count2 = 0
                }
            }
            
            // Upload user's wordlist to FirebaseStorage
            
            let wordListData = try wordFrequencyList.rawData()
            let metadata = StorageMetadata()
            metadata.contentType = "application/json"
            
            let uid = try auth.checkAuthState()
            
            storage.reference(withPath: "\(uid)-wordlist.json").putData(wordListData, metadata: metadata)
            
            // ここでFirestoreにフラグを立てる
            try database.setWordListState()
            
            print("Saved data")
        } catch {
            throw error
        }
    }
    
    func generateWordList(of userSkill: Int) {
        skill = userSkill
        
        print("Generate wordlist level: \(skill)")
        
        // Load WordFrequency.json
        let url = Bundle.main.url(forResource: "WordFrequency", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        var wordFrequencyList = (try? JSON(data: data!))!
        
        // Load WordFrequencyKey.json
        let keyUrl = Bundle.main.url(forResource: "WordFrequencyKey", withExtension: "json")
        let keyData = try? Data(contentsOf: keyUrl!)
        let keyJson = (try? JSON(data: keyData!))!
        
        listlength = wordFrequencyList.count
        
        for index in 0 ..< listlength {
            key.append(keyJson[index].stringValue)
        }
                
        threshold = Int(round(Double(listlength) * (Double(skill) - 2) * 0.05))
        range = Int(round(Double(listlength) * 0.01))
        
        let posA = threshold - Int(round(Double(range)/2))
        let posB = threshold + Int(round(Double(range)/2))
        
        for index in (posA..<posB+1).reversed() {
            wordFrequencyList[key[index]]["understand"] = JSON(0.8)
            wordFrequencyList[key[index]]["read"] = JSON(false)
        }
        
        var prob1 = 0.81
        var count1 = 0
        for index in (0..<posA+1).reversed() {
            wordFrequencyList[key[index]]["understand"] = JSON(prob1)
            wordFrequencyList[key[index]]["read"] = JSON(false)
            count1 = count1 + 1
            if count1 > range {
                if prob1 < 1 {
                    prob1 = round((prob1 + 0.01) * 1000) / 1000
                }
                count1 = 0
            }
        }
        print(wordFrequencyList[key[threshold]])
        
        var prob2 = 0.79
        var count2 = 0
        for index in posB..<listlength {
            wordFrequencyList[key[index]]["understand"] = JSON(prob2)
            wordFrequencyList[key[index]]["read"] = JSON(false)
            count2 = count2 + 1
            if(count2 > range){
              if(prob2 > 0){
                prob2 = round((prob2 - 0.01) * 1000) / 1000
              }
              count2 = 0
            }
        }
        
        // Upload user's wordlist to FirebaseStorage
        let storage = Storage.storage()
        if let wordlistData = try? wordFrequencyList.rawData() {
            let metadata = StorageMetadata()
            metadata.contentType = "application/json"
            guard let userID = Auth.auth().currentUser?.uid else {
                print("Cannot fetch userID")
                return
            }
            storage.reference(withPath: "\(userID)-wordlist.json").putData(wordlistData, metadata: metadata)
            
            // ここでFirestoreにフラグを立てる
            
            print("Saved data")
        } else {
            print("Error")
        }
    }
        
    func downloadData() {
        print("Downloading data...")
        
        // Download Namelist
        self.nameList = [String]()
        var url = Bundle.main.url(forResource: "Namelist", withExtension: "json")
        var data = try? Data(contentsOf: url!)
        var json = (try? JSON(data: data!))!
        for index in 0 ..< json.count {
            self.nameList.append(json[index].stringValue)
        }
        
        // Download wordFreqListKey
        self.wordFreqListKey = [String]()
        url = Bundle.main.url(forResource: "wordfreqlist", withExtension: "json")
        data = try? Data(contentsOf: url!)
        json = (try? JSON(data: data!))!
        for (keyValue, _):(String, JSON) in json {
            self.wordFreqListKey.append(keyValue)
        }
        
        // Download word family
        self.wordFamily = [String : String]()
        url = Bundle.main.url(forResource: "wordfamily", withExtension: "json")
        data = try? Data(contentsOf: url!)
        json = (try? JSON(data: data!))!
        for (key, _):(String, JSON) in json {
            self.wordFamily.updateValue(json[key].stringValue, forKey: key)
        }
    }
    
    func parseNameList() -> [String] {
        let filePath = Bundle.main.path(forResource: "Namelist", ofType: "json")!
        let file = FileHandle(forReadingAtPath: filePath)
        let data = file!.readDataToEndOfFile()
         
        do {
            // パースする
            let json = try JSONSerialization.jsonObject(with: data)
            let arr = json as! Array<String>
            //print(dict)
            return arr
        } catch {
            //print(error)
            return [String]()
        }
    }
    
    // MARK: - Estimate a number of unknown words and understanding level of the article.
    func downloadJSON(text: [String], completion: @escaping () -> Void) {
        /// Begin the calculation
        print("Begin the calculation")
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot fetch userID")
            return
        }
        self.isLoading = true
        print("loading...")
        
        /// User's wordlist URL
        var wordListJsonUrl: URL?
        let storage = Storage.storage()
        
        // TODO: - Update FirebaseStorage URL
        let wordListReference = storage.reference(forURL: "gs://vocatest-1322f.appspot.com/\(userID)-wordlist.json")
        
        self.nameList = parseNameList()
        
        /// Fetch the download URL
        wordListReference.downloadURL(completion: { url, error in
            /// Error handling
            if error != nil {
                print(error!.localizedDescription)
                print("fail get downloadURL")
                return
            }
            
            if url != nil {
                /// URL to the user's word list in Firebase Storage
                wordListJsonUrl = url
                                
                // Access to the user's word list
                URLSession.shared.dataTask(with: wordListJsonUrl!) { (data, response, error) in
                    guard let data = data else {
                        print("Error accessing word list in Firebase Storge")
                        return
                    }
                    
                    // Store the user's word list
                    let wordListJson = (try? JSON(data: data))!
        
                    for i in 0 ..< text.count {
                        var hard = 0
                        var count = 0
                        
                        var names = [String]()
                        var finalResult = [String]()
                        
                        print("NLP of text[\(i)] begin")
                        let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .nameType], options: 0)
                        tagger.string = text[i]
                        let range = NSRange(location: 0, length: text[i].utf16.count)
                        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
                        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]
                        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, stop in
                            if let lemma = tag?.rawValue {
                                finalResult.append(lemma.lowercased())
                            }
                        }
                        
                        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, _ in
                            if let tag = tag, tags.contains(tag) {
                                let token = (text[i] as NSString).substring(with: tokenRange)
                                names.append(token.lowercased())
                            }
                        }
                        print("NLP of text[\(i)] end")
                        
                        print("Remove names begin")
                        //finalResult = finalResult.filter{!names.contains($0)}
                        finalResult = finalResult.filter{!self.ifNotNames(value: $0) }
                        //finalResult = finalResult.filter{!self.nameList.contains($0)}
                        print("Remove names end")
                        
                        self.checkList = [String]()
                        
                        print("[Begin] Check if wordfreqlist contains")
                        for j in 0 ..< finalResult.count {
                            //print("[Begin] Check if wordfreqlist contains finalResult[\(j)]")
                            
                            if let understandWord = wordListJson[finalResult[j]]["understand"].double  /*self.wordFreqListKey.contains(finalResult[j])*/ {
                                //print("[Begin] Check if finalResult[\(j)] < 0.8")

                                if(understandWord/*wordListJson[finalResult[j]]["understand"].double!*/ <= 0.8){
                                    hard += 1
                                    if self.checkList.contains(finalResult[j]) == false {
                                        self.checkList.append(finalResult[j])
                                    }
                                }
                                //print("[End] Check if finalResult[\(j)] < 0.8")
                            }
                            count += 1
                            //print("[End] Check if wordfreqlist contains finalResult[\(j)]")
                        }
                        print("[End] Check if wordfreqlist contains")
                        
                        let percentage = round( (1 - (Double(hard)/Double(count)) ) * 1000 ) / 10
                        
                        DispatchQueue.main.async {
                            self.dataSource.append(["percentage": percentage, "hard": self.checkList.count])
                        }

                        print("Calculation of article \(i+1)/\(text.count) finished")
                        print("Check list: \(self.checkList)")
                        
                    }
                    
                    print("End of calculation")
                    print("Data: \(self.dataSource)")
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion()
                    }
                }.resume()
            } else {
                print("url is nil")
                return
            }
        })
    }
    
    func ifNotNames(value: String) -> Bool {
        if self.nameList.firstIndex(of: value) != nil {
            return true
        }
        return false
    }
    
    /// 単語リストを更新・Firestoreに単語を格納
    /// - Parameters:
    ///   - originalUnknownWords: チェック前の未知単語リスト
    ///   - checkedUnknownWords: チェック済みの未知単語リスト
    ///   - completion: 終了後に行うことを記述
    func updateWordList(originalUnknownWords: [String], checkedUnknownWords: [String], contentType: ContentType, sentences: [String:Sentence], totalWords: Int, videoID: String?, completion: @escaping () -> Void) {
        /// 既知単語を格納
        var knownWords = [String]()
        
        for word in originalUnknownWords {
            if !checkedUnknownWords.contains(word) {
                knownWords.append(word)
            }
        }
        
        /// UIDを取得　ドキュメントを探すのに必要
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot fetch userID")
            return
        }
        
        self.isLoading = true
        
        /// Storageに保存してあるファイルを読み取る
        var wordListJsonUrl: URL?
        let storage = Storage.storage()
        let wordListReference = storage.reference(forURL: "gs://vocatest-1322f.appspot.com/\(userID)-wordlist.json")
        
        // Fetch the download URL
        wordListReference.downloadURL { url, error in
            // Error handling
            if error != nil {
                print(error!.localizedDescription)
                print("fail get downloadURL")
                return
            }
            
            if url != nil {
                // URL to the user's word list in Firebase Storage
                wordListJsonUrl = url
                                
                // Access to the user's word list
                URLSession.shared.dataTask(with: wordListJsonUrl!) { (data, response, error) in
                    guard let data = data else {
                        print("Error accessing word list in Firebase Storge")
                        return
                    }
                    
                    let document = userID
                    
                    // Store the user's word list
                    var wordListJson = (try? JSON(data: data))!
                    
                    var unknownWordsDetailData = [String:Any]()
                    
                    /// 既知単語に対する処理
                    for word in knownWords {
                        /// 既知である確率を1に設定
                        wordListJson[word]["understand"] = JSON(1.0)
                        /// 見たことにあるにtrueを設定
                        wordListJson[word]["read"] = JSON(true)
                        
                        switch contentType {
                        case .article:
                            Firestore.firestore().collection(self.firestoreCollection).document(document).updateData(["unknownwords.\(word)": FieldValue.delete()])
                            Firestore.firestore().collection(self.firestoreCollection).document(document).updateData(["multiUnknownwords.\(word)": FieldValue.delete()])
                        }
                    }
                    
                    var newWordsCount = 0
                    
                    /// 未知単語に対する処理
                    for word in checkedUnknownWords {
                        if !wordListJson[word]["read"].boolValue {
                            newWordsCount += 1
                            /// 見たことにあるにtrueを設定
                            wordListJson[word]["read"] = JSON(true)
                        }
                        
                        
                        
                        /// 手動で登録する単語はunderstandの確率を変えてやる
                        if wordListJson[word]["understand"].doubleValue > 0.8 {
                            wordListJson[word]["understand"] = JSON(0.79)
                        }
                        
                        let dt = Date()
                        let dateFormatter = DateFormatter()

                        // DateFormatter を使用して書式とロケールを指定する
                        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: Locale(identifier: "ja_JP"))
                        
                        let wordData: [String:Any] = [
                            "original": word,
                            "videoID": videoID ?? "",
                            //"translatedWord" : "",
                            "parts": wordListJson[word]["parts"].stringValue,
                            "rank": wordListJson[word]["rank"].intValue,
                            "understand": wordListJson[word]["understand"].doubleValue,
                            "sentence": sentences[word]?.english ?? "",
                            "translatedSentence": sentences[word]?.japanese ?? "",
                            "lastTime": dateFormatter.string(from: dt),
                            "remember": 0,
                            "repetition" : 0,
                            "view" : true,
                            "contentType": contentType.rawValue
                        ]
                        
                        unknownWordsDetailData.updateValue(wordData, forKey: word)
                    }
                    
                    print("Words: \(unknownWordsDetailData)")
                    
                    switch contentType {
                    case .article:
                        let unknownWordsData = [
                            "unknownwords" : unknownWordsDetailData,
                            "multiUnknownwords" : unknownWordsDetailData
                        ]
                        
                        if !checkedUnknownWords.isEmpty {
                            Firestore.firestore().collection(self.firestoreCollection).document(document).setData(unknownWordsData, merge: true)
                            
                            for word in checkedUnknownWords {
                                self.originalAPIManager.translate(with: .google, word: word) { translatedWord in
                                    let data = [
                                        "unknownwords" : [
                                            word : [
                                                "translatedWord": translatedWord
                                            ]
                                        ],
                                        "multiUnknownwords" : [
                                            word : [
                                                "translatedWord": translatedWord
                                            ]
                                        ]
                                    ]
                                    Firestore.firestore().collection(self.firestoreCollection).document(document).setData(data, merge: true)
                                }
                            }
                        }
                        break
                    }
                    
                    let dt = Date()
                    let dateFormatter = DateFormatter()

                    // DateFormatter を使用して書式とロケールを指定する
                    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: Locale(identifier: "ja_JP"))
                    let today = dateFormatter.string(from: dt)
                    
                    var stats = totalWords
                    var statsNew = newWordsCount
                    
                    
                    Firestore.firestore().collection(self.firestoreCollection).document(document).getDocument { (documentSnapshot, error) in
                        if let document = documentSnapshot {
                            let results = document.data()
                            if let currentStatsData = results?["stats"] as? [String:Int] {
                                if let todayStats = currentStatsData[today] {
                                    print("statsが見つかりました: \(todayStats)")
                                    stats += todayStats
                                }
                            }
                            if let currentStatsNewData = results?["statsNew"] as? [String:Int] {
                                if let todayStatsNew = currentStatsNewData[today] {
                                    print("statsNewが見つかりました: \(todayStatsNew)")
                                    statsNew += todayStatsNew
                                }
                            }
                        }
                        
                        print("Stats: \(stats)")
                        print("StatsNew: \(statsNew)")
                        
                        Firestore.firestore().collection(self.firestoreCollection).document(document).setData(["stats": [today: stats]], merge: true)
                        Firestore.firestore().collection(self.firestoreCollection).document(document).setData(["statsNew": [today: statsNew]], merge: true)
                    }
                    
                    // Firebase Storage
                    let storage = Storage.storage()
                    if let wordlistData = try? wordListJson.rawData() {
                        let metadata = StorageMetadata()
                        metadata.contentType = "application/json"
                        guard let userID = Auth.auth().currentUser?.uid else {
                            print("Cannot fetch userID")
                            return
                        }
                        storage.reference(withPath: "\(userID)-wordlist.json").putData(wordlistData, metadata: metadata)
                    }
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion()
                    }
                }.resume()
            } else {
                print("url is nil")
                return
            }
        }
    }
    
    func updateTranslation(of word: String, to translation: String, type: ContentType) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Cannot fetch userID")
            return
        }
        
        let document = userID
        
        var fieldName = ""
        
        switch type {
        case .article:
            fieldName = "unknownwords"
        }
        
        let data = [
            fieldName : [
                word : [
                    "translatedWord": translation
                ]
            ]
        ]
        
        Firestore.firestore().collection(self.firestoreCollection).document(document).setData(data, merge: true)
    }
}

enum ContentType: String {
    case article = "article"
}
