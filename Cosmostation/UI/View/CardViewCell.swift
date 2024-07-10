//
//  CardViewCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

@IBDesignable
class CardViewCell: UIView {
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let backgroundView = UIView()    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundView.layer.borderWidth = 0.5
        backgroundView.backgroundColor = .clear
        backgroundView.clipsToBounds = true
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 1, height: 1)
        backgroundView.layer.shadowOpacity = 0.4
        backgroundView.layer.shadowRadius = 3
        
        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = 12
        blurView.backgroundColor = .clear
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0.2
        backgroundView.addSubview(blurView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        backgroundView.frame = bounds
    }
}
