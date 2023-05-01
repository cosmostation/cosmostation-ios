//
//  NeuSingleVoteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class NeuSingleVoteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var yesLabel: UILabel!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var btnAbstain: UIButton!
    @IBOutlet weak var abstainLabel: UILabel!
    
    var actionYes: (() -> Void)? = nil
    var actionNo: (() -> Void)? = nil
    var actionAbstain: (() -> Void)? = nil
    
    @IBAction func onClickYes(_ sender: UIButton) {
        actionYes?()
    }
    @IBAction func onClickNo(_ sender: UIButton) {
        actionNo?()
    }
    @IBAction func onClickAbstain(_ sender: UIButton) {
        actionAbstain?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ module: NeutronProposalModule?, _ proposal: JSON?, _ myOpinion: String?) {
        if let chainConfig = chainConfig, let module = module, let proposal = proposal {
            let id = proposal["id"].int64Value
            let contents = proposal["proposal"]
            titleLabel.text = "# ".appending(String(id)).appending("  ").appending(contents["title"].stringValue)
            
            let expirationTime = contents["expiration"]["at_time"].int64Value
            if (expirationTime > 0) {
                let time = expirationTime / 1000000
                timeLabel.text = WDP.dpTime(time).appending(" ").appending(WDP.dpTimeGap(time))
            }
            let expirationHeight = contents["expiration"]["at_height"].int64Value
            if (expirationHeight > 0) {
                timeLabel.text = "Expiration at : " + String(expirationHeight)
            }
            
            onCheckDim()
            if (myOpinion?.lowercased() == "yes") {
                yesLabel.textColor = chainConfig.chainColor
                btnYes.tintColor = chainConfig.chainColor
                btnYes.layer.borderColor = chainConfig.chainColor.cgColor
                
            } else if (myOpinion?.lowercased() == "no") {
                noLabel.textColor = chainConfig.chainColor
                btnNo.tintColor = chainConfig.chainColor
                btnNo.layer.borderColor = chainConfig.chainColor.cgColor
                
            } else if (myOpinion?.lowercased() == "abstain") {
                abstainLabel.textColor = chainConfig.chainColor
                btnAbstain.tintColor = chainConfig.chainColor
                btnAbstain.layer.borderColor = chainConfig.chainColor.cgColor
            }
        }
    }
    
    func onCheckDim() {
        yesLabel.textColor = UIColor.font03
        btnYes.tintColor = UIColor.font03
        btnYes.layer.borderColor = UIColor.font03.cgColor
        noLabel.textColor = UIColor.font03
        btnNo.layer.borderColor = UIColor.font03.cgColor
        btnNo.tintColor = UIColor.font03
        abstainLabel.textColor = UIColor.font03
        btnAbstain.tintColor = UIColor.font03
        btnAbstain.layer.borderColor = UIColor.font03.cgColor
    }
    
}
