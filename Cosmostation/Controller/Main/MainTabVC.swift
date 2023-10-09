//
//  MainTabVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
        
        BaseData.instance.baseAccount?.initAccount()
        
        self.tabBar.tintColor = .white
        self.tabBar.layer.masksToBounds = true
        self.tabBar.layer.cornerRadius = 8
        self.tabBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.delegate = self
        self.selectedIndex = BaseData.instance.getLastTab()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        BaseData.instance.setLastTab(tabBarController.selectedIndex)
    }

}


extension UIView {
    func addBackground() {
        let num = Int.random(in: 0..<BASE_BG_IMG.count)
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: BASE_BG_IMG[num])
        imageViewBackground.contentMode = .scaleToFill

        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
