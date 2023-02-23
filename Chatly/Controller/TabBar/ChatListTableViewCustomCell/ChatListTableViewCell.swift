//
//  ChatListTableViewCell.swift
//  Chatly
//
//  Created by Alper Yorgun on 12.02.2023.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chatListTableViewCellImage.clipsToBounds = true
        chatListTableViewCellImage.makeRounded()
        
    }
    
    @IBOutlet weak var chatListTableViewCellImage: UIImageView!
    
    @IBOutlet weak var chatListTableViewCellName: UILabel!
    
    @IBOutlet weak var chatListTableViewCellLastMessage: UILabel!
    
    @IBOutlet weak var chatListTableViewCellUnreadMessageCountImage: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
