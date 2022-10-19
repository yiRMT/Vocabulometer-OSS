//
//  AboutViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/04/17.
//

import UIKit

class AboutViewController: UIViewController {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        versionLabel.text = "Version: \(version)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapEmailButton(_ sender: Any) {
        guard let url = URL(string: "mailto:imp.vocameter.ios@gmail.com") else { return }
        UIApplication.shared.open(url)
    }
}
