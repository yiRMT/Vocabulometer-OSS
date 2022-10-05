//
//  ContentsManager.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/25.
//

import Foundation

class ContentsManager {
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
    
    func parseLemma() -> [String:String] {
        let filePath = Bundle.main.path(forResource: "Lemma", ofType: "json")!
        let file = FileHandle(forReadingAtPath: filePath)
        let data = file!.readDataToEndOfFile()
         
        do {
            // パースする
            let json = try JSONSerialization.jsonObject(with: data)
            let dict = json as! Dictionary<String, String>
            //print(dict)
            return dict
        } catch {
            //print(error)
            return [String:String]()
        }
    }
    
    func parseWordListKey() -> [String] {
        let filePath = Bundle.main.path(forResource: "WordFrequencyKey", ofType: "json")!
        let file = FileHandle(forReadingAtPath: filePath)
        let data = file!.readDataToEndOfFile()
         
        do {
            // パースする
            let json = try JSONSerialization.jsonObject(with: data)
            let array = json as! Array<String>
            //print(dict)
            
            return array
        } catch {
            //print(error)
            return [String]()
        }
    }
}

struct Sentence {
    var english: String
    var japanese: String
}
