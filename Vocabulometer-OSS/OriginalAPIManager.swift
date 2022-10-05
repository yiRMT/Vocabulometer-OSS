//
//  OriginalAPIManager.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/25.
//

import Foundation

class OriginalAPIManager {
    var translatedResult = ""
    
    func translate(with api: TranslateType, word: String, completion: @escaping (String) -> Void) {
        print("Checking translation")
        
        var apiURL: String {
            switch api {
            case .google:
                return "https://script.google.com/macros/s/AKfycbzt9lEf3151KgLRjbaOu5sdTn4hBBY1Y9ZgLxVIiyBALA37Xe5sPQnn3KWeVTCl1tow/exec?text=\(word)&source=en&target=ja"
            case .deepL:
                return "Write API url here"
            }
        }
        
        /// URLの生成
        guard let url = URL(string: apiURL) else { return }
        
        /// URLリクエストの生成
        let request = URLRequest(url: url)
        
        /// URLにアクセス
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Accessing")
            
            if let data = data {
                print("Checking data")

                let decoder = JSONDecoder()
                
                switch api {
                case .google:
                    guard let decodedResponse = try? decoder.decode(GoogleTranslateResponse.self, from: data) else {
                        print("Json decode エラー")
                        return
                    }
                    
                    print(decodedResponse.translated)

                    self.translatedResult = decodedResponse.translated
                    completion(self.translatedResult)
                case .deepL:
                    guard let decodedResponse = try? decoder.decode(DeepLResponse.self, from: data) else {
                        print("Json decode エラー")
                        return
                    }
                    
                    print(decodedResponse.translations.first!.text)

                    self.translatedResult = decodedResponse.translations.first!.text
                    completion(self.translatedResult)
                }
                
            } else {
                 print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()      // タスク開始処理（必須）
    }
    
    /// APIから取得する戻り値の型
    struct GoogleTranslateResponse: Codable {
        var translated: String
    }
     
    struct DeepLResponse: Codable {
        var translations: [Result]
        struct Result: Codable {
            var detected_source_language: String
            var text: String
        }
    }
    
    enum TranslateType {
        case google
        case deepL
    }
}
