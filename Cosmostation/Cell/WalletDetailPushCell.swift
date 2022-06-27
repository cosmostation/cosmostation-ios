//
//  WalletDetailPushCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/12.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import UserNotifications

class WalletDetailPushCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardView!
    @IBOutlet weak var pushMsgLabel: UILabel!
    @IBOutlet weak var pushSwitch: UISwitch!
    
    var actionPush: ((Bool) -> Void)? = nil
    @IBAction func onClickPush(_ sender: UISwitch) {
        actionPush?(sender.isOn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig, _ account: Account) {
        rootView.backgroundColor = chainConfig.chainColorBG
        pushSwitch.onTintColor = chainConfig.chainColor
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    if (account.account_push_alarm) {
                        self.pushSwitch.setOn(true, animated: false)
                        self.pushMsgLabel.text = NSLocalizedString("push_enabled_state_msg", comment: "")
                    } else {
                        self.pushSwitch.setOn(false, animated: false)
                        self.pushMsgLabel.text = NSLocalizedString("push_disabled_state_msg", comment: "")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.pushSwitch.setOn(false, animated: false)
                    self.pushMsgLabel.text = NSLocalizedString("push_disabled_state_msg", comment: "")
                }
            }
        }
    }
}
