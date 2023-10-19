//
//  KavaMintListMyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

class KavaMintListMyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketTypeLabel: UILabel!
    @IBOutlet weak var marketPairLabel: UILabel!
    @IBOutlet weak var riskRateTitleLabel: UILabel!
    @IBOutlet weak var riskRateLabel: UILabel!
    @IBOutlet weak var borrowedTitle: UILabel!
    @IBOutlet weak var borrowedValueLabel: UILabel!
    @IBOutlet weak var collateralTitle: UILabel!
    @IBOutlet weak var collateralValueLabel: UILabel!
    @IBOutlet weak var currentPriceTitle: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var liquidatePriceTitle: UILabel!
    @IBOutlet weak var liquidatePriceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        marketImg.af.cancelImageRequest()
        marketImg.image = nil
    }
    
    
    func onBindCdp(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?,
                   _ priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?,
                   _ myCdp : Kava_Cdp_V1beta1_CDPResponse?) {
        if (collateralParam == nil || priceFeed == nil || myCdp == nil) { return }
        let url = KAVA_CDP_IMG_URL + collateralParam!.type + ".png"
        marketImg.af.setImage(withURL: URL(string: url)!)
        marketTypeLabel.text = collateralParam?.type.uppercased()
        marketPairLabel.text = collateralParam?.spotMarketID.uppercased()
        
    }
}
