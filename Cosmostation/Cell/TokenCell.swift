//
//  TokenCell.swift
//  Cosmostation
//
//  Created by yongjoo on 30/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class TokenCell: UITableViewCell {
    
    @IBOutlet weak var tokenImg: UIImageView!
    @IBOutlet weak var tokenSymbol: UILabel!
    @IBOutlet weak var tokenTitle: UILabel!
    @IBOutlet weak var tokenDescription: UILabel!
    @IBOutlet weak var tokenAmount: UILabel!
    @IBOutlet weak var tokenValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        tokenAmount.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: Font_13_footnote)
        tokenValue.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_13_footnote)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.tokenImg.af_cancelImageRequest()
        self.tokenSymbol.textColor = UIColor.white
        self.tokenSymbol.text = "-"
        self.tokenTitle.text = "-"
        self.tokenDescription.text = "-"
        self.tokenAmount.text = "-"
        self.tokenValue.text = "-"
    }
    
    func onBindBridgeToken(_ chain: ChainType, _ coin: Coin) {
        if let bridgeTokenInfo = BaseData.instance.getBridge_gRPC(coin.denom) {
            if let tokenImgeUrl = bridgeTokenInfo.getImgUrl() {
                tokenImg.af_setImage(withURL: tokenImgeUrl)
            } else {
                tokenImg.image = UIImage(named: "tokenIc")
            }
            tokenSymbol.text = bridgeTokenInfo.origin_symbol
            tokenSymbol.textColor = UIColor.white
            tokenTitle.text = ""
            tokenDescription.text = bridgeTokenInfo.display_symbol
            
            let available = BaseData.instance.getAvailableAmount_gRPC(coin.denom)
            let decimal = bridgeTokenInfo.decimal
            
            tokenAmount.attributedText = WUtils.displayAmount2(available.stringValue, tokenAmount.font!, decimal, 6)
            tokenValue.attributedText = WUtils.dpUserCurrencyValue(bridgeTokenInfo.origin_symbol!.lowercased(), available, decimal, tokenValue.font)
        }
    }
    
}
