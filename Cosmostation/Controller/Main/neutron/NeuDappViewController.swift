//
//  NeuDappViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NeuDappViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var swapView: UIView!
    @IBOutlet weak var liquidityView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        swapView.alpha = 1
        liquidityView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            swapView.alpha = 1
            liquidityView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            swapView.alpha = 0
            liquidityView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_neutron_defi", comment: "");
        self.navigationItem.title = NSLocalizedString("title_neutron_defi", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

}

extension WUtils {
    
    static func swapAssetInfo(_ pair: NeutronSwapPoolPair) -> JSON {
        var result = JSON()
        if (pair.type == "cw20") {
            result = ["token" : ["contract_addr" : pair.address]]
        } else {
            result = ["native_token" : ["denom" : pair.denom]]
        }
        return result
    }
}
