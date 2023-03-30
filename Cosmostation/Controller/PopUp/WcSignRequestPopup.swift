//
//  WcSignRequestPopup.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/03/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WcSignRequestPopup: BaseViewController, SBCardPopupContent {
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard =  true
    let allowsSwipeToDismissPopupCard =  false

    @IBOutlet weak var wcMsgTextView: UITextView!
    
    
    var wcType :WcRequestType?   // 1 == trust request, 2 == keplr request
    var wcMsg :Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wcMsgTextView.text = wcMsg?.prettyJson
        self.wcMsgTextView.textColor = UIColor.font05
    }

    @IBAction func onClickCancel(_ sender: UIButton) {
        popupViewController?.close()
        popupViewController?.resultDelegate?.SBCardPopupResponse(type: wcType!.rawValue, result: -1)
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        popupViewController?.close()
        popupViewController?.resultDelegate?.SBCardPopupResponse(type: wcType!.rawValue, result: 0)
    }
    
}

public enum WcRequestType: Int {
    case TRUST_TYPE = 1
    case COSMOS_TYPE = 2
    case COSMOS_DIRECT_TYPE = 3
    case V2_SIGN_DIRECT = 4
    case V2_SIGN_AMINO = 5
    case INJECT_SIGN_AMINO = 6
    case INJECT_SIGN_DIRECT = 7
}
