//
//  ViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/14.
//

import UIKit

class MainViewController: UIViewController {
    let auth = Authentication()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapSignOutButton(_ sender: Any) {
        auth.signOut()
    }    
}

