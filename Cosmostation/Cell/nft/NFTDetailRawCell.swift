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
        guard let chainConfig = ChainFactory().getChainConfig(chainType) else {
            return
        }
        nftCardView.backgroundColor = chainConfig.chainColorBG
        if (chainType == .IRIS_MAIN) {
            if let dataString = irisRes?.nft.data.data(using: .utf8) {
                nftRawLabel.text = dataString.prettyJson?.replacingOccurrences(of: "\\", with: "")
            }
            
        } else if (chainType == .CRYPTO_MAIN) {
            if let dataString = croRes?.nft.data.data(using: .utf8) {
                nftRawLabel.text = dataString.prettyJson?.replacingOccurrences(of: "\\", with: "")
            }
        }
    }
}
