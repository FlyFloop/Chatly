//
//  Message.swift
//  Chatly
//
//  Created by Alper Yorgun on 10.02.2023.
//

import Foundation
import MessageKit


struct Message : MessageType {
    var sender: MessageKit.SenderType
    
    var messageId: String = ""
    
    var sentDate: Date
    
    var kind: MessageKind
    
    var isMessageRead : Bool
    
    
}
