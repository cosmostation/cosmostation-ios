//
//  EvmHistoryVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/01/25.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class EvmHistoryVC: BaseVC {
    
    var selectedChain: EvmClass!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        guard let url = selectedChain.getExplorerAccount() else { return }
        self.onShowSafariWeb(url)
    }
    
}
