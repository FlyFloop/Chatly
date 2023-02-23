//
//  FriendsRequestCellTableViewCell.swift
//  Chatly
//
//  Created by Alper Yorgun on 5.02.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class FriendsRequestCellTableViewCell: UITableViewCell {
    
    private let firebaseNetworkManager = FirebaseNetworkManager()
    private let userDefaultsManager = UserDefaultsManager()
    
    
    
    @IBOutlet weak var friendsRequestCellImage: UIImageView!
    
    @IBOutlet weak var friendsRequestCellNameLabel: UILabel!
    
    @IBOutlet weak var friendsRequestsCellConfirmImageView: UIImageView!
    
    var friendsRequestTableView : UITableView? = nil
    var friend : Friend? = nil
    var navigationController : UINavigationController? = nil
    let firebaseFirestore = Firestore.firestore()
    
    

    @IBOutlet weak var friendsRequestsCellRejectImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        friendsRequestCellImage.clipsToBounds = true
        friendsRequestCellImage.makeRounded()
        initTapGestureRecognizer()

    }
    func initTapGestureRecognizer()  {
             let tapNameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(friendRequestConfirmIconPressed))
             let tapStatusGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(friendRequestRejectIconPressed))
             friendsRequestsCellConfirmImageView.isUserInteractionEnabled = true
             friendsRequestsCellConfirmImageView.addGestureRecognizer(tapNameGestureRecognizer)
             friendsRequestsCellRejectImageView.isUserInteractionEnabled = true
             friendsRequestsCellRejectImageView.addGestureRecognizer(tapStatusGestureRecognizer)
    }
    func goToViewFriendsView(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func friendRequestConfirmIconPressed(handler : () -> ()) {
        guard let safeFriend = friend else {return}
        guard let user = userDefaultsManager.getUserInfoFromUserDefaults() else {return}
        guard let safeUserProfile = user.profilePhoto else {return}
        guard let safeUserId = user.userId else {return}
        let userChatRoomUniqueCode = GenerateRandomUserUniqueCode.randomChatRoomsUniqueCode(userId: safeUserId, friendId: safeFriend.id)
        
        self.firebaseFirestore.collection(FirebaseStringConstants.usersCollectionFirestore).document(safeUserId).collection(FirebaseStringConstants.cchatRoomsUniqueCodesCollection).document(safeFriend.id).setData([FirebaseStringConstants.uniqueCodeString:userChatRoomUniqueCode])
        self.firebaseFirestore.collection(FirebaseStringConstants.usersCollectionFirestore).document(safeFriend.id).collection(FirebaseStringConstants.cchatRoomsUniqueCodesCollection).document(safeUserId).setData([FirebaseStringConstants.uniqueCodeString:userChatRoomUniqueCode])
        let userRef : DocumentReference = self.firebaseFirestore.collection(FirebaseStringConstants.usersCollectionFirestore).document(safeUserId)
        let friendRef : DocumentReference = self.firebaseFirestore.collection(FirebaseStringConstants.usersCollectionFirestore).document(safeFriend.id)
        self.firebaseFirestore.collection(FirebaseStringConstants.chatRoomsCollection).document(userChatRoomUniqueCode).collection(FirebaseStringConstants.usersCollectionFirestore).document(safeUserId).setData([FirebaseStringConstants.refString : userRef])
        self.firebaseFirestore.collection(FirebaseStringConstants.chatRoomsCollection).document(userChatRoomUniqueCode).collection(FirebaseStringConstants.usersCollectionFirestore).document(safeFriend.id).setData([FirebaseStringConstants.refString : friendRef])
 
        let userModel = Friend(id: safeUserId, userName: user.userName, profilePhoto: safeUserProfile, userStatus: user.userStatus, lastSeen: user.userLastSeen, chatRoomCode: userChatRoomUniqueCode, ref: userRef)
        let friendModel = Friend(id: safeFriend.id, userName: safeFriend.userName, profilePhoto: safeFriend.profilePhoto, userStatus: safeFriend.userStatus, lastSeen: safeFriend.lastSeen, chatRoomCode: userChatRoomUniqueCode, ref: friendRef)
        firebaseNetworkManager.confirmFriendRequest(friend: friendModel, user: userModel)
        goToViewFriendsView()
       
    }
    @objc func friendRequestRejectIconPressed(handler : () -> ()) {
        guard let safeFriend = friend else {return}
        firebaseNetworkManager.rejectFriendRequest(friend: safeFriend)
        goToViewFriendsView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
