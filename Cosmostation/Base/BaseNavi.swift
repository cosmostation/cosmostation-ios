//
//  BaseNavi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseNavi: UINavigationController{

    var isPushingViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.backButtonDisplayMode = .minimal
    }
}

extension BaseNavi: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == .push) {
            return SlideInTransition()
        } else {
            return SlideOutTransition()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        isPushingViewController = false
    }
}

extension BaseNavi: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else { return true }
        return viewControllers.count > 1 && !isPushingViewController
    }
}

