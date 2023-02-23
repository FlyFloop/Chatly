//
//  ViewController.swift
//  Chatly
//
//  Created by Alper Yorgun on 29.01.2023.
//

import UIKit

class ViewController: UIViewController {
 
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    let firebaseNetworkManager = FirebaseNetworkManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseNetworkManager.viewControllerDelegate = self
        let result = firebaseNetworkManager.autoLogin()
        if result {
            self.performSegue(withIdentifier: StringConstants.autoLoginSegue, sender: self)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        configureViewControllerComponents()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    func configureViewControllerComponents() {
        loginButton.titleLabel?.textColor = ChatlyColorConstants.buttonForegroundColor
        registerButton.titleLabel?.textColor = ChatlyColorConstants.buttonForegroundColor
        loginButton.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        loginButton.clipsToBounds = true
        registerButton.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        registerButton.clipsToBounds = true
        imageView.layer.cornerRadius = CornerRadiusConstans.buttonCornerRadius
        imageView.clipsToBounds = true
        loginButton.titleLabel?.text = StringConstants.loginButtonString
        registerButton.titleLabel?.text = StringConstants.registerButtonString
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: StringConstants.goToLoginSegueString, sender: self)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: StringConstants.goToRegisterSegueString, sender: self)
    }
    

}

