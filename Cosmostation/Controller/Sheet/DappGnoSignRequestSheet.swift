//
//  DappGnoSignRequestSheet.swift
//  Cosmostation
//
//  Created by 권혁준 on 11/12/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire
import Foundation

class DappGnoSignRequestSheet: BaseVC {
    
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
    }
    
    override func setLocalizedString() {
        requestTitle.text = NSLocalizedString("str_tx_request", comment: "")
        safeMsgTitle.isHidden = true
        warnMsgLabel.isHidden = false
        dangerMsgTitle.isHidden = false
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
        
        parsingRequest()
    }
    
    private func parsingRequest() {
        guard let gnoFetcher = (selectedChain as? ChainGno)?.getGnoFetcher() else { return }
        
        Task {
            do {
                var memo = ""
                if requestToSign?["memo"].type != .null {
                    memo = requestToSign?["memo"].stringValue ?? ""
                }
                
                if let signMsgs = try await Signer.gnoSignMsg(requestToSign!),
                   let defaultFee = selectedChain.getDefaultFeeCoins().first {
                    
                    let txFee = Tm2_Tx_TxFee.with {
                        $0.gasWanted = Int64(3000000000)
                        $0.gasFee = defaultFee.amount + defaultFee.denom
                    }
                    
                    if let simulReq = Signer.genSimul(selectedChain, signMsgs, memo, txFee),
                       let simulRes = try await gnoFetcher.simulateTx(simulReq) {
                        
                        DispatchQueue.main.async {
                            if simulRes.responseBase.hasError {
                                self.onUpdateWithSimul(nil, simulRes.responseBase.error.typeURL)
                            } else {
                                self.onUpdateWithSimul(simulRes.gasUsed, nil)
                            }
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.dismissWithFail()
                }
            }
        }
    }
    
    func onUpdateWithSimul(_ gasUsed: Int64?, _ errorMessage: String? = nil) {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        bodyCardView.isHidden = false
        
        guard let toGas = gasUsed else {
            controlStakView.isHidden = true
            confirmBtn.isEnabled = false
            errorCardView.isHidden = false
            errorMsgLabel.text = errorMessage
            toSignTextView.text = "\(JSON(requestToSign?.rawString()?.data(using: .utf8) ?? ""))"
            return
        }
        
        onInitFeeView(toGas)
    }
    
    func onInitFeeView(_ gasUsed: Int64) {
        errorCardView.isHidden = true
        controlStakView.isHidden = false
        feeCardView.isHidden = false
        confirmBtn.isEnabled = true
        
        feeImg.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.gasAssetDenom()!), placeholderImage: UIImage(named: "tokenDefault"))
        feeLabel.text = selectedChain.stakingAssetSymbol()
        feeDenomLabel.text = selectedChain.stakingAssetSymbol()
        onUpdateFeeView(gasUsed)
    }
    
    func onUpdateFeeView(_ gasUsed: Int64) {
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.gasAssetDenom()) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let gasLimit = NSDecimalNumber.init(value: Double(gasUsed) * selectedChain.getSimulatedGasMultiply())
        let feeAmount = gasLimit.multiplying(by: NSDecimalNumber.init(value: 1.1)).multiplying(byPowerOf10: -3, withBehavior: getDivideHandler(3)).multiplying(byPowerOf10: -(msAsset.decimals ?? 8), withBehavior: getDivideHandler(msAsset.decimals ?? 8))
        let feeValue = feePrice.multiplying(by: feeAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, msAsset.decimals)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        
        requestToSign?["gasFee"].uInt64Value = UInt64(truncating: feeAmount.multiplying(byPowerOf10: msAsset.decimals ?? 8, withBehavior: getDivideHandler(0)))
        requestToSign?["gasWanted"].uInt64Value = UInt64(truncating: gasLimit)
        
        toSignTextView.text = "\(JSON(requestToSign?.rawString()?.data(using: .utf8) ?? ""))"
    }
    
    func dismissWithFail() {
        webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId)
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        guard let gnoFetcher = (selectedChain as? ChainGno)?.getGnoFetcher() else { return }
        
        Task {
            do {
                let gasFee = requestToSign?["gasFee"].int64Value ?? 0
                let gasWanted = requestToSign?["gasWanted"].int64Value ?? 0
                var memo = ""
                if requestToSign?["memo"].type != .null {
                    memo = requestToSign?["memo"].stringValue ?? ""
                }
                let messages = requestToSign?["messages"][0]
                let value = messages?["value"]
                let type = messages?["type"].stringValue
                
                guard let valueJson = value else { return }
                let valueData = try valueJson.rawData()
                let msg = try JSONDecoder().decode(Signer.Msg.self, from: valueData)
                var typeMsg = msg
                typeMsg.type = type ?? ""
                
                let fee = Tm2_Tx_TxFee.with {
                    $0.gasWanted = gasWanted
                    $0.gasFee = String(gasFee) + selectedChain.stakingAssetDenom()
                }
                
                guard let sig = Signer.gnoSignature(selectedChain, [typeMsg], memo, .init(gas_wanted: String(fee.gasWanted), gas_fee: fee.gasFee)) else { return }
                
                if let signMsgs = try await Signer.gnoSignMsg(requestToSign!) {
                    let broadReq = Signer.genTx(selectedChain, signMsgs, memo, fee, sig)
                    let txByte = try broadReq.serializedData().base64EncodedString()
                    
                    var signJson = JSON()
                    signJson["code"].int = 0
                    signJson["status"].string = "success"
                    signJson["message"].string = ""

                    if method == "gno_signAndSendTransaction" {
                        let hash = try await broadcastTx(gnoFetcher.getRpc(), txByte)
                        let hashData: JSON = ["hash": hash]
                        signJson["data"] = hashData
                        
                    } else {
                        let encodeData: JSON = ["encodedTransaction": txByte]
                        signJson["data"] = encodeData
                    }
                    
                    webSignDelegate?.onAcceptInjection(signJson, requestToSign!, messageId!)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.dismissWithFail()
                }
            }
        }
        
        dismiss(animated: true)
    }
}

extension DappGnoSignRequestSheet {
    
    func broadcastTx(_ rpc: String, _ txByte: String) async throws -> String {
        let params: Parameters = ["jsonrpc":"2.0",
                                  "method": "broadcast_tx_async",
                                  "params": [txByte],
                                  "id": 1]
        let result = try await AF.request(rpc, method: .post, parameters: params, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        let hash = result["result"]["hash"].stringValue
        return hash
    }
}
