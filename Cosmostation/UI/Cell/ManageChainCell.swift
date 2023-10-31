//
//  ManageChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/18.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class ManageChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var endpointLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func bindCosmosClassChain(_ chain: CosmosClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        if (chain is ChainBinanceBeacon) {
            typeLabel.text = "LCD"
            endpointLabel.text = BNB_BEACON_LCD
        } else if (chain is ChainOkt60Keccak) {
            typeLabel.text = "LCD"
            endpointLabel.text = OKT_LCD
        } else {
            typeLabel.text = "GRPC"
            endpointLabel.text = chain.getGrpc().host + " : " +  String(chain.getGrpc().port)
        }
    }
    
}
