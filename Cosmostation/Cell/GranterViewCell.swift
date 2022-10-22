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
        guard let chainConfig = chainConfig else { return }
        granterAddressLabel.text = address
        
        var tempCoin = Coin.init(chainConfig.stakeDenom, "0")
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(chainConfig.chainType, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Bank_V1beta1_QueryBalanceRequest.with { $0.address = address; $0.denom = chainConfig.stakeDenom }
                if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).balance(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    tempCoin = Coin.init(response.balance.denom, response.balance.amount)
                }
                try channel.close().wait()
            } catch { }
            DispatchQueue.main.async(execute: {
                WDP.dpCoin(chainConfig, tempCoin, self.granterAvailableDenomLabel, self.granterAvailableAmountLabel)
            });
        }
    }
}
