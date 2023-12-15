//
//  ServiceCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class ServiceCell: UITableViewCell {

    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var serviceImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    
    @IBOutlet weak var tagskip: UIImageView!
    @IBOutlet weak var tag1inch: UIImageView!
    @IBOutlet weak var tagsquid: UIImageView!
    @IBOutlet weak var tagosmo: UIImageView!
    @IBOutlet weak var tagAstroport: UIImageView!
    @IBOutlet weak var tagkava: UIImageView!
    @IBOutlet weak var tagneutron: UIImageView!
    @IBOutlet weak var tagmoonpay: UIImageView!
    @IBOutlet weak var tagkado: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        tagskip.isHidden = true
        tag1inch.isHidden = true
        tagsquid.isHidden = true
        tagosmo.isHidden = true
        tagAstroport.isHidden = true
        tagkava.isHidden = true
        tagneutron.isHidden = true
        tagmoonpay.isHidden = true
        tagkado.isHidden = true
        rootView.setBlur()
    }
    
    func onBindService(_ position: Int) {
        if (position == 0) {
            serviceImg.image = UIImage(named: "imgServiceMintscan")
            
            titleLabel.text = "MINTSCAN"
            msgLabel.text = "Second generation blockchain analytics \nplatform specialized in on-chain \ndata visualization."
            
        } else if (position == 1) {
            serviceImg.image = UIImage(named: "imgServiceClaim")
            
            titleLabel.text = "CLAIM REWARDS"
            msgLabel.text = "Easily claim all rewards exceeding $0.1 \nacross Cosmos Chains with a single \nclick."
            
        } else if (position == 2) {
            serviceImg.image = UIImage(named: "imgServiceSwap")
            tagskip.isHidden = false
            tagosmo.isHidden = false
            tagAstroport.isHidden = false
            
            titleLabel.text = "COIN SWAP"
            msgLabel.text = "Exchange the coins you have for a \nvariety of different coins"
            
        } else if (position == 3) {
            serviceImg.image = UIImage(named: "imgServiceDapp")
            tagkava.isHidden = false
            tagneutron.isHidden = false
            
            titleLabel.text = "DAPP"
            msgLabel.text = "Discover, Track & Trade Everything \nDeFi, NFT and Gaming"
            
        } else if (position == 4) {
            serviceImg.image = UIImage(named: "imgServiceBuy")
            tagmoonpay.isHidden = false
            tagkado.isHidden = false
            
            titleLabel.text = "BUY CRYPTO"
            msgLabel.text = "The coins purchased can be used for\n online transactions and investments"
        }
        
    }
    
}
