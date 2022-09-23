//
//  UIViewController+Alert.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/24.
//

import UIKit

public extension UIViewController {
    // MARK: Public Methods
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true, completion: nil)
    }
    
}
