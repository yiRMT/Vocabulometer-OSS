//
//  ArticleFlashcardViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/08.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseFirestore

class ArticleFlashcardViewController: UIViewController {
    // MARK: 変数
    /// Firebase関連
    let database = DatabaseManager()
    let uid = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    /// Flashcard用のModel
    var flashcardManager = FlashcardManager()
    /// 読み上げ用のAPI
    let synthesizer = AVSpeechSynthesizer()
    /// Activity Indicator（読み込み時のくるくる）
    var activityIndicatorView = UIActivityIndicatorView()
    /// Flashcard用の状態変数
    var currentCardIndex = 0
    var inputCards = [String]()
    var cardsData = [String:[String:Any]]()
    var cardsKey = [String]()
    var isEnglish = true
    var isUpdating = true
    
    // MARK: UI部品（共通）
    /// FlashcardをまとめたView
    @IBOutlet weak var flashcardView: UIView!
    /// Flashcard内部のUI部品（共通）
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var japaneseLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    /// カードが空になったときに表示させるラベル
    @IBOutlet weak var resetLabel: UILabel!

    // MARK: UI部品（Article用）
    /// Articleの例文を表示させるUI部品
    @IBOutlet weak var sentenceLabel: UILabel!
    @IBOutlet weak var sentenceSwitch: UISwitch!
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()

        synthesizer.delegate = self
        
        resetLabel.isHidden = true
        
        // ActivityIndicatorを作成＆中央に配置
        activityIndicatorView.center = flashcardView.center
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        // クルクルをストップした時に非表示する
        activityIndicatorView.hidesWhenStopped = true
        // Viewに追加
        flashcardView.addSubview(activityIndicatorView)
        
        // Do any additional setup after loading the view.
        flashcardView.layer.cornerRadius = 10
        flashcardView.layer.shadowColor = UIColor.black.cgColor
        flashcardView.layer.shadowOpacity = 0.5
        flashcardView.layer.shadowRadius = 8
        flashcardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        sentenceLabel.numberOfLines = 0
        
        reloadFlashcard()
        
        statusLabel.text = "\(currentCardIndex+1)/\(cardsKey.count)"
        
