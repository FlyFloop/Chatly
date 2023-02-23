//
//  BulletinBoardTextField.swift
//  Chatly
//
//  Created by Alper Yorgun on 2.02.2023.
//

import Foundation
import BLTNBoard



@objc public class TextFieldBulletinPage : BLTNPageItem, UITextFieldDelegate {

    @objc public var textField: UITextField!

    @objc public var textInputHandler: ((TextFieldBulletinPage, String?) -> Void)? = nil
    
    public var textFieldPlaceHolder = ""

    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        textField = interfaceBuilder.makeTextField(placeholder: textFieldPlaceHolder, returnKey: .done, delegate: self)
        return [textField]
    }

    override public func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }

    override public func actionButtonTapped(sender: UIButton) {
        textField.resignFirstResponder()
        super.actionButtonTapped(sender: sender)
    }

}
