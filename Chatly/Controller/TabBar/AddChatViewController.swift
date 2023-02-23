//
//  AddChatViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 16.02.2023.
//

import UIKit

class AddChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsCoreData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let tableViewCell = addChatTableView.dequeueReusableCell(withIdentifier: CellStrings.friendsTableViewCell, for: indexPath) as? FriendsTableViewCell

        tableViewCell?.friendsTableViewCellLabel.text = friendsCoreData[indexPath.row].userName
        guard let safeProfilePhoto = friendsCoreData[indexPath.row].profilePhoto else {return UITableViewCell()}

        guard let safeUrl = URL(string: safeProfilePhoto) else {return UITableViewCell()}

        urlNetworkManager.fetchImageWithUrl(handler: { image in
            guard let safeImage = image else {return}
            
            tableViewCell?.friendsTableViewCellImage.image = safeImage
        }, url: safeUrl)
    
        guard let safeTableViewCell = tableViewCell else {return UITableViewCell()}
  
        return safeTableViewCell
    }
    
    
    
    @IBOutlet weak var addChatTableView: UITableView!
    
    @IBOutlet weak var selectedFriendLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    let firebaseNetworkManager = FirebaseNetworkManager()
    let urlNetworkManager = URLNetworkModel()
    let coreDataManager = CoreDataManager()
    var friends : [Friend] = []
    var friendsCoreData : [FriendCoreData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseNetworkManager.viewControllerDelegate = self
        addChatTableView.dataSource = self
        addChatTableView.delegate = self
        addChatTableView.register(UINib(nibName: CellStrings.friendsTableViewCellClass, bundle: nil), forCellReuseIdentifier: CellStrings.friendsTableViewCell)
        selectedFriendLabel.text = ""

       
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseNetworkManager.getFriends { friendsC in
            guard let safeFriends = friendsC else {return}
        guard let coreDataItems = self.coreDataManager.loadFriends(context: self.context) else {return}

        self.friendsCoreData = coreDataItems
            print(self.friendsCoreData.count)
            self.friends = safeFriends
        
            self.addChatTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let safeFriendUserName = friendsCoreData[indexPath.row].userName else {return}
        selectedFriendLabel.text = "\(StringConstants.selectedFriend) : \(safeFriendUserName)"
    }
    

    @IBAction func addChatButtonPressed(_ sender: UIButton) {
     
            let messageViewController = MessageViewController()
            guard let safeIndexPath = self.addChatTableView.indexPathForSelectedRow else {return}
            messageViewController.receiverId = self.friendsCoreData[safeIndexPath.row].id
            self.navigationController?.pushViewController(messageViewController, animated: true)
        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
