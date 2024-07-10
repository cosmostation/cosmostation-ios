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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func onBindService(_ position: Int) {
        if (position == 0) {
            serviceImg.image = UIImage(named: "imgServiceMintscan")
            titleLabel.text = "MINTSCAN"
            msgLabel.text = "Second generation blockchain\nanalytics platform specialized in\non-chain data visualization."
            
        } else if (position == 1) {
            serviceImg.image = UIImage(named: "imgServiceClaim")
            titleLabel.text = "ALL CHAIN REWARDS"
            msgLabel.text = "Easily claim all rewards\nexceeding $0.1 across Cosmos\nchains with a single click."
            
        } else if (position == 2) {
            serviceImg.image = UIImage(named: "imgServiceCompunding")
            titleLabel.text = "ALL CHAIN COMPOUNDING"
            msgLabel.text = "Enjoy the eighth wonder of \nthe world with a single click."
            
        } else if (position == 3) {
            serviceImg.image = UIImage(named: "imgServiceVote")
            titleLabel.text = "ALL CHAIN VOTE"
            msgLabel.text = "Check the list of live proposals\nof the chains you staked and\nvote for."
            
        } else if (position == 4) {
            serviceImg.image = UIImage(named: "imgServiceSwap")
            titleLabel.text = "COIN SWAP"
            msgLabel.text = "Exchange the coins you have\nfor a variety of different coins."
            
        } else if (position == 5) {
            serviceImg.image = UIImage(named: "imgServiceDapp")
            titleLabel.text = "DAPP"
            msgLabel.text = "Discover, Track & Trade\nEverything DeFi, NFT and\nGaming."
            
        } else if (position == 6) {
            serviceImg.image = UIImage(named: "imgServiceBuy")
            titleLabel.text = "BUY CRYPTO"
            msgLabel.text = "The coins purchased can be\nused for online transactions\nand investments."
        }
        
    }
    
}
