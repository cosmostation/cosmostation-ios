//
//  WalletAuthzCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletAuthzCell: UITableViewCell {
    
    @IBOutlet weak var authzImg: UIImageView!
    @IBOutlet weak var authzMsgLabel: UILabel!
    @IBOutlet weak var btnAuthz: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        authzMsgLabel.text = NSLocalizedString("msg_authz_description", comment: "")
    }
    
    var actionAuthz: (() -> Void)? = nil
    
    @IBAction func onClickAuthz(_ sender: UIButton) {
        actionAuthz?()
    }
    
    func onBindCell(_ chainConfig: ChainConfig?) {
        authzImg.image = authzImg.image!.withRenderingMode(.alwaysTemplate)
        authzImg.tintColor = chainConfig?.chainColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnAuthz.borderColor = UIColor.font05
    }
    
}
