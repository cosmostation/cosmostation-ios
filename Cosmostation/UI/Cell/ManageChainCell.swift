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
        evmLayer.isHidden = true
        grpcLayer.isHidden = true
        lcdLayer.isHidden = true
    }
    
    override func prepareForReuse() {
        evmLayer.isHidden = true
        grpcLayer.isHidden = true
        lcdLayer.isHidden = true
    }
    
    
    func bindManageChain(_ chain: BaseChain) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        if (chain.name == "OKT") {
            lcdLayer.isHidden = false
            lcdEndpointLabel.text = chain.getLcdfetcher()!.getLcd().replacingOccurrences(of: "https://", with: "")
            lcdEndpointLabel.adjustsFontSizeToFitWidth = true
        }
        
        if (chain.supportCosmosGrpc) {
            grpcLayer.isHidden = false
            grpcEndpointLabel.text = chain.getGrpcfetcher()!.getGrpc().host + " : " +  String(chain.getGrpcfetcher()!.getGrpc().port)
            grpcEndpointLabel.adjustsFontSizeToFitWidth = true
        }
        
        if (chain.supportEvm) {
            evmLayer.isHidden = false
            evmEndpointLabel.text = chain.getEvmfetcher()!.getEvmRpc().replacingOccurrences(of: "https://", with: "")
            evmEndpointLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
}
