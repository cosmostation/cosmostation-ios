//
//  SettingSwitchCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SettingSwitchCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var setImg: UIImageView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setMsgLabel: UILabel!
    @IBOutlet weak var selectSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setMsgLabel.isHidden = true
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func onBindHideLegacy() {
        setImg.image = UIImage(named: "setHideLegacy")
        setTitleLabel.text = NSLocalizedString("setting_hide_legacy", comment: "")
        selectSwitch.isOn = !BaseData.instance.getHideLegacy()
    }
    
    func onBindTestnet() {
        setImg.image = UIImage(named: "setTestnet")
        setTitleLabel.text = NSLocalizedString("setting_show_testnet", comment: "")
        selectSwitch.isOn = BaseData.instance.getShowTestnet()
    }
    
    func onBindSetNotification() {
        setImg.image = UIImage(named: "setNoti")
        setTitleLabel.text = NSLocalizedString("setting_notification_title", comment: "")
        selectSwitch.isOn = BaseData.instance.getPushNoti()
    }
    
    func onBindSetAppLock() {
        setImg.image = UIImage(named: "setAppLock")
        setTitleLabel.text = NSLocalizedString("setting_app_lock_title", comment: "")
        selectSwitch.isOn = BaseData.instance.getUsingAppLock()
    }
    
    func onBindSetBioAuth() {
        setImg.image = UIImage(named: "setBioAuth")
        setTitleLabel.text = NSLocalizedString("setting_bio_auth_title", comment: "")
        selectSwitch.isOn = BaseData.instance.getUsingBioAuth()
    }
    
}
