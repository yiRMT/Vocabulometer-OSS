//
//  ArticleMenuViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/04/19.
//

import UIKit

class ArticleMenuViewController: UIViewController {
    var database = DatabaseManager()
    var articleManager = ArticleManager()
    
    var contentType = ContentType.article
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // IBAction
    @IBAction func tapEasyButton(_ sender: Any) {
        Task {
            do {
                let userInfo = try await database.getUserInfoData()
                let viewController = storyboard!.instantiateViewController(withIdentifier: "articleListView") as! ArticleListViewController
                viewController.textLevel = articleManager.articleLevel("Easy", userInfo.skill)
                viewController.articleLevel = "Easy"
                viewController.contentType = contentType
                navigationController?.pushViewController(viewController, animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func tapBalancedButton(_ sender: Any) {
        Task {
            do {
                let userInfo = try await database.getUserInfoData()
                let viewController = storyboard!.instantiateViewController(withIdentifier: "articleListView") as! ArticleListViewController
                viewController.textLevel = articleManager.articleLevel("Balanced", userInfo.skill)
                viewController.articleLevel = "Balanced"
                viewController.contentType = contentType
                navigationController?.pushViewController(viewController, animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func tapHardButton(_ sender: Any) {
        Task {
            do {
                let userInfo = try await database.getUserInfoData()
                let viewController = storyboard!.instantiateViewController(withIdentifier: "articleListView") as! ArticleListViewController
                viewController.textLevel = articleManager.articleLevel("Hard", userInfo.skill)
                viewController.articleLevel = "Hard"
                viewController.contentType = contentType
                navigationController?.pushViewController(viewController, animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
