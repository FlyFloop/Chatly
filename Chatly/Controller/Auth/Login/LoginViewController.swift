//
//  LoginViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 30.01.2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import CoreData


class LoginViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()
    let firebaseNetworkManager = FirebaseNetworkManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let coreDataManager = CoreDataManager()
    
    
    
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
        
        func stopLoaderAndGoHomeView(loader : UIAlertController) {
            DispatchQueue.main.async {
                loader.dismiss(animated: true) {
                    self.firebaseNetworkManager.getUserInfo { user in
                        self.performSegue(withIdentifier: SegueStrings.goToHomeFromLoginSegueString, sender: self)
                    }
                    
                }
            }
        }
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationTitleColor.configureNavigationBarTitle(title: StringConstants.loginViewTitle, navigationItem: self.navigationItem, navigationController: self.navigationController)
        firebaseNetworkManager.viewControllerDelegate = self
        // Do any additional setup after loading the view.
        let result = firebaseNetworkManager.autoLogin()
        if result {
            self.performSegue(withIdentifier: SegueStrings.goToHomeFromLoginSegueString, sender: self)
            
        }
    }
   
    @IBAction func googeLoginButtonPressed(_ sender: UIButton) {
       // self.performSegue(withIdentifier: StringConstants.goToHomeFromLoginSegueString, sender: self)

        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

            if error != nil {
            // ...
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
            firebaseAuth.signIn(with: credential){
                result , error in
                let loader = self.loader()
              
                if error != nil {
                    print(ErrorStrings.googleLoginButtonError)
                    return
                }
                self.firebaseNetworkManager.getUserInfo { user in
                    guard let safeUser = user else  {return}
                    let newModel = UserCoreData(context: self.context)
                    newModel.userStatus = safeUser.userStatus
                    newModel.profilePhoto = safeUser.profilePhoto
                    newModel.userName = safeUser.userName
                    newModel.userId = safeUser.userId
                    newModel.userEmail = safeUser.userEmail
                    newModel.userUniqueCode = safeUser.userUniqueCode
                    self.coreDataManager.saveItem(context: self.context)
                    self.firebaseNetworkManager.userOnline()
                    
                    self.stopLoaderAndGoHomeView(loader: loader)
                }
            }
          // ...
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
