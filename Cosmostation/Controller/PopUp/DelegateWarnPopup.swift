//
//  DelegateWarnPopup.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/06/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit

class DelegateWarnPopup: BaseViewController, SBCardPopupContent {
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard =  true
    let allowsSwipeToDismissPopupCard =  false
    var warnImgType: UInt16?
    @IBOutlet weak var warnImg: UIImageView!
    @IBOutlet weak var delegateWarnTitle: UILabel!
    @IBOutlet weak var delegateWarnContent: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateWarnTitle.text = NSLocalizedString("str_delegate_warn_title", comment: "")
        delegateWarnContent.text = NSLocalizedString("str_delegate_warn_msg", comment: "")
        btnCancel.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        btnConfirm.setTitle(NSLocalizedString("confirm", comment: ""), for: .normal)
        
        if (warnImgType == 14) {
            self.warnImg.image = UIImage(named: "imgDelegate14Warning")
        } else if (warnImgType == 3) {
            self.warnImg.image = UIImage(named: "imgDelegate3Warning")
        } else if (warnImgType == 28) {
            self.warnImg.image = UIImage(named: "imgDelegate28Warning")
        } else if (warnImgType == 7) {
            self.warnImg.image = UIImage(named: "imgDelegate7Warning")
        } else if (warnImgType == 30) {
            self.warnImg.image = UIImage(named: "imgDelegate30Warning")
        } else {
            self.warnImg.image = UIImage(named: "imgDelegateWarning")
        }
    }

    @IBAction func onClickCancel(_ sender: UIButton) {
        popupViewController?.resultDelegate?.SBCardPopupResponse(type: 0, result: -1)
        popupViewController?.close()
    }
    @IBAction func onClickConfirm(_ sender: UIButton) {
        popupViewController?.resultDelegate?.SBCardPopupResponse(type: 0, result: 1)
        popupViewController?.close()
    }
    
}
