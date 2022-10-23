//
//  WalletUnbondingInfoCellTableViewCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/02.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class TokenDetailUnbondingDetailCell: UITableViewCell {
    
    @IBOutlet weak var unBondingCard: CardView!
    @IBOutlet weak var unBondingSchduleLabel: UILabel!
    @IBOutlet weak var unBondingCnt: UILabel!
    
    @IBOutlet weak var unBondingLayer0: UIView!
    @IBOutlet weak var unBondingTime0: UILabel!
    @IBOutlet weak var unBondingMoniker0: UILabel!
    @IBOutlet weak var unBondingAmount0: UILabel!
    
    @IBOutlet weak var unBondingLayer1: UIView!
    @IBOutlet weak var unBondingTime1: UILabel!
    @IBOutlet weak var unBondingMoniker1: UILabel!
    @IBOutlet weak var unBondingAmount1: UILabel!
    
    @IBOutlet weak var unBondingLayer2: UIView!
    @IBOutlet weak var unBondingTime2: UILabel!
    @IBOutlet weak var unBondingMoniker2: UILabel!
    @IBOutlet weak var unBondingAmount2: UILabel!
    
    @IBOutlet weak var unBondingLayer3: UIView!
    @IBOutlet weak var unBondingTime3: UILabel!
    @IBOutlet weak var unBondingMoniker3: UILabel!
    @IBOutlet weak var unBondingAmount3: UILabel!
    
    @IBOutlet weak var unBondingLayer4: UIView!
    @IBOutlet weak var unBondingTime4: UILabel!
    @IBOutlet weak var unBondingMoniker4: UILabel!
    @IBOutlet weak var unBondingAmount4: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        unBondingAmount0.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unBondingAmount1.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unBondingAmount2.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unBondingAmount3.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unBondingAmount4.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        unBondingSchduleLabel.text = NSLocalizedString("str_unbonding_schedule", comment: "")
    
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.unBondingLayer1.isHidden = true
        self.unBondingLayer2.isHidden = true
        self.unBondingLayer3.isHidden = true
        self.unBondingLayer4.isHidden = true
    }
    
    func onBindUnbondingToken(_ chainConfig: ChainConfig) {
        unBondingCard.backgroundColor = chainConfig.chainColorBG
        if (chainConfig.isGrpc) {
            onBindUnbonding_gRPC(chainConfig)
        }
    }
    
    func onBindUnbonding_gRPC(_ chainConfig: ChainConfig) {
        let stakingDivideDecimal = chainConfig.divideDecimal
        let stakingDisplayDecimal = chainConfig.displayDecimal
        let unbondingEntries = BaseData.instance.getUnbondingEntrie_gRPC()
        unBondingCnt.text = String(unbondingEntries.count)
        
        let unbondingTime0 = unbondingEntries[0].completionTime.seconds * 1000
        unBondingTime0.text = WDP.dpTime(unbondingTime0)
        unBondingMoniker0.text = WDP.dpTimeGap(unbondingTime0)
        unBondingAmount0.attributedText = WDP.dpAmount(unbondingEntries[0].balance, unBondingAmount0.font!, stakingDivideDecimal, stakingDisplayDecimal)
        
        if (unbondingEntries.count > 1) {
            unBondingLayer1.isHidden = false
            let unbondingTime1 = unbondingEntries[1].completionTime.seconds * 1000
            unBondingTime1.text = WDP.dpTime(unbondingTime1)
            unBondingMoniker1.text = WDP.dpTimeGap(unbondingTime1)
            unBondingAmount1.attributedText = WDP.dpAmount(unbondingEntries[1].balance, unBondingAmount1.font!, stakingDivideDecimal, stakingDisplayDecimal)
        }
        if (unbondingEntries.count > 2) {
            unBondingLayer2.isHidden = false
            let unbondingTime2 = unbondingEntries[2].completionTime.seconds * 1000
            unBondingTime2.text = WDP.dpTime(unbondingTime2)
            unBondingMoniker2.text = WDP.dpTimeGap(unbondingTime2)
            unBondingAmount2.attributedText = WDP.dpAmount(unbondingEntries[2].balance, unBondingAmount2.font!, stakingDivideDecimal, stakingDisplayDecimal)
        }
        if (unbondingEntries.count > 3) {
            unBondingLayer3.isHidden = false
            let unbondingTime3 = unbondingEntries[3].completionTime.seconds * 1000
            unBondingTime3.text = WDP.dpTime(unbondingTime3)
            unBondingMoniker3.text = WDP.dpTimeGap(unbondingTime3)
            unBondingAmount3.attributedText = WDP.dpAmount(unbondingEntries[3].balance, unBondingAmount3.font!, stakingDivideDecimal, stakingDisplayDecimal)
        }
        if (unbondingEntries.count > 4) {
            unBondingLayer4.isHidden = false
            let unbondingTime4 = unbondingEntries[4].completionTime.seconds * 1000
            unBondingTime4.text = WDP.dpTime(unbondingTime4)
            unBondingMoniker4.text = WDP.dpTimeGap(unbondingTime4)
            unBondingAmount4.attributedText = WDP.dpAmount(unbondingEntries[4].balance, unBondingAmount4.font!, stakingDivideDecimal, stakingDisplayDecimal)
        }
    }
}
