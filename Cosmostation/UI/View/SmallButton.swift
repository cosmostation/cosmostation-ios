//
//  SmallButton.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//


import UIKit

class SmallButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.titleLabel?.font = .fontSize12Bold
        self.layer.cornerRadius = 8
        self.setTitleColor(.white, for: .selected)
        self.setTitleColor(.color03, for: .normal)
        
        if (self.isSelected) {
            self.backgroundColor = .colorPrimary
        } else {
            self.backgroundColor = .color05
        }
    }
    
    override var isSelected: Bool {
        didSet {
            setup()
        }
    }

}

