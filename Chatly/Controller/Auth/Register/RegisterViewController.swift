//
//  RegisterViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 30.01.2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import NanoID

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    let firebaseStorage = Storage.storage().reference()
    let firebaseAuth = Auth.auth()
    let firebaseFirestore = Firestore.firestore()
    let urlNetwork = URLNetworkModel()
    let firebaseNetworkManager = FirebaseNetworkManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationTitleColor.configureNavigationBarTitle(title: "Register", navigationItem: self.navigationItem, navigationController: self.navigationController)
        firebaseNetworkManager.viewControllerDelegate = self
        let result = firebaseNetworkManager.autoLogin()
       
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loader() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: StringConstants.alertLoaderMessage, preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.large
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            return alert
        }
        
        func stopLoaderAndGoRootView(loader : UIAlertController) {
            DispatchQueue.main.async {
                loader.dismiss(animated: true) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    
    
    @IBAction func googleRegisterButtonPressed(_ sender: UIButton) {
        signInUser { bool in
            
        }
        
    }
    func signInUser(handler :@escaping(Bool?) ->()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if error != nil {
                handler(nil)
            return
          }
          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }
          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)
            guard let googleSafeUser = user?.profile else {return}
            let date = Date.now
            let dateFormatter = DateFormatter()
            let stringDate = dateFormatter.string(from: date)
            Auth.auth().signIn(with: credential) {authResult , error in
                
                if error != nil {
                    print(ErrorStrings.googleSigninError)
                    handler(nil)
                    return
                }
                guard let safeUserId = Auth.auth().currentUser?.uid else {return}
                let alert = self.loader()
                let userUniqueCode = GenerateRandomUserUniqueCode.randomUserUniqueCode(userId: safeUserId)
                if googleSafeUser.hasImage {
                   
                    let ref = self.firebaseStorage.child(safeUserId).child(FirebaseStringConstants.imageRefStorage).child(FirebaseStringConstants.profilePhotoStringRefStorage)
                    // 0 -> profile photo
                    
                    guard let safeUserProfileUrl = googleSafeUser.imageURL(withDimension: 2048) else {return}
                    
                    self.urlNetwork.fetchAndUploadGoogleImage(handler: { imageLinkString in
                        let userModel = User(userUniqueCode: userUniqueCode,userName: googleSafeUser.name, profilePhoto: imageLinkString, userStatus: StringConstants.userFirstSetDataStatus, userLastSeen: stringDate, userEmail: googleSafeUser.email, isUserOnline: false)
                        do{
                            try self.firebaseFirestore.collection(FirebaseStringConstants.usersCollectionFirestore).document(safeUserId).setData(from: userModel)
                        } catch {
                            print(ErrorStrings.googleSigninSetDataError)
                        }
                    }, url: safeUserProfileUrl, ref: ref)
                    DispatchQueue.main.async {
                      
                        self.stopLoaderAndGoRootView(loader: alert)
                        
                    }
                handler(true)
                }
                else {
                    let userModel = User(userUniqueCode: userUniqueCode, userName: googleSafeUser.name, profilePhoto: nil, userStatus: StringConstants.userFirstSetDataStatus, userLastSeen: stringDate, userEmail: googleSafeUser.email, isUserOnline: false)
                    do{
                        try self.firebaseFirestore.collection(FirebaseStringConstants.usersCollectionFirestore).document(safeUserId).setData(from: userModel)
                    } catch {
                        print(ErrorStrings.googleSigninSetDataError)
                    }
                    DispatchQueue.main.async {
                        self.stopLoaderAndGoRootView(loader: alert)
                      
                    }
                    handler(true)
                }
               
            }
            
            
        }
    }
    @IBAction func appleRegisterButtonPressed(_ sender: UIButton) {
    }    
}
