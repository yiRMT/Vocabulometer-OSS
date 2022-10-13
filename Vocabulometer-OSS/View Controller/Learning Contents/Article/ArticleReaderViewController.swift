//
//  ArticleReaderViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/04/26.
//

import UIKit
import RegeributedTextView
import CoreMotion

class ArticleReaderViewController: UIViewController {
    var articleManager = ArticleManager()
    var wordListGenerator = WordListGenerator()
    var originalAPIManager = OriginalAPIManager()
    // MotionManager
    let motionManager = CMMotionManager()
    
    var contentType = ContentType.article
    
    var article = Article(id: 0, title: "Sample", text: "\tLUXOR, Egypt - King Tut may be buried in an ancient Egyptian queen's tomb.\n\nMamdouh el-Damaty, Egypt's antiquities minister, said Tuesday that the 3,300-year-old tomb may contain hidden chambers.\n\nEl-Damaty said he will seek approval to use radar to inspect the tomb, by bouncing radio waves off of any objects. He made the announcement while touring the burial sites of Tutankhamun, known as King Tut, and other pharaohs in the famed Valley of the Kings.\n\n## Was Tut Tucked Into Nefertiti's Tomb?\n\nEl-Damaty was visiting Luxor with Egyptologist Nicholas Reeves, a British expert on ancient Egypt. Reeves recently speculated that Tutankhamun may have been buried in an outer chamber of what was originally the tomb of Egyptian Queen Nefertiti. King Tut died at the age of 19.\n\nReeves said high-resolution images of the tomb \"revealed several very interesting features which look not at all natural.\" They include \"very, very straight lines which are 90 degrees to the ground.\" He said the lines seem to correspond with other features within the tomb.\n\nThe features are difficult to see with the naked eye, he said.\n\n## Design Indicates That Queen Is Buried There\n\nReeves said the walls could conceal two hidden doorways. One of them perhaps leads to Nefertiti's burial place. He also argued that the design of the tomb suggests it was built for a queen, rather than a king.\n\n\"I agree with him that there's probably something behind the walls,\" el-Damaty said. But he said if anyone is buried there it is likely Kia, believed by some Egyptologists to be King Tut's mother.\n\nNefertiti was famed for her beauty and was the model for a famous 3,300-year-old sculpture. She was the main wife of the Pharaoh Akhenaten, who introduced an early form of monotheism, or belief in one god, into Egypt. Akhenaten was followed by a pharaoh called Smenkhare and then Tut, who is widely believed to have been Akhenaten's son.\n\nReeves argues that Smenkhare is actually Nefertiti.\n\n## Ancient Egypt Awash In Mystery\n\nAround the same time that Smenkhare became pharoah, Nefertiti seemed to just disappear from history \"according to the latest inscriptions just being found,\" said Reeves. He explained his theory inside King Tut's tomb. \"I think that Nefertiti didn't disappear, she simply changed her name.\"\n\nAfter Nefertiti died, Tut was responsible for burying her. Then when he died, someone decided to build more chambers in the tomb, Reeves suggested. \"I think since Nefertiti had been buried a decade before, they remembered that tomb was there and they thought, 'Well, perhaps we can extend it,'\" he said.\n\nAny discovery would provide more information about this turbulent time in ancient Egypt.\n\n\"Akhenaten's family is full of secrets and historical issues that have yet to be resolved,\" el-Damaty said.")
    
    var unknwonWordsList = [String]()
    var originalWordsList = [String]()
    var unknownWordsRegs = ""
    var totalWords = 0
    
    
    @IBOutlet weak var translateSearchBar: UISearchBar!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var translatedResultLabel: UILabel!
    
    @IBOutlet weak var articleTextField: RegeributedTextView!
    @IBOutlet weak var isHighlightUnknownWords: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Article Reader"
        self.arrowImage.isHidden = true
        self.translatedResultLabel.isHidden = true
        
        let regPrefix = #"(?<=[\s\n\b("]|^)"#
        let regSuffix = #"(?=[\s\n\b,.?)_:;"]|$)"#
        unknownWordsRegs = regPrefix + originalWordsList.joined(separator: "\(regSuffix)|\(regPrefix)") + regSuffix

        articleTextField.isEditable = false
        articleTextField.textAlignment = .justified
        articleTextField.text = self.article.text
        articleTextField.addAttributes(unknownWordsRegs, attributes: [.bold, .backgroundColor(.yellow), .textColor(.black)])
        
        translateSearchBar.delegate = self
        
        translateSearchBar.autocapitalizationType = .none
        
