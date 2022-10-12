//
//  ArticleManager.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/12.
//

import Foundation
import UIKit

// Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// JSON Decoder and Encoder
import SwiftyJSON

class ArticleManager: ContentsManager {
    // MARK: Variables
    /// Store article data
    var listOfArticles = [Article]()
    /// Store data from local JSON files
    var nameList = [String]()
    var wordFrequencyListKey = [String]()
    var wordFamily = [String : String]()
    
    /// Unknown word counts and percentages
    var dataSource = [[String:Any]]()
    /// A list of nknown words
    var unknownWords = [[String]]()
    var originalWords = [[String]]()
    
    // Variables related to unknown words estimation
    /// Store check list
    var checkList = [String]()
    var checkListOriginal = [String]()
        
    var sentenceDictionary = [String:Sentence]()
    
    // MARK: Functions
    /// Estimate appropriate article levels for users
    /// - Returns: Article levels optimised to datasets
    func articleLevel(_ levelSelect: String, _ userSkill: Int) -> Int {
        var adjustedLevel = 3
        
        switch levelSelect {
        case "Easy":
            adjustedLevel = userSkill - 2
        case "Balanced":
            adjustedLevel = userSkill
        case "Hard":
            adjustedLevel = userSkill + 2
        default:
            print("Adjusted a level")
        }
        
        if adjustedLevel < 3 {
            return 3
        } else if adjustedLevel > 10 {
            return 10
        } else {
            return adjustedLevel
        }
    }
    
    func findArticles(level: Int, category: String) async throws -> [Article] {
        listOfArticles = .init()
        
        let fileName = convertDatasetTitle(level: level)
        print(fileName)
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")
        
        do {
            let data = try Data(contentsOf: url!)
            let articleList = try JSON(data: data)
            let numberOfArticles = articleList[category].count
            print("Number of articles: \(numberOfArticles)")
            
            if numberOfArticles != 0 {
                for articleIndex in 0 ..< numberOfArticles {
                    let idJSON = articleList[category][articleIndex]["id"]
                    let titleJSON = articleList[category][articleIndex]["title"]
                    let textJSON = articleList[category][articleIndex]["text"]
                    
                    listOfArticles.append(Article(id: idJSON.int!, title: titleJSON.string!, text: textJSON.string!))
                }
            }
            
            return listOfArticles
        } catch {
            throw error
        }
    }
        
    func convertDatasetTitle(level: Int) -> String {
        return "textdata" + (String)(level)
    }
        
