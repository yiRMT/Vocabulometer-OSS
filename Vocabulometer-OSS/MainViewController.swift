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
        do {
            try auth.signOut()
            let viewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationNavigationController")
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
            self.present(viewController, animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }    
}

