//
//  AuthzGranteeCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/26.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzGranteeCell: UITableViewCell {

    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var granteeAddressLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    
    var actionGranteeAddress: (() -> Void)? = nil
    
    @IBAction func onClickGranteeAddress(_ sender: UIButton) {
        actionGranteeAddress?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ address: String) {
        if (chainConfig == nil) { return }
        let stakingDenom = chainConfig!.stakeDenom
        let divideDecimal = WUtils.mainDivideDecimal(chainConfig?.chainType)
        
        rootCardView.backgroundColor = chainConfig!.chainColorBG
        granteeAddressLabel.text = address
        granteeAddressLabel.adjustsFontSizeToFitWidth = true
        availableAmountLabel.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmountLabel.font!, divideDecimal, 6)
    }
}
