//
//  RegisterUnknownWordsViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/08.
//

import UIKit

class RegisterUnknownWordsViewController: UIViewController {
    var wordListGenerator = WordListGenerator()
    var originalAPIManager = OriginalAPIManager()
    var unknownWordsList = [String]()
    var checkedUnknownWordList = [String]()
    var countUnknownWords = 0
    var sentenceDictionary = [String:Sentence]()
    var contentType: ContentType = .article
    var videoID = ""
    var startTime = 0.0
    var totalWords = 0
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var registerUnknownWordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        registerUnknownWordsTableView.dataSource = self
        registerUnknownWordsTableView.delegate = self
        
        // ActivityIndicatorを作成＆中央に配置
        activityIndicatorView.center = self.view.center
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        // クルクルをストップした時に非表示する
        activityIndicatorView.hidesWhenStopped = true
        // Viewに追加
        self.view.addSubview(activityIndicatorView)
        
        // 複数選択を有効にする
        registerUnknownWordsTableView.allowsMultipleSelection = true
    }

    @IBAction func tapRegisterButton(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
        print(sentenceDictionary)
        
        Task {
            do {
                try await wordListGenerator.updateWordList(originalUnknownWords: unknownWordsList, checkedUnknownWords: checkedUnknownWordList, contentType: contentType, sentences: sentenceDictionary, totalWords: totalWords, videoID: videoID)
                view.isUserInteractionEnabled = true
                activityIndicatorView.stopAnimating()
                let layerNumber = navigationController!.viewControllers.count
                let _ = navigationController?.popToViewController(navigationController!.viewControllers[layerNumber - 3], animated: true)
            } catch {
                activityIndicatorView.stopAnimating()
                view.isUserInteractionEnabled = true
                // ここでalertを表示
                let okAction = UIAlertAction(title: "OK", style: .default)
                showAlert(title: "Alert", message: error.localizedDescription, actions: [okAction])
                print(error.localizedDescription)
            }
        }
    }
}

extension RegisterUnknownWordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("num of rows")
        return unknownWordsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("Begin generating a table")
        let cell: UITableViewCell = registerUnknownWordsTableView.dequeueReusableCell(withIdentifier: "registerUnknwonWordsTableViewCell", for: indexPath)
        cell.textLabel?.text = unknownWordsList[indexPath.row]
        cell.selectionStyle = .none
        if checkedUnknownWordList.contains((cell.textLabel?.text)!) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension RegisterUnknownWordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = registerUnknownWordsTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        if !checkedUnknownWordList.contains(unknownWordsList[indexPath.row]) {
            checkedUnknownWordList.append(unknownWordsList[indexPath.row])
        }
        
        print(checkedUnknownWordList)
        countUnknownWords += 1
        print("Row \(indexPath.row) has selected")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = registerUnknownWordsTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        checkedUnknownWordList.removeAll(where: {$0 == unknownWordsList[indexPath.row]})
        countUnknownWords -= 1
        print("Row \(indexPath.row) has deselected")
    }
}
