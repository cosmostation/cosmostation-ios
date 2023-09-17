//
//  BaseRedButton.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseRedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.titleLabel?.font = .fontSize16Bold
        self.layer.cornerRadius = 8
        self.backgroundColor = .colorRed
        self.tintColor = .white
        self.setTitleColor(.white, for: .normal)
    }

}