    func estimateUnknownWords() async throws {
        // Begin the calculation
        print("Begin the calculation")
        do {
            let uid = try auth.checkAuthState()
                        
            // User's wordlist URL
            let storage = Storage.storage()
            let wordListReference = storage.reference(forURL: "gs://vocatest-1322f.appspot.com/\(uid)-wordlist.json")
            // URL to the user's word list in Firebase Storage
            let wordListJsonUrl = try await wordListReference.downloadURL()
            
            // Access to the user's word list
            let (data, _) = try await URLSession.shared.data(from: wordListJsonUrl)
            // 名前のリストとレンマを読み込む
            let nameList = parseNameList()
            let lemma = parseLemma()
            
            // ユーザのワードリストを読み込み
            let wordListJson = try JSON(data: data)
            
            DispatchQueue.main.async {
                self.dataSource = .init()
                self.unknownWords = .init()
                self.originalWords = .init()
            }
            
            // 各文章について
            for i in 0 ..< listOfArticles.count {
                var hard = 0
                //var count = 0
                let count: Wrapper<Int> = Wrapper(0)
                
                let str = listOfArticles[i].text.lowercased().trimmingCharacters(in: .whitespaces).replacingOccurrences(of: #"[\n_#:;.,!?\"() ]+"#, with: "-", options: [.regularExpression]).components(separatedBy: "-")
                var words = Set(str.filter { (($0 >= "a") && ($0 <= "z")) || (($0 >= "A") && ($0 <= "Z")) })
                words.subtract(nameList)
                var finalResult = Array(words)
                let copiedResult = finalResult
                
                checkList = [String]()
                checkListOriginal = [String]()
                
                //print("[Begin] Check if wordfreqlist contains")
                for j in 0 ..< finalResult.count {
                    if let lemmaResult = lemma[finalResult[j]] {
                        finalResult[j] = lemmaResult
                    }
                    
                    if let understandWord = wordListJson[finalResult[j]]["understand"].double {
                        if(understandWord <= 0.8){
                            hard += 1
                            if checkList.contains(finalResult[j]) == false {
                                checkList.append(finalResult[j])
                                checkListOriginal.append(copiedResult[j])
                            }
                        }
                    }
                    
                    count.value += 1
                }
                //print("[End] Check if wordfreqlist contains")
                
                let percentage = round( (1 - (Double(hard)/Double(count.value)) ) * 1000 ) / 10
                
                DispatchQueue.main.async {
                    self.dataSource.append(["percentage": percentage, "hard": self.checkList.count, "total": count.value])
                    self.unknownWords.append(self.checkList)
                    self.originalWords.append(self.checkListOriginal)
                }

                //print("Calculation of article \(i+1)/\(self.listOfArticles.count) finished")
                //print("Check list: \(self.checkList)")
            }
            
            print("End of calculation")
            print("Data: \(self.dataSource)")
            print("Unknown words: \(self.unknownWords)")
            print("Original words: \(self.originalWords)")
            
        } catch {
            throw error
        }
    }
    
    func getSentence(text: String, unknownWords: [String], originalWords: [String]) async throws {
        sentenceDictionary = .init()
        print(text)
        for i in 0..<unknownWords.count {
            var sentence = Sentence(english: "", japanese: "", startTime: 0.0)
            let regexPattern = #"[.#\n\t][A-Za-z0-9 ,\"\'\-]*("# + originalWords[i] + #")([_:;.!?\"\'()\n\t]|[ ,\"\'\-][A-Za-z0-9 ,\"\'\-]+[_:;.!?\"\'()\n\t])"#
            let result = text.match(regexPattern)
            if !result.isEmpty {
                var resultSentence = result.first!
                resultSentence.removeFirst()
                sentence = Sentence(english: resultSentence, japanese: "", startTime: 0.0)
                sentenceDictionary.updateValue(sentence, forKey: unknownWords[i])
            } else {
                sentence = Sentence(english: "Could not find the example sentence.", japanese: "", startTime: 0.0)
                sentenceDictionary.updateValue(sentence, forKey: unknownWords[i])
            }
            
            print("Sentence for: \(unknownWords[i])")
            print("English: \(sentence.english)")
            print("Japanese: \(sentence.japanese)")
        }
    }
        
    var registerWord = ""
    var originalWord = ""
    
    func registerNewWord(word: String, currentUnknownWords: [String], text: String) async throws {
        registerWord = word
        originalWord = word
        
        let lemma = parseLemma()
        if let lemmaResult = lemma[word] {
            registerWord = lemmaResult
        }
        
        guard !currentUnknownWords.contains(registerWord) else {
            print("Already registered")
            throw ArticleError.targetWordIsAlreadyRegistered
        }
        
        let wordList = parseWordListKey()
        guard wordList.contains(registerWord) else {
            throw ArticleError.notFoundInWordList
        }
               
        sentenceDictionary = .init()
        print(text)

        var sentence = Sentence(english: "", japanese: "", startTime: 0.0)
        let regexPattern = #"[.#\n\t][A-Za-z0-9 ,\"\'\-]*("# + word + #")([_:;.!?\"\'()\n\t]|[ ,\"\'\-][A-Za-z0-9 ,\"\'\-]+[_:;.!?\"\'()\n\t])"#
        let result = text.match(regexPattern)
        if !result.isEmpty {
            var resultSentence = result.first!
            resultSentence.removeFirst()
            sentence = Sentence(english: resultSentence, japanese: "", startTime: 0.0)
            sentenceDictionary.updateValue(sentence, forKey: registerWord)
        } else {
            sentence = Sentence(english: "Could not find the example sentence.", japanese: "", startTime: 0.0)
            sentenceDictionary.updateValue(sentence, forKey: registerWord)
        }
        
        print("Sentence for: \(word)")
        print("English: \(sentence.english)")
        print("Japanese: \(sentence.japanese)")
        
        if sentence.english != "Could not find the example sentence." {
            return
        }
        
        throw ArticleError.failedToRegister
    }
}

struct Article {
    var id: Int
    var title: String
    var text: String
}

struct ArticleUnknownWords {
    var lastTime: String
    var parts: String
    var rank: Int
    var repetition: Int
    var sentence: String
    var understand: Double
    var view: Bool
}

enum ArticleError: Error, LocalizedError {
    case targetWordIsAlreadyRegistered
    case notFoundInWordList
    case failedToRegister
    var errorDescription: String? {
        switch self {
        case .targetWordIsAlreadyRegistered:
            return "This word is already registered as an unknown word."
        case .notFoundInWordList:
            return "This word was not found in the word list."
        case .failedToRegister:
            return "Failed to register this word."
        }
    }
}
