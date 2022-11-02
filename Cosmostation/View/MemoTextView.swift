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
        self.layer.borderColor = UIColor.font04.cgColor
        self.backgroundColor = UIColor.font02
        self.tintColor = UIColor.font05
    }
}
