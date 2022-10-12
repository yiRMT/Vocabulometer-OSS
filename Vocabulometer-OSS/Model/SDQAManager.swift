//
//  SDQAManager.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/24.
//

import Foundation

class SDQAManager {
    var sqdaDict = [String]()
    var sqdaBools = [Bool]()
    
    func parse(_ level: String) {
        guard let url = Bundle.main.url(forResource: "SanDiegoQuickAsessment", withExtension: "json") else {
            fatalError("File not found")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Load error")
        }
                
        let decoder = JSONDecoder()

        guard let sqdaWords: SDQAWords = try? decoder.decode(SDQAWords.self, from: data) else {
            fatalError()
        }
        
        switch level {
        case "a":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.a {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "b":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.b {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "c":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.c {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "d":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.d {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "e":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.e {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "f":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.f {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "g":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.g {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "h":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.h {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        case "i":
            sqdaDict = []
            sqdaBools = []
            for sqdaWord in sqdaWords.i {
                self.sqdaDict.append(sqdaWord.word)
                self.sqdaBools.append(sqdaWord.understand)
            }
        default:
            print(self.sqdaDict)
        }
        print(sqdaDict)
    }
}

struct SDQAWords: Codable {
    var a: [SDQAWordList]
    var b: [SDQAWordList]
    var c: [SDQAWordList]
    var d: [SDQAWordList]
    var e: [SDQAWordList]
    var f: [SDQAWordList]
    var g: [SDQAWordList]
    var h: [SDQAWordList]
    var i: [SDQAWordList]
    
    struct SDQAWordList: Codable {
        var word: String
        var understand: Bool
    }
}
