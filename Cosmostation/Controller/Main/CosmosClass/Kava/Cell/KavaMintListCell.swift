//
//  KavaMintListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SDWebImage

class KavaMintListCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketTypeLabel: UILabel!
    @IBOutlet weak var marketPairLabel: UILabel!
    @IBOutlet weak var minCollateralRate: UILabel!
    @IBOutlet weak var stabilityFee: UILabel!
    @IBOutlet weak var liquidationPenalty: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        marketImg.sd_cancelCurrentImageLoad()
        marketImg.image = nil
    }
    func onBindCdp(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?) {
        if (collateralParam == nil) { return }
        let url = KAVA_CDP_IMG_URL + collateralParam!.type + ".png"
        marketImg.sd_setImage(with: URL(string: url)!)
        marketTypeLabel.text = collateralParam?.type.uppercased()
        marketPairLabel.text = collateralParam?.spotMarketID.uppercased()
        minCollateralRate.attributedText = WDP.dpAmount(collateralParam!.getDpLiquidationRatio().stringValue, minCollateralRate.font, 2)
        stabilityFee.attributedText = WDP.dpAmount(collateralParam!.getDpStabilityFee().stringValue, stabilityFee.font, 2)
        liquidationPenalty.attributedText = WDP.dpAmount(collateralParam!.getDpLiquidationPenalty().stringValue, liquidationPenalty.font, 2)
    }
}
