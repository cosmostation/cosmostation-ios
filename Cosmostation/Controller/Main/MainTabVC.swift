//
//  MainTabVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SafariServices

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
        
        BaseData.instance.baseAccount?.initAccount()
        BaseData.instance.baseAccount?.fetchDpChains()
        
        self.tabBar.tintColor = .white
        self.tabBar.layer.masksToBounds = true
        self.tabBar.layer.cornerRadius = 8
        self.tabBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.delegate = self
        self.selectedIndex = BaseData.instance.getLastTab()
        
        self.onHandleEvent()
    }
    
    //Disable default tabbar change animation with iOS 18
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let targetIndex = tabBarController.viewControllers?.firstIndex(where: { $0 == viewController }) {
            UIView.performWithoutAnimation {
                tabBarController.selectedIndex = targetIndex
            }
            BaseData.instance.setLastTab(tabBarController.selectedIndex)
        }
        return false
    }
    
    var chainImg: UIImageView?
    func showChainBgImage(_ imgUrl: URL?) {
        if (chainImg?.isHidden == false) { return }
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let x = CGFloat.random(in: -150..<(width-150))
        let y = CGFloat.random(in: 300..<(height-150))
        chainImg = UIImageView(frame: CGRectMake(x, y, 300, 300))
        chainImg?.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: "chainDefault"))
        chainImg?.contentMode = .scaleToFill
        chainImg?.alpha = 0
        
        view.insertSubview(chainImg!, at: 0)
        
        UIView.animate(withDuration: 3, animations: {
            self.chainImg?.alpha = 0.1
            self.chainImg?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
    
    func hideChainBgImg() {
        chainImg?.isHidden = true
    }
    
    func onHandleEvent()  {
        if let appSchemeUrl = BaseData.instance.appSchemeUrl {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
                dappDetail.dappType = .DEEPLINK_WC2
                dappDetail.dappUrl = appSchemeUrl
                dappDetail.modalPresentationStyle = .fullScreen
                self.present(dappDetail, animated: true)
                BaseData.instance.appSchemeUrl = nil
            })
            
        } else if let userInfo = BaseData.instance.appUserInfo {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                if (userInfo["push_type"] as? String == "0") {
                    if let txhash = userInfo["txhash"] as? String,
                       let network = userInfo["network"] as? String,
                       let url = URL(string: MintscanTxUrl.replacingOccurrences(of: "${apiName}", with: network).replacingOccurrences(of: "${hash}", with: txhash)) {
                        let safariViewController = SFSafariViewController(url: url)
                        safariViewController.modalPresentationStyle = .popover
                        self.present(safariViewController, animated: true)
                    }
                }
                BaseData.instance.appUserInfo = nil
            })
        }
    }
}

extension UIView {
    func addBackground() {
        if BaseData.instance.getTheme() == 0 {
            let img = UIImage(named: "basebgDark")
            layer.contents = img?.cgImage
            contentMode = .scaleAspectFill

        } else {
            guard let background = BASE_BG_IMG.randomElement() else { return }
            let img = UIImage(named: background)
            layer.contents = img?.cgImage
            contentMode = .scaleAspectFill

        }
    }
}
