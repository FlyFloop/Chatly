//
//  FriendsTableViewCell.swift
//  Chatly
//
//  Created by Alper Yorgun on 6.02.2023.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var friendsTableViewCellImage: UIImageView!
    
    
    @IBOutlet weak var friendsTableViewCellLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        friendsTableViewCellImage.clipsToBounds = true
        friendsTableViewCellImage.contentMode = .scaleAspectFill
        friendsTableViewCellImage.makeRounded()
       
    }
    


    @objc func deleteFriendFromFriends()  {
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
