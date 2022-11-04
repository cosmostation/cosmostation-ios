//
//  OtherValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo on 04/06/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class OtherValidatorCell: UITableViewCell {
    
    @IBOutlet weak var votingPowerTitleLabel: UILabel!
    @IBOutlet weak var estAprTitleLabel: UILabel!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var validatorImg: UIImageView!
    @IBOutlet weak var revokedImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var bandOracleOffImg: UIImageView!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        validatorImg.layer.borderWidth = 1
        validatorImg.layer.masksToBounds = false
        validatorImg.layer.borderColor = UIColor.font04.cgColor
        validatorImg.layer.cornerRadius = validatorImg.frame.height/2
        validatorImg.clipsToBounds = true
        
        self.selectionStyle = .none
        
        powerLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        commissionLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        votingPowerTitleLabel.text = NSLocalizedString("str_voting_power", comment: "")
        estAprTitleLabel.text = NSLocalizedString("str_est_apr", comment: "")
    }
    
    override func prepareForReuse() {
        self.validatorImg.image = UIImage(named: "validatorDefault")
        self.monikerLabel.text = "-"
        self.powerLabel.text = "-"
        self.commissionLabel.text = "-"
        self.bandOracleOffImg.isHidden = true
        super.prepareForReuse()
    }
    
    func updateView(_ validator: Cosmos_Staking_V1beta1_Validator, _ chainConfig: ChainConfig?) {
        if (chainConfig == nil) { return }
        let chainType = chainConfig!.chainType
        powerLabel.attributedText = WDP.dpAmount(validator.tokens, powerLabel.font!, chainConfig!.divideDecimal, 6)
        commissionLabel.attributedText = WUtils.getDpEstAprCommission(commissionLabel.font, NSDecimalNumber.one, chainType)
        if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operatorAddress)) {
            validatorImg.af_setImage(withURL: url)
        }
        
        monikerLabel.text = validator.description_p.moniker
        monikerLabel.adjustsFontSizeToFitWidth = true
        if (validator.jailed == true) {
            revokedImg.isHidden = false
            validatorImg.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            revokedImg.isHidden = true
            validatorImg.layer.borderColor = UIColor.font04.cgColor
        }
        if BaseData.instance.mMyValidators_gRPC.first(where: {$0.operatorAddress == validator.operatorAddress}) != nil {
            cardView.backgroundColor = chainConfig?.chainColorBG
        } else {
            cardView.backgroundColor = UIColor.cardBg
        }
        
        //temp hide apr for no mint param chain
        if (chainType == ChainType.ALTHEA_TEST) {
            commissionLabel.text = "--"
        }
    }
    
}
