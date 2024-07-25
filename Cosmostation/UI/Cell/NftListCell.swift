//
//  NftListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

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
        nftImageView.image = UIImage(named: "imgNftPlaceHolder")
        titleLabel.text = ""
    }
    
    func onBindNft(_ info: JSON, _ nft: Cw721TokenModel) {
        if let url = nft.tokenDetails["url"].string {
            nftImageView?.kf.setImage(with: URL(string: url)!, placeholder: UIImage(named: "imgNftPlaceHolder"))
        }
        titleLabel.text = info["name"].stringValue + " #" + nft.tokenId
        titleLabel.adjustsFontSizeToFitWidth = true
    }

}
