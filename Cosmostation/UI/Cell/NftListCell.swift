//
//  NftListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class NftListCell: UICollectionViewCell {

    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var nftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        nftImageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        nftImageView.sd_cancelCurrentImageLoad()
        nftImageView.image = UIImage(named: "imgNftPlaceHolder")
        titleLabel.text = ""
    }
    
    func onBindNft(_ info: JSON, _ nft: Cw721TokenModel) {
        if let url = nft.tokenDetails["url"].string {
            nftImageView?.sd_setImage(with: URL(string: url)!, placeholderImage: UIImage(named: "imgNftPlaceHolder"))
        }
        titleLabel.text = info["name"].stringValue + " #" + nft.tokenId
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func onBindSuiNft(_ suiNFT: Sui_Rpc_V2_Object) {
        if let url = suiNFT.suiNftURL() {
            nftImageView.sd_setImage(with: url)
        } else {
            nftImageView.image = UIImage(named: "imgNftPlaceHolder")
        }
        let name = suiNFT.suiNftName()
        titleLabel.text = !name.isEmpty ? name : suiNFT.objectID
        titleLabel.adjustsFontSizeToFitWidth = !name.isEmpty
    }

    func onBindNft(_ nft: JSON) {
        if let url = nft.iotaNftULR() {
            nftImageView.sd_setImage(with: url)
        } else {
            nftImageView.image = UIImage(named: "imgNftPlaceHolder")
        }
        
        let name = nft["display"]["data"]["name"].stringValue
        let objectId = nft["objectId"].stringValue

        titleLabel.text = !name.isEmpty ? name : objectId
        titleLabel.adjustsFontSizeToFitWidth = !name.isEmpty ? true : false
    }
}
