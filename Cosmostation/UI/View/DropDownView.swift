//
//  DropDownView.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class DropDownView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        layer.borderColor = UIColor.color05.cgColor
        layer.borderWidth = 0.5
    }
}
