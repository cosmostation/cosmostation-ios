//
//  CardView.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let backgroundView = UIView()
    let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear)
    let animatorFraction = 0.82
    
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
        backgroundView.addSubview(blurView)
        
//        animator.stopAnimation(true)
//        animator.addAnimations {
//            self.blurView.effect = nil
//        }
//        animator.fractionComplete = animatorFraction
        setBlur()
        
    }
    
    deinit {
        animator.pauseAnimation()
        animator.stopAnimation(true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        backgroundView.frame = bounds
    }
    
    
    func setBlur() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            self.animator.stopAnimation(true)
            self.animator.addAnimations {
                self.blurView.effect = nil
            }
            self.animator.fractionComplete = self.animatorFraction
        })
    }
}
