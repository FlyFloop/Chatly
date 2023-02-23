//
//  Friend.swift
//  Chatly
//
//  Created by Alper Yorgun on 4.02.2023.
//

import Foundation
import FirebaseFirestore

struct Friend : Codable, Equatable {
    var id : String
    var userName : String
    var profilePhoto : String
    var userStatus : String?
    var lastSeen : String?
    var chatRoomCode : String?
    var ref : DocumentReference?

}
