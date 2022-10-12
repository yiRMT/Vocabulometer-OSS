//
//  ArticleDetailViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/04/21.
//

import UIKit

class ArticleDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

}
