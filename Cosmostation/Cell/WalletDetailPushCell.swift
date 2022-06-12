//
//  WalletDetailPushCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/12.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletDetailPushCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardView!
    @IBOutlet weak var pushMsgLabel: UILabel!
    @IBOutlet weak var pushSwitch: UISwitch!
    
    var actionPush: (() -> Void)? = nil
    @IBAction func onClickPush(_ sender: UISwitch) {
//        actionNickname?()
        print("onClickPush ", sender.isOn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView() {
        
    }
}
