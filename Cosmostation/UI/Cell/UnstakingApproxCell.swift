//
//  UnstakingApproxCell.swift
//  Cosmostation
//
//  Created by 차소민 on 3/5/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie

class UnstakingApproxCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unstakingLabel: UILabel!
    @IBOutlet weak var unstakingAnimationView: LottieAnimationView!
    @IBOutlet weak var withdrawableImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        unstakingAnimationView.animation = LottieAnimation.named("loadingSmallYellow")
        unstakingAnimationView.contentMode = .scaleAspectFit
        unstakingAnimationView.loopMode = .loop
        unstakingAnimationView.animationSpeed = 1.3
        unstakingAnimationView.play()
    }
    
    override func prepareForReuse() {
        logoImg.sd_cancelCurrentImageLoad()
        logoImg.image = UIImage(named: "validatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
        unstakingAnimationView.isHidden = true
        withdrawableImage.isHidden = true
        arrowImage.isHidden = true
    }
    
    func onBindBtcUndelegate(_ baseChain: ChainBitCoin86, _ delegation: BtcDelegation?, _ provider: FinalityProvider?) {
        guard let delegation else { return }
        let apiName = baseChain.isTestnet ? "babylon-testnet" : "babylon"
        logoImg.sd_setImage(with: URL(string: ResourceBase + apiName + "/finality-provider/" + delegation.providerPk + ".png"), placeholderImage: UIImage(named: "validatorDefault"))
        
        if delegation.jailed {
            jailedTag.isHidden = false
        } else if provider?.votingPower == "0" {
            inactiveTag.isHidden = false
        }
        
        nameLabel.text = delegation.moniker
        
        let unstakedAmount = NSDecimalNumber(integerLiteral: delegation.amount).multiplying(byPowerOf10: -8)
        unstakingLabel.attributedText = WDP.dpAmount(unstakedAmount.stringValue, unstakingLabel.font, 8)
                
        
        if delegation.state.lowercased().contains("withdrawable") {
            withdrawableImage.isHidden = false
            statusLabel.text = "Withdrawable"
            statusDescriptionLabel.text = "Ready to Withdraw"
            arrowImage.isHidden = false
        } else {
//            unstakingAnimationView.isHidden = false
            statusLabel.text = "Unstaking"
            statusDescriptionLabel.text = "Takes around 7 days"
        }
    }
}
