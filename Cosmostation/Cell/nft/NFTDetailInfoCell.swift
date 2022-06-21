//
//  NFTDetailInfoCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/21.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class NFTDetailInfoCell: UITableViewCell {

    @IBOutlet weak var nftCardView: CardView!
    @IBOutlet weak var nftNameLabel: UILabel!
    @IBOutlet weak var nftDescrpLabel: UILabel!
    @IBOutlet weak var nftDenomLabel: UILabel!
    @IBOutlet weak var nftTokenLabel: UILabel!
    @IBOutlet weak var nftIssuerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindNFT(_ chainType: ChainType?, _ irisRes: Irismod_Nft_QueryNFTResponse?, _ croRes: Chainmain_Nft_V1_QueryNFTResponse?, _ denomId: String?, _ tokenId: String?) {
        guard let chainConfig = ChainFactory().getChainConfig(chainType) else {
            return
        }
        nftCardView.backgroundColor = chainConfig.chainColorBG
        if (chainType == .IRIS_MAIN) {
            self.nftNameLabel.text = irisRes?.nft.name
            self.nftDescrpLabel.text = WUtils.getNftDescription(irisRes?.nft.data)
            self.nftIssuerLabel.text = WUtils.getNftIssuer(irisRes?.nft.data)
            
        } else if (chainType == .CRYPTO_MAIN) {
            self.nftNameLabel.text = croRes?.nft.name
            self.nftDescrpLabel.text = WUtils.getNftDescription(croRes?.nft.data)
            self.nftIssuerLabel.text = WUtils.getNftIssuer(croRes?.nft.data)
            
        }
        nftDenomLabel.text = denomId
        nftTokenLabel.text = tokenId
    }
    
}
