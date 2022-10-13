//
//  BrowseViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/12.
//

import UIKit

class BrowseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // IBAction
    /// Navigate to Article Menu View when the Article button pressed
    @IBAction func tapArticleButton(_ sender: Any) {
        let viewController = UIStoryboard(name: "ArticleMenu", bundle: nil).instantiateViewController(withIdentifier: "ArticleMenu") as! ArticleMenuViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
}
