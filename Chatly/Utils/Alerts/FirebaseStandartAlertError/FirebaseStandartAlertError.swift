//
//  FirebaseStandartAlertError.swift
//  Chatly
//
//  Created by Alper Yorgun on 16.02.2023.
//

import Foundation
import UIKit


struct FirebaseStandartErrorAlert {
    static func showAlert(presentViewController : UIViewController, error : Error){
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        presentViewController.present(alert, animated: true)
    }
}
