//
//  NeuMultiVoteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/05/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NeuMultiVoteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    
    var actionSelect: (() -> Void)? = nil
    
    @IBAction func onClick(_ sender: UIButton) {
        actionSelect?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ proposal: JSON?, _ position: Int, _ myOpinion: Int?) {
        if let chainConfig = chainConfig, let proposal = proposal {
            let choice = proposal["proposal"]["choices"].arrayValue[position]
            titleLabel.text = choice["option_type"].stringValue
            descriptionLabel.text = choice["description"].stringValue
            
            if (myOpinion == position) {
                btnSelect.tintColor = chainConfig.chainColor
                btnSelect.layer.borderColor = chainConfig.chainColor.cgColor
            } else {
                btnSelect.tintColor = UIColor.font03
                btnSelect.layer.borderColor = UIColor.font03.cgColor
            }
        }
    }
}
