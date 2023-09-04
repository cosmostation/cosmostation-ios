//
//  WalletVestingDetailCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/06/04.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TokenDetailVestingDetailCell: UITableViewCell {

    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var vestingSchduleLabel: UILabel!
    @IBOutlet weak var vestingCntLabel: UILabel!
    
    @IBOutlet weak var vestingLayer0: UIView!
    @IBOutlet weak var vestingTime0: UILabel!
    @IBOutlet weak var vestingGap0: UILabel!
    @IBOutlet weak var vestingAmount0: UILabel!
    
    @IBOutlet weak var vestingLayer1: UIView!
    @IBOutlet weak var vestingTime1: UILabel!
    @IBOutlet weak var vestingGap1: UILabel!
    @IBOutlet weak var vestingAmount1: UILabel!
    
    @IBOutlet weak var vestingLayer2: UIView!
    @IBOutlet weak var vestingTime2: UILabel!
    @IBOutlet weak var vestingGap2: UILabel!
    @IBOutlet weak var vestingAmount2: UILabel!
    
    @IBOutlet weak var vestingLayer3: UIView!
    @IBOutlet weak var vestingTime3: UILabel!
    @IBOutlet weak var vestingGap3: UILabel!
    @IBOutlet weak var vestingAmount3: UILabel!
    
    @IBOutlet weak var vestingLayer4: UIView!
    @IBOutlet weak var vestingTime4: UILabel!
    @IBOutlet weak var vestingGap4: UILabel!
    @IBOutlet weak var vestingAmount4: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
//        vestingTotalAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount0.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount1.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount2.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount3.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount4.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        vestingSchduleLabel.text = NSLocalizedString("str_vesting_schedule", comment: "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.vestingLayer4.isHidden = true
        self.vestingLayer3.isHidden = true
        self.vestingLayer2.isHidden = true
        self.vestingLayer1.isHidden = true
    }
    
    func onBindVestingToken(_ chainConfig: ChainConfig, _ denom: String) {
        if (chainConfig.chainType == ChainType.KAVA_MAIN) {
            if (denom == KAVA_MAIN_DENOM) {
                rootCardView.backgroundColor = chainConfig.chainColorBG
            } else if (denom == KAVA_HARD_DENOM) {
                rootCardView.backgroundColor = UIColor.cardBg
            } else if (denom == KAVA_SWAP_DENOM) {
                rootCardView.backgroundColor = UIColor.cardBg
            }
            onBindVesting_gRPC(chainConfig, denom)
            
        } else {
            rootCardView.backgroundColor = chainConfig.chainColorBG
            onBindVesting_gRPC(chainConfig, denom)
            
        }
    }
    
    func onBindVesting_gRPC(_ chainConfig: ChainConfig, _ denom: String) {
        let baseData = BaseData.instance
        if (chainConfig.chainType == .NEUTRON_MAIN || chainConfig.chainType == .NEUTRON_TEST) {
            vestingCntLabel.text = String(1)
            vestingTime0.text = WDP.dpTime(baseData.mNeutronDuration)
            vestingGap0.text = WDP.dpTimeGapByNeutron(baseData.mNeutronDuration)
            vestingAmount0.attributedText = WDP.dpAmount(baseData.mNeutronVesting.stringValue, vestingAmount0.font!, 6, 6)
            
        } else {
            let vps = baseData.onParseRemainVestingsByDenom_gRPC(denom)
            vestingCntLabel.text = String(vps.count)
            
            vestingTime0.text = WDP.dpTime(vps[0].length)
            vestingGap0.text = WDP.dpTimeGap(vps[0].length)
            vestingAmount0.attributedText = WDP.dpAmount(WUtils.getAmountVp(vps[0], denom).stringValue, vestingAmount0.font!, 6, 6)
            
            if (vps.count > 1) {
                vestingLayer1.isHidden = false
                vestingTime1.text = WDP.dpTime(vps[1].length)
                vestingGap1.text = WDP.dpTimeGap(vps[1].length)
                vestingAmount1.attributedText = WDP.dpAmount(WUtils.getAmountVp(vps[1], denom).stringValue, vestingAmount0.font!, 6, 6)
            }
            if (vps.count > 2) {
                vestingLayer2.isHidden = false
                vestingTime2.text = WDP.dpTime(vps[2].length)
                vestingGap2.text = WDP.dpTimeGap(vps[2].length)
                vestingAmount2.attributedText = WDP.dpAmount(WUtils.getAmountVp(vps[2], denom).stringValue, vestingAmount0.font!, 6, 6)
            }
            if (vps.count > 3) {
                vestingLayer3.isHidden = false
                vestingTime3.text = WDP.dpTime(vps[3].length)
                vestingGap3.text = WDP.dpTimeGap(vps[3].length)
                vestingAmount3.attributedText = WDP.dpAmount(WUtils.getAmountVp(vps[3], denom).stringValue, vestingAmount0.font!, 6, 6)
            }
            if (vps.count > 4) {
                vestingLayer4.isHidden = false
                vestingTime4.text = WDP.dpTime(vps[4].length)
                vestingGap4.text = WDP.dpTimeGap(vps[4].length)
                vestingAmount4.attributedText = WDP.dpAmount(WUtils.getAmountVp(vps[4], denom).stringValue, vestingAmount0.font!, 6, 6)
            }
        }
    }
}
