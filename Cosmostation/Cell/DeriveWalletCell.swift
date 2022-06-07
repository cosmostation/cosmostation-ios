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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        addressLabel.text = "loading..."
        amountLabel.text = ""
        denomLabel.text = "loading..."
    }
    
    func onBindWallet(_ words: MWords, _ chainType: ChainType,  _ type: Int, _ path: Int) {
//        addressLabel.text = "loading..."
//        amountLabel.text = ""
//        denomLabel.text = "loading..."
//        
//        let chainConfig = ChainFactory().getChainConfig(chainType)
//        rootCardView.backgroundColor = WUtils.getChainBg(chainConfig.chainType)
//        chainImgView.image = chainConfig.chainImg
//        pathLabel.text = chainConfig.getHdPath(type, path)
//        
//        var dpAddress = ""
//        DispatchQueue.global().async {
//            dpAddress = WKey.getDpAddress(chainConfig, words, type, path)
//            DispatchQueue.main.async(execute: {
//                self.addressLabel.text = dpAddress
//            });
//        }
    }
    
}
