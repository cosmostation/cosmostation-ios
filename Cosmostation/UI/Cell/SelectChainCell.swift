//
//  SelectChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var logoImg2: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var deprecatedLabel: UILabel!
    @IBOutlet weak var evmLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var assetCntLabel: UILabel!
    @IBOutlet weak var selectSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        deprecatedLabel.isHidden = true
        evmLabel.isHidden = true
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func bindCosmosClassChain(_ account: BaseAccount, _ chain: CosmosClass, _ selectedList: [String]) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        logoImg2.image =  UIImage.init(named: chain.logo2)
        nameLabel.text = chain.name.uppercased()
        hdPathLabel.text = chain.getHDPath(account.lastHDPath)
        
        if (chain is ChainBinanceBeacon) {
            assetCntLabel.text = String(chain.lcdAccountInfo["balances"].arrayValue.count) + " Coins"
        } else if (chain is ChainOktKeccak256) {
            assetCntLabel.text = String(chain.lcdAccountInfo["value","coins"].arrayValue.count) + " Coins"
        } else {
            assetCntLabel.text = String(chain.cosmosBalances.count) + " Coins"
        }
        
        if (account.type == .withMnemonic) {
            hdPathLabel.text = chain.getHDPath(account.lastHDPath)
            
            if (chain.accountKeyType.pubkeyType == .ETH_Keccak256
                || chain.accountKeyType.pubkeyType == .INJECTIVE_Secp256k1) {
                if (chain.accountKeyType.hdPath == "m/44'/60'/0'/0/X") {
                    evmLabel.isHidden = false
                }
            } else if (!chain.isDefault) {
                deprecatedLabel.isHidden = false
            }
            
        } else {
            hdPathLabel.text = ""
            
            if (chain.accountKeyType.pubkeyType == .ETH_Keccak256
                || chain.accountKeyType.pubkeyType == .INJECTIVE_Secp256k1) {
                if (chain.accountKeyType.hdPath == "m/44'/60'/0'/0/X") {
                    evmLabel.isHidden = false
                }
            }
        }
        
        WDP.dpValue(chain.allValue(), currencyLabel, valueLabel)
        selectSwitch.isOn = selectedList.contains(chain.tag)
        selectSwitch.isHidden = chain is ChainCosmos
    }
}
