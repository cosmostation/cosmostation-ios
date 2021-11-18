//
//  TokenDetailIBCInfoCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/20.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TokenDetailIBCInfoCell: TokenDetailCell {

    @IBOutlet weak var relayerImg: UIImageView!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var acrossChain: UILabel!
    @IBOutlet weak var acrossDenom: UILabel!
    
    var ibcDivideDecimal: Int16 = 6
    var ibcDisplayDecimal: Int16 = 6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: Font_15_subTitle)
        denomLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindIBCTokenInfo(_ chainType: ChainType, _ ibcDenom: String) {
        let ibcHash = ibcDenom.replacingOccurrences(of: "ibc/", with: "")
        if let ibcToken = BaseData.instance.getIbcToken(ibcHash) {
            ibcDivideDecimal = ibcToken.decimal ?? 6
            ibcDisplayDecimal = ibcToken.decimal ?? 6
            
            if let url = BaseData.instance.getIbcRlayerImg(chainType, ibcToken.channel_id) {
                relayerImg.af_setImage(withURL: url)
            }
            denomLabel.text = ibcDenom
            acrossChain.text = ibcToken.counter_party?.chain_id
            acrossDenom.text = ibcToken.base_denom
            
        } else {
            denomLabel.text = "unknown"
        }
        
        let total = BaseData.instance.getAvailableAmount_gRPC(ibcDenom)
        availableLabel.attributedText = WUtils.displayAmount2(total.stringValue, availableLabel.font, ibcDivideDecimal, ibcDisplayDecimal)
    }
}
