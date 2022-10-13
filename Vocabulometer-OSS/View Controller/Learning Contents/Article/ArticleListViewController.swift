//
//  ArticleListViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/04/26.
//

import UIKit

class ArticleListViewController: UIViewController {     
    var articleManager = ArticleManager()
    
    var articleLevel = "Balanced"
    
    var contentType = ContentType.article
    
    var articleListArray = [Article]()
    
    var textLevel = 7
    
    @IBOutlet weak var articleListTableView: UITableView!
    
    @IBOutlet weak var articleLevelLabel: UILabel!
    
    @IBOutlet weak var pullDownMenu: UIButton!
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var estimationData = [[String:Any]]()
    var estimatedUnknownWords = [[String]]()
    var estimatedOriginalWords = [[String]]()
    
    var selectedCategoryType = CategoryType.entertainment
    
    var isLoading = true
    
    
    let articleTitlesArray = [
            "Halloween spending expected to decline slightly this year",
            "Bakken truckers often \"haul heavy\"",
            "Hungarian lawmakers ban Sunday shopping to boost family togetherness",
            "Economic meltdown or not, Indians want their gold",
            "In Tehran, skepticism mixes with cautious optimism over nuclear deal",
            "Islamic State isn't just destroying ancient artifacts \u{2001}Eit's selling them",
            "As Europe makes room for refugees, some in Japan ask: Why not us?"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleListTableView.register(UINib(nibName: "ArticleListTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleListTableViewCell")
        
        // Do any additional setup after loading the view.
        
        // ActivityIndicatorを作成＆中央に配置
        activityIndicatorView.center = self.view.center
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        // クルクルをストップした時に非表示する
        activityIndicatorView.hidesWhenStopped = true
        // Viewに追加
        self.view.addSubview(activityIndicatorView)
        
        articleLevelLabel.text = "Article level: \(articleLevel)"
        articleListTableView.delegate = self
        articleListTableView.dataSource = self
        
        // UIButtonにUIMenuを設定する
        configurePullDownMenu()
        
        articleListTableView.refreshControl = UIRefreshControl()
        articleListTableView.refreshControl?.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        articleListTableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArticleDetailSegue" {
            
            if let indexPath = articleListTableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? ArticleReaderViewController else {
                    fatalError("Failed to prepare ArticleReaderViewController.")
                }
                
                destination.article = self.articleListArray[indexPath.row]
            }
        }
    }
     */
    
    enum CategoryType: String {
        case entertainment = "Entertainment"
        case economy = "Economy"
        case environment = "Environment"
        case lifestyle = "Lifestyle"
        case politics = "Politics"
        case science = "Science"
        case sport = "Sport"
    }
    
    
    private func configurePullDownMenu() {
        var actions = [UIMenuElement]()
        
        // Entertainment
        actions.append(UIAction(title: CategoryType.entertainment.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.entertainment ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .entertainment
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // Economy
        actions.append(UIAction(title: CategoryType.economy.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.economy ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .economy
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // Environment
        actions.append(UIAction(title: CategoryType.environment.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.environment ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .environment
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // Lifestyle
        actions.append(UIAction(title: CategoryType.lifestyle.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.lifestyle ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .lifestyle
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // Politics
        actions.append(UIAction(title: CategoryType.politics.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.politics ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .politics
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // Science
        actions.append(UIAction(title: CategoryType.science.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.science ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .science
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // Sport
        actions.append(UIAction(title: CategoryType.sport.rawValue, image: nil, state: self.selectedCategoryType == CategoryType.sport ? .on : .off, handler: { (_) in
            self.selectedCategoryType = .sport
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configurePullDownMenu()
        }))
        
        // UIButtonにUIMenuを設定
        pullDownMenu.menu = UIMenu(title: "", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        pullDownMenu.showsMenuAsPrimaryAction = true
        // ボタンの表示を変更
        pullDownMenu.setTitle(self.selectedCategoryType.rawValue, for: .normal)
        isLoading = true
        view.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()

        Task {
            do {
                articleListArray = try await articleManager.findArticles(level: textLevel, category: selectedCategoryType.rawValue.lowercased())
                try await articleManager.estimateUnknownWords()
                estimationData = .init()
                estimatedUnknownWords = .init()
                
                estimationData = articleManager.dataSource
                estimatedUnknownWords = articleManager.unknownWords
                estimatedOriginalWords = articleManager.originalWords
                isLoading = false
                articleListTableView.reloadData()
                
                view.isUserInteractionEnabled = true
                activityIndicatorView.stopAnimating()
            } catch {
                print(error.localizedDescription)
                configurePullDownMenu()
            }
        }
        
        print(selectedCategoryType.rawValue.lowercased())
    }

}

extension ArticleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = articleListTableView.dequeueReusableCell(withIdentifier: "ArticleListTableViewCell", for: indexPath) as! ArticleListTableViewCell
        
        cell.articleTitleLabel.text = articleListArray[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        //cell.textLabel?.numberOfLines = 0
        
        if isLoading {
            self.view.isUserInteractionEnabled = false
            self.activityIndicatorView.startAnimating()
            
            cell.percentageLabel.text = "nil %"
            cell.wordCountLabel.text = "nil words"
        } else {
            self.view.isUserInteractionEnabled = true
            self.activityIndicatorView.stopAnimating()
            cell.percentageLabel.text = (String)(estimationData[indexPath.row]["percentage"] as! Double) + " %"
            cell.wordCountLabel.text = (String)(estimationData[indexPath.row]["hard"] as! Int) + " words"
        }
        
        return cell
    }
    
    
}

extension ArticleListViewController: UITableViewDelegate {
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップされたセルの行番号を出力
        print("\(indexPath.row)番目の行が選択されました。")
        // セルの選択を解除
        articleListTableView.deselectRow(at: indexPath, animated: true)
        // 画面遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "ArticleReaderView") as! ArticleReaderViewController
        nextView.article = self.articleListArray[indexPath.row]
        nextView.unknwonWordsList = self.estimatedUnknownWords[indexPath.row]
        nextView.originalWordsList = self.estimatedOriginalWords[indexPath.row]
        nextView.totalWords = self.estimationData[indexPath.row]["total"] as! Int
        nextView.contentType = self.contentType
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc private func onRefresh(_ sender: AnyObject) {
        Task {
            do {
                articleListArray = try await articleManager.findArticles(level: textLevel, category: selectedCategoryType.rawValue.lowercased())
                try await articleManager.estimateUnknownWords()
                estimationData = .init()
                estimatedUnknownWords = .init()
                
                estimationData = articleManager.dataSource
                estimatedUnknownWords = articleManager.unknownWords
                estimatedOriginalWords = self.articleManager.originalWords
                isLoading = false
                articleListTableView.reloadData()
                
                DispatchQueue.main.async {
                    self.articleListTableView.refreshControl?.endRefreshing()
                }
            } catch {
                DispatchQueue.main.async {
                    self.articleListTableView.refreshControl?.endRefreshing()
                }
                print(error.localizedDescription)
            }
        }
    }
}
