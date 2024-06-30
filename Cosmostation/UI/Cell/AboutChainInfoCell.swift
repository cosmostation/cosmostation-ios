//
//  AboutChainInfoCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class AboutChainInfoCell: UITableViewCell {
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var initTimeTitle: UILabel!
    @IBOutlet weak var initTimeabel: UILabel!
    @IBOutlet weak var chainIdcosmosView: UIView!
    @IBOutlet weak var chainIdcosmosTitle: UILabel!
    @IBOutlet weak var chainIdcosmosLabel: UILabel!
    @IBOutlet weak var chainIdevmView: UIView!
    @IBOutlet weak var chainIdevmTitle: UILabel!
    @IBOutlet weak var chainIdevmLabel: UILabel!
    @IBOutlet weak var gasFeeView: UIView!
    @IBOutlet weak var gasFeeTitle: UILabel!
    @IBOutlet weak var gssFeeLabel: UILabel!
    @IBOutlet weak var networkTitle: UILabel!
    @IBOutlet weak var networkLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
        chainIdcosmosView.isHidden = true
        chainIdevmView.isHidden = true
        gasFeeView.isHidden = true
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        chainIdcosmosView.isHidden = true
        chainIdevmView.isHidden = true
        gasFeeView.isHidden = true
    }
    
    
    func onBindChainInfo(_ chain: BaseChain, _ json: JSON) {
        
        initTimeTitle.text = NSLocalizedString("str_initial_issue", comment: "")
        if let inittime = json["params"]["chainlist_params"]["origin_genesis_time"].string {
            initTimeabel.text = WDP.dpDate(inittime)
        }
        
        if (chain.supportEvm && chain.isCosmos()) {
            chainIdcosmosView.isHidden = false
            chainIdevmView.isHidden = false
            chainIdcosmosTitle.text = NSLocalizedString("str_chain_id_cosmos", comment: "")
            chainIdcosmosLabel.text = json["params"]["chainlist_params"]["chain_id_cosmos"].string
            chainIdevmTitle.text = NSLocalizedString("str_chain_id_evm", comment: "")
            chainIdevmLabel.text = json["params"]["chainlist_params"]["chain_id_evm"].string?.hexToNSDecimal().stringValue
            
        } else if (chain.supportEvm) {
            chainIdcosmosView.isHidden = true
            chainIdevmView.isHidden = false
            chainIdevmTitle.text = NSLocalizedString("str_chain_id", comment: "")
            chainIdevmLabel.text = json["params"]["chainlist_params"]["chain_id_evm"].string?.hexToNSDecimal().stringValue
            
            gasFeeView.isHidden = false
            gasFeeTitle.text = NSLocalizedString("str_gas_fee_coin", comment: "")
            gssFeeLabel.text = json["params"]["chainlist_params"]["symbol"].string
            
        } else if (chain.isCosmos()) {
            chainIdcosmosView.isHidden = false
            chainIdevmView.isHidden = true
            chainIdcosmosTitle.text = NSLocalizedString("str_chain_id", comment: "")
            chainIdcosmosLabel.text = json["params"]["chainlist_params"]["chain_id_cosmos"].string
        }
        
        networkTitle.text = NSLocalizedString("str_network", comment: "")
        if (chain.isTestnet == true) {
            networkLabel.text = NSLocalizedString("str_testnet", comment: "")
        } else {
            networkLabel.text = NSLocalizedString("str_mainnet", comment: "")
        }
        
    }
}
