//
//  WebNaviButton.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/28/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class WebNaviButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        alpha = isEnabled ? 1.0 : 0.3
    }
    
    open override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.3
            layoutIfNeeded()
        }
    }
}
