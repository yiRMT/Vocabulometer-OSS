//
//  WordListDetailViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/29.
//

import UIKit

class WordListDetailViewController: UIViewController {
    var contentType = ContentType.article
    var wordListGenerator = WordListGenerator()
    var originalAPIManager = OriginalAPIManager()
    var word = ""
    var wordListData = [String:Any]()
    
    var items = ["word", "translatedWord", "sentence", "lastTime"]
    
    @IBOutlet weak var wordListDetailTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        wordListDetailTableView.dataSource = self
        wordListDetailTableView.delegate = self
        
        self.navigationItem.title = word
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        wordListDetailTableView.setEditing(editing, animated: animated)
        wordListDetailTableView.isEditing = editing
    }
}

extension WordListDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wordListDetailTableView.dequeueReusableCell(withIdentifier: "WordListDetailTableViewCell", for: indexPath)
        let sentenceCell = wordListDetailTableView.dequeueReusableCell(withIdentifier: "WordListSentenceTableViewCell", for: indexPath) as! WordListSentenceTableViewCell
        let translatedWordCell = wordListDetailTableView.dequeueReusableCell(withIdentifier: "WordListTranslatedWordTableViewCell", for: indexPath) as! EditableTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Word"
            cell.detailTextLabel?.text = word
            return cell
        case 1:
            if wordListData["translatedWord"] as? String != "" {
                translatedWordCell.translationTextField.text = wordListData["translatedWord"] as? String
            } else {
                self.originalAPIManager.translate(with: .google, word: word) { result in
                    DispatchQueue.main.async {
                        translatedWordCell.translationTextField.text = result
                    }
                }
            }
            
            translatedWordCell.translationTextField.delegate = self
            return translatedWordCell
        case 2:
            sentenceCell.titleLabel.text = "Sentence"
            sentenceCell.titleLabel.sizeToFit()
            sentenceCell.sentenceLabel.text = wordListData["sentence"] as? String
            sentenceCell.sentenceLabel.sizeToFit()
            return sentenceCell
        default:
            cell.textLabel?.text = items[indexPath.row]
            cell.detailTextLabel?.text = wordListData[items[indexPath.row]] as? String
            return cell
        }
    }
}

extension WordListDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let url = URL(string: "https://ejje.weblio.jp/content/\(word)") else { return }
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WordListDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            textField.text = self.wordListData["translatedWord"] as? String
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.wordListGenerator.updateTranslation(of: self.word, to: textField.text ?? "", type: self.contentType)
        }
        
        self.showAlert(title: "Alert", message: "Are you sure you want to change the translation?", actions: [cancelAction, okAction])
        
        return true
    }
}
