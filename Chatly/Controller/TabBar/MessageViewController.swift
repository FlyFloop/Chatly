//
//  MessageViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 10.02.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

struct Sender :  SenderType {
    var senderId: String
    var displayName: String
}

class MessageViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
   
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var messages :  [Message] = []
    let urlNetworkManager = URLNetworkModel()
    let firebaseNetworkManager = FirebaseNetworkManager()
    let coreDataManager = CoreDataManager()
    let messageCell = MessageContentCell()
    var receiverId : String? = nil
    var friend : Friend? = nil
    var userModel : User? = nil
    let firebaseFirestore = Firestore.firestore()
    var currentUser = Sender(senderId: "", displayName: "")
    var otherUser = Sender(senderId: "", displayName: "")
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate  = self
        messagesCollectionView.messagesDisplayDelegate = self
        firebaseNetworkManager.viewControllerDelegate = self
     //   messagesCollectionView.messageCellDelegate = self
        
        

        self.becomeFirstResponder()
        messageInputBar.delegate = self
 
   
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getInfos()

    }
    
    func getInfos(){
        guard let safeUserModel = coreDataManager.loadUser(context: context) else {return}
        guard let safeReceiverId = receiverId else {return}
        messagesCollectionView.backgroundColor = ChatlyColorConstants.viewBackgroundColor
        let friendCD = self.coreDataManager.getFriendDetail(context: self.context, friendId: safeReceiverId)
        
         
        firebaseNetworkManager.getChats(handler: { message, user in
            guard let safeMessages = message else {return}
            DispatchQueue.main.async {
                self.messages = safeMessages
                self.currentUser = user
                self.otherUser.senderId = safeReceiverId
                self.messagesCollectionView.reloadData()
            }
        }, receiverId: safeReceiverId)
        
//hepsini guard let ile tekrar yaz

        let userMC = User(userId: safeUserModel.first?.userId ?? "", userName: safeUserModel.first?.userName ?? "", userStatus: safeUserModel.first?.userStatus ?? "", userLastSeen: safeUserModel.first?.userLastSeen ?? "", userEmail: safeUserModel.first?.userEmail ?? "", isUserOnline: safeUserModel.first?.isUserOnline ?? false)
        
        userModel = userMC
        let friendModel = Friend(id: friendCD?.first?.id ?? "", userName: friendCD?.first?.userName ?? "", profilePhoto: friendCD?.first?.profilePhoto ?? "", chatRoomCode: friendCD?.first?.chatRoomCode)
        friend = friendModel
        configureNavigationBar()
        configureInputBar()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let safeUserId = firebaseNetworkManager.firebaseAuth.currentUser?.uid else {return}
        guard let safeReceiverId = receiverId else {return}
        guard let safeChatRoomCode = friend?.chatRoomCode else {return}
        if text.isEmpty {
         return
        }
        firebaseNetworkManager.sendTextMessage(senderId: safeUserId, receiverId: safeReceiverId, messageBody: text, chatRoomCode: safeChatRoomCode)
        inputBar.inputTextView.text.removeAll()
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let safeChatRoomCode = friend?.chatRoomCode else {return}
        self.firebaseNetworkManager.messageReadTrue(chatRoomCode: safeChatRoomCode, messageDocId: messages[indexPath.row].messageId)
    }
    
    
    func configureNavigationBar(){
        guard let safeUrl = URL(string: friend?.profilePhoto ?? "") else {return}
        
        urlNetworkManager.fetchImageWithUrl(handler: { image in
            
            guard let photoImage = image else {return}
            guard let image = photoImage.resizeImage(image: photoImage, targetSize: CGSize(width: 40, height: 44)) else {return}
            let buttonContainer =  UIView(frame: CoreGraphics.CGRect(x: 0, y: 0, width: 200, height: 44));
             buttonContainer.backgroundColor = .clear
            let  profileView =  UIImageView(frame: CoreGraphics.CGRect(x: 0, y: 0, width: 0, height: 0))
            let  lbltitle =  UILabel(frame: CoreGraphics.CGRect(x: 55, y: -2, width: 0, height: 0))
            let  lbltitle1 =  UILabel(frame: CoreGraphics.CGRect(x: 55, y: 19, width: 0, height: 0))
            

            profileView.image = image
            profileView.contentMode = .scaleAspectFill
            profileView.translatesAutoresizingMaskIntoConstraints = false
            guard let safeUserName = self.friend?.userName else {return}
            lbltitle.text = safeUserName
            lbltitle.sizeToFit()
            self.firebaseNetworkManager.listenUserOnlineStatus(handler: { result in
                DispatchQueue.main.async {
                    if result {
                        lbltitle1.text = StringConstants.online
                        lbltitle1.textColor = ChatlyColorConstants.labelColor
                        lbltitle1.font = .systemFont(ofSize: 16, weight: .thin)
                        lbltitle.textColor = ChatlyColorConstants.labelColor
                        lbltitle1.sizeToFit()
                        buttonContainer.addSubview(profileView)
                         buttonContainer.addSubview(lbltitle)
                        buttonContainer.addSubview(lbltitle1)
                        let btnTitle =  UIButton(type: .custom)
                         btnTitle.frame = CoreGraphics.CGRect(x: 0, y: 0, width: 200, height: 44);
                         btnTitle.backgroundColor = .clear;
                           buttonContainer.addSubview(btnTitle)
                        self.navigationItem.titleView = buttonContainer
                    }
                    else {
                        lbltitle1.text = StringConstants.offline
                        lbltitle1.textColor = ChatlyColorConstants.labelColor
                        lbltitle1.font = .systemFont(ofSize: 15, weight: .thin)
                        lbltitle.textColor = ChatlyColorConstants.labelColor
                        lbltitle1.sizeToFit()
                        buttonContainer.addSubview(profileView)
                         buttonContainer.addSubview(lbltitle)
                        buttonContainer.addSubview(lbltitle1)
                        let btnTitle =  UIButton(type: .custom)
                         btnTitle.frame = CoreGraphics.CGRect(x: 0, y: 0, width: 200, height: 44);
                         btnTitle.backgroundColor = .clear;
                           buttonContainer.addSubview(btnTitle)
                        self.navigationItem.titleView = buttonContainer
                    }
                }
            }, receiverId: self.receiverId!)
            lbltitle1.sizeToFit()
            buttonContainer.addSubview(profileView)
             buttonContainer.addSubview(lbltitle)
            buttonContainer.addSubview(lbltitle1)
            let btnTitle =  UIButton(type: .custom)
             btnTitle.frame = CoreGraphics.CGRect(x: 0, y: 0, width: 200, height: 44);
             btnTitle.backgroundColor = .clear;
               buttonContainer.addSubview(btnTitle)
            self.navigationItem.titleView = buttonContainer
            
        }, url: safeUrl)
    }
    
    func configureInputBar(){

        messageInputBar.inputTextView.backgroundColor = .opaqueSeparator
        messageInputBar.inputTextView.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        messageInputBar.inputTextView.clipsToBounds = true
        messageInputBar.backgroundView.backgroundColor =  ChatlyColorConstants.viewBackgroundColor
        
    }

    
  
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let safeUserId = userModel?.userId else {return}
        guard let safeFriendId = friend?.id else {return}
        avatarView.backgroundColor = .clear
        if message.sender.senderId == safeFriendId {
            guard let safeFriendPhoto = friend?.profilePhoto else {return}
            guard let safeUrl = URL(string: safeFriendPhoto) else {return}
            urlNetworkManager.fetchImageWithUrl(handler: { image in
                guard let safeImage = image else {return}
                avatarView.image = safeImage
            }, url: safeUrl)
        }
        else if message.sender.senderId == safeUserId {
            guard let safeUserModel = userModel else {return}
            guard let safeProfilePhoto = safeUserModel.profilePhoto else {return}
            guard let safeUrl = URL(string: safeProfilePhoto) else {return}
            urlNetworkManager.fetchImageWithUrl(handler: { image in
                guard let safeImage = image else {return}
                avatarView.image = safeImage
            }, url: safeUrl)
        }
        else {
            return
        }
        
    }
    
    
    
    
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    
   
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
 
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return ChatlyColorConstants.labelColor
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .opaqueSeparator
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
