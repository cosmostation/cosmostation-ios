//
//  KeyboardViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 26/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class PincodeInputVC: UIPageViewController {

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "PincodeDecimalVC"),
                self.newVc(viewController: "PincodeAlphabetVC")]
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    
    func newVc(viewController: String) ->UIViewController {
        return UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setViewControllerForce(_:)), name: Notification.Name("KeyBoardPage"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("KeyBoardPage"), object: nil)
    }
    
    
    @objc func setViewControllerForce(_ notification: NSNotification) {
        if let page = notification.userInfo?["Page"] as? Int {
            if(page == 0) {
                if let firstViewController = orderedViewControllers.first {
                    setViewControllers([firstViewController], direction: .reverse, animated: true, completion: { (finished) -> Void in
                        NotificationCenter.default.post(name: Notification.Name("unlockBtns"), object: nil, userInfo: nil)
                    })
                }
            } else {
                if let secondController = orderedViewControllers.last {
                    setViewControllers([secondController], direction: .forward, animated: true, completion: { (finished) -> Void in
                        NotificationCenter.default.post(name: Notification.Name("unlockBtns"), object: nil, userInfo: nil)
                    })
                }
            }
        }
    }
}
