//
//  NoticeSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class NoticeSheet: BaseVC {
    
    @IBOutlet weak var noticeTitleLabel: UILabel!
    @IBOutlet weak var noticeMsgLabel: UILabel!
    @IBOutlet weak var subBtn: SecButton!
    @IBOutlet weak var okBtn: BaseButton!
    
    
    var noticeType: NoticeType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setLocalizedString() {
        noticeTitleLabel.text = NSLocalizedString("str_warnning", comment: "")
        noticeMsgLabel.text = NSLocalizedString("msg_swap_warn", comment: "")
        if (noticeType == .SwapInitWarn) {
            subBtn.setTitle(NSLocalizedString("str_do_not_show_7_days", comment: ""), for: .normal)
            okBtn.setTitle(NSLocalizedString("str_ok", comment: ""), for: .normal)
        }
    }
    
    @IBAction func onClickSubBtn(_ sender: UIButton) {
        if (noticeType == .SwapInitWarn) {
            BaseData.instance.setSwapWarn()
            dismiss(animated: true)
        }
    }
    
    @IBAction func onClickOkBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


public enum NoticeType: Int {
    case SwapInitWarn = 0
}
