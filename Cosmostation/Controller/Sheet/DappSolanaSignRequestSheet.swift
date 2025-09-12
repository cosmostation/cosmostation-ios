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
    var messageId: JSON!
    var selectedChain: BaseChain!
    
    var signature: String!
    var data: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        confirmBtn.isEnabled = false
        
        paringRequest()
    }
    
    override func setLocalizedString() {
        if (method == "solana_signMessage") {
            requestTitle.text = NSLocalizedString("str_permit_request", comment: "")
        } else {
            requestTitle.text = NSLocalizedString("str_tx_request", comment: "")
        }
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    func paringRequest() {
        guard let solanaFetcher = (selectedChain as? ChainSolana)?.getSolanaFetcher() else { return }
        
        Task {
            if method == "solana_signMessage" {
                do {
                    if let parseMessage = try await solanaFetcher.parseMessage(requestToSign!),
                       let signMessage = try await solanaFetcher.signMessage(requestToSign!, selectedChain.privateKey?.hexEncodedString()) {
                        let serializedSignMessageJsonData = try JSON(data: Data(signMessage.utf8))
                        
                        data = serializedSignMessageJsonData["publicKey"].stringValue
                        signature = serializedSignMessageJsonData["signature"].stringValue
                        
                        DispatchQueue.main.async {
                            self.onInitView()
                            self.toSignTextView.text = parseMessage
                            self.safeMsgTitle.isHidden = false
                        }
                    }
                    
                } catch {
                    print("fetching error: \(error)")
                    DispatchQueue.main.async {
                        self.dismissWithFail()
                    }
                }
                
            } else {
                
            }
        }
    }
    
    func onInitView() {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false
        confirmBtn.isEnabled = true
    }
    
    func dismissWithFail() {
        webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId)
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if method == "solana_signMessage" {
            let data: JSON = ["signature": signature, "publicKey": data]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
        }
        
        dismiss(animated: true)
    }
}
