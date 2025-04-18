//
//  EcoListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class EcoListCell: UICollectionViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var typeTagLabel: RoundedPaddingLabel!
    @IBOutlet weak var supportImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        supportImageView.isHidden = true
        thumbnailImageView.image = nil
        typeTagLabel.text = ""
        titleLabel.text = ""
        descriptionLabel.text = ""
    }
    
    func onBindEcoSystem(_ info: JSON?) {
        guard let info = info else { return }
        
        if let url = URL(string: info["thumbnail"].stringValue) {
            thumbnailImageView?.sd_setImage(with: url)
        }
        titleLabel.text = info["name"].string
        descriptionLabel.setLineSpacing(text: info["description"].stringValue, font: .fontSize11Medium)
        typeTagLabel.text = info["type"].string
        if let support = info["support"].bool {
            supportImageView.isHidden = support
        }
    }
    
    func onBindTestDapp(_ index: Int) {
        let endpoint = "https://raw.githubusercontent.com/cosmostation/chainlist/master/wallet_mobile/mobile_ecosystem/cosmos/resource/"
        if index == 0 {
            let url = URL(string: endpoint + "injection.png")
            thumbnailImageView.sd_setImage(with: url)
            titleLabel.text = "Injection Example"
            descriptionLabel.setLineSpacing(text: "This page offers examples and guidance for integrating and using the Cosmostation app in applications.", font: .fontSize11Medium)
            typeTagLabel.text = "Develop Tool"

        } else {
            let url = URL(string: endpoint + "github.png")
            thumbnailImageView.sd_setImage(with: url)
            titleLabel.text = "Injection Github"
            descriptionLabel.setLineSpacing(text: "This Github provides sample code and guides for integrating Cosmostation Wallet with DApps.", font: .fontSize11Medium)
            typeTagLabel.text = "Github"
        }
    }

}
