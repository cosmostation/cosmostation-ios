//
//  NoticeTableViewCell.swift
//  Cosmostation
//
//  Created by 차소민 on 9/25/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import CDMarkdownKit

class NoticeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var contentLabel: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentLabel.isEditable = false
        contentLabel.isSelectable = true
        contentLabel.dataDetectorTypes = .link

        contentLabel.sizeToFit()
    }
    
    func setNoticeContent(_ markdown: String) {
        let markdownParser = CDMarkdownParser(fontColor: .color01)
        
        markdownParser.header.font = .fontSize10Bold
        
        markdownParser.link.underlineColor = .color01
        markdownParser.link.font = .fontSize12Bold

        markdownParser.list.font = .fontSize12Bold
        markdownParser.list.indicator = "•"
        
        contentLabel.attributedText = markdownParser.parse(markdown)

    }
    
}
