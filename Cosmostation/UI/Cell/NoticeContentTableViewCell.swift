//
//  NoticeContentTableViewCell.swift
//  Cosmostation
//
//  Created by 차소민 on 9/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import CDMarkdownKit
import SwiftyJSON

class NoticeContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeTag: RoundedPaddingLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    
    let markdownParser = CDMarkdownParser(fontColor: .color01)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        contentLabel.isEditable = false
        contentLabel.isSelectable = true
        contentLabel.dataDetectorTypes = .link
        contentLabel.sizeToFit()
        
        setMarkdownParser()
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        typeTag.text = ""
        dateLabel.text = ""
        contentLabel.text = ""
    }
    
    private func setMarkdownParser() {

        markdownParser.header.font = .fontSize10Bold
        markdownParser.header.fontIncrease = 1
        
        markdownParser.link.underlineColor = .color01
        markdownParser.link.font = .fontSize12Bold

        markdownParser.list.font = UIFont(name: "SpoqaHanSansNeo-Medium", size: 11)!
        markdownParser.list.color = .color02
        markdownParser.list.indicator = "•"
    }
    
    func setNoticeContent(_ notice: JSON) {
        titleLabel.text = notice["title"].stringValue
        typeTag.text = notice["type"].stringValue
        dateLabel.text = "Update : \(WDP.dpDate(notice["created_at"].stringValue))" //???: updated_at
        contentLabel.attributedText = markdownParser.parse("### Chain Support\r\n- Support SUI Mainnet\r\n- Support MANTRA Testnet\r\n### Additional\r\n- Support Drop-money\r\n- Support End-point initialization\r\n" +
                                                           "### Changes\r\n- Support Drop-money\r\n- Support End-point initialization"/*notice["content"].stringValue*/)
    }
    
}
