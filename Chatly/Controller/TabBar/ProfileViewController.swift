//
//  ProfileViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 1.02.2023.
//

import UIKit
import BLTNBoard //

import UserNotifications

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var statusChangeIcon: UIImageView!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var statusTextLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var nameChangeIcon: UIImageView!
    @IBOutlet weak var profileNavigationBar: UINavigationBar!
    
    
    
    let imageCache = NSCache<NSString,UIImage>()
    let urlNetwork : URLNetworkModel = URLNetworkModel()
    var userModel : User?
    let firebaseNetworkManager : FirebaseNetworkManager = FirebaseNetworkManager()
    var isName = false
    let coreDataManager = CoreDataManager()
    var userCoreData : [UserCoreData] = []

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       
    }
    
    private lazy var statusChangeBottomSheet : BLTNItemManager = {
        let title =  StringConstants.changeStatusTitle
        let description = "\(StringConstants.changeStatusDescription)  \(self.statusTextLabel.text ?? "error status change")"
        let placeHolder = StringConstants.changeStatusPlaceholder
            let item = TextFieldBulletinPage(title: title)
        item.actionButtonTitle = StringConstants.changeStatusActionButtonTitle
            item.descriptionText = description
            item.textFieldPlaceHolder = placeHolder
            item.appearance.actionButtonColor = ChatlyColorConstants.buttonBackgroundColor
            item.appearance.actionButtonTitleColor = ChatlyColorConstants.buttonForegroundColor
            item.appearance.descriptionTextColor = ChatlyColorConstants.labelColor
            item.requiresCloseButton = true
            item.isDismissable = true
            item.actionHandler =  { _ in
                guard let safeTextField = item.textField.text else {return}
                self.firebaseNetworkManager.changeUserStatus(newUserStatus: safeTextField)
                self.statusTextLabel.text = safeTextField
                self.userCoreData.first?.setValue(safeTextField, forKey: CoreDataStrings.userStatusKey)
                self.coreDataManager.saveItem(context: self.context)
                self.dismiss(animated: true)
                //loader koy
            }
        
            let itemInterfaceBuilder = BLTNInterfaceBuilder(appearance: item.appearance)
            _ = item.makeViewsUnderDescription(with: itemInterfaceBuilder)
        
            return BLTNItemManager(rootItem: item)
    }()
    private lazy var nameChangeBottomSheet : BLTNItemManager = {
        let title =  StringConstants.changeNameTitle
        let description = "\(StringConstants.changeStatusDescription)  \(self.nameTextLabel.text ?? "error name change")"
        let placeHolder = StringConstants.changeNamePlaceholder
            let item = TextFieldBulletinPage(title: title)
        item.actionButtonTitle = StringConstants.changeNameActionButtonTitle
          
            item.descriptionText = description
            item.textFieldPlaceHolder = placeHolder
            item.appearance.actionButtonColor = ChatlyColorConstants.buttonBackgroundColor
            item.appearance.actionButtonTitleColor = ChatlyColorConstants.buttonForegroundColor
            item.appearance.descriptionTextColor = ChatlyColorConstants.labelColor
            item.requiresCloseButton = true
            item.isDismissable = true
            item.actionHandler =  { _ in
                guard let safeTextField = item.textField.text else {return}
                self.firebaseNetworkManager.changeUserName(newUserName: safeTextField)
                self.nameTextLabel.text = safeTextField
                self.userCoreData.first?.setValue(safeTextField, forKey: CoreDataStrings.userNameKey)
                self.coreDataManager.saveItem(context: self.context)
                self.dismiss(animated: true)
                //loader koy
            }
            let itemInterfaceBuilder = BLTNInterfaceBuilder(appearance: item.appearance)
            _ = item.makeViewsUnderDescription(with: itemInterfaceBuilder)
        
            return BLTNItemManager(rootItem: item)
    }()
    
      override func viewDidLoad() {
        super.viewDidLoad()
        initProfileScreen()
          firebaseNetworkManager.viewControllerDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let safeCoreDataUser = coreDataManager.loadUser(context: context) else {return}
        userCoreData = safeCoreDataUser
        initProfileScreen()
    }
    func initGestureRecognizers(){
        let tapNameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nameChangeIconPressed))
        let tapStatusGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(statusChangeIconPressed))
        let tapProfilePhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePhoto))
        nameChangeIcon.isUserInteractionEnabled = true
        nameChangeIcon.addGestureRecognizer(tapNameGestureRecognizer)
        statusChangeIcon.isUserInteractionEnabled = true
        statusChangeIcon.addGestureRecognizer(tapStatusGestureRecognizer)
        profilePhotoImageView.addGestureRecognizer(tapProfilePhotoGestureRecognizer)
        profilePhotoImageView.isUserInteractionEnabled = true
    }
    
    @objc func changeProfilePhoto() {
        let imagePickController = UIImagePickerController()
        imagePickController.delegate = self
        imagePickController.allowsEditing = true
        imagePickController.sourceType = .photoLibrary
        present(imagePickController, animated: true)
        
     }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: StringConstants.imagePickerInfoKey)] as? UIImage {
            profilePhotoImageView.image = image
        
            self.firebaseNetworkManager.updateUserProfilePhoto(handler: { photoString in
                self.profilePhotoImageView.image = image
                picker.dismiss(animated: true)
            }, image: image)
        }
        
    }
   @objc func nameChangeIconPressed() {
       nameChangeBottomSheet.backgroundViewStyle = .blurredLight
       nameChangeBottomSheet.showBulletin(above: self)

    }
    @objc func statusChangeIconPressed() {
        statusChangeBottomSheet.backgroundViewStyle = .blurredLight
        statusChangeBottomSheet.showBulletin(above: self)
     }
    func initProfilePhotoImage()  {
        profilePhotoImageView.makeRounded()

    }
    func initSettingsButton(){
        settingsButton.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        settingsButton.clipsToBounds = true
    }
    
    func initProfileScreen() {
        initGestureRecognizers()
        initSettingsButton()
        initProfilePhotoImage()
        
       
            guard let safeUserCoreData = userCoreData.first else {
                firebaseNetworkManager.getUserInfo { user in
                    DispatchQueue.main.async {
                             guard let safeUserPhotoString = user?.profilePhoto else {return}
                             guard let safeUrl = URL(string: safeUserPhotoString) else {return}
                        self.nameTextLabel.text = user?.userName
                        self.statusTextLabel.text = user?.userStatus
                        if let imageC = self.imageCache.object(forKey: StringConstants.profilePhotoCache as NSString){
                            DispatchQueue.main.async {
                                self.profilePhotoImageView.image = imageC
                                
                            }
                            return
                        }
                        else {
                            self.urlNetwork.fetchImageWithUrl(handler: { image in
                                guard let safeImage = image else {return}
                                self.profilePhotoImageView.image = safeImage
                                self.imageCache.setObject(safeImage, forKey: StringConstants.profilePhotoCache as NSString)
                            }, url: safeUrl)
                        }

                    }
                }
                return
            }
        DispatchQueue.main.async {
            self.nameTextLabel.text = safeUserCoreData.userName
            self.statusTextLabel.text = safeUserCoreData.userStatus
            guard let safeProfilePhoto = safeUserCoreData.profilePhoto else {return}
            guard let safeUrl = URL(string: safeProfilePhoto) else {return}
            if let imageC = self.imageCache.object(forKey: StringConstants.profilePhotoCache as NSString){
                DispatchQueue.main.async {
                    self.profilePhotoImageView.image = imageC
                }
                return
            }
            self.urlNetwork.fetchImageWithUrl(handler: { image in
                guard let safeImage = image else {return}
                self.profilePhotoImageView.image = safeImage
                self.imageCache.setObject(safeImage, forKey: StringConstants.profilePhotoCache as NSString)
            }, url: safeUrl)
        }
       
       
       
    }
    
  
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: SegueStrings.goToSettingsFromProfileSegueString, sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
