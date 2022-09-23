//
//  SignInViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/15.
//

import UIKit

class SignInViewController: UIViewController {
    let auth = Authentication()
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVisibilityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = title
        logoImageView.image = UIImage(named: "Splash")
        initEmailTextField()
        initPasswordField()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func tapPasswordVisibilityButton(_ sender: Any) {
        if passwordTextField.isSecureTextEntry {
            passwordVisibilityButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            passwordVisibilityButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        passwordTextField.isSecureTextEntry.toggle()
        
    }
    
    @IBAction func tapForgotPasswordButton(_ sender: Any) {
        
    }
    
    @IBAction func tapSignInButton(_ sender: Any) {
        Task {
            do {
                try await auth.signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "")
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! MainViewController
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                present(vc, animated: true)
            } catch {
                
            }
        }
    }
    
    func initEmailTextField() {
        emailTextField.delegate = self
        emailTextField.placeholder = "Email"
        emailTextField.textContentType = .username
        emailTextField.keyboardType = .emailAddress
    }
    
    func initPasswordField() {
        passwordTextField.delegate = self
        passwordTextField.placeholder = "Password"
        passwordTextField.textContentType = .password
        passwordTextField.keyboardType = .asciiCapable
        passwordTextField.isSecureTextEntry = true
    }
}

extension SignInViewController: UITextFieldDelegate {
    /// Close system keyboard when you press return button
    /// - Parameter textField: UITextField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let nextTag = textField.tag + 1
        if let nextTextField = self.view.viewWithTag(nextTag) {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
