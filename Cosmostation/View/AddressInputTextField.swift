//
//  AddressInputTextField.swift
//  Cosmostation
//
//  Created by yongjoo on 27/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class AddressInputTextField: UITextField {
    let border = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor(named: "_font02")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "_font04")!.cgColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.setLeftPaddingPoints(2)
        self.setRightPaddingPoints(2)
    }
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
