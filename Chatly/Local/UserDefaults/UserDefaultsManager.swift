//
//  UserDefaultsManager.swift
//  Chatly
//
//  Created by Alper Yorgun on 3.02.2023.
//

import Foundation


struct UserDefaultsManager {
    func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    func saveChatRoomCodeToUserDefaults(chatRoomCode : String){
        UserDefaults.standard.set(chatRoomCode, forKey: "chatRoomCode")
    }
    func getChatRoomCodeFromUserDefaults(chatRoomCode : String) -> String? {
        guard let safeChatRoomCode = UserDefaults.standard.string(forKey: UserDefaultsStrings.chatRoomCode) else {return nil}
        return safeChatRoomCode
    }
    
    func saveFriendToUserDefaults(friend : Friend){
        let friendModel = friend
        do {
            let encoder = JSONEncoder()
            let data =  try encoder.encode(friendModel)
            UserDefaults.standard.set(data, forKey: UserDefaultsStrings.friendInUserDefaults)
        } catch {
            print(ErrorStrings.userDefaultsSaveFriendError)
        }
    }
    func saveChatRoomUniqueCode (code : String) {
        UserDefaults.standard.set(code, forKey: StringConstants.chatUsersUniqueCode)
    }
    func getChatRoomUniqueCode () -> String? {
        guard let code = UserDefaults.standard.string(forKey: UserDefaultsStrings.chatUsersUniqueCode) else {return nil}
        return code
    }
    func getFriendFromUserDefaults () -> Friend? {
        if let data = UserDefaults.standard.object(forKey: UserDefaultsStrings.friendInUserDefaults){
            do{
                let decoder = JSONDecoder()
                let model = try decoder.decode(Friend.self, from: data as! Data)
                return model
                
            } catch {
                print("unable to get friend from userdefaults")
            }
        }
        return nil
    }
    func saveUserToUserDefaults(user : User){
        let userModel = user
        do {
            let encoder = JSONEncoder()
            let data =  try encoder.encode(userModel)
            UserDefaults.standard.set(data, forKey: UserDefaultsStrings.userInUserDefaults)
        } catch {
            print("unable to save user object ")
        }
    }
    func getUserFromUserDefaults () -> User? {
        if let data = UserDefaults.standard.object(forKey: UserDefaultsStrings.userInUserDefaults){
            do{
                let decoder = JSONDecoder()
                let model = try decoder.decode(User.self, from: data as! Data)
                return model
                
            } catch {
                print("unable to get user from userdefaults")
            }
        }
        return nil
    }
    func getUserInfoFromUserDefaults() -> User? {
        lazy var isUserNameUserDefaults = false
        lazy var isUserStatusUserDefaults = false
        lazy var isProfilePhotoUserDefaults = false
        lazy var isUserLastSeenUserDefaults = false
        lazy var isUserEmailUserDefaults = false
        lazy var isUserIdUserDefaults = false
         var userNameUserDefaults = ""
         var userStatusUserDefaults = ""
         var profilePhotoUserDefaults = ""
         var userLastSeenUserDefaults = ""
         var userEmailUserDefaults = ""
         var userIdUserDefaults = ""
 
    
        if let userName = UserDefaults.standard.string(forKey: "userName") {
           userNameUserDefaults = userName
            isUserNameUserDefaults = true
        }
        if let userStatus = UserDefaults.standard.string(forKey: "userStatus") {
            userStatusUserDefaults = userStatus
            isUserStatusUserDefaults = true
           
        }
        if let userLastSeen = UserDefaults.standard.string(forKey: "userLastSeen") {
            userLastSeenUserDefaults = userLastSeen
            isUserLastSeenUserDefaults = true
            
        }
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            userEmailUserDefaults = userEmail
            isUserEmailUserDefaults = true
        }
        if let profilePhoto = UserDefaults.standard.string(forKey: "userPhoto") {
            profilePhotoUserDefaults = profilePhoto
            isProfilePhotoUserDefaults = true
        }
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            userIdUserDefaults = userId
            isUserIdUserDefaults = true
        }
        if isUserNameUserDefaults && isUserStatusUserDefaults && isProfilePhotoUserDefaults && isUserLastSeenUserDefaults && isUserEmailUserDefaults   {
            let userModel = User(userId : userIdUserDefaults ,userName: userNameUserDefaults,profilePhoto: profilePhotoUserDefaults, userStatus: userStatusUserDefaults, userLastSeen: userLastSeenUserDefaults, userEmail: userEmailUserDefaults, isUserOnline: true)
           
            return userModel
        }else{
         return nil
        }
    }
}
