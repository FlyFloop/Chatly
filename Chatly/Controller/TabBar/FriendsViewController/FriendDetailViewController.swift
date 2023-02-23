//
//  FriendDetailViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 6.02.2023.
//

import UIKit
import BLTNBoard

class FriendDetailViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var friendId : String? = nil
    let firebaseNetworkManager = FirebaseNetworkManager()
    let urlRequest = URLNetworkModel()
    var friendsCoreData : [FriendCoreData] = []
    let coreDataManager = CoreDataManager()
    let userDefaultsManager = UserDefaultsManager()
    private let friendImageCache = NSCache<NSString,UIImage>()
    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendStatusLabel: UILabel!
    @IBOutlet weak var friendLastSeen: UILabel!
    @IBOutlet weak var deleteFriendButton: UIButton!
    @IBOutlet weak var goToChatsButton: UIButton!
    
    var isFriendDeleted : Bool {
        get{
            return self.isFriendDeleted
        }
        set{
            if newValue == true {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private lazy var deleteFriendBottomSheet : BLTNItemManager = {
       
        let title =  StringConstants.deleteFriendTitle
        let description = "\(StringConstants.deleteFriendDescription) \(friendNameLabel.text ?? "error")."
       
            let item = BLTNPageItem(title: title)
        item.actionButtonTitle = StringConstants.deleteFriendActionButtonTitle
            item.descriptionText = description
            item.appearance.actionButtonColor = ChatlyColorConstants.buttonBackgroundColor
            item.appearance.actionButtonTitleColor = ChatlyColorConstants.buttonForegroundColor
            item.appearance.descriptionTextColor = ChatlyColorConstants.labelColor
            item.requiresCloseButton = true
            item.isDismissable = true
            item.actionHandler =  { _ in
                guard let safeFriendId = self.friendId else {return}
                guard let safeChatRoomCode = self.userDefaultsManager.getChatRoomUniqueCode() else {return}
               self.firebaseNetworkManager.deleteFriend(friendId: safeFriendId, chatRoomCode: safeChatRoomCode)
                self.coreDataManager.deleteFriend(context: self.context, friendId: safeFriendId)
                
                self.dismiss(animated: true) {
                   
                    self.isFriendDeleted = true
                }
               
                
                //loader koy
            }
            
            return BLTNItemManager(rootItem: item)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initImageView()
        deleteFriendButton.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        deleteFriendButton.clipsToBounds = true
        goToChatsButton.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        goToChatsButton.clipsToBounds = true
        firebaseNetworkManager.viewControllerDelegate = self
    }
    
    func initImageView()  {
        friendImageView.makeRounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
   
            getUserDetail()
        
        
       
        
    }
    
    func getUserDetail(){
        guard let safeFriendId = friendId else {return}
        firebaseNetworkManager.getFriendDetail(handler: { friend in
            guard let safeFriendModel = friend else {return}
            guard let safeUrl = URL(string: safeFriendModel.profilePhoto) else {return}
            guard let safeChatRoomCode = friend?.chatRoomCode else {return}
            self.userDefaultsManager.saveChatRoomUniqueCode(code: safeChatRoomCode)
                self.urlRequest.fetchImageWithUrl(handler: { image in
                    guard let safeImage = image else {return}
                    self.friendImageView.image = safeImage
               
                    
                    }, url: safeUrl)
            
            self.friendNameLabel.text = safeFriendModel.userName
            self.friendStatusLabel.text = safeFriendModel.userStatus
            self.friendLastSeen.text = safeFriendModel.lastSeen
            do {
                let fetchRequest = FriendCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", safeFriendId)
                let friendCoreData = try self.context.fetch(fetchRequest)
            
                friendCoreData.first?.setValue(safeFriendModel.userName, forKey: CoreDataStrings.userNameKey)
                friendCoreData.first?.setValue(safeFriendModel.profilePhoto, forKey: CoreDataStrings.profilePhotoKey)
                friendCoreData.first?.setValue(safeFriendModel.chatRoomCode, forKey: CoreDataStrings.chatRoomCodeKey)
                self.coreDataManager.saveItem(context: self.context)
            } catch {
                
            }
        }, friendId: safeFriendId)
    }
    
    
    @IBAction func deleteFriendButtonPressed(_ sender: UIButton) {
        deleteFriendBottomSheet.backgroundViewStyle = .blurredLight
        deleteFriendBottomSheet.showBulletin(above: self)
        //chatroomlarda dahil olmak üzere bir çok yer silinicek
        
    }
    
    
    @IBAction func FriendDetailGoToChatsButtonPressed(_ sender: UIButton) {
     
        // MARK: Passing data through navigation PushViewController
           

        let messageViewController = MessageViewController()
    
            messageViewController.receiverId = friendId
        self.navigationController?.pushViewController(messageViewController, animated: true)
                   
                
            
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
    }
    
    

}
