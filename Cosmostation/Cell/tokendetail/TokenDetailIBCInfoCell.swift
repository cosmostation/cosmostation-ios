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
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindIBCTokenInfo(_ chainType: ChainType, _ ibcDenom: String) {
        let ibcHash = ibcDenom.replacingOccurrences(of: "ibc/", with: "")
        if let ibcToken = BaseData.instance.getIbcToken(ibcHash) {
            if let url = BaseData.instance.getIbcRlayerImg(chainType, ibcToken.channel_id) {
                relayerImg.af_setImage(withURL: url)
            }
            channelLabel.text = ibcToken.channel_id
            denomLabel.text = ibcDenom
            
        } else {
            channelLabel.text = "unknown"
            denomLabel.text = "unknown"
        }
    }
}
