//
//  EarnViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class EarnViewController: BaseViewController {
    
    var mEarnDeposits: Array<Coin> = Array<Coin>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.onFetchData()
    }
    
    var mFetchCnt = 0
    func onFetchData() {
        self.mFetchCnt = 1
        self.onFetchgRPCMyEarnDeposits(account!.account_address)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            print("Earnings ", mEarnDeposits)
        }
    }
    
    func onFetchgRPCMyEarnDeposits(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Kava_Earn_V1beta1_QueryDepositsRequest.with { $0.depositor = address }
                if let response = try? Kava_Earn_V1beta1_QueryClient(channel: channel).deposits(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.deposits.forEach { deposit in
                        deposit.value.forEach { rawCoin in
                            self.mEarnDeposits.append(Coin.init(rawCoin.denom, rawCoin.amount))
                        }
                    }
                }
                try channel.close().wait()
                
            } catch { print("onFetchgRPCMyEarnDeposits failed: \(error)") }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }

}
