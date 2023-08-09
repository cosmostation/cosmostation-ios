//
//  SlideOutTransition.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

final class SlideOutTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard let fromVC = ctx.viewController(forKey: .from),
              let toVC = ctx.viewController(forKey: .to) else { return }
        let containerView = ctx.containerView
        
        toVC.view.frame = containerView.bounds.offsetBy(dx: -containerView.frame.size.width, dy: 0.0)
        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: ctx),
                       delay: 0,
                       options: [ .curveEaseInOut ],
                       animations: {
            toVC.view.frame = containerView.bounds
            fromVC.view.frame = containerView.bounds.offsetBy(dx: containerView.frame.size.width, dy: 0)
        },
                       completion: { (finished) in
            ctx.completeTransition(true)
        })
    }
    
    func animationEnded(_ transitionCompleted: Bool) { }
    
}

