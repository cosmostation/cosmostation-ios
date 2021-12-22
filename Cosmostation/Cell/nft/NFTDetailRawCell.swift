//
//  NFTDetailRawCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/21.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class NFTDetailRawCell: UITableViewCell {

    @IBOutlet weak var nftCardView: CardView!
    @IBOutlet weak var nftRawLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindNFT(_ chainType: ChainType?, _ irisRes: Irismod_Nft_QueryNFTResponse?, _ croRes: Chainmain_Nft_V1_QueryNFTResponse?) {
        nftCardView.backgroundColor = WUtils.getChainBg(chainType)
        if (chainType == ChainType.IRIS_MAIN) {
            nftRawLabel.text = irisRes?.nft.data.data(using: .utf8)!.prettyJson!.replacingOccurrences(of: "\\", with: "")
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            nftRawLabel.text = croRes?.nft.data.data(using: .utf8)!.prettyJson!.replacingOccurrences(of: "\\", with: "")
        }
    }
}
