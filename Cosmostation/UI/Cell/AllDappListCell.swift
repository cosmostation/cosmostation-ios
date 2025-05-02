//
//  AllDappListCell.swift
//  Cosmostation
//
//  Created by 차소민 on 2/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class AllDappListCell: UICollectionViewCell {

    @IBOutlet weak var dappImageView: UIImageView!
    @IBOutlet weak var tagLabel: RoundedPaddingLabel!
    @IBOutlet weak var dappNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var chainStackView: UIStackView!
    @IBOutlet weak var chainLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet var chainImageViews: [UIImageView]!
    
    var isFavorited: Bool = false
    var favoriteDelegate: FavoriteDelegate?
    var id: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dappImageView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        for i in 0 ..< chainImageViews.count {
            if i != 0 {
                chainImageViews[i].isHidden = true
            }
        }
    }
    
    @IBAction func setDappPinned(_ sender: Any) {
        isFavorited.toggle()
        let image = isFavorited ? UIImage(named: "iconStarFill") : UIImage(named: "iconStar")
        favoriteButton.setImage(image, for: .normal)
        
        favoriteDelegate?.setFavoriteData(id, isFavorited)
    }
    
    func onBindEcosystem(_ ecosystem: JSON, _ isPinned: Bool) {
        self.isFavorited = isPinned
        let image = isPinned ? UIImage(named: "iconStarFill") : UIImage(named: "iconStar")
        favoriteButton.setImage(image, for: .normal)

        self.id = ecosystem["id"].intValue
        dappImageView.sd_setImage(with: URL(string: ecosystem["thumbnail"].stringValue), placeholderImage: UIImage(named: "imgDefaultDapp"))
        tagLabel.text = ecosystem["type"].stringValue
        dappNameLabel.text = ecosystem["name"].stringValue
        descriptionLabel.setLineSpacing(text: ecosystem["description"].stringValue, font: .fontSize12Medium)
        
        setSupportChains(chains: ecosystem["chains"].arrayValue.map{ $0.stringValue })
    }
    
    private func setSupportChains(chains: [String]) {
        DispatchQueue.global().async {
            if chains.count == 1 {
                guard let chain = ALLCHAINS().filter({ $0.apiName == chains.first }).first else { return }
                DispatchQueue.main.async {
                    
                    self.chainImageViews.first?.image = chain.getChainImage()
                    self.chainLabel.isHidden = false
                    self.chainLabel.text = chain.apiName.uppercased()
                }
            } else {
                if chains.count <= 7 {
                    DispatchQueue.main.async {
                        self.chainLabel.isHidden = true
                    }
                    
                    for (i, chainName) in chains.enumerated() {
                        guard let chain = ALLCHAINS().filter({ $0.apiName == chainName }).first else { return }
                        DispatchQueue.main.async {
                            self.chainImageViews[i].isHidden = false
                            self.chainImageViews[i].image = chain.getChainImage()
                        }
                    }
                } else {
                    for i in 0...6 {
                        guard let chain = ALLCHAINS().filter({ $0.apiName == chains[i] }).first else { return }
                        DispatchQueue.main.async {
                            self.chainImageViews[i].isHidden = false
                            self.chainImageViews[i].image = chain.getChainImage()
                        }
                    }
                    
                    let cnt = chains.count - 7
                    DispatchQueue.main.async {
                        
                        self.chainLabel.isHidden = false
                        self.chainLabel.text = "+\(cnt)"
                    }
                }
            }
        }
    }
    
    
    func updateFavoriteButton(_ isFavorited: Bool) {
        self.isFavorited = isFavorited
        let image = self.isFavorited ? UIImage(named: "iconStarFill") : UIImage(named: "iconStar")
        favoriteButton.setImage(image, for: .normal)

    }
    
}


protocol FavoriteDelegate {
    func setFavoriteData(_ id: Int?, _ isPinned: Bool)
}
