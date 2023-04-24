//
//  WalletNobleCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/04/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class WalletNobleCell: UITableViewCell {

    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    
    @IBOutlet weak var btnDelegate: UIButton!
    @IBOutlet weak var btnNmm: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func updateView(_ account: Account?, _ chainConfig: ChainConfig?) {
        guard let account = account, let chainConfig = chainConfig else { return }
        let stakingDenom = chainConfig.stakeDenom
        
        let availTotalToken = BaseData.instance.getAvailableAmount_gRPC(stakingDenom)
        
        totalAmount.attributedText = WDP.dpAmount(availTotalToken.stringValue, totalAmount.font!, 6, 6)
        
        BaseData.instance.updateLastTotal(account, availTotalToken.multiplying(byPowerOf10: -6).stringValue)
        
        if let msAsset = BaseData.instance.getMSAsset(chainConfig, stakingDenom) {
            WDP.dpAssetValue(msAsset.coinGeckoId, availTotalToken, 6, totalValue)
        }
    }
    
    var actionDelegate: (() -> Void)? = nil
    var actionNmm: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    
    @IBAction func onClickNmm(_ sender: Any) {
        actionNmm?()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDelegate.borderColor = UIColor.font05
        btnNmm.borderColor = UIColor.font05
    }
}
