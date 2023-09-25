//
//  BaseButton.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseButton: UIButton {
    
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
        
        if (self.isEnabled) {
            self.backgroundColor = .colorPrimary
            self.tintColor = .white
            self.setTitleColor(.white, for: .normal)
        } else {
            self.backgroundColor = .color05
            self.setTitleColor(.color03, for: .normal)
        }
        
    }
    
    override var isEnabled: Bool {
        didSet {
            setup()
        }
    }

}
