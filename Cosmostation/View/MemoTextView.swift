//
//  MemoTextView.swift
//  Cosmostation
//
//  Created by yongjoo on 08/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class MemoTextView: UITextView {

    let border = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        self.backgroundColor = UIColor.init(named: "_font02")
        self.tintColor = UIColor.init(named: "_font05")
    }
}
