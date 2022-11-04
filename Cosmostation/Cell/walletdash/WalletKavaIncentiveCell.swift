//
//  WalletKavaIncentiveCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/27.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class WalletKavaIncentiveCell: UITableViewCell {

    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var kavaAmountLabel: UILabel!
    @IBOutlet weak var hardAmountLabel: UILabel!
    @IBOutlet weak var swpAmountLabel: UILabel!
    @IBOutlet weak var btnClaimIncentive: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        kavaAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        hardAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        swpAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        incentiveLabel.text = NSLocalizedString("str_incentive", comment: "")
        btnClaimIncentive.setTitle(NSLocalizedString("btn_claim_incentive", comment: ""), for: .normal)
    }
    
    var actionGetIncentive: (() -> Void)? = nil
    @IBAction func onClickIncentive(_ sender: Any) {
        actionGetIncentive?()
    }
    
    func updateView() {
        let kavaAmount = BaseData.instance.mIncentiveRewards?.getIncentiveAmount(KAVA_MAIN_DENOM) ?? NSDecimalNumber.zero
        let hardAmount = BaseData.instance.mIncentiveRewards?.getIncentiveAmount(KAVA_HARD_DENOM) ?? NSDecimalNumber.zero
        let swpAmount = BaseData.instance.mIncentiveRewards?.getIncentiveAmount(KAVA_SWAP_DENOM) ?? NSDecimalNumber.zero
        
        kavaAmountLabel.attributedText = WDP.dpAmount(kavaAmount.stringValue, kavaAmountLabel.font, 6, 6)
        hardAmountLabel.attributedText = WDP.dpAmount(hardAmount.stringValue, hardAmountLabel.font, 6, 6)
        swpAmountLabel.attributedText = WDP.dpAmount(swpAmount.stringValue, swpAmountLabel.font, 6, 6)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnClaimIncentive.borderColor = UIColor.font05
    }
}
