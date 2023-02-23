//
//  User.swift
//  Chatly
//
//  Created by Alper Yorgun on 31.01.2023.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct User : Codable, Identifiable{
    @DocumentID var id : String? = UUID().uuidString
    var userId : String?
    var userUniqueCode : String?
    var userName : String
    var profilePhoto : String?
    var userStatus : String
    var userLastSeen : String
    var userEmail : String
    var isUserOnline : Bool
    var ref : DocumentReference?
}
