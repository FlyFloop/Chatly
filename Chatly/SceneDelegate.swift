//
//  SceneDelegate.swift
//  Chatly
//
//  Created by Alper Yorgun on 29.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let firebaseNetworkManager = FirebaseNetworkManager()
    let coreDataManager = CoreDataManager()
    

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        firebaseNetworkManager.updateLastSeen()
        firebaseNetworkManager.userOfline()
       
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        firebaseNetworkManager.userOnline()
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }
    func sceneWillEnterForeground(_ scene: UIScene) {

    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        firebaseNetworkManager.updateLastSeen()
        firebaseNetworkManager.userOfline()
    }

}

