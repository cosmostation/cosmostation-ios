//
//  DaoProposalCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class DaoProposalCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ module: NeutronProposalModule, _ proposal: JSON) {
        let id = proposal["id"].int64Value
        let contents = proposal["proposal"]
        
        titleLabel.text = "# ".appending(String(id)).appending("  ").appending(contents["title"].stringValue)
        descriptionLabel.text = contents["description"].stringValue
    }
    
}
