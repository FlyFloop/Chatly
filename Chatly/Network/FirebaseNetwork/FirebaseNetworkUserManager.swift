//
//  FirebaseNetworkUserManager.swift
//  Chatly
//
//  Created by Alper Yorgun on 2.02.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import MessageKit
import FirebaseStorage
class FirebaseNetworkManager {
    let firebaseAuth = Auth.auth()
    let firebaseFirestore = Firestore.firestore()
    let firebaseStorage = Storage.storage()
    var userModel : User?
    let userDefaultsManager = UserDefaultsManager()
    let coreDataManager = CoreDataManager()
    var viewControllerDelegate : UIViewController?
    
    var friendsRequests : [Friend] = []
  
    var friendsRequestsDocuments : [QueryDocumentSnapshot]?
    var friends : [Friend] = []
    var friendsDocuments : [QueryDocumentSnapshot]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    func getLastMessages(handler :@escaping(String) -> () ){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).collection("chatRoomsUniqueCodes").getDocuments { querySnapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
               
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let safeQuerySnapShot = querySnapShot else {return}
            let docs = safeQuerySnapShot.documents
            docs.forEach { queryDocSnapShot in
                 var messagesDictionary : [String : String] = [:]
                 let safeQueryDocSnapShot = queryDocSnapShot
                 let data =  safeQueryDocSnapShot.data()
                 let friendId = safeQueryDocSnapShot.documentID
                 let friendChatRoomCode = data["uniqueCode"] as! String
                self.firebaseFirestore.collection("chatRooms").document(friendChatRoomCode).collection("messages").order(by: "messageDate").getDocuments {   chatQuerySnapShot, error in
                    guard let safeChatQuerySnapShot = chatQuerySnapShot else {return}
                    let docs = safeChatQuerySnapShot.documents
                    var unreadedMessageCount = 0
                    docs.forEach { queryDocSnapShot in
                        let doc = queryDocSnapShot.data()
                        let id = doc["senderId"] as! String
                        if id != safeUserId {
                            if (doc["isMessageRead"] as? Bool) == false {
                                unreadedMessageCount += 1
                            }
                        }
                    }
                    guard let lastMessage = docs.last else {return}
                    let lastData = lastMessage.data()
                    let message = lastData["messageBody"]  as! String
                    let id = lastData["senderId"] as! String
                    let useCode = lastData["chatRoomCode"] as! String
                    
                    let lastMessageChatRoomCode = "\(useCode)"
                    messagesDictionary[lastMessageChatRoomCode] = message
                    UserDefaults.standard.set(messagesDictionary, forKey: "lastMessages")
                    UserDefaults.standard.set(unreadedMessageCount, forKey: "unreadedMessageCount")
                }
            }
            handler("nil")
        }
    }
    

    func getFriendDetail(handler:@escaping(Friend?) -> () , friendId : String) {
        DispatchQueue.main.async {
                     self.firebaseFirestore.collection("users").document(friendId).getDocument { docSnapShot, error in
                         guard let safeViewController = self.viewControllerDelegate else {return}
                         if error != nil {
                             FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                             return
                         }
                         guard let safeDocSnapShot = docSnapShot else {return}
                         safeDocSnapShot.reference.collection("chatRoomsUniqueCodes").getDocuments { queryDocSnapShot, error in
                             if error != nil {
                                 guard let safeViewController = self.viewControllerDelegate else {return}
                                 FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                                 return
                             }
                             guard let docs = queryDocSnapShot?.documents else {return}
                             docs.forEach { queryDocSnap in
                                 let data = queryDocSnap.data()
                                 guard let chatRoomCode = data["uniqueCode"] as? String else {return}
                                 self.userDefaultsManager.saveChatRoomUniqueCode(code: chatRoomCode)
                             }
                         }
                         let data = safeDocSnapShot.data()
                         guard let safeData = data else {return}
                         let name = safeData["userName"] as! String
                         let status = safeData["userStatus"] as! String
                         let lastSeen = safeData["userLastSeen"] as! String
                         let profilePhoto = safeData["profilePhoto"] as! String
                         guard let chatRoom = self.userDefaultsManager.getChatRoomUniqueCode() else {return}
                         let model = Friend(id: friendId, userName: name, profilePhoto: profilePhoto, userStatus: status, lastSeen: lastSeen, chatRoomCode: chatRoom)
                         self.userDefaultsManager.saveFriendToUserDefaults(friend: model)
                         handler(model)
                 }
        }
       
    }
    
    func getChats(handler:@escaping([Message]?, _ currentUser : Sender) -> (),receiverId : String){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        guard let usersChatRoomCode = userDefaultsManager.getChatRoomUniqueCode() else {return}

        firebaseFirestore.collection("chatRooms").document(usersChatRoomCode).collection("messages").order(by: "messageDate").addSnapshotListener { querySnapShot, error in
            var messages : [Message] = []
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
               
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            
          
            guard let safeQuerySnapShot = querySnapShot else {return}
            let docs = safeQuerySnapShot.documents
            
            if docs.count == 0 {
                return
            }
        
            for message in docs {
                var currentUser = Sender(senderId: safeUserId, displayName: "display name")
                var otherUser = Sender(senderId: receiverId, displayName: "other name")
                let data = message.data()
                let messageBody = data["messageBody"] as! String
                let senderId = data["senderId"] as! String
                let isMessageRead = data["isMessageRead"] as! Bool
                let messageId = message.documentID
                if senderId != safeUserId {
                    otherUser.senderId = senderId
                    let messageModel = Message(sender: otherUser, messageId: messageId, sentDate: Date.now, kind: .text(messageBody), isMessageRead: isMessageRead)
                    messages.append(messageModel)
                }
                else {
                    currentUser.senderId = safeUserId
                    let messageModel = Message(sender: currentUser, messageId: messageId, sentDate: Date.now, kind: .text(messageBody), isMessageRead: isMessageRead)
                    messages.append(messageModel)
                }
                handler(messages, currentUser)
            }
        }
    }
    func listenUserOnlineStatus(handler : @escaping(Bool) -> (), receiverId : String){
        firebaseFirestore.collection("users").document(receiverId).addSnapshotListener { docSnapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
               
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let safeDocSnapShot = docSnapShot else {return}
            let data = safeDocSnapShot.data()
            guard let safeData = data else {return}
            let userOnlineStatus = safeData["isUserOnline"] as! Bool
            
            handler(userOnlineStatus)
        }
    }
    
    func autoLogin() -> Bool{
        if firebaseAuth.currentUser != nil {
           return true
        }
        else {return false}
    }
    
    //buraya direk obje yollucam
    func sendTextMessage(senderId : String, receiverId : String, messageBody : String, chatRoomCode : String){
        guard let usersChatRoomCode = userDefaultsManager.getChatRoomUniqueCode() else {return}
        self.firebaseFirestore.collection("chatRooms").document(usersChatRoomCode).collection("messages").addDocument(data: ["messageBody" : messageBody,
                                                                                                                             "messageDate" : Date().timeIntervalSince1970,
                                                                                                                             "senderId" : senderId, "isMessageRead" : false,
                                                                                                                    "chatRoomCode" : chatRoomCode])
    }
    //check chatroom is any message there for listing chats view controller
    func getChatsFriends(handler : @escaping([Friend]?) -> () ){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        self.firebaseFirestore.collection("users").document(safeUserId).collection("chatRoomsUniqueCodes").getDocuments { querySnapShot, error in
            if error != nil {
                return
            }
            guard let docs = querySnapShot?.documents else {return}
            var chatRoomCodes : [String] = []
            var friendsIds : [String] = []
            var friendsChats : [Friend] = []
            docs.forEach { docsSnapShot in
                let data = docsSnapShot.data()
                guard let id = data["uniqueCode"] as? String else {return}
                chatRoomCodes.append(id)
            }
            chatRoomCodes.forEach { chatRoomCode in
                self.firebaseFirestore.collection("chatRooms").document(chatRoomCode).collection("messages").getDocuments { chatDocSnapShot, error in
                    if error != nil {
                        print(1)
                    }
                    guard let safeChatDocSnapShot = chatDocSnapShot?.documents.count else {return}
                    if safeChatDocSnapShot == 0 {
                     
                    }
                    else {
                        self.firebaseFirestore.collection("chatRooms").document(chatRoomCode).collection("users").getDocuments { chatUsersQuerySnapshot, error in
                            if error != nil {
                                print("getchats friends error")
                            }
                            guard let safeChatUsersQuerySnapshot = chatUsersQuerySnapshot else {return}
                            let docs = safeChatUsersQuerySnapshot.documents
                            docs.forEach { chatUsersQuerySnapshotDocs in
                                let id = chatUsersQuerySnapshotDocs.documentID
                                if id != safeUserId {
                                    friendsIds.append(id)
                                }
                            }
                            friendsIds.forEach { friendId in
                                self.firebaseFirestore.collection("users").document(friendId).getDocument { docSnapShot, error in
                                    if error != nil {
                                        
                                    }
                                    guard let safeDocSnapShot = docSnapShot else {return}
                                    guard let data = safeDocSnapShot.data() else {return}
                                    let id = safeDocSnapShot.documentID
                                    guard let name = data["userName"] as? String else {return}
                                    guard let profilePhoto = data["profilePhoto"] as? String else {return}
                                    let model = Friend(id: id, userName: name, profilePhoto: profilePhoto)
                                    friendsChats.append(model)
//                                    let chatCoreData = ChatsCoreData(context: self.context)
//                                    chatCoreData.profilePhoto = profilePhoto
//                                    chatCoreData.name = name
//                                    chatCoreData.userId = id
//                                    self.coreDataManager.saveItem(context: self.context)
                                    handler(friendsChats)
                                }
                               
                            }
                            
                        }
                    }
                }
            }
        }
    }
    func deleteFriend(friendId : String, chatRoomCode : String){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("requests").document(safeUserId).collection("friends").document(friendId).delete()
        firebaseFirestore.collection("requests").document(friendId).collection("friends").document(safeUserId).delete()
        firebaseFirestore.collection("chatRooms").document(chatRoomCode).collection("users").getDocuments { querySnapSht, error in
            if error != nil {
                
            }
            guard let safeQuerySnapshot = querySnapSht else {return}
            let docs = safeQuerySnapshot.documents
            docs.forEach { doc in
                doc.reference.delete()
            }
        }
        firebaseFirestore.collection("chatRooms").document(chatRoomCode).collection("messages").getDocuments { querySnapSht, error in
            if error != nil {
                
            }
            guard let safeQuerySnapshot = querySnapSht else {return}
            let docs = safeQuerySnapshot.documents
            docs.forEach { doc in
                doc.reference.delete()
            }
        }
        firebaseFirestore.collection("users").document(safeUserId).collection("chatRoomsUniqueCodes").document(friendId).delete()
        firebaseFirestore.collection("users").document(friendId).collection("chatRoomsUniqueCodes").document(safeUserId).delete()
        firebaseFirestore.collection("chatRooms").document(chatRoomCode).delete()
    }
    
    func getChatRoomsCodeForUser(handler:@escaping(String?) -> ()){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("requests").document(safeUserId).collection("friends").getDocuments { querySnapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let docs = querySnapShot?.documents else {return}
            docs.forEach { queryDocSnapShot in
                var friendChatRoomCodeDictionary : [String : String] = [:]
                let data = queryDocSnapShot.data()
                let friendId = data["id"] as! String
                let chatRoomCode = data["chatRoomCode"] as! String
                friendChatRoomCodeDictionary[friendId] = chatRoomCode
                UserDefaults.standard.set(friendChatRoomCodeDictionary, forKey: "friendChatRoomCodeDictionary")
                handler("")
            }
        }
    }
    
    func updateUserProfilePhoto(handler : @escaping(String?) -> (), image : UIImage){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
         let ref = firebaseStorage.reference().child(safeUserId).child("images").child("0")
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)! as Data
        ref.putData(data) { metaData, error in
            if error != nil {
                print("fetch and upload image put data error ")
                handler(nil)
                return
            }
            ref.downloadURL { url, error in
                if error != nil {
                    print("fetch and upload image downloadurl error ")
                    handler(nil)
                    return
                }
                guard let safeUrl = url?.absoluteString else {return}
                self.firebaseFirestore.collection("users").document(safeUserId).updateData(["profilePhoto" : safeUrl])
                let userCoreData = self.coreDataManager.loadUser(context: self.context)
                userCoreData?.first?.setValue(safeUrl, forKey: "profilePhoto")
                self.coreDataManager.saveItem(context: self.context)
                handler(url?.absoluteString)
            }
        }
       
    }
    func logout(){
        do{
            userOfline()
            updateLastSeen()
            try firebaseAuth.signOut()
            userDefaultsManager.clearUserDefaults()
            coreDataManager.deleteUser(context: context)
            coreDataManager.deleteFriends(context: context)
        } catch {
            print("error while sign out app")
        }
        
    }
    
    func deleteAccount(){
        do{
            guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
            firebaseStorage.reference().child(safeUserId).delete { error in
                if error != nil {
                    print("error deleting images")
                }
            }
            firebaseFirestore.collection("users").document(safeUserId).delete()
            firebaseFirestore.collection("requests").document(safeUserId).delete()
            userDefaultsManager.clearUserDefaults()
            coreDataManager.deleteUser(context: context)
            coreDataManager.deleteFriends(context: context)
            try firebaseAuth.signOut()
        } catch {
            
        }
    }
    func getFriends(handler : @escaping(([Friend]?) -> () )){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("requests").document(safeUserId).collection("friends").addSnapshotListener { snapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let safeQuerySnapShot = snapShot else {return}
            let docs = safeQuerySnapShot.documents
            self.friendsDocuments = docs
            guard let safeFriendsDocs = self.friendsDocuments else {return}
            
            safeFriendsDocs.forEach { docSnapShot in
               
                let data = docSnapShot.data()
                let ref = data["ref"] as! DocumentReference
                ref.addSnapshotListener { docSnap, error in
                    if error != nil {
                        return
                    }
                    guard let safeDocSnapShot = docSnap else {return}
                    guard let safeData = safeDocSnapShot.data() else {return}
                    let name = safeData["userName"] as! String
                    let id = safeDocSnapShot.documentID
                    let userProfilePhoto = safeData["profilePhoto"] as! String
                    let model = Friend(id: id, userName: name,profilePhoto: userProfilePhoto)
                    if self.friends.contains(where: {$0 == model}){
                        
                    }
                    else {
                        self.friends.append(model)
                        do {
                            
                            let request = FriendCoreData.fetchRequest()
                           request.predicate = NSPredicate(format: "id == %@", model.id)
                            let fetched = try self.context.fetch(request)
                            fetched.first?.setValue(model.userName, forKey: "userName")
                            fetched.first?.setValue(model.profilePhoto, forKey: "profilePhoto")
                            self.coreDataManager.saveItem(context: self.context)
                            let friendsCoreData = self.coreDataManager.loadFriends(context: self.context)
                            
                             let safeFetchedItems = fetched.count
                            if safeFetchedItems == 0 {
                                self.coreDataManager.deleteFriend(context: self.context, friendId: model.id)
                            }
                            if safeFetchedItems > 0 {
                                
                            } else {
                                let newItem = FriendCoreData(context: self.context)
                                newItem.userName = model.userName
                                newItem.profilePhoto = model.profilePhoto
                                newItem.id = model.id
                                
                                self.coreDataManager.saveItem(context: self.context)
                            }

                        } catch {
                            
                        }
                    }
                }
                handler(self.friends)
            }
                            
        }
    }
    
    func getChatFriends(chatRoomCode : String){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("chatRooms").document(chatRoomCode).getDocument { docSnapShot, error in
            if error != nil {
                print("get chat friends error")
                return
            }
        }
    }
    
    func confirmFriendRequest(friend : Friend, user : Friend) {
        
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        do{
            try   firebaseFirestore.collection("requests").document(safeUserId).collection("friends").document(friend.id).setData(from: friend)
            try  firebaseFirestore.collection("requests").document(friend.id).collection("friends").document(safeUserId).setData(from: user)
               firebaseFirestore.collection("requests").document(safeUserId).collection("friendsRequests").document(friend.id).delete()
       
        } catch {
            print("confirm friend request error")
        }
    }
    func rejectFriendRequest(friend : Friend) {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
               firebaseFirestore.collection("requests").document(safeUserId).collection("friendsRequests").document(friend.id).delete()
    }

    func getUserFriendsRequests(handler : @escaping([Friend]?) ->()) {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("requests").document(safeUserId).collection("friendsRequests").getDocuments { snapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
               
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let safeQuerySnapShot = snapShot else {return}
            let docs = safeQuerySnapShot.documents
            self.friendsRequestsDocuments = docs
            guard let safeFriendsDocs = self.friendsRequestsDocuments else {return}
          
                self.friendsRequests = safeFriendsDocs.map({ snapShot in
                     let docs = snapShot.data()
                     let name = docs["userName"] as! String
                     let id = snapShot.documentID
                     let userProfilePhoto = docs["profilePhoto"] as! String
                    return Friend(id: id, userName: name,profilePhoto: userProfilePhoto)
                })
            handler(self.friendsRequests)
        }
    }
    
    
    func getUserUniqueCode(handler :@escaping(String?) -> ()) {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).getDocument { docSnapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
               
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let safeDocSnapShot = docSnapShot else {return}
            guard let data = safeDocSnapShot.data() else {return}
            guard let userUniqueCode = data["userUniqueCode"] as? String else {return}
            handler(userUniqueCode)
        }
    }

 
    func getUserInfo(handler :@escaping(User?) -> ()){
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        var userName : String = ""
        var userStatus : String = ""
        var userLastSeen : String = ""
        var userEmail : String = ""
        var userPhoto : String = ""
        
        guard let userModel = userDefaultsManager.getUserInfoFromUserDefaults() else {
                firebaseFirestore.collection("users").document(safeUserId).getDocument { documentSnapshot, error in
                    print("firebase")
                    guard let safeViewController = self.viewControllerDelegate else {return}
                    if error != nil {
                       
                        FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                        return
                    }
                    guard let safeDocumentSnapshot = documentSnapshot else {return}
                    guard let safeData =  safeDocumentSnapshot.data() else {return}
                    userName = safeData["userName"] as! String
                    UserDefaults.standard.set(userName, forKey: "userName")
                    guard let safeUserId = self.firebaseAuth.currentUser?.uid else {return}
                    UserDefaults.standard.set(safeUserId, forKey: "userId")
                    userStatus = safeData["userStatus"] as! String
                    UserDefaults.standard.set(userStatus, forKey: "userStatus")
                    userLastSeen = safeData["userLastSeen"] as! String
                    UserDefaults.standard.set(userLastSeen, forKey: "userLastSeen")
                    userEmail = safeData["userEmail"] as! String
                    UserDefaults.standard.set(userEmail, forKey: "userEmail")
                    userPhoto = safeData["profilePhoto"] as! String
                    UserDefaults.standard.set(userPhoto, forKey: "userPhoto")
                    let lastSeen = DateManager.getCurrentDateWithLocaleString()
                    let userModel = User(userName: userName,profilePhoto: userPhoto, userStatus: userStatus, userLastSeen: lastSeen, userEmail: userEmail, isUserOnline: true)
                    handler(userModel)
                }
                return
            }
            handler(userModel)   
    }
    
    func changeUserName(newUserName : String) {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).updateData(["userName" : newUserName])
        UserDefaults.standard.set(newUserName, forKey: "userName")
       
    }
    func changeUserStatus(newUserStatus : String) {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).updateData(["userStatus" : newUserStatus])
        UserDefaults.standard.set(newUserStatus, forKey: "userStatus")
    }
    func userTyping() {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).updateData(["isUserTyping" : true])
    }
    func userNotTyping() {
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).updateData(["isUserTyping" : false])
    }
    
    func updateLastSeen(){
        guard let safeUserId = Auth.auth().currentUser?.uid else {return}
        let dateString = DateManager.getCurrentDateWithLocaleString()
        firebaseFirestore.collection("users").document(safeUserId).updateData(["userLastSeen" : dateString])
    }
    func userOnline() {
        guard let safeUserId = Auth.auth().currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).updateData(["isUserOnline" : true])
    }
    func messageReadTrue(chatRoomCode : String, messageDocId : String){
        firebaseFirestore.collection("chatRooms").document(chatRoomCode).collection("messages").document(messageDocId).updateData(["isMessageRead" : true])
    }
    func userOfline() {
        guard let safeUserId = Auth.auth().currentUser?.uid else {return}
        firebaseFirestore.collection("users").document(safeUserId).updateData(["isUserOnline" : false])
    }
    
    func addFriend(handler :@escaping(User?) -> (),userCode : String) {
        let ref = firebaseFirestore.collection("users")
        guard let safeUserId = firebaseAuth.currentUser?.uid else {return}
        let user = ref.whereField("userUniqueCode", isEqualTo: userCode)
        user.getDocuments { querySnapShot, error in
            guard let safeViewController = self.viewControllerDelegate else {return}
            if error != nil {
               
                FirebaseStandartErrorAlert.showAlert(presentViewController: safeViewController, error: error!)
                return
            }
            guard let safeQuerySnapShot = querySnapShot else {return}
            let docs = safeQuerySnapShot.documents
            if docs.count == 1 {
                docs.forEach { queryDocSnapShot in
                    let receiveUserId = queryDocSnapShot.documentID
                    _ = queryDocSnapShot.data()
                    guard let userModel = self.userDefaultsManager.getUserInfoFromUserDefaults() else {return}
                    
                    guard let safeUserModelProfilePhoto = userModel.profilePhoto else {return}
                     let userName =  userModel.userName
                     let profilePhoto = safeUserModelProfilePhoto
                    self.firebaseFirestore.collection("requests").document(receiveUserId).collection("friendsRequests").document(safeUserId).setData(["profilePhoto" : profilePhoto,"userName" : userName])
                }
            }
            else {
                print("useruniquecode error please contact with support team")
                return
            }
        }
   
    }
}