        /// 読み上げ設定
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSession.Category.playback) 
    }
    
    // MARK: イベント処理（共通）
    
    /// 単語翻訳ボタンを押したときの処理
    /// - Parameter sender:
    @IBAction func tapTranslate(_ sender: Any) {
        isEnglish = false
        japaneseLabel.text = "翻訳中..."
        japaneseLabel.isHidden = false
        
        guard let wordData = cardsData[englishLabel.text!] else { return }
        
        guard let translatedWord = wordData["translatedWord"] as? String else {
            return
        }
        
        if translatedWord != "" {
            japaneseLabel.text = translatedWord
        } else {
            flashcardManager.translateWord(word: englishLabel.text ?? "") {
                self.japaneseLabel.text = self.flashcardManager.translatedResult
            }
        }
    }
    
    /// 単語読み上げボタンを押した時の処理
    /// - Parameter sender:
    @IBAction func tapSpeech(_ sender: Any) {
        if let englishString = englishLabel.text {
            let utterance = AVSpeechUtterance(string: englishString)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.2
            synthesizer.speak(utterance)
        }
    }
    
    /// 暗記したボタンを押した時の処理
    /// - Parameter sender:
    @IBAction func tapRemember(_ sender: Any) {
        isEnglish = true
        japaneseLabel.isHidden = true
        nextCard(isRemember: true)
        if cardsKey.count > currentCardIndex {
            englishLabel.text = cardsKey[currentCardIndex]
            sentenceLabel.text = cardsData[englishLabel.text!]!["sentence"] as? String
        }
    }
    
    /// 暗記していないボタンを押した時の処理
    /// - Parameter sender:
    @IBAction func tapNotRemember(_ sender: Any) {
        isEnglish = true
        japaneseLabel.isHidden = true
        nextCard(isRemember: false)
        if cardsKey.count > currentCardIndex {
            englishLabel.text = cardsKey[currentCardIndex]
            sentenceLabel.text = cardsData[englishLabel.text!]!["sentence"] as? String
        }
    }
    
    /// 再読み込みボタンを押した時の処理
    /// - Parameter sender:
    @IBAction func tapReload(_ sender: Any) {
        reloadFlashcard()
    }
    
    /// カードリセットボタンを押した時の処理
    /// - Parameter sender:
    @IBAction func tapReset(_ sender: Any) {
        resetCards {
        }
    }
    
    // MARK: イベント処理（Article用）
    /// 例文の表示切り替え処理
    /// - Parameter sender:
    @IBAction func toggleSentence(_ sender: Any) {
        if sentenceSwitch.isOn {
            sentenceLabel.isHidden = false
        } else {
            sentenceLabel.isHidden = true
        }
    }
    
    // MARK: 関数（共通）
    /// 次のカードを表示するための関数
    /// - Parameter isRemember: 暗記したか暗記していないかBool値で渡す
    func nextCard(isRemember: Bool) {
        let word: String = cardsKey[currentCardIndex]
        
        let dt = Date()
        let dateFormatter = DateFormatter()

        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMd", options: 0, locale: Locale(identifier: "ja_JP"))
        
        cardsData[word]?["lastTime"] = dateFormatter.string(from: dt)
        
        if isRemember {
            cardsData[word]?["view"] = false
            if let remeber = cardsData[word]?["remember"] as? Int {
                if remeber > 0 {
                    cardsData[word]?["remember"] = remeber + 1
                } else {
                    cardsData[word]?["remember"] = 1
                }
            }
        } else {
            cardsData[word]?["view"] = true
        }
        
        if let repetition = cardsData[word]?["repetition"] as? Int {
            if repetition > 0 {
                cardsData[word]?["repetition"] = repetition + 1
            } else {
                cardsData[word]?["repetition"] = 1
            }
        }
        
        currentCardIndex += 1
        
        if cardsKey.count > currentCardIndex {
            print("Next card")
            statusLabel.text = "\(currentCardIndex+1)/\(cardsKey.count)"
        } else {
            print("Remake")
            activityIndicatorView.startAnimating()
            makeNewCards {
                print("Cards remaked")
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    /// Firebase上のフラッシュカードの情報をリセットする
    /// 使用前の状態に戻す
    /// - Parameter completion: 非同期処理完了後に行う処理を記述
    func resetCards(completion: @escaping () -> Void) {
        guard let document = uid else {
            print("Couldn't find User ID!")
            return
        }
        
        for word in Array(cardsData.keys) {
            cardsData[word]?["view"] = true
            cardsData[word]?["remember"] = 0
            cardsData[word]?["repetition"] = 0
        }
        
        let data = [
            "unknownwords" : cardsData
        ]
        
        db.collection(database.userDataCollection).document(document).setData(data, merge: true)
        DispatchQueue.main.async {
            self.isUpdating = true
            self.statusLabel.text = "\(self.currentCardIndex+1)/\(self.cardsKey.count)"
            self.reloadFlashcard()
            completion()
        }
    }
    
    /// カードを一周した際に行う処理
    /// - Parameter completion: 非同期処理完了後に行う処理を記述
    func makeNewCards(completion: @escaping () -> Void) {
        guard let document = uid else {
            print("Couldn't find User ID!")
            return
        }
        
        let data = [
            "unknownwords" : cardsData
        ]
        
        db.collection(database.userDataCollection).document(document).setData(data, merge: true)
        
        DispatchQueue.main.async {
            self.reloadFlashcard()
            self.isUpdating = true
            completion()
        }
    }
    
    
    
    // MARK: 関数（Article用）
    // 変数をコンテンツごとに変更してやる必要がある
    /// カードのキー（cardsKey）の状態を更新する
    func setCards() {
        cardsKey = [String]()
        let completeCardsKey = Array(flashcardManager.articleFlashcardsData.keys)
        for word in completeCardsKey {
            if let view = cardsData[word]?["view"] as? Bool {
                if view == true {
                    cardsKey.append(word)
                }
            }
        }
    }
    
    /// フラッシュカードの内容を更新する
    /// cardsKeyが空かどうかによってフラッシュカードの内容を変更する
    func reloadFlashcard() {
        activityIndicatorView.startAnimating()
        flashcardManager.getArticleFlashcards {
            self.currentCardIndex = 0
            self.cardsData = self.flashcardManager.articleFlashcardsData
            self.setCards()
            print("Card key: \(self.cardsKey)")
            if !self.cardsKey.isEmpty {
                self.flashcardView.isHidden = false
                self.resetLabel.isHidden = true
                self.englishLabel.text = self.cardsKey.first ?? "No card registered"
                self.japaneseLabel.isHidden = true
                self.sentenceLabel.text = self.cardsData[self.englishLabel.text!]!["sentence"] as? String
                self.isUpdating = self.flashcardManager.isArticleFlashcardsUpdating
                
                self.statusLabel.text = "\(self.currentCardIndex+1)/\(self.cardsKey.count)"
            } else {
                self.flashcardView.isHidden = true
                self.resetLabel.isHidden = false
            }
            self.activityIndicatorView.stopAnimating()
        }
    }
}

// MARK: 読み上げ機能のDelegate
extension ArticleFlashcardViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
           print("読み上げ開始")
        }
        
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
       print("読み上げ終了")
    }
}

// とりあえず用意したが不要かも
struct ArticleFlashcard {
    var english: String
    var japanese: String
    var sentence: String
}
