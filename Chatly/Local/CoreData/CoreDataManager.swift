//
//  CoreDataManager.swift
//  Chatly
//
//  Created by Alper Yorgun on 16.02.2023.
//

import Foundation
import UIKit
import CoreData





struct CoreDataManager {
    func saveItem(context : NSManagedObjectContext){
        //coredata saving
        do {
            try context.save()
        } catch {
            print(ErrorStrings.coreDataSaveItemError)
        }
    }
    func loadUser(context : NSManagedObjectContext)  -> [UserCoreData]? {
        let userRequest : NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        do{
            let fetchedData = try context.fetch(userRequest)
           return fetchedData
        } catch {
            print(ErrorStrings.coreDataLoadUserError)
        }
        return nil
    }
    func loadChatFriends(context : NSManagedObjectContext) -> [ChatsCoreData]? {
        let chatUserRequest : NSFetchRequest<ChatsCoreData> = ChatsCoreData.fetchRequest()
        do {
            let fetchedData = try context.fetch(chatUserRequest)
            return fetchedData
        } catch {
            print(ErrorStrings.coreDataLoadChatFriendsError)
        }
        return nil
    }
    func deleteUser(context : NSManagedObjectContext) {
          let fetchRequest = UserCoreData.fetchRequest()
          let items = try? context.fetch(fetchRequest)
          for item in items ?? [] {
              context.delete(item)
          }
          try? context.save()
      }
    func deleteFriend(context : NSManagedObjectContext, friendId : String){
        do {
            let fetchRequest = FriendCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", friendId)
            let friendCoreData = try context.fetch(fetchRequest)
            guard let firstFriendCoreData = friendCoreData.first else {return}
            context.delete(firstFriendCoreData)
            try context.save()
        } catch {
            
        }
    }
    func loadFriends(context : NSManagedObjectContext) -> [FriendCoreData]? {
        do {
            let fetchRequest = FriendCoreData.fetchRequest()
            let items = try context.fetch(fetchRequest)
            return items
        } catch {
            print(ErrorStrings.coreDataLoadFriendsError)
        }
        return nil
    }
    func deleteFriends(context : NSManagedObjectContext) {
          //write item type to itemType
          let fetchRequest = FriendCoreData.fetchRequest()
          let items = try? context.fetch(fetchRequest)
          for item in items ?? [] {
              context.delete(item)
          }
          try? context.save()
      }
    func getFriendDetail(context : NSManagedObjectContext, friendId : String) -> [FriendCoreData]? {
        let fetchRequest = FriendCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", friendId)
        let items = try? context.fetch(fetchRequest)
        return items
    }
}
