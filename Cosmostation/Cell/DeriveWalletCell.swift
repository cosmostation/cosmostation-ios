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
    
    func onBindWallet(_ derive: Derive) {
        let chainConfig = ChainFactory().getChainConfig(derive.chaintype)
        chainImgView.image = chainConfig.chainImg
        pathLabel.text = chainConfig.getHdPath(derive.hdpathtype, derive.path)
        addressLabel.text = derive.dpAddress
        
        if let coin = derive.coin {
            WUtils.showCoinDp(coin, denomLabel, amountLabel, derive.chaintype)
        } else {
            amountLabel.text = ""
            denomLabel.text = ""
        }
        
        if (derive.status == -1) {
            statusLabel.text = ""
            dimCardView.isHidden = true
            rootCardView.borderWidth = 0.5
            rootCardView.borderColor = UIColor(hexString: "#4b4f54")
            
        } else if (derive.status == 0) {
            statusLabel.text = ""
            dimCardView.isHidden = true
            rootCardView.borderWidth = 0.5
            rootCardView.borderColor = UIColor(hexString: "#4b4f54")
            
        } else if (derive.status == 1) {
            statusLabel.text = ""
            dimCardView.isHidden = true
            rootCardView.borderWidth = 0.5
            rootCardView.borderColor = UIColor(hexString: "#4b4f54")
            
        } else if (derive.status == 2) {
            statusLabel.text = "Imported"
            dimCardView.isHidden = false
            rootCardView.borderWidth = 0.0
        }
        
        if (derive.selected == true) {
            rootCardView.borderWidth = 1.2
            rootCardView.borderColor = .white
        }
    }
    
}
