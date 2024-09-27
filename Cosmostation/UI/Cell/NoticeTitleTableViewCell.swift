//
//  NoticeTitleTableViewCell.swift
//  Cosmostation
//
//  Created by 차소민 on 9/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NoticeTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeTag: RoundedPaddingLabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        typeTag.text = ""
        dateLabel.text = ""
    }
    
    func setNoticeTitle(_ notice: JSON) {
        titleLabel.text = notice["title"].stringValue
        typeTag.text = notice["type"].stringValue
        dateLabel.text = "Update : \(WDP.dpDate(notice["created_at"].stringValue))" //???: updated_at
    }
}
