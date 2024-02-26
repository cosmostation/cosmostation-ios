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
        BaseData.instance.baseAccount?.fetchDisplayEvmChains()
        BaseData.instance.baseAccount?.fetchDisplayCosmosChains()
        
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
    
    var chainImg: UIImageView?
    func showChainBgImage(_ uiImge: UIImage) {
        if (chainImg?.isHidden == false) { return }
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let x = CGFloat.random(in: -150..<(width-150))
        let y = CGFloat.random(in: 300..<(height-150))
        chainImg = UIImageView(frame: CGRectMake(x, y, 300, 300))
        chainImg?.image = uiImge
        chainImg?.contentMode = .scaleToFill
        chainImg?.alpha = 0
        
        view.addSubview(chainImg!)
        view.insertSubview(chainImg!, at: 1)
        
        UIView.animate(withDuration: 3, animations: {
            self.chainImg?.alpha = 0.05
            self.chainImg?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
    
    func hideChainBgImg() {
        chainImg?.isHidden = true
    }
}


extension UIView {
    func addBackground() {
        let num = Int.random(in: 0..<BASE_BG_IMG.count)
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let bgImg = UIImageView(frame: CGRectMake(0, 0, width, height))
        bgImg.image = UIImage(named: BASE_BG_IMG[num])
        bgImg.contentMode = .scaleToFill

        self.addSubview(bgImg)
        self.sendSubviewToBack(bgImg)
    }
}
