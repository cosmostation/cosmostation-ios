//
//  DappSolanaSignRequestSheet.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/11/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire

class DappSolanaSignRequestSheet: BaseVC {
    
    var webSignDelegate: WebSignDelegate?
    
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var safeMsgTitle: UILabel!
    @IBOutlet weak var dangerMsgTitle: UILabel!
    @IBOutlet weak var warnMsgLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var bodyCardView: FixCardView!
    @IBOutlet weak var toSignTextView: UITextView!
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeImg: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var controlStakView: UIStackView!
    @IBOutlet weak var cancelBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var method: String!
    var requestToSign: JSON?
    var displayToSign: JSON?
    var messageId: JSON?
    var selectedChain: BaseChain!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        confirmBtn.isEnabled = false
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
    }
}
