//
//  EcoListCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class EcoListCell: UICollectionViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var typeTagLabel: PaddingLabel!
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
            thumbnailImageView?.kf.setImage(with: url)
        }
        titleLabel.text = info["name"].string
        descriptionLabel.text = info["description"].string
        typeTagLabel.text = info["type"].string
        if let support = info["support"].bool {
            supportImageView.isHidden = support
        }
    }

}
