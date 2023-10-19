//
//  KavaMintListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

class KavaMintListCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var marketImg: UIImageView!
    @IBOutlet weak var marketTypeLabel: UILabel!
    @IBOutlet weak var marketPairLabel: UILabel!

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
    func onBindCdp(_ collateralParam: Kava_Cdp_V1beta1_CollateralParam?) {
        if (collateralParam == nil) { return }
        let url = KAVA_CDP_IMG_URL + collateralParam!.type + ".png"
        marketImg.af.setImage(withURL: URL(string: url)!)
        marketTypeLabel.text = collateralParam?.type.uppercased()
        marketPairLabel.text = collateralParam?.spotMarketID.uppercased()
        
    }
}
