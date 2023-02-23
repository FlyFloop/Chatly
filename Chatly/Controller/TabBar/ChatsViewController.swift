//
//  ChatViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 1.02.2023.
//

import UIKit

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        friends.removeAll()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatTableViewListCell = chatTableView.dequeueReusableCell(withIdentifier: CellStrings.chatListTableViewCell) as! ChatListTableViewCell
      //  guard let image =  UIImage(named: "google_resize_icon") else {return}
        let safeUrl = URL(string: friends[indexPath.row].profilePhoto)
        chatTableViewListCell.chatListTableViewCellImage.image =  UIImage(named: StringConstants.googleResizeIcon)
        urlNetworkManager.fetchImageWithUrl(handler: { image in
            guard let safeImage = image else {return}
            chatTableViewListCell.chatListTableViewCellImage.image = safeImage
            chatTableViewListCell.chatListTableViewCellName.text = self.friends[indexPath.row].userName
            guard let lastMessagesUserDefaults = UserDefaults.standard.dictionary(forKey: UserDefaultsStrings.lastMessages) else {return}
            guard let friendChatRoomCodeDictionary = UserDefaults.standard.dictionary(forKey: UserDefaultsStrings.friendChatRoomCodeDictionary) else {return}
            if  lastMessagesUserDefaults.keys.contains(where: {$0 == friendChatRoomCodeDictionary[self.friends[indexPath.row].id] as! String}) {
                let chatUsersRoomCode = friendChatRoomCodeDictionary[self.friends[indexPath.row].id] as! String
                chatTableViewListCell.chatListTableViewCellLastMessage.text = lastMessagesUserDefaults[chatUsersRoomCode] as? String
            }

            

            let count = UserDefaults.standard.integer(forKey: UserDefaultsStrings.unreadedMessageCount)
            if count <= 50 {
                let stringCount = String(count)
                let imageNameString = "\(stringCount).circle.fill"
                guard let image = UIImage(named: imageNameString) else {return}
                chatTableViewListCell.chatListTableViewCellUnreadMessageCountImage.isHidden = false
                chatTableViewListCell.chatListTableViewCellUnreadMessageCountImage.image = image
            }
            else if count == 0 {
                chatTableViewListCell.chatListTableViewCellUnreadMessageCountImage.isHidden = true
            }
            else if count > 50{
                let imageNameString = "message.badge.filled.fill"
                guard let image = UIImage(named: imageNameString) else {return}
                chatTableViewListCell.chatListTableViewCellUnreadMessageCountImage.isHidden = false
                chatTableViewListCell.chatListTableViewCellUnreadMessageCountImage.image = image
            }
           
        }, url: safeUrl)
        
        return chatTableViewListCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageViewController = MessageViewController()

        firebaseNetworkManager.getUserInfo { user in
            guard let safeUser = user else {return}
            messageViewController.userModel = safeUser
            messageViewController.receiverId = self.friends[indexPath.row].id
            messageViewController.friend = self.friends[indexPath.row]
            
            self.navigationController?.pushViewController(messageViewController, animated: true)
        }
       
        
       
    }
        
    @IBOutlet weak var addChatIconButton: UIBarButtonItem!
    @IBOutlet weak var chatTableView: UITableView!
    var friends : [Friend] = []
    var lastMessages : [String : Any] = [:]
    let firebaseNetworkManager = FirebaseNetworkManager()
    let urlNetworkManager = URLNetworkModel()
    let userDefaultManager = UserDefaultsManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationTitleColor.configureNavigationBarTitle(title: StringConstants.chats, navigationItem: self.navigationItem, navigationController: self.navigationController)
        chatTableView.delegate = self
        chatTableView.dataSource = self
        firebaseNetworkManager.viewControllerDelegate = self
        chatTableView.register(UINib(nibName: CellStrings.chatListTableViewCellClass, bundle: nil), forCellReuseIdentifier: CellStrings.chatListTableViewCell)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseNetworkManager.getLastMessages {messages in}
        firebaseNetworkManager.getChatRoomsCodeForUser {n in}

        firebaseNetworkManager.getChatsFriends { friendsChats in
            guard let safeFriends = friendsChats else {return}
            self.friends = safeFriends
            self.chatTableView.reloadData()
        }
    }
    @IBAction func addChatIconPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: SegueStrings.goToAddChatFromChatsView, sender: self)
    }
   

   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
