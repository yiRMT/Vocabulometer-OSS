//
//  WordListViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/27.
//

import UIKit

class WordListViewController: UIViewController {
    var database = DatabaseManager()
    var contentType = ContentType.article
    
    var wordArray = [String]()
    var wordListData = [String:Any]()
    
    @IBOutlet weak var wordListTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                try await database.getWordData(contentType: contentType)
                wordArray = database.wordDataKeys
                wordListData = database.wordData
                wordListTableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordListTableView.dataSource = self
        wordListTableView.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        wordListTableView.setEditing(editing, animated: animated)
        wordListTableView.isEditing = editing
    }
}

extension WordListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wordListTableView.dequeueReusableCell(withIdentifier: "WordListTableViewCell", for: indexPath)
        cell.textLabel?.text = wordArray[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension WordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップされたセルの行番号を出力
        print("\(indexPath.row)番目の行が選択されました。")
        // セルの選択を解除
        wordListTableView.deselectRow(at: indexPath, animated: true)
        // 画面遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "WordListDetailView") as! WordListDetailViewController
        nextView.word = wordArray[indexPath.row]
        nextView.wordListData = wordListData[nextView.word] as! [String : Any]
        nextView.contentType = contentType
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
                let word = self.wordArray[indexPath.row]
                self.wordArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                Task {
                    do {
                        try await self.database.removeWordData(contentType: self.contentType, word: word)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("キャンセルが選択されました。")
            }
            
            showAlert(title: "Alert", message: "Are you sure you want to remove\n\"\(wordArray[indexPath.row])\"\nfrom your unknown words list?", actions: [cancelAction, confirmAction])
        }
    }
}
