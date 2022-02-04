//
//  CdpListAllCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/26.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class CdpListAllCell: UITableViewCell {

    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketType: UILabel!
    @IBOutlet weak var marketTitle: UILabel!
    @IBOutlet weak var minCollateralRate: UILabel!
    @IBOutlet weak var stabilityFee: UILabel!
    @IBOutlet weak var liquidationPenalty: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        minCollateralRate.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        stabilityFee.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        liquidationPenalty.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    
    func onBindOtherCdp(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam) {
        marketType.text = collateralParam.type.uppercased()
        marketTitle.text = collateralParam.getDpMarketId()
        minCollateralRate.attributedText = WUtils.displayPercent(collateralParam.getDpLiquidationRatio(), minCollateralRate.font)
        stabilityFee.attributedText = WUtils.displayPercent(collateralParam.getDpStabilityFee(), stabilityFee.font)
        liquidationPenalty.attributedText = WUtils.displayPercent(collateralParam.getDpLiquidationPenalty(), liquidationPenalty.font)
        let url = KAVA_CDP_IMG_URL + collateralParam.getMarketImgPath()! + ".png"
        marketImg.af_setImage(withURL: URL(string: url)!)
    }
}
