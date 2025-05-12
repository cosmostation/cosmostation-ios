//
//  TextInput.swift
//  SplashWallet
//
//  Created by yongjoo jung on 2023/04/07.
//

import UIKit
import MaterialComponents

extension MDCOutlinedTextField {
    
    func setup() {
        self.label.textColor = .color01
        self.tintColor = .color01
        self.containerRadius = 8
        self.setFloatingLabelColor(.color01, for: .editing)
        self.setFloatingLabelColor(.color04, for: .normal)
        self.setNormalLabelColor(.color04, for: .normal)
        self.setOutlineColor(.color01, for: .editing)
        self.setOutlineColor(.color05, for: .normal)
        self.returnKeyType = .done
        self.enablesReturnKeyAutomatically = true
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.smartInsertDeleteType = .no
        self.textContentType = .init(rawValue: "")
        self.keyboardType = .default
    }

}

extension MDCOutlinedTextArea {
    func setup() {
        self.label.textColor = .color01
        self.tintColor = .color01
        self.containerRadius = 8
        self.setFloatingLabel(.color01, for: .editing)
        self.setFloatingLabel(.color04, for: .normal)
        self.setNormalLabel(.color04, for: .normal)
        self.setOutlineColor(.color01, for: .editing)
        self.setOutlineColor(.color05, for: .normal)
        self.textView.font = .fontSize16Bold
        self.textView.returnKeyType = .done
        self.textView.enablesReturnKeyAutomatically = true
        self.textView.autocorrectionType = .no
        self.textView.autocapitalizationType = .none
        self.textView.smartInsertDeleteType = .no
        self.textView.textContentType = .init(rawValue: "")
        self.textView.keyboardType = .default
    }
}
