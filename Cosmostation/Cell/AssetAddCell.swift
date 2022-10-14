//
//  AssetAddCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AssetAddCell: UITableViewCell {

    @IBOutlet weak var tokenEditTitle: UILabel!
    @IBOutlet weak var tokenEditMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        tokenEditTitle.text = NSLocalizedString("str_edit_token_list", comment: "")
        tokenEditMsg.text = NSLocalizedString("msg_edit_token_list", comment: "")
    }
    
}
