//
//  GenerateRandomUserUniqueCode.swift
//  Chatly
//
//  Created by Alper Yorgun on 3.02.2023.
//

import Foundation
import NanoID

struct GenerateRandomUserUniqueCode {
    static func randomUserUniqueCode(userId : String) -> String {
        let id = ID()
        let randomId = id.generate(alphabet: .full,size:2)
        let index = userId.index(userId.startIndex, offsetBy:2)
        let randomSecondId = id.generate(alphabet: .full,size:2)
        let safeUserIdSubstring = userId[..<index]
        let userUniqueCode = "\(randomId)\(safeUserIdSubstring)\(randomSecondId)"
        return userUniqueCode
    }
    static func randomChatRoomsUniqueCode(userId : String, friendId : String) -> String {
        let id = ID()
        let randomId = id.generate(alphabet: .full,size:2)
        let index = userId.index(userId.startIndex, offsetBy:2)
        let randomSecondId = id.generate(alphabet: .full,size:2)
        let safeUserIdSubstring = userId[..<index]
        
        let randomThree = id.generate(alphabet: .full,size:2)
        let indexFriend = friendId.index(friendId.startIndex, offsetBy:2)
        let randomFourId = id.generate(alphabet: .full,size:2)
        let safeFriendIdSubstring = friendId[..<indexFriend]
        let randomCharRoomsUniqueCode = "\(randomId)\(safeUserIdSubstring)\(randomSecondId)\(randomThree)\(safeFriendIdSubstring)\(randomFourId)"
        return randomCharRoomsUniqueCode
    }
}
