//
//  SelectRecipientChainCell.swift
//  Cosmostation
//
//  Created by 차소민 on 3/31/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class SelectRecipientChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var selectedImg: UIView!
    @IBOutlet weak var chainLogoImg: UIImageView!
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var ibcSendTag: RoundedPaddingLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        setConfiguration()
    }
    
    func setConfiguration() {
        ibcSendTag.layer.borderColor = UIColor.colorSubGreen01.cgColor
        ibcSendTag.layer.borderWidth = 1
    }
    
    func onBindChain(_ chain: BaseChain, _ toChain: BaseChain, _ fromChain: BaseChain) {
        chainLogoImg.image = chain.getChainImage()
        chainNameLabel.text = chain.name

        ibcSendTag.isHidden = fromChain.tag == chain.tag
        
        if toChain.tag == chain.tag {
            rootView.backgroundColor = .color08
            selectedImg.isHidden = false
        } else {
            rootView.backgroundColor = .clear
            selectedImg.isHidden = true
        }
    }
}
