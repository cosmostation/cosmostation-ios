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
import Alamofire

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
    var displayToSign: JSON?
    var messageId: JSON?
    var selectedChain: BaseChain!
    var bytes: String!
    
    var suiFeeBudget = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        confirmBtn.isEnabled = false
            
        Task {
            if method == "sui_signAndExecuteTransaction" || method == "sui_signAndExecuteTransactionBlock" || method == "sui_signTransaction" || method == "sui_signTransactionBlock" {
                await dryrun()
            } else if method == "iota_signAndExecuteTransaction" || method == "iota_signAndExecuteTransactionBlock" || method == "iota_signTransaction" || method == "iota_signTransactionBlock" {
                await iotaDryrun()
            }
            
            DispatchQueue.main.async {
                self.onInitView()
            }
        }
    }
    
    override func setLocalizedString() {
        if (method == "sui_signMessage") || (method == "sui_signPersonalMessage") || (method == "iota_signMessage") || (method == "iota_signPersonalMessage") {
            requestTitle.text = NSLocalizedString("str_permit_request", comment: "")
        } else {
            requestTitle.text = NSLocalizedString("str_tx_request", comment: "")
        }
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    func onInitView() {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false
        confirmBtn.isEnabled = true
        
        if (method == "sui_signMessage") || (method == "sui_signPersonalMessage") || (method == "iota_signMessage") || (method == "iota_signPersonalMessage") {
            let data = Data(base64Encoded: requestToSign!["message"].stringValue)
            if let decode = String(data: data!, encoding: .utf8) {
                toSignTextView.text = decode
            }
            safeMsgTitle.isHidden = false
            
        } else {
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false
            toSignTextView.text = "\(displayToSign!)"
            onInitFeeView()
        }
    }

    func onInitFeeView() {
        feeImg.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakeDenom ?? selectedChain.mainAssetSymbol()), placeholderImage: UIImage(named: "tokenDefault"))
        feeLabel.text = selectedChain.mainAssetSymbol()
        feeDenomLabel.text = selectedChain.mainAssetSymbol()
        onUpdateFeeView()
    }
    
    func onUpdateFeeView() {
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.mainAssetSymbol()) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeDpBudge = suiFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
        let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpBudge.stringValue, feeAmountLabel!.font, 9)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    private func dryrun() async {
        guard let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() else { return }
        
        do {
            if let response = try await suiFetcher.suiDryrun(bytes) {
                if let error = response["error"]["message"].string {
                    print("fetching error: \(error)")
                    DispatchQueue.main.async {
                        self.dismissWithFail()
                    }
                    return
                }
                
                suiFeeBudget = {
                    let gasUsed = response["result"]["effects"]["gasUsed"]
                    let storageCost = gasUsed["storageCost"].intValue - gasUsed["storageRebate"].intValue
                    let cost = gasUsed["computationCost"].intValue + (storageCost > 0 ? storageCost : 0)
                    return NSDecimalNumber(value: cost)
                }()
                
                onUpdateFeeView()
                
                let gasData = response["result"]["input"]["gasData"]
                displayToSign!["gasData"] = gasData
            }
            
        } catch {
            print("fetching error: \(error)")
            DispatchQueue.main.async {
                self.dismissWithFail()
            }
        }
    }
    private func iotaDryrun() async {
        guard let iotaFetcher = (selectedChain as? ChainIota)?.getIotaFetcher() else { return }
        
        do {
            if let response = try await iotaFetcher.iotaDryrun(bytes) {
                if let error = response["error"]["message"].string {
                    print("fetching error: \(error)")
                    DispatchQueue.main.async {
                        self.dismissWithFail()
                    }
                    return
                }
                
                suiFeeBudget = {
                    let gasUsed = response["result"]["effects"]["gasUsed"]
                    let storageCost = gasUsed["storageCost"].intValue - gasUsed["storageRebate"].intValue
                    let cost = gasUsed["computationCost"].intValue + (storageCost > 0 ? storageCost : 0)
                    return NSDecimalNumber(value: cost)
                }()
                
                onUpdateFeeView()
                
                let gasData = response["result"]["input"]["gasData"]
                displayToSign!["gasData"] = gasData
            }
            
        } catch {
            print("fetching error: \(error)")
            DispatchQueue.main.async {
                self.dismissWithFail()
            }
        }
    }

    func dismissWithFail() {
        webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId!)
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if method == "sui_signTransaction" || method == "sui_signTransactionBlock" {
            let data: JSON = ["transactionBlockBytes": bytes, "signature": Signer.suiSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
            
        } else if method == "sui_signAndExecuteTransaction" || method == "sui_signAndExecuteTransactionBlock" {
            guard let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() else { return }
            Task {
                let options = requestToSign!["options"]
                if let data = try await suiFetcher.suiExecuteTx(self.bytes, Signer.suiSignatures(selectedChain, bytes), options) {
                    webSignDelegate?.onAcceptInjection(data["result"], requestToSign!, messageId!)
                    
                } else {
                    webSignDelegate?.onCancleInjection("Fail suiExecuteTx request", requestToSign!, messageId!)
                }
            }
            
        } else if (method == "sui_signMessage") {
            guard let messageBytes = requestToSign?["message"] else { return }
            let data: JSON = ["messageBytes": messageBytes, "signature": Signer.suiSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
            
        } else if (method == "sui_signPersonalMessage") {
            guard let messageBytes = requestToSign?["message"] else { return }
            let data: JSON = ["bytes": messageBytes, "signature": Signer.suiSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
            
        }
        
        else if (method == "iota_signTransactionBlock" || method == "iota_signTransaction") {
            let data: JSON = ["bytes": bytes, "signature": Signer.iotaSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)

        } else if (method == "iota_signAndExecuteTransactionBlock") || (method == "iota_signAndExecuteTransaction") {
            guard let iotaFetcher = (selectedChain as? ChainIota)?.getIotaFetcher() else { return }
            Task {
                let options = requestToSign!["options"]
                if let data = try await iotaFetcher.iotaExecuteTx(self.bytes, Signer.iotaSignatures(selectedChain, bytes), options) {
                    webSignDelegate?.onAcceptInjection(data["result"], requestToSign!, messageId!)
                    
                } else {
                    webSignDelegate?.onCancleInjection("Fail iotaExecuteTx request", requestToSign!, messageId!)
                }
            }
        } else if (method == "iota_signMessage") || (method == "iota_signPersonalMessage") {
            guard let messageBytes = requestToSign?["message"] else { return }
            let data: JSON = ["bytes": messageBytes, "signature": Signer.iotaSignatures(selectedChain, bytes)]
            webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
        }
        
        dismiss(animated: true)
    }
}



