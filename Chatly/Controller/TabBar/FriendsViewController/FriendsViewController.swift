//
//  FriendsViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 3.02.2023.
//

import UIKit
import BLTNBoard

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsCoreData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsViewTableViewCell = friendsTableView.dequeueReusableCell(withIdentifier: CellStrings.friendsTableViewCell, for: indexPath) as? FriendsTableViewCell
        
        guard let safeFriendCoreDataProfilePhoto = friendsCoreData[indexPath.row].profilePhoto else {return UITableViewCell()}
        guard let safeUrl = URL(string: safeFriendCoreDataProfilePhoto) else {return UITableViewCell()}
        urlNetworkManager.fetchImageWithUrl(handler: { image in
            guard let safeImage = image else {return }
            friendsViewTableViewCell?.friendsTableViewCellImage.image = safeImage
        }, url: safeUrl)
        friendsViewTableViewCell?.friendsTableViewCellLabel.text = friendsCoreData[indexPath.row].userName



        guard let safeFriendsViewTableViewCell = friendsViewTableViewCell else {return UITableViewCell()}
        return safeFriendsViewTableViewCell
    }
    
    
    let firebaseNetworkManager = FirebaseNetworkManager()
    let urlNetworkManager = URLNetworkModel()
    let coreDataManager = CoreDataManager()
    var userUniqueCode : String = ""
    var friends : [Friend] = []
    var friendsCoreData : [FriendCoreData] = []
    
    
    private lazy var addFriendBottomSheet : BLTNItemManager = {
  
        let item = TextFieldBulletinPage(title: StringConstants.addFriendTitle)
        item.actionButtonTitle = StringConstants.addFriendActionButtonTitle
          
        item.descriptionText = "\(StringConstants.addFriendDescriptionText)  \"\(userUniqueCode)\" "
        item.textFieldPlaceHolder = StringConstants.addFriendPlaceHolderText
            item.appearance.actionButtonColor = ChatlyColorConstants.buttonBackgroundColor
            item.appearance.actionButtonTitleColor = ChatlyColorConstants.buttonForegroundColor
            item.appearance.descriptionTextColor = ChatlyColorConstants.labelColor
            item.requiresCloseButton = true
            item.isDismissable = true
            item.actionHandler =  { _ in
                guard let safeTextField = item.textField.text else {return}
                if safeTextField == self.userUniqueCode {
                    return
                }
                self.firebaseNetworkManager.addFriend(handler: { user in
                    
                    
                }, userCode: safeTextField)
                self.dismiss(animated: true)
                //loader koy
            }
            let itemInterfaceBuilder = BLTNInterfaceBuilder(appearance: item.appearance)
            _ = item.makeViewsUnderDescription(with: itemInterfaceBuilder)
        
            return BLTNItemManager(rootItem: item)
    }()
    
    @IBOutlet weak var friendsTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendsTableView.register(UINib(nibName: CellStrings.friendsTableViewCellClass, bundle: nil), forCellReuseIdentifier: CellStrings.friendsTableViewCell)
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        firebaseNetworkManager.viewControllerDelegate = self
        UINavigationTitleColor.configureNavigationBarTitle(title: StringConstants.friendsViewTitle, navigationItem: self.navigationItem, navigationController: self.navigationController)
        
        firebaseNetworkManager.getUserUniqueCode { uniqueCode in
            guard let safeUserUniqueCode = uniqueCode else {return}
            self.userUniqueCode = safeUserUniqueCode
        }
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriends()
      
    }
    func getFriends(){
            firebaseNetworkManager.getFriends { friendsN in
                    guard let safeFriends = friendsN else {return}
                guard let coreDataItems = self.coreDataManager.loadFriends(context: self.context) else {return}
                self.friendsCoreData = coreDataItems
                    self.friends = safeFriends
                    self.friendsTableView.reloadData()
            }
    }
    
    @IBAction func friendRequestsIconPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: SegueStrings.goToFriendsRequestsFromFriendsPage, sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendsTableView.cellForRow(at: indexPath)?.selectionStyle = .none
        self.performSegue(withIdentifier: SegueStrings.goToFriendsToFriendsDetail, sender: self)
    }
    

    @IBAction func friendsAddFriendButtonPressed(_ sender: UIBarButtonItem) {
        addFriendBottomSheet.backgroundViewStyle = .blurredLight
        addFriendBottomSheet.showBulletin(above: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueStrings.goToFriendsToFriendsDetail {
            let destinationVC = segue.destination as! FriendDetailViewController
            guard let indexPath =  friendsTableView.indexPathForSelectedRow else {return}
            destinationVC.friendId = friendsCoreData[indexPath.row].id
        }
    }
    

}
