//
//  SwitchAccountCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SwitchAccountCell: UITableViewCell {
    
    @IBOutlet weak var rootview: UIView!
    @IBOutlet weak var chainAccountCard: CardView!
    @IBOutlet weak var chainAccountKeyImg: UIImageView!
    @IBOutlet weak var chainAccountName: UILabel!
    @IBOutlet weak var chainAccountAddress: UILabel!
    @IBOutlet weak var chainAccountAmount: UILabel!
    @IBOutlet weak var chainAccountDenom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindChainAccounts(_ data: ChainAccounts?, _ accountPosition: Int, _ currentAccount: Account?) {
        rootview.backgroundColor = WUtils.getChainBg(data?.chainType)
        
        let dpAccount = data?.accounts[accountPosition]
        let dpChain = WUtils.getChainType(dpAccount!.account_base_chain)
        
        if (dpAccount?.account_has_private == true) {
            chainAccountKeyImg.image = chainAccountKeyImg.image!.withRenderingMode(.alwaysTemplate)
            chainAccountKeyImg.tintColor = WUtils.getChainColor(dpChain)
        } else {
            chainAccountKeyImg.tintColor = COLOR_DARK_GRAY
        }
        chainAccountName.text = WUtils.getWalletName(dpAccount)
        chainAccountAddress.text = dpAccount!.account_address
        
//        let dpChainConfig = ChainFactory().getChainConfig(dpChain!)
//        WUtils.showCoinDp(dpChainConfig.stakeDenom, dpAccount!.account_last_total, chainAccountDenom, chainAccountAmount, dpChain)
        
        chainAccountAmount.attributedText = WUtils.displayAmount2(dpAccount?.account_last_total, chainAccountAmount.font, 0, 6)
        WUtils.setDenomTitle(dpChain, chainAccountDenom)
        
        if (dpAccount?.account_id == currentAccount?.account_id) {
            chainAccountCard.borderWidth = 1.0
            chainAccountCard.borderColor = .white
        } else {
            chainAccountCard.borderWidth = 0.2
            chainAccountCard.borderColor = .gray
        }
        
        let tapItem = UITapGestureRecognizer(target: self, action: #selector(self.onTapItem))
        self.chainAccountCard.addGestureRecognizer(tapItem)
    }
    
    var actionTapItem: (() -> Void)? = nil
    @objc func onTapItem(sender : UITapGestureRecognizer) {
        actionTapItem?()
    }
    
}
