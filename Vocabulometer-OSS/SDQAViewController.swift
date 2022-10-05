//
//  SDQAViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/25.
//

import UIKit

class SDQAViewController: UIViewController {
    let sdqaManager = SDQAManager()
    let database = DatabaseManager()
    var wordListGenerator = WordListGenerator()
    
    // Variables which are related to San Diego Quick Assessment
    /// Store SDQA words
    var sqdaWords = [[String]]()
    /// Store numbers of unknown words per page
    var wordCount = [Int:Int]()
    /// Count unknown words of the current page
    var countUnknownWords = 0
    /// Current page index
    var pageCount = 0
    /// Current English level
    var skill = 0
    
    var activityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var sdqaTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        initActivityIndicator()
    }
    
    func initTableView() {
        setWords()
        sdqaTableView.dataSource = self
        sdqaTableView.delegate = self
        sdqaTableView.allowsMultipleSelection = true
    }
    
    func initActivityIndicator() {
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    /// Estimate user's English level
    /// - Parameter level:
    func calcLevel(_ level: Int) {
        wordCount.updateValue(countUnknownWords, forKey: level)
        print(wordCount)
    }
    
    /// 単語データを用意
    func setWords() {
        for level in 1..<10 {
            switch level {
            case 1:
                self.sdqaManager.parse("a")
            case 2:
                self.sdqaManager.parse("b")
            case 3:
                self.sdqaManager.parse("c")
            case 4:
                self.sdqaManager.parse("d")
            case 5:
                self.sdqaManager.parse("e")
            case 6:
                self.sdqaManager.parse("f")
            case 7:
                self.sdqaManager.parse("g")
            case 8:
                self.sdqaManager.parse("h")
            case 9:
                self.sdqaManager.parse("i")
            default:
                print("parsed")
            }
            sqdaWords.append(sdqaManager.sqdaDict)
        }
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        calcLevel(pageCount)
        print("pageCount: \(self.pageCount)")
        
        if wordCount[self.pageCount]! > 2 {
            /// If more than three words has been selected on the current page, finish estimating English level
            
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            
            skill += 3
            //userWord.skill = self.skill
            //userInfo.skill = self.skill
            //userWord.generateWordList()
            //userInfo.update()
            print("User skill: \(self.skill)")
            /// Update user's English skill data on Firestore
            Task {
                do {
                    try database.updateDataOf(skill)
                    /// Generate personalized word list
                    try await wordListGenerator.generateWordList(of: skill)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            activityIndicatorView.stopAnimating()
            view.isUserInteractionEnabled = true
            
            /// Switch to main screen (modal)
            let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainNavigationController")
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
            self.present(viewController, animated: true)
        } else {
            /// If less than two words has been selected on the current page, present next page
            
            /// Deselect every cells
            for row in 0...9 {
                let indexPath = IndexPath(row: row, section: 0)
                tableView(sdqaTableView, didDeselectRowAt: indexPath)
                print("Deselect row \(row)")
            }
            
            /// Increment English levels and page numbers
            self.skill += 1
            self.pageCount += 1
            
            /// Reload cell data
            sdqaTableView.reloadData()
            
            /// Reset number of unknown words on the current page
            countUnknownWords = 0
        }
    }
}

extension SDQAViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = sdqaTableView.dequeueReusableCell(withIdentifier: "sdqaTableViewCell", for: indexPath)
        cell.textLabel?.text = sqdaWords[pageCount][indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

extension SDQAViewController: UITableViewDelegate {
    /// セルを選択した時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = sdqaTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        countUnknownWords += 1
    }
    
    /// セルの選択が解除された時の処理
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = sdqaTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        countUnknownWords -= 1
    }
}
