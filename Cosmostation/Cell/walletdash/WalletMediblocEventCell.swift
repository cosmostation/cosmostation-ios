//
//  WalletMediblocEventCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/13.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletMediblocEventCell: UITableViewCell {
    
    @IBOutlet weak var btnDownload: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    var actionDownload: (() -> Void)? = nil
    
    @IBAction func onClickDownload(_ sender: Any) {
        actionDownload?()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDownload.borderColor = UIColor.font05
    }
    
}
