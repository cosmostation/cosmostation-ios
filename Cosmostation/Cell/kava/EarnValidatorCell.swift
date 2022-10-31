//
//  EarnValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class EarnValidatorCell: UITableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var validatorImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalDenomLabel: UILabel!
    @IBOutlet weak var liquidityTitleLabel: UILabel!
    @IBOutlet weak var liquidityAmountLabel: UILabel!
    @IBOutlet weak var liquidityDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        validatorImg.layer.borderWidth = 1
        validatorImg.layer.masksToBounds = false
        validatorImg.layer.borderColor = UIColor(named: "_font04")!.cgColor
        validatorImg.layer.cornerRadius = validatorImg.frame.height/2
        validatorImg.clipsToBounds = true
        self.selectionStyle = .none
        
        totalAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        liquidityAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    func onBindView(_ chainConfig: ChainConfig, _ deposit: Coin) {
        cardView.backgroundColor = chainConfig.chainColorBG
        let valOpAddress = deposit.denom.replacingOccurrences(of: "bkava-", with: "")
        if let validator = BaseData.instance.mAllValidators_gRPC.filter({ $0.operatorAddress == valOpAddress }).first {
            monikerLabel.text = validator.description_p.moniker
            monikerLabel.adjustsFontSizeToFitWidth = true
            if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operatorAddress)) {
                validatorImg.af_setImage(withURL: url)
            }
        }
        
        if let totalBkava = BaseData.instance.mParam?.params?.supply?.filter({ $0.denom == deposit.denom }).first {
            totalAmountLabel.attributedText = WDP.dpAmount(totalBkava.amount, totalAmountLabel.font!, 6, 6)
        }
        liquidityAmountLabel.attributedText = WDP.dpAmount(deposit.amount, liquidityAmountLabel.font!, 6, 6)
    }
    
    func onBindDepositView(_ chainConfig: ChainConfig, _ validator : Cosmos_Staking_V1beta1_Validator, _ deposits: Array<Coin>) {
        monikerLabel.text = validator.description_p.moniker
        monikerLabel.adjustsFontSizeToFitWidth = true
        if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operatorAddress)) {
            validatorImg.af_setImage(withURL: url)
        }
        if let totalBkava = BaseData.instance.mParam?.params?.supply?.filter({ $0.denom == "bkava-" + validator.operatorAddress }).first {
            totalAmountLabel.attributedText = WDP.dpAmount(totalBkava.amount, totalAmountLabel.font!, 6, 6)
        }
        
        if let matched = deposits.filter({ $0.denom.contains(validator.operatorAddress) }).first {
            cardView.backgroundColor = chainConfig.chainColorBG
            liquidityAmountLabel.attributedText = WDP.dpAmount(matched.amount, liquidityAmountLabel.font!, 6, 6)
        } else {
            cardView.backgroundColor = UIColor.init(named: "_card_bg")
            liquidityAmountLabel.attributedText = WDP.dpAmount("0", liquidityAmountLabel.font!, 6, 6)
        }
    }
    
}
