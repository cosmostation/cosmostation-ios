//
//  VoteDetailMsgCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class VoteDetailMsgCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var requsetLayer: UIView!
    @IBOutlet weak var requsetAmountLabel: UILabel!
    @IBOutlet weak var requsetDenomLabel: UILabel!
    @IBOutlet weak var descriptionTv: UITextView!
    @IBOutlet weak var toggleBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func onBindView(_ message: MintscanV2Message?, _ position: Int, _ selected : Array<Int>) {
        typeLabel.text = String(position + 1) + ". " + String(message?.type?.split(separator: ".").last ?? "")
        titleLabel.text = message?.title
//        descriptionTv.text = message?.description
        descriptionTv.attributedText = message?.description?.htmlToAttributedString
        
        if (selected.contains(position)) {
            descriptionTv.isHidden = false
            toggleBtn.setImage(UIImage(named: "arrowUp"), for: .normal)
        } else {
            descriptionTv.isHidden = true
            toggleBtn.setImage(UIImage(named: "arrowDown"), for: .normal)
        }
    }
    
    var actionToggle: (() -> Void)? = nil
    @IBAction func onToggle(_ sender: UIButton) {
        actionToggle?()
    }
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
