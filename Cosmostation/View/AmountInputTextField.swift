//
//  AmountInputTextField.swift
//  Cosmostation
//
//  Created by yongjoo on 08/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class AmountInputTextField: UITextField {
    let border = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor(named: "_font02")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "_font04")!.cgColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        
        self.setLeftPaddingPoints(8)
        self.setRightPaddingPoints(60)
    }
}
