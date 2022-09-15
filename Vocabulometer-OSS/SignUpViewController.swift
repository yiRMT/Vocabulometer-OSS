//
//  SignUpViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/15.
//

import UIKit

class SignUpViewController: UIViewController {
    let auth = Authentication()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordVisibilityButton: UIButton!
    @IBOutlet weak var confirmPasswordVisibilityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = title
        
        initEmailTextField()
        initNewPasswordField()
        initConfirmPasswordField()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapNewPasswordVisibilityButton(_ sender: Any) {
        if newPasswordTextField.isSecureTextEntry {
            newPasswordVisibilityButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            newPasswordVisibilityButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        newPasswordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func tapConfirmPasswordVisibilityButton(_ sender: Any) {
        if confirmPasswordTextField.isSecureTextEntry {
            confirmPasswordVisibilityButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            confirmPasswordVisibilityButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        confirmPasswordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func tapSignUpButton(_ sender: Any) {
        Task {
            do {
                try await auth.signUp(withEmail: emailTextField.text ?? "", password: newPasswordTextField.text ?? "")
            } catch {
                
            }
        }
    }
    
    func initEmailTextField() {
        emailTextField.placeholder = "Email"
        emailTextField.textContentType = .username
        emailTextField.keyboardType = .emailAddress
    }
    
    func initNewPasswordField() {
        newPasswordTextField.placeholder = "New Password"
        newPasswordTextField.textContentType = .newPassword
        newPasswordTextField.keyboardType = .asciiCapable
        newPasswordTextField.isSecureTextEntry = true
    }
    
    func initConfirmPasswordField() {
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.textContentType = .password
        confirmPasswordTextField.keyboardType = .asciiCapable
        confirmPasswordTextField.isSecureTextEntry = true
    }
}
