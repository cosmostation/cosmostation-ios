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
    @IBOutlet weak var evmLayer: UIView!
    @IBOutlet weak var evmEndpointLabel: UILabel!
    @IBOutlet weak var grpcLayer: UIView!
    @IBOutlet weak var grpcEndpointLabel: UILabel!
    @IBOutlet weak var lcdLayer: UIView!
    @IBOutlet weak var lcdEndpointLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
        evmLayer.isHidden = true
        grpcLayer.isHidden = true
        lcdLayer.isHidden = true
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        evmLayer.isHidden = true
        grpcLayer.isHidden = true
        lcdLayer.isHidden = true
    }
    
    func bindManageEvmClassChain(_ chain: EvmClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        if (chain is ChainOktEVM) {
            lcdLayer.isHidden = false
            lcdEndpointLabel.text = OKT_LCD
            
        } else if (chain.supportCosmos == true) {
            grpcLayer.isHidden = false
            grpcEndpointLabel.text = chain.getGrpc().host + " : " +  String(chain.getGrpc().port)
        }
        evmLayer.isHidden = false
        evmEndpointLabel.text = chain.getEvmRpc()
    }
    
    func bindManageCosmosClassChain(_ chain: CosmosClass) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        if (chain is ChainBinanceBeacon) {
            lcdLayer.isHidden = false
            lcdEndpointLabel.text = BNB_BEACON_LCD
            
        } else {
            grpcLayer.isHidden = false
            grpcEndpointLabel.text = chain.getGrpc().host + " : " +  String(chain.getGrpc().port)
            
        }
    }
    
}
