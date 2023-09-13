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
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func onBindSetNotification() {
        setImg.image = UIImage(named: "setNoti")
        setTitleLabel.text = NSLocalizedString("setting_notification_title", comment: "")
        selectSwitch.isOn = false
        Task {
            if let status = try? await PushUtils.shared.getStatus() {
                print("onBindSetNotification status ", status)
                self.selectSwitch.isOn = status["subscribe"].bool ?? false
            }
        }
    }
    
    func onBindSetAppLock() {
        setImg.image = UIImage(named: "setAppLock")
        setTitleLabel.text = NSLocalizedString("setting_app_lock_title", comment: "")
        selectSwitch.isOn = BaseData.instance.getUsingAppLock()
        
    }
    
    func onBindSetEngineerMode() {
        setImg.image = UIImage(named: "setEngineer")
        setTitleLabel.text = NSLocalizedString("setting_engineermode_title", comment: "")
        selectSwitch.isOn = BaseData.instance.getUsingEnginerMode()
        
    }
    
}
