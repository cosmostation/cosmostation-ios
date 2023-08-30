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
        self.setFloatingLabelColor(.color03, for: .normal)
        self.setNormalLabelColor(.color03, for: .normal)
        self.setOutlineColor(.color01, for: .editing)
        self.setOutlineColor(.color03, for: .normal)
        self.returnKeyType = .done
        self.enablesReturnKeyAutomatically = true
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.smartInsertDeleteType = .no
        self.textContentType = .init(rawValue: "")
        self.keyboardType = .default
    }

}

//extension MDCOutlinedTextArea {
//    func setup() {
//        self.label.textColor = UIColor.base05
//        self.tintColor = UIColor.text01
//        self.containerRadius = 8
//        self.setFloatingLabel(UIColor.primary, for: .editing)
//        self.setFloatingLabel(UIColor.base04, for: .normal)
//        self.setNormalLabel(UIColor.base04, for: .normal)
//        self.setOutlineColor(UIColor.primary, for: .editing)
//        self.setOutlineColor(UIColor.base03, for: .normal)
//        self.textView.font = font5
//        self.textView.returnKeyType = .done
//        self.textView.enablesReturnKeyAutomatically = true
//        self.textView.autocorrectionType = .no
//        self.textView.autocapitalizationType = .none
//        self.textView.smartInsertDeleteType = .no
//        self.textView.textContentType = .init(rawValue: "")
//        self.textView.keyboardType = .default
//    }
//
//    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        setup()
//    }
//}
