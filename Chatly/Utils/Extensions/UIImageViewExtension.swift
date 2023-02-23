//
//  UIImageViewExtension.swift
//  Chatly
//
//  Created by Alper Yorgun on 7.02.2023.
//

import Foundation
import UIKit

extension UIImageView {
    
    func makeRounded() {
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
    
    
}
