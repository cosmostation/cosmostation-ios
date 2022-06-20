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
        guard let dpChainConfig = ChainFactory().getChainConfig(data?.chainType) else {
            return
        }
        rootview.backgroundColor = dpChainConfig.chainColorBG
        
        let dpAccount = data?.accounts[accountPosition]
        if (dpAccount?.account_has_private == true) {
            chainAccountKeyImg.image = chainAccountKeyImg.image!.withRenderingMode(.alwaysTemplate)
            chainAccountKeyImg.tintColor = dpChainConfig.chainColor
        } else {
            chainAccountKeyImg.tintColor = COLOR_DARK_GRAY
        }
        chainAccountName.text = dpAccount?.getDpName()
        chainAccountAddress.text = dpAccount!.account_address
        
        WUtils.showCoinDp(dpChainConfig.stakeDenom, dpAccount!.account_last_total, chainAccountDenom, chainAccountAmount, dpChainConfig.chainType)
        
        if (dpAccount?.account_id == currentAccount?.account_id) {
            chainAccountCard.borderWidth = 1.0
            chainAccountCard.borderColor = UIColor.init(named: "_font05")
        } else {
            chainAccountCard.borderWidth = 0.2
            chainAccountCard.borderColor = UIColor.init(named: "_font04")
        }
        
        let tapItem = UITapGestureRecognizer(target: self, action: #selector(self.onTapItem))
        self.chainAccountCard.addGestureRecognizer(tapItem)
    }
    
    var actionTapItem: (() -> Void)? = nil
    @objc func onTapItem(sender : UITapGestureRecognizer) {
        actionTapItem?()
    }
    
}
