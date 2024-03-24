//
//  NftListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage

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
        nftImageView.image = nil
        titleLabel.text = ""
    }
    
    func onBindNft(_ nft: Cw721TokenModel) {
        let ipfsUrl = nft.tokenDetails["image"].stringValue.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
        if let imageURL: URL = URL(string: ipfsUrl) {
            nftImageView?.af.setImage(withURL: imageURL)
        }
        titleLabel.text = nft.tokenDetails["name"].stringValue
    }

}
