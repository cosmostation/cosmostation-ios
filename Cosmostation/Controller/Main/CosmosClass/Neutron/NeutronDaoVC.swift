//
//  NeutronDaoVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import MaterialComponents
import Alamofire
import SwiftyJSON

class NeutronDaoVC: BaseVC {
    
    @IBOutlet weak var tabbar: MDCTabBarView!
    @IBOutlet weak var singleDaoList: UIView!
    @IBOutlet weak var multipleDaoList: UIView!
    @IBOutlet weak var overruleList: UIView!
    
    var selectedChain: ChainNeutron!
    var neutronMyVotes = [JSON]()
    var isShowAll = false
    
    var showAll: UIBarButtonItem?
    var filtered: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        setTabbarView()
        fetchMyVotes(selectedChain.bechAddress!)
        
        showAll = UIBarButtonItem(image: UIImage(named: "iconFilterOn"), style: .plain, target: self, action: #selector(onClickFilterOn))
        filtered = UIBarButtonItem(image: UIImage(named: "iconFilterOff"), style: .plain, target: self, action: #selector(onClickFilterOff))
        navigationItem.setRightBarButton(showAll, animated: true)
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_daos_proposal_list", comment: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "singleDaoVC") {
            let target = segue.destination as! NeutronSingleDao
            target.selectedChain = selectedChain
        } else if (segue.identifier == "multipleDaoVC") {
            let target = segue.destination as! NeutronMultiDao
            target.selectedChain = selectedChain
        } else if (segue.identifier == "overruleDao") {
            let target = segue.destination as! NeutronOverruleDao
            target.selectedChain = selectedChain
        }
    }
    
    @objc func onClickFilterOn() {
        navigationItem.setRightBarButton(filtered, animated: true)
        isShowAll = !isShowAll
        NotificationCenter.default.post(name: Notification.Name("ToggleFilter"), object: nil, userInfo: nil)
    }
    
    @objc func onClickFilterOff() {
        navigationItem.setRightBarButton(showAll, animated: true)
        isShowAll = !isShowAll
        NotificationCenter.default.post(name: Notification.Name("ToggleFilter"), object: nil, userInfo: nil)
    }
    
    func setTabbarView() {
        let singleDaoTabBar = UITabBarItem(title: "Single", image: nil, tag: 0)
        let multipleDaoTabBar = UITabBarItem(title: "Multiple", image: nil, tag: 1)
        let overruleDaoBar = UITabBarItem(title: "Overrule", image: nil, tag: 2)
        tabbar.items.append(singleDaoTabBar)
        tabbar.items.append(multipleDaoTabBar)
        tabbar.items.append(overruleDaoBar)
        
        tabbar.barTintColor = .clear
        tabbar.selectionIndicatorStrokeColor = .white
        tabbar.setTitleFont(.fontSize14Bold, for: .normal)
        tabbar.setTitleFont(.fontSize14Bold, for: .selected)
        tabbar.setTitleColor(.color03, for: .normal)
        tabbar.setTitleColor(.color01, for: .selected)
        tabbar.setSelectedItem(singleDaoTabBar, animated: false)
        tabbar.tabBarDelegate = self
        tabbar.preferredLayoutStyle = .fixed
        tabbar.setContentPadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), for: .scrollable)
        
        singleDaoList.alpha = 1
        multipleDaoList.alpha = 0
        overruleList.alpha = 0
    }

    
    public func fetchMyVotes(_ voter: String)  {
        let url = MINTSCAN_API_URL + "v10/" + selectedChain.apiName + "/dao/address/" + voter + "/votes"
        AF.request(url, method: .get).responseDecodable(of: [JSON].self) { response in
            switch response.result {
            case .success(let values):
                self.neutronMyVotes = values
            case .failure:
                print("fetchMyVotes error")
            }
        }
    }
}

extension NeutronDaoVC: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        if (item.tag == 0) {
            singleDaoList.alpha = 1
            multipleDaoList.alpha = 0
            overruleList.alpha = 0
            
        } else if (item.tag == 1) {
            singleDaoList.alpha = 0
            multipleDaoList.alpha = 1
            overruleList.alpha = 0
            
        } else if (item.tag == 2) {
            singleDaoList.alpha = 0
            multipleDaoList.alpha = 0
            overruleList.alpha = 1
        }
    }
}

extension String {

    func containsEmoji() -> Bool {
        for character in self {
            var shouldCheckNextScalar = false
            for scalar in character.unicodeScalars {
               if shouldCheckNextScalar {
                    if scalar == "\u{FE0F}" {
                        return true
                    }
                    shouldCheckNextScalar = false
                }
                
                if scalar.properties.isEmoji {
                    if scalar.properties.isEmojiPresentation {
                        return true
                    }
                    shouldCheckNextScalar = true
                }
            }
        }
        return false
    }
}
