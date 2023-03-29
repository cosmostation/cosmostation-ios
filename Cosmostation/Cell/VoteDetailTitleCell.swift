//
//  VoteDetailTitleCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/29.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class VoteDetailTitleCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var expeditedImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView() {
        
    }
}
