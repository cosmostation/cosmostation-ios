//
//  WalletDetailAddressCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/12.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletDetailAddressCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardView!
    @IBOutlet weak var chainImg: UIImageView!
    @IBOutlet weak var walletName: UILabel!
    
    var actionNickname: (() -> Void)? = nil
    @IBAction func onClickNickname(_ sender: UIButton) {
        actionNickname?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig, _ account: Account) {
        rootView.backgroundColor = chainConfig.chainColorBG
        chainImg.image = chainConfig.chainImg
        walletName.text = account.getDpName()
    }
}
