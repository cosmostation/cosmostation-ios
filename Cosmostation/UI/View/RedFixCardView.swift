//
//  RedFixCardView.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class RedFixCardView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = UIColor.colorRed.withAlphaComponent(0.05)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        layer.borderColor = UIColor.colorRed.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 0.5
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 3
    }
}

