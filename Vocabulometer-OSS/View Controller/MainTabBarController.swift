//
//  MainTabBarController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/05.
//

import UIKit

class MainTabBarController: UITabBarController {
    let auth = AuthenticationManager()
    
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
    @IBAction func tapSignOutButton(_ sender: Any) {
        do {
            try auth.signOut()
            let storyboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: Bundle.main)
            let next = storyboard.instantiateViewController(withIdentifier: "AuthenticationNavigationController")
            next.modalPresentationStyle = .fullScreen
            next.modalTransitionStyle = .crossDissolve
            self.present(next, animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
