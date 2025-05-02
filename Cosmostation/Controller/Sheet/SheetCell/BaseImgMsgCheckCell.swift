//
//  BaseImgMsgCheckCell.swift
//  Cosmostation
//
//  Created by 차소민 on 4/2/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class BaseImgMsgCheckCell: UITableViewCell {
    
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var networkImageView: UIImageView!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var dappCountLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        contentView.backgroundColor = .clear
        checkImageView.isHidden = true
        selectedColorView.isHidden = true
    }
    
    func onBindDappNetwork(_ position: Int, _ chain: BaseChain?, _ dappCount: Int,  _ selectedNetwork: BaseChain?) {
        
        if let chain {
            networkLabel.text = chain.getChainName()
            networkImageView.image = chain.getChainImage()
            dappCountLabel.text = String(dappCount)

            if let selectedNetwork {
                if chain.apiName == selectedNetwork.apiName {
                    selectedColorView.isHidden = false
                    checkImageView.isHidden = false
                    contentView.backgroundColor = .color08
                } else {
                    selectedColorView.isHidden = true
                    checkImageView.isHidden = true
                    contentView.backgroundColor = .clear
                }
            }
            
        } else {
            networkLabel.text = "All Network"
            networkImageView.image = UIImage(named: "iconNetwork")
            dappCountLabel.text = String(dappCount)
            
            if chain == nil && selectedNetwork == nil {
                selectedColorView.isHidden = false
                checkImageView.isHidden = false
                contentView.backgroundColor = .color08
            } else {
                selectedColorView.isHidden = true
                checkImageView.isHidden = true
                contentView.backgroundColor = .clear
            }
        }
        
    }

}
