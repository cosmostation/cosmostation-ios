//
//  GranterViewCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/26.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class GranterViewCell: UITableViewCell {

    @IBOutlet weak var granterAddressLabel: UILabel!
    @IBOutlet weak var granterAvailableAmountLabel: UILabel!
    @IBOutlet weak var granterAvailableDenomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ address: String) {
        if (chainConfig == nil) { return }
        granterAddressLabel.text = address
        
        var tempCoin = Coin.init(chainConfig!.stakeDenom, "0")
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(chainConfig!.chainType, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
                let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address; $0.pagination = page }
                if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.balances.forEach { balance in
                        if (balance.denom == chainConfig!.stakeDenom) {
                            tempCoin = Coin.init(balance.denom, balance.amount)
                        }
                    }
                }
                try channel.close().wait()
                
            } catch { }
            DispatchQueue.main.async(execute: {
                WDP.dpCoin(chainConfig, tempCoin, self.granterAvailableDenomLabel, self.granterAvailableAmountLabel)
            });
        }
    }
}
