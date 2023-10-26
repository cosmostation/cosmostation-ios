//
//  AboutDescriptionCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class AboutDescriptionCell: UITableViewCell {
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var chainDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindDescription(_ chain: CosmosClass, _ json: JSON) {
        chainNameLabel.text = chain.name
        if (BaseData.instance.getLanguage() == 2 && !json["ko"].stringValue.isEmpty) {
            chainDescriptionLabel.text = json["ko"].stringValue
        } else  if (BaseData.instance.getLanguage() == 3 && !json["ja"].stringValue.isEmpty) {
            chainDescriptionLabel.text = json["ja"].stringValue
        } else {
            chainDescriptionLabel.text = json["en"].stringValue
        }
    }
}
