//
//  ChainSelectVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class ChainSelectVC: BaseVC {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        baseAccount.initData(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)),
                                               name: Notification.Name("FetchData"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"),
                                                  object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        print("onFetchDone ", Date().timeIntervalSince1970, " ", notification.object as! String)
        
        if (baseAccount.allCosmosClassChains.filter { $0.fetched == false }.count == 0) {
            // All fetche done
            
            baseAccount.allCosmosClassChains.forEach { chain in
                let address = RefAddress(baseAccount.id, chain.id, chain.address!,chain.allStakingDenomAmount().stringValue, chain.allValue(true).stringValue)
                BaseData.instance.updateRefAddresses(address)
            }
            baseAccount.sortCosmosChain()
        }

    }

}
