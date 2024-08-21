//
//  DappSuiSignRequestSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 8/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Web3Core
import WalletConnectSign
import SwiftProtobuf

class DappSuiSignRequestSheet: BaseVC {

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
        
        confirmBtn.isEnabled = true
                
        if let requestToSign {
            toSignTextView.text = "\(requestToSign.rawValue)"
        }

        
        
        Task {
            do {
                
                //
                
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    self.onInitView()
                }
                
            } catch {
                print("fetching error: \(error)")
                DispatchQueue.main.async {
                    self.dismissWithFail()
                }
            }
        }

    }
    
    override func setLocalizedString() {
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    func dismissWithFail() {
//        webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId!)
        dismiss(animated: true)
    }
    
    func onInitView() {
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false

        //
    }
    

    @IBAction func onClickCancel(_ sender: Any) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if method == "sui_signTransaction" {
            let data: JSON = ["bytes": "", "signature": ""]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
        }
        
        dismiss(animated: true)
    }
    
}


extension DappSuiSignRequestSheet: BaseSheetDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        
    }
    
}



