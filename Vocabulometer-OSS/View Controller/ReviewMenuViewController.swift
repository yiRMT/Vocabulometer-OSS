//
//  ReviewMenuViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/06/06.
//

import UIKit

class ReviewMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapArticleWordlist(_ sender: Any) {
        let storyboard = UIStoryboard(name: "WordList", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "WordListView") as! WordListViewController
        nextView.contentType = .article
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
