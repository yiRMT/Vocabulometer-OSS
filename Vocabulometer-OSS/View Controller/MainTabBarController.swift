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
        let imageView = UIImageView(image: UIImage(named: "Navigation Icon"))
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func tapSettingsButton(_ sender: Any) {
        let viewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsView") as! SettingsViewController
        navigationController?.pushViewController(viewController, animated: true)
    }    
}
