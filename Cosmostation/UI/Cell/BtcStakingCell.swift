//
//  BtcStakingCell.swift
//  Cosmostation
//
//  Created by 차소민 on 2/26/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class BtcStakingCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var stakingLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var inceptionLabel: UILabel!
    @IBOutlet weak var transactionIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "validatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
    }
    
    func onBindBtcMyDelegate(_ baseChain: BaseChain, _ delegation: BtcDelegation?) {
        guard let delegation else { return }
                
        logoImg.sd_setImage(with: URL(string: ResourceBase + baseChain.apiName + "/finality-provider/" + delegation.providerPk + ".png"), placeholderImage: UIImage(named: "validatorDefault"))
        
        jailedTag.isHidden = !(delegation.jailed)
        
        nameLabel.text = delegation.moniker
        let commission = NSDecimalNumber(string: delegation.commission).multiplying(byPowerOf10: 2)
        commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        
        let stakedAmount = NSDecimalNumber(integerLiteral: delegation.amount).multiplying(byPowerOf10: -8)
        stakingLabel.text = stakedAmount.stringValue
        
        symbolLabel.text = baseChain.isTestnet ? "sBTC" : "BTC"
        
        inceptionLabel.text = WDP.dpFullTime(delegation.inceptionTime)
        
        transactionIdLabel.text = delegation.transactionID
    }
}
