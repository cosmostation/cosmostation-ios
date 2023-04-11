//
//  WalletNeutronCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/04/11.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class WalletNeutronCell: UITableViewCell {
    
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var totalbondedAmount: UILabel!
    
    @IBOutlet weak var btnVault: UIButton!
    @IBOutlet weak var btnDao: UIButton!
    @IBOutlet weak var btnDefi: UIButton!
    @IBOutlet weak var btnWc: UIButton!
    
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var totalbondedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        totalbondedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        totalbondedLabel.text = NSLocalizedString("str_bonded", comment: "")
    }
    
    func updateView(_ account: Account?, _ chainConfig: ChainConfig?) {
        guard let account = account, let chainConfig = chainConfig else { return }
        let stakingDenom = chainConfig.stakeDenom
        
        let bondedAmount = NSDecimalNumber.zero
        let totalToken = BaseData.instance.getAvailableAmount_gRPC(stakingDenom).adding(bondedAmount)
        
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, 6, 6)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmount.font!, 6, 6)
        totalbondedAmount.attributedText = WDP.dpAmount(bondedAmount.stringValue, totalbondedAmount.font!, 6, 6)
        
        BaseData.instance.updateLastTotal(account, totalToken.multiplying(byPowerOf10: -6).stringValue)
        
        if let msAsset = BaseData.instance.getMSAsset(chainConfig, stakingDenom) {
            WDP.dpAssetValue(msAsset.coinGeckoId, totalToken, 6, totalValue)
        }
    }
    
    var actionVault: (() -> Void)? = nil
    var actionDao: (() -> Void)? = nil
    var actionDefi: (() -> Void)? = nil
    var actionWc: (() -> Void)? = nil
    
    @IBAction func onClickVault(_ sender: Any) {
        actionVault?()
    }
    
    @IBAction func onClickDao(_ sender: Any) {
        actionDao?()
    }
    
    @IBAction func onClickDefi(_ sender: Any) {
        actionDefi?()
    }
    
    @IBAction func onClickWc(_ sender: Any) {
        actionWc?()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnVault.borderColor = UIColor.font05
        btnDao.borderColor = UIColor.font05
        btnDefi.borderColor = UIColor.font05
        btnWc.borderColor = UIColor.font05
    }
}
