//
//  WalletAddressCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletAddressCell: UITableViewCell {
    @IBOutlet weak var cardRoot: CardView!
    @IBOutlet weak var dpKeyStateImg: UIImageView!
    @IBOutlet weak var dpAddressLabel: UILabel!
    @IBOutlet weak var ethAddressLabel: UILabel!
    @IBOutlet weak var totalValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapAddress))
        self.contentView.isUserInteractionEnabled = true
        self.cardRoot.addGestureRecognizer(tap)
    }
    
    var actionTapAddress: (() -> Void)? = nil
    
    @objc func onTapAddress(sender:UITapGestureRecognizer) {
        actionTapAddress?()
    }
    
    func updateView(_ account: Account?, _ chainConfig: ChainConfig?) {
        if (chainConfig == nil || account == nil) { return }
        cardRoot.backgroundColor = chainConfig?.chainColorBG
        dpAddressLabel.text = account?.account_address
        dpAddressLabel.adjustsFontSizeToFitWidth = true
        
        if (chainConfig?.etherAddressSupport == true) {
            ethAddressLabel.isHidden = false
            ethAddressLabel.text = "(" + WKey.convertAddressCosmosToTender(account!.account_address) + ")"
        } else {
            ethAddressLabel.isHidden = true
        }
        
        if (account!.account_has_private == true) {
            dpKeyStateImg.image = UIImage.init(named: "iconKeyFull")
            dpKeyStateImg.image = dpKeyStateImg.image!.withRenderingMode(.alwaysTemplate)
            dpKeyStateImg.tintColor = chainConfig?.chainColor
        } else {
            dpKeyStateImg.image = UIImage.init(named: "iconKeyEmpty")
        }
        totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainConfig, totalValue.font)
    }
}
