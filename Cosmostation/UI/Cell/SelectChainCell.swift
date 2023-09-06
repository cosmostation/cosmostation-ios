//
//  SelectChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var logoImg2: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var legacyLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var assetCntLabel: UILabel!
    @IBOutlet weak var selectSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass, _ selectedList: [String]) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        pathLabel.text = chain.getHDPath(account.lastHDPath)
//
        if (chain is ChainBinanceBeacon) {
            assetCntLabel.text = String(chain.lcdAccountInfo["balances"].arrayValue.count) + " Coins"
        }  else {
            assetCntLabel.text = String(chain.cosmosBalances.count) + " Coins"
        }
        legacyLabel.isHidden = chain.isDefault
        
        WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
        selectSwitch.isOn = selectedList.contains(chain.id)
    }
}
