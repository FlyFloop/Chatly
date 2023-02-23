//
//  UINavigationItemTitleColorFunction.swift
//  Chatly
//
//  Created by Alper Yorgun on 31.01.2023.
//

import Foundation
import UIKit

struct UINavigationTitleColor {
    static func configureNavigationBarTitle(title : String, navigationItem : UINavigationItem, navigationController : UINavigationController?) {
        navigationItem.title = title
        let textAttributes = [NSAttributedString.Key.foregroundColor: ChatlyColorConstants.labelColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
}
