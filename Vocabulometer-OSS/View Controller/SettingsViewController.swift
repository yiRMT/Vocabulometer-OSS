//
//  SettingsViewController.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/22.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    let auth = AuthenticationManager()

    @IBOutlet weak var settingsTableView: UITableView!
    
    let sectionTitles = ["General", ""]
    
    let items = [["User Info", "About"], ["Sign out"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tapSignOut() {
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

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = settingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        
        if items[indexPath.section][indexPath.row] == "Sign out" {
            cell.textLabel?.textColor = .red
        } else {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }
    
    
}

extension SettingsViewController: UITableViewDelegate {
    
    enum SettingsIndex: Int {
    case userInfo = 0
    case about = 1
    case signOut = 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        switch items[indexPath.section][indexPath.row] {
        case "User Info":
            let viewController = UIStoryboard(name: "Setup", bundle: nil).instantiateViewController(withIdentifier: "UserInfo") as! UserInfoViewController
            viewController.isHomeView = true
            navigationController?.pushViewController(viewController, animated: true)
        case "About":
            let viewController = UIStoryboard(name: "About", bundle: nil).instantiateViewController(withIdentifier: "AboutView") as! AboutViewController
            navigationController?.pushViewController(viewController, animated: true)
        case "Sign out":
            tapSignOut()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}
