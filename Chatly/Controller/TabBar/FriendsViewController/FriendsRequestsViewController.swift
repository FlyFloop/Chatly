//
//  FriendsRequestsViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 4.02.2023.
//

import UIKit

class FriendsRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsViewTableViewCell = friendsRequestTableView.dequeueReusableCell(withIdentifier: CellStrings.friendsRequestViewTableViewCell, for: indexPath) as? FriendsRequestCellTableViewCell
        friendsViewTableViewCell?.friendsRequestTableView = friendsRequestTableView
        friendsViewTableViewCell?.friend = friends[indexPath.row]
        friendsViewTableViewCell?.navigationController = self.navigationController
        guard let safeUrl = URL(string: friends[indexPath.row].profilePhoto) else {return UITableViewCell()}
        urlNetworkManager.fetchImageWithUrl(handler: { image in
            guard let safeImage = image else {return }
            friendsViewTableViewCell?.friendsRequestCellImage.image = safeImage
        }, url: safeUrl)
        friendsViewTableViewCell?.friendsRequestCellNameLabel.text = friends[indexPath.row].userName
 
        
       
        guard let safeFriendsViewTableViewCell = friendsViewTableViewCell else {return UITableViewCell()}
        return safeFriendsViewTableViewCell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendsRequestTableView.cellForRow(at: indexPath)?.selectionStyle = .none
 
    }
    
    
    
    
    @IBOutlet weak var friendsRequestTableView: UITableView!
    var friends : [Friend] = []
    let firebaseNetworkManager = FirebaseNetworkManager()
    let urlNetworkManager = URLNetworkModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendsRequestTableView.register(UINib(nibName: CellStrings.friendsRequestTableViewCellClass, bundle: nil), forCellReuseIdentifier: CellStrings.friendsRequestViewTableViewCell)
        friendsRequestTableView.delegate = self
        friendsRequestTableView.dataSource = self
        firebaseNetworkManager.viewControllerDelegate = self
        getUserFriendsRequests()
        
        // Do any additional setup after loading the view.
    }
    
    func getUserFriendsRequests(){
        firebaseNetworkManager.getUserFriendsRequests { friendsRequests in
            guard let safeFriendsRequests = friendsRequests else {return}
            self.friends = safeFriendsRequests
            self.friendsRequestTableView.reloadData()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
