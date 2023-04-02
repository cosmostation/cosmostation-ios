//
//  VoteDetailMsgCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class VoteDetailMsgCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var requsetLayer: UIView!
    @IBOutlet weak var requsetAmountLabel: UILabel!
    @IBOutlet weak var requsetDenomLabel: UILabel!
    @IBOutlet weak var descriptionBarLayer: UIView!
    @IBOutlet weak var descriptionTv: UITextView!
    @IBOutlet weak var toggleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ message: MintscanV2Message?, _ position: Int, _ selected : Array<Int>) {
        guard let chainConfig = chainConfig else {
            return
        }
        typeLabel.text = String(position + 1) + ". " + String(message?.type?.split(separator: ".").last ?? "")
        typeLabel.textColor = chainConfig.chainColor
        titleLabel.text = message?.title
        descriptionTv.text = message?.description
        descriptionTv.tintColor = UIColor(named: "photon")!
        
        if let reqCoin = message?.requestAmount {
            WDP.dpCoin(chainConfig, reqCoin, requsetDenomLabel, requsetAmountLabel)
            requsetLayer.isHidden = false
        } else {
            requsetLayer.isHidden = true
        }
        
        if (selected.contains(position)) {
            descriptionBarLayer.isHidden = false
            descriptionTv.isHidden = false
            toggleBtn.setImage(UIImage(named: "arrowUp"), for: .normal)
        } else {
            descriptionBarLayer.isHidden = true
            descriptionTv.isHidden = true
            toggleBtn.setImage(UIImage(named: "arrowDown"), for: .normal)
        }
        descriptionTv.delegate = self
    }
    
    var actionToggle: (() -> Void)? = nil
    @IBAction func onToggle(_ sender: UIButton) {
        actionToggle?()
    }
    
    var actionLink: ((URL) -> Void)? = nil
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        actionLink?(URL)
        return false
    }
}
