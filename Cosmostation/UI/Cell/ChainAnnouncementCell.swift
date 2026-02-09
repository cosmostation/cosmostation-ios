//
//  ChainAnnouncementCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2/9/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import UIKit

class ChainAnnouncementCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startAtLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bindAnnouncement(_ announcement: AdsInfo) {
        titleLabel.text = announcement.title
        startAtLabel.text = WDP.dpDate(announcement.startAt)
    }
}
