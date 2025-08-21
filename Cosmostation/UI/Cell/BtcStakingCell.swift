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
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "iconValidatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
    }
    
    func onBindBtcMyDelegate(_ baseChain: ChainBitCoin86, _ delegation: BtcDelegation?, _ provider: FinalityProvider?, _ timeLockWeeks: Int) {
        guard let delegation else { return }
        let apiName = baseChain.isTestnet ? "babylon-testnet" : "babylon"
        logoImg.sd_setImage(with: URL(string: ResourceBase + apiName + "/finality-provider/" + delegation.providerPk + ".png"), placeholderImage: UIImage(named: "iconValidatorDefault"))
        
        if delegation.jailed {
            jailedTag.isHidden = false
        } else if provider?.votingPower == "0" {
            inactiveTag.isHidden = false
        }
        
        nameLabel.text = delegation.moniker
        var commission: NSDecimalNumber = .zero
        if NSDecimalNumber(string: delegation.commission).compare(1) == .orderedDescending {
            commission = NSDecimalNumber(string: delegation.commission).multiplying(byPowerOf10: -16)
        } else {
            commission = NSDecimalNumber(string: delegation.commission).multiplying(byPowerOf10: 2)
        }
        commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        
        let stakedAmount = NSDecimalNumber(integerLiteral: delegation.amount).multiplying(byPowerOf10: -8)
        stakingLabel.attributedText = WDP.dpAmount(stakedAmount.stringValue, stakingLabel.font, 8)
        
        symbolLabel.text = baseChain.mainAssetSymbol()
                
        
        let timeLock = Calendar.current.date(byAdding: .weekOfYear, value: timeLockWeeks, to: WUtils.timeStringToDate(delegation.inceptionTime) ?? Date())
        timeLabel.text = WDP.dpDateWithSimpleTime(timeLock)
    }
}
