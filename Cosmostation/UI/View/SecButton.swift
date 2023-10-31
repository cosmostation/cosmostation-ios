//
//  SecButton.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/06.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SecButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
//        self.titleLabel?.font = .fontSize16Bold
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.titleLabel?.textAlignment = .center
        
        if (self.isEnabled) {
            self.backgroundColor = .white.withAlphaComponent(0)
            self.layer.borderColor = UIColor.color01.cgColor
            self.setTitleColor(.color01, for: .normal)
        } else {
            self.backgroundColor = .white.withAlphaComponent(0)
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.color05.cgColor
            self.setTitleColor(.color05, for: .normal)
        }
        
    }
    
    override var isEnabled: Bool {
        didSet {
            setup()
        }
    }

}