        articleTextField.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        UIMenuController.shared.menuItems = [.init(title: "Register", action: #selector(ArticleReaderViewController.registerUnknownWord))]
        
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
            motionManager.accelerometerUpdateInterval = 0.5

            // センサー値の取得開始
            motionManager.startAccelerometerUpdates(
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.outputAccelData(acceleration: accelData!.acceleration)
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAccelerometer()
    }
    
    func outputAccelData(acceleration: CMAcceleration){
        // 加速度センサー [G]
        print("(\(acceleration.x), \(acceleration.y), \(acceleration.z))")
    }
    
    // センサー取得を止める場合
    func stopAccelerometer(){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    @objc func registerUnknownWord() {
        guard let range = articleTextField.selectedTextRange, let word = articleTextField.text(in: range),
            !word.isEmpty else {
            return
        }

        print("text: \(word)")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("キャンセルが選択されました。")
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            
            Task {
                do {
                    try await self.articleManager.registerNewWord(word: word, currentUnknownWords: self.unknwonWordsList, text: self.article.text)
                    self.unknwonWordsList.append(self.articleManager.registerWord)
                    self.originalWordsList.append(self.articleManager.originalWord)
                    self.unknownWordsRegs = self.unknwonWordsList.joined(separator: "|")
                    self.articleTextField.addAttributes(word, attributes: [.bold, .backgroundColor(.yellow),.textColor(.black)])
                    let registerOkAction = UIAlertAction(title: "OK", style: .default)
                    DispatchQueue.main.async {
                        self.showAlert(title: "Succeded", message: "Succeeded to register \n\"\(word)\"\n as an unknown word.", actions: [registerOkAction])
                    }
                } catch ArticleError.targetWordIsAlreadyRegistered {
                    let registerOkAction = UIAlertAction(title: "OK", style: .default)
                    DispatchQueue.main.async {
                        self.showAlert(title: "Already registered", message: "\"\(word)\"\n is already registered as an unknown word.", actions: [registerOkAction])
                    }
                } catch {
                    let registerOkAction = UIAlertAction(title: "OK", style: .default)
                    DispatchQueue.main.async {
                        self.showAlert(title: "Failed to register", message: "Failed to register \n\"\(word)\"\n as an unknown word.", actions: [registerOkAction])
                    }
                }
            }
        }
        
        self.showAlert(title: "Word Registration", message: "Do you want to register \n\"\(word)\"\n as an unknown one?", actions: [cancelAction, okAction])
    }


    @IBAction func tapFinishReadingButton(_ sender: Any) {
        Task {
            do {
                try await articleManager.getSentence(text: article.text, unknownWords: unknwonWordsList, originalWords: originalWordsList)
                let viewController = UIStoryboard(name: "RegisterUnknownWords", bundle: nil).instantiateViewController(withIdentifier: "RegisterUnknownWordsView") as! RegisterUnknownWordsViewController
                viewController.unknownWordsList = unknwonWordsList
                viewController.sentenceDictionary = articleManager.sentenceDictionary
                viewController.totalWords = totalWords
                print(articleManager.sentenceDictionary)
                viewController.contentType = contentType
                navigationController?.pushViewController(viewController, animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func toggleHighlightUnknownWords(_ sender: UISwitch) {
        if isHighlightUnknownWords.isOn {
            articleTextField.addAttributes(unknownWordsRegs, attributes: [.bold, .backgroundColor(.yellow), .textColor(.black)])
        } else {
            articleTextField.removeAllAttribute()
            articleTextField.addAttributes(unknownWordsRegs, attributes: [.font(.systemFont(ofSize: 17.0)), .textColor(.label)])
        }
    }
}

extension ArticleReaderViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text?.isEmpty ?? true {
            arrowImage.isHidden = true
            translatedResultLabel.isHidden = true
        } else {
            arrowImage.isHidden = false
            translatedResultLabel.isHidden = false
            
            translatedResultLabel.text = "翻訳中..."
            
            let searchWord = searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
            
            originalAPIManager.translate(with: .google, word: searchWord) { result in
                DispatchQueue.main.async {
                    self.translatedResultLabel.text = result
                }
                                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    print("キャンセルが選択されました。")
                }
                
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    Task {
                        do {
                            try await self.articleManager.registerNewWord(word: searchWord, currentUnknownWords: self.unknwonWordsList, text: self.article.text)
                            self.unknwonWordsList.append(self.articleManager.registerWord)
                            self.originalWordsList.append(self.articleManager.originalWord)
                            self.unknownWordsRegs = self.unknwonWordsList.joined(separator: "|")
                            self.articleTextField.addAttributes(searchWord, attributes: [.bold, .backgroundColor(.yellow),.textColor(.black)])
                            let registerOkAction = UIAlertAction(title: "OK", style: .default)
                            DispatchQueue.main.async {
                                self.showAlert(title: "Succeded", message: "Succeeded to register \n\"\(searchWord)\"\n as an unknown word.", actions: [registerOkAction])
                            }
                        } catch ArticleError.targetWordIsAlreadyRegistered {
                            let registerOkAction = UIAlertAction(title: "OK", style: .default)
                            DispatchQueue.main.async {
                                self.showAlert(title: "Already registered", message: "\"\(searchWord)\"\n is already registered as an unknown word.", actions: [registerOkAction])
                            }
                        } catch {
                            let registerOkAction = UIAlertAction(title: "OK", style: .default)
                            DispatchQueue.main.async {
                                self.showAlert(title: "Failed to register", message: "Failed to register \n\"\(searchWord)\"\n as an unknown word.", actions: [registerOkAction])
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.showAlert(title: "Word Registration", message: "Do you want to register \n\"\(searchWord)\"\n as an unknown one?", actions: [cancelAction, okAction])
                }
            }
        }
    }
}
