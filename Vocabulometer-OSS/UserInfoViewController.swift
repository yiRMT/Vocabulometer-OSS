//
//  UserInfoViewController.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/09/24.
//

import UIKit

class UserInfoViewController: UIViewController {
    let database = DatabaseManager()
    var isHomeView = false
    var userSkill = 4
    var selectedNativeLanguageType = LanguageType.japanese
    var selectedGenderType = GenderType.male
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nativeLanguageButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ageTextField.delegate = self
        
        /// 初期設定画面の時の設定
        if !isHomeView {
            navigationItem.hidesBackButton = true
        }
        
        /// Home Viewの時の設定
        if isHomeView {
            submitButton.titleLabel?.text = "Change"
            /// Firebaseからユーザー情報を取得
            Task {
                do {
                    let userInfo = try await database.getUserInfoData()
                    ageTextField.text = String(userInfo.age)
                    switch userInfo.nativeLanguage {
                        case "Japanese":
                            selectedNativeLanguageType = .japanese
                        case "French":
                            selectedNativeLanguageType = .french
                        case "German":
                            selectedNativeLanguageType = .german
                        case "Other":
                            selectedNativeLanguageType = .other
                        default:
                            selectedNativeLanguageType = .japanese
                    }
                    switch userInfo.gender {
                        case "Male":
                            selectedGenderType = .male
                        case "Female":
                            selectedGenderType = .female
                        case "Custom":
                            selectedGenderType = .custom
                        case "Rather not say":
                            selectedGenderType = .ratherNotSay
                        default:
                            selectedGenderType = .male
                    }
                    
                    configureNativeLanguageMenu()
                    configureGenderMenu()
                    userSkill = userInfo.skill
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        // UIButtonにUIMenuを設定する
        self.configureNativeLanguageMenu()
        self.configureGenderMenu()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // Native Language
    
    enum LanguageType: String {
        case japanese = "Japanese"
        case french = "French"
        case german = "German"
        case other = "Other"
    }
    
    private func configureNativeLanguageMenu() {
        var actions = [UIMenuElement]()
        
        // Japanese
        actions.append(UIAction(title: LanguageType.japanese.rawValue, image: nil, state: self.selectedNativeLanguageType == LanguageType.japanese ? .on : .off, handler: { (_) in
            self.selectedNativeLanguageType = .japanese
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureNativeLanguageMenu()
        }))
        
        // French
        actions.append(UIAction(title: LanguageType.french.rawValue, image: nil, state: self.selectedNativeLanguageType == LanguageType.french ? .on : .off, handler: { (_) in
            self.selectedNativeLanguageType = .french
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureNativeLanguageMenu()
        }))
        
        // German
        actions.append(UIAction(title: LanguageType.german.rawValue, image: nil, state: self.selectedNativeLanguageType == LanguageType.german ? .on : .off, handler: { (_) in
            self.selectedNativeLanguageType = .german
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureNativeLanguageMenu()
        }))
        
        // Other
        actions.append(UIAction(title: LanguageType.other.rawValue, image: nil, state: self.selectedNativeLanguageType == LanguageType.other ? .on : .off, handler: { (_) in
            self.selectedNativeLanguageType = .other
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureNativeLanguageMenu()
        }))
        
        // UIButtonにUIMenuを設定
        nativeLanguageButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        nativeLanguageButton.showsMenuAsPrimaryAction = true
        // ボタンの表示を変更
        nativeLanguageButton.setTitle(self.selectedNativeLanguageType.rawValue, for: .normal)
    }
    
    // Gender
    
    enum GenderType: String {
        case male = "Male"
        case female = "Female"
        case custom = "Custom"
        case ratherNotSay = "Rather not say"
    }
    
    private func configureGenderMenu() {
        var actions = [UIMenuElement]()
        
        // Male
        actions.append(UIAction(title: GenderType.male.rawValue, image: nil, state: self.selectedGenderType == GenderType.male ? .on : .off, handler: { (_) in
            self.selectedGenderType = .male
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureGenderMenu()
        }))
        
        // Female
        actions.append(UIAction(title: GenderType.female.rawValue, image: nil, state: self.selectedGenderType == GenderType.female ? .on : .off, handler: { (_) in
            self.selectedGenderType = .female
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureGenderMenu()
        }))
        
        // Custom
        actions.append(UIAction(title: GenderType.custom.rawValue, image: nil, state: self.selectedGenderType == GenderType.custom ? .on : .off, handler: { (_) in
            self.selectedGenderType = .custom
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureGenderMenu()
        }))
        
        // Rather not say
        actions.append(UIAction(title: GenderType.ratherNotSay.rawValue, image: nil, state: self.selectedGenderType == GenderType.ratherNotSay ? .on : .off, handler: { (_) in
            self.selectedGenderType = .ratherNotSay
            // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
            self.configureGenderMenu()
        }))
        
        // UIButtonにUIMenuを設定
        genderButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        genderButton.showsMenuAsPrimaryAction = true
        // ボタンの表示を変更
        genderButton.setTitle(self.selectedGenderType.rawValue, for: .normal)
    }
    
    // MARK: IBAction
    /// 提出（変更）ボタンを押したときの処理
    @IBAction func tapSubmitButton(_ sender: Any) {
        let userInfoData = UserInfo(age: Int(ageTextField.text!) ?? 20, nativeLanguage: selectedNativeLanguageType.rawValue, gender: selectedGenderType.rawValue, skill: userSkill)
        
        do {
            try database.storeUserInfo(of: userInfoData)
            
            /// 初期設定かHomeViewかで画面遷移を変える
            if isHomeView {
                navigationController?.popViewController(animated: true)
            } else {
                let storyboard: UIStoryboard = self.storyboard!
                let viewController = storyboard.instantiateViewController(withIdentifier: "SDQAStoryboard")
                navigationController?.pushViewController(viewController, animated: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension UserInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// ユーザー情報を定義する構造体
struct UserInfo {
    var age: Int
    var nativeLanguage: String
    var gender: String
    var skill: Int
}
