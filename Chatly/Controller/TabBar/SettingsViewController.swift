//
//  SettingsViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 3.02.2023.
//

import UIKit
import FirebaseAuth
import BLTNBoard

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let firebaseAuth = Auth.auth()
    let userDefaultsManager = UserDefaultsManager()
    let firebaseNetworkManager = FirebaseNetworkManager()
    let coreDataManager = CoreDataManager()
    
    private lazy var deleteAccount : BLTNItemManager = {
        let title =  StringConstants.deleteAccountTitle
        let description = StringConstants.deleteAccountDescription
        
            let item = BLTNPageItem(title: title)
        item.actionButtonTitle = StringConstants.deleteAccountButtonTitle
            item.descriptionText = description
            item.appearance.actionButtonColor = ChatlyColorConstants.buttonBackgroundColor
            item.appearance.actionButtonTitleColor = ChatlyColorConstants.buttonForegroundColor
            item.appearance.descriptionTextColor = ChatlyColorConstants.labelColor
            item.requiresCloseButton = true
            item.isDismissable = true
            item.actionHandler =  { _ in
                self.firebaseNetworkManager.deleteAccount()
                self.dismiss(animated: true) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                //loader koy
            }
            let itemInterfaceBuilder = BLTNInterfaceBuilder(appearance: item.appearance)
            _ = item.makeViewsUnderDescription(with: itemInterfaceBuilder)
        
            return BLTNItemManager(rootItem: item)
    }()
    
   
    
    
    @IBOutlet weak var settingsNavigationBar: UINavigationBar!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsButtons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsViewTableViewCell = settingsViewTableView.dequeueReusableCell(withIdentifier: StringConstants.settingsViewTableViewCell, for: indexPath)
        var settingsViewTableViewCellContentConfig = settingsViewTableViewCell.defaultContentConfiguration()
        
        settingsViewTableViewCellContentConfig.text = settingsButtons[indexPath.row]
        
        settingsViewTableViewCell.contentConfiguration = settingsViewTableViewCellContentConfig
        
        
        return settingsViewTableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsViewTableView.cellForRow(at: indexPath)?.selectionStyle = .none
    switch indexPath.row {
        case 0:
            logout()
        case 1:
        deleteAccount.backgroundViewStyle = .blurredLight
        deleteAccount.showBulletin(above: self)
                
        default:
            print("")
        }
    }
    
    func logout(){
        firebaseNetworkManager.logout()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBOutlet weak var settingsViewTableView: UITableView!
    let settingsButtons = ["Logout", "Delete Account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewTableView.delegate = self
        settingsViewTableView.dataSource = self
        firebaseNetworkManager.viewControllerDelegate = self
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

}
