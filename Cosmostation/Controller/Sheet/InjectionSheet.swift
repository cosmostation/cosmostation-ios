//
//  InjectionSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/9/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class InjectionSheet: BaseVC {
    
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var noticeMsgLabel: UILabel!
    @IBOutlet weak var subBtn: SecButton!
    @IBOutlet weak var okBtn: BaseButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setLocalizedString() {
        noticeTitleLabel.text = NSLocalizedString("str_support_injection", comment: "")
        noticeMsgLabel.text = NSLocalizedString("msg_support_injection", comment: "")
        subBtn.setTitle(NSLocalizedString("str_do_not_show_7_days", comment: ""), for: .normal)
        okBtn.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
    }
    
    @IBAction func onClickSubBtn(_ sender: UIButton) {
        BaseData.instance.setInjectionWarn()
        dismiss(animated: true)
    }
    
    @IBAction func onClickOkBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
