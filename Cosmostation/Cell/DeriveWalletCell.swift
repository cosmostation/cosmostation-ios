//
//  DeriveWalletCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/05/06.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class DeriveWalletCell: UITableViewCell {

    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var chainImgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var dimCardView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindWallet(_ words: MWords, _ chainType: ChainType,  _ type: Int, _ path: Int) {
        let chainConfig = ChainFactory().getChainConfig(chainType)
        rootCardView.backgroundColor = WUtils.getChainBg(chainConfig.chainType)
        
        var dpAddress = ""
        DispatchQueue.global().async {
            dpAddress = WKey.getDpAddress(chainConfig, words, type, path)
            DispatchQueue.main.async(execute: {
                self.addressLabel.text = dpAddress
            });
        }
    }
    
}
