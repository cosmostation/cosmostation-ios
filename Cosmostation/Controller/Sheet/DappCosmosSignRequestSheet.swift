//
//  DappCosmosSignRequestSheet.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/25/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lottie
import Web3Core
import WalletConnectSign
import SwiftProtobuf

class DappCosmosSignRequestSheet: BaseVC {
    
    var webSignDelegate: WebSignDelegate?
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var safeMsgTitle: UILabel!
    @IBOutlet weak var dangerMsgTitle: UILabel!
    @IBOutlet weak var warnMsgLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var bodyCardView: FixCardView!
    @IBOutlet weak var wcMsgTextView: UITextView!
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    @IBOutlet weak var feeDappBtn: SmallButton!
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var controlStakView: UIStackView!
    @IBOutlet weak var cancelBtn: SecButton!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var method: String!
    var requestToSign: JSON?
    var messageId: JSON?
    var wcRequest: WalletConnectSign.Request?
    
    var selectedChain: BaseChain!
    var allChains = [BaseChain]()
    
    var targetChain: BaseChain!
    var targetChainId: String?
    var targetDocs: JSON!
    var isEditFee = true
    
    var selectedFeePosition = 0
    var feeInfos = [FeeInfo]()
    var txFee: Cosmos_Tx_V1beta1_Fee?
    var authInfo: Cosmos_Tx_V1beta1_AuthInfo!
    var dappTxFee: Cosmos_Tx_V1beta1_Fee?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        confirmBtn.isEnabled = true
        if (requestToSign == nil) {
            dismissWithFail()
            return
        }
        
        Task {
            try await onParsingRequest()
            if (method == "cos_signDirect" || method == "cosmos_signDirect") {
                try? await targetChain?.getCosmosfetcher()?.fetchCosmosAvailables()
            }
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.onInitView()
            }
        }
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeDenom)))
    }
    
    override func setLocalizedString() {
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    
    func onParsingRequest() async throws {
        
        if (method == "cos_signMessage") {
            let requestChainName = requestToSign?["params"]["chainName"].stringValue
            let requestChainId = requestToSign?["params"]["chainId"].stringValue
            
            if let chain = allChains.filter({ $0.chainIdCosmos == requestChainId ||
                $0.chainIdCosmos == requestChainName ||
                $0.name.lowercased() == requestChainId?.lowercased() ||
                $0.name.lowercased() == requestChainName?.lowercased()} ).first {
                targetChain = chain
            } else {
                print("Parsing error")
                return
            }
            
            
        } else {
            if let editFee = requestToSign?.isEditFee,
               let docs = requestToSign?.docs,
               let chain = allChains.filter({ $0.chainIdCosmos == docs.chainId }).first {
                isEditFee = editFee
                targetDocs = docs
                targetChain = chain
            } else {
                print("Parsing error")
                return
            }
            
            if (method == "cos_signAmino" || method == "cosmos_signAmino") {
                if (isEditFee == false && (targetDocs!["fee"]["amount"].isEmpty || targetDocs!["fee"]["gas"] == "0") || isEditFee == true) {
                    let baseFeeDatas = targetChain.getBaseFeeInfo().FeeDatas
                    let gasLimit = targetDocs!["fee"]["gas"].string ?? targetChain.getInitGasLimit().stringValue
                    let feeDenom = targetDocs!["fee"]["amount"][0]["denom"].string ?? baseFeeDatas[0].denom
                    let gasRate = baseFeeDatas.filter { $0.denom == feeDenom }.first?.gasRate ?? NSDecimalNumber.zero
                    let feeAmount = NSDecimalNumber(string: gasLimit).multiplying(by: gasRate, withBehavior: handler0Up)
                    targetDocs!["fee"]["amount"] = [["amount": feeAmount.stringValue, "denom": feeDenom]]
                    targetDocs!["fee"]["gas"].stringValue = gasLimit
                }
                dappTxFee = setFeeData(targetDocs!["fee"]["gas"].stringValue,
                                       targetDocs!["fee"]["amount"][0]["denom"].stringValue,
                                       targetDocs!["fee"]["amount"][0]["amount"].stringValue)
                
                
            } else if (method == "cos_signDirect" || method == "cosmos_signDirect") {
                if let authInfoBytes = targetDocs.authInfoBytes,
                    let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoBytes)!) {
                    if (authInfo.fee.gasLimit > 0 && authInfo.fee.amount.count >= 1) {
                        dappTxFee = authInfo.fee
                    }
                }
            }
        }
    }
    
    func onInitView() {
        
        onInitFeeView()
        
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        barView.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        
        if (method == "cos_signMessage") {
            wcMsgTextView.text = requestToSign?["params"]["message"].rawString()
            safeMsgTitle.isHidden = false
            
        } else {
            if (targetDocs == nil) {
                errorMsgLabel.text = "Request Pasing Error"
                errorCardView.isHidden = false
                return
            }
            if (targetChain == nil) {
                errorMsgLabel.text = "Not Supported Chain"
                errorCardView.isHidden = false
                return
            }
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false
            wcMsgTextView.text = targetDocs?.rawString()
        }
    }
    
    func onInitFeeView() {
        feeSegments.removeAllSegments()
        if (method == "cos_signAmino" || method == "cosmos_signAmino") {
            feeSegments.insertSegment(withTitle: NSLocalizedString("str_fixed", comment: ""), at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            confirmBtn.isEnabled = true
            txFee = dappTxFee
            
        } else if (method == "cos_signDirect" || method == "cosmos_signDirect") {
            feeInfos = selectedChain.getFeeInfos()
            for i in 0..<feeInfos.count {
                feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
            }
            selectedFeePosition = selectedChain.getBaseFeePosition()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            txFee = selectedChain.getInitPayableFee()
            if (dappTxFee != nil) {
                feeDappBtn.isHidden = false
                feeDappBtn.isSelected = false
                
            }
            onSimul()
        }
        onUpdateFeeView()
    }
    
    func onUpdateFeeView() {
        if let txFee = txFee,
            let feeAsset = BaseData.instance.getAsset(targetChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = feeAsset.symbol
            WDP.dpCoin(feeAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, feeAsset.decimals)
            let msPrice = BaseData.instance.getPrice(feeAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -feeAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    @objc func onSelectFeeDenom() {
        if (method == "cos_signAmino" || method == "cosmos_signAmino") {
            return
            
        } else if (method == "cos_signDirect" || method == "cosmos_signDirect") {
            if (selectedFeePosition < 0) { return }
            if (feeInfos.count > 0) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.targetChain = targetChain
                baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
                baseSheet.sheetDelegate = self
                baseSheet.sheetType = .SelectFeeDenom
                onStartSheet(baseSheet, 240, 0.6)
            }
        }
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        if (selectedFeePosition == sender.selectedSegmentIndex) { return }
        feeDappBtn.isSelected = false
        selectedFeePosition = sender.selectedSegmentIndex
        txFee = targetChain.getUserSelectedFee(selectedFeePosition, txFee!.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @IBAction func onClickDappFee(_ sender: SmallButton) {
        if (feeDappBtn.isSelected) { return }
        feeDappBtn.isSelected = true
        selectedFeePosition = -1
        feeSegments.selectedSegmentIndex = selectedFeePosition
        txFee = dappTxFee
        onUpdateFeeView()
        onSimul()
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        if (selectedFeePosition >= 0) {
            if let toGas = gasUsed {
                txFee!.gasLimit = UInt64(Double(toGas) * selectedChain.getSimulatedGasMultiply())
                if let gasRate = feeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == txFee!.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: txFee!.gasLimit)
                    let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    txFee!.amount[0].amount = feeCoinAmount!.stringValue
                }
            }
        }
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        confirmBtn.isEnabled = true
    }
    
    func dismissWithFail() {
        if (method == "cos_signAmino" || method == "cos_signDirect" || method == "cos_signMessage") {
            webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId!)
            
        } else if (method == "cosmos_signAmino" || method == "cosmos_signDirect") {
            webSignDelegate?.onCancleWC2(wcRequest!)
        }
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        dismissWithFail()
        
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        if (method == "cos_signMessage") {
            let signer = requestToSign?["params"]["signer"]
            let message = requestToSign?["params"]["message"].stringValue
            let base64 = message!.data(using: .utf8)!.base64EncodedString()
            
            let msg = L_Generator.personalSignMsg(base64, signer!.stringValue)
            let fee = L_Fee.init("0", [])
            let stdMsg = L_Generator.getToSignMsg("", "0", "0", [msg], fee, "")
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            let toSignData = try! encoder.encode(stdMsg)
            let sig = getSignatureResponse(selectedChain!.privateKey!, toSignData)
            
            var signed = JSON()
            signed["pub_key"] = sig.pubKey!
            signed["signature"].stringValue = sig.signature!
            webSignDelegate?.onAcceptInjection(signed, requestToSign!, messageId!)
            
        } else if (method == "cos_signAmino") {
            var signed = JSON()
            let sortedJsonData = try! targetDocs!.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let sig = getSignatureResponse(targetChain!.privateKey!, sortedJsonData)
            signed["pub_key"] = sig.pubKey!
            signed["signature"].stringValue = sig.signature!
            signed["signed_doc"] = targetDocs
            webSignDelegate?.onAcceptInjection(signed, targetDocs!, messageId!)
            
        } else if (method == "cosmos_signAmino") {
            let sortedJsonData = try? targetDocs.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let sig = getSignatureResponse(self.targetChain.privateKey!, sortedJsonData!)
            let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
            let response: JSON = ["signed" : targetDocs.rawValue, "signDoc" : targetDocs.rawValue, "signature" : signature.dictionaryValue]
            webSignDelegate?.onAcceptWC2(AnyCodable(response), wcRequest!)
            
        } else if (method == "cos_signDirect") {
            var signed = JSON()
            
            if let chainId = targetDocs.chainId,
               let bodyString = targetDocs.bodyBytes,
               let authInfoString = targetDocs.authInfoBytes,
               let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: Data.dataFromHex(bodyString)!),
               var authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoString)!) {
                
                //update authInfo with user modified fee
                if (selectedFeePosition == -1) {
                    authInfo.fee.gasLimit = dappTxFee!.gasLimit
                    authInfo.fee.amount[0] = dappTxFee!.amount[0]
                } else {
                    authInfo.fee.gasLimit = txFee!.gasLimit
                    authInfo.fee.amount[0] = txFee!.amount[0]
                }
                targetDocs = setAuthInfo(targetDocs, try! authInfo.serializedData().toHexString())
                requestToSign = setAuthInfo(requestToSign!, try! authInfo.serializedData().toHexString())
                
                let signedDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                    $0.bodyBytes = try! bodyBytes.serializedData()
                    $0.authInfoBytes = try! authInfo.serializedData()
                    $0.chainID = chainId
                    $0.accountNumber = targetDocs["account_number"].uInt64Value
                }
                
                let sig = getSignatureResponse(self.targetChain.privateKey!, try! signedDoc.serializedData())
                signed["pub_key"] = sig.pubKey!
                signed["signature"].stringValue = sig.signature!
                signed["signed_doc"] = targetDocs
                webSignDelegate?.onAcceptInjection(signed, requestToSign!, messageId!)
            }
            
        } else if (method == "cosmos_signDirect") {
            if let chainId = targetDocs.chainId,
               let bodyString = targetDocs.bodyBytes,
               let authInfoString = targetDocs.authInfoBytes,
               let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: Data.dataFromHex(bodyString)!),
               let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoString)!) {
                let signedDoc = Cosmos_Tx_V1beta1_SignDoc.with {
                    $0.bodyBytes = try! bodyBytes.serializedData()
                    $0.authInfoBytes = try! authInfo.serializedData()
                    $0.chainID = chainId
                    $0.accountNumber = targetDocs["accountNumber"].uInt64Value
                }
                let sig = getSignatureResponse(self.targetChain.privateKey!, try! signedDoc.serializedData())
                let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
                webSignDelegate?.onAcceptWC2(AnyCodable(signature.dictionaryValue), wcRequest!)
            }
        }
        self.dismiss(animated: true)
    }
    
    
    func setFeeData(_ gas: String, _ denom: String, _ amount: String) -> Cosmos_Tx_V1beta1_Fee {
        let feeCoin = Cosmos_Base_V1beta1_Coin.init(denom, amount)
        return Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = UInt64(gas)!
            $0.amount = [feeCoin]
        }
    }
    
    
    func setAuthInfo(_ json: JSON, _ authByte: String) -> JSON {
        var result = json
        if let authInfo = json["auth_info_bytes"].string {
            result["auth_info_bytes"].stringValue = authByte
        }
        if let authInfo = json["authInfoBytes"].string {
            result["authInfoBytes"].stringValue = authByte
        }
        if let authInfo = json["params"]["doc"]["auth_info_bytes"].string {
            result["params"]["doc"]["auth_info_bytes"].stringValue = authByte
        }
        if let authInfo = json["params"]["signDoc"]["auth_info_bytes"].string {
            result["params"]["signDoc"]["auth_info_bytes"].stringValue = authByte
        }
        if let authInfo = json["params"]["doc"]["authInfoBytes"].string {
            result["params"]["doc"]["authInfoBytes"].stringValue = authByte
        }
        if let authInfo = json["params"]["signDoc"]["authInfoBytes"].string {
            result["params"]["signDoc"]["authInfoBytes"].stringValue = authByte
        }
        return result
    }
    
    private func getSignatureResponse(_ privateKey: Data, _ signData: Data) -> (signature: String?, pubKey: JSON?) {
        var result: (String?, JSON?)
        var sig: Data?
        var pubkey: JSON?
        var type: String?
        if (targetChain.accountKeyType.pubkeyType == .INJECTIVE_Secp256k1) {
            sig = SECP256K1.compactsign(signData.sha3(.keccak256), privateKey: privateKey)!
            type = INJECTIVE_KEY_TYPE_PUBLIC
            
        } else if (targetChain.accountKeyType.pubkeyType == .ETH_Keccak256 || targetChain.accountKeyType.pubkeyType == .STRATOS_Keccak256 || targetChain.accountKeyType.pubkeyType == .INITIA_Keccak256) {
            sig = SECP256K1.compactsign(signData.sha3(.keccak256), privateKey: privateKey)!
            type = ETHERMINT_KEY_TYPE_PUBLIC
            
        } else if (targetChain.accountKeyType.pubkeyType == .BERA_Secp256k1) {
            //TODO Bera
        } else if (targetChain.accountKeyType.pubkeyType == .COSMOS_Secp256k1) {
            sig = SECP256K1.compactsign(signData.sha256(), privateKey: privateKey)!
            type = COSMOS_KEY_TYPE_PUBLIC
        }
        pubkey = ["type" : type, "value" : targetChain.publicKey?.base64EncodedString()]
        result = (sig?.base64EncodedString(), pubkey)
        return result
    }
    
}

extension DappCosmosSignRequestSheet: BaseSheetDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeePosition].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onSimul() {
        view.isUserInteractionEnabled = false
        confirmBtn.isEnabled = false
        loadingView.isHidden = false
        
        if (targetChain.isSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        Task {
            do {
                let simulReq = genSimulTxs()
                let simulRes = try await targetChain.getCosmosfetcher()!.simulateTx(simulReq!)
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(simulRes)
                }
                
            } catch {
                print("onSimul Error \(error)")
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.loadingView.isHidden = true
                    self.onShowToast("Error : " + "\n" + "\(error)")
                }
            }
        }
    }
    
    func genSimulTxs() -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if let bodyString = targetDocs.bodyBytes,
           let authInfoString = targetDocs.authInfoBytes,
           let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: Data.dataFromHex(bodyString)!),
           var authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: Data.dataFromHex(authInfoString)!) {
            authInfo.fee.amount = txFee!.amount
            authInfo.fee.gasLimit = txFee!.gasLimit
            
            let simulateTx = Cosmos_Tx_V1beta1_Tx.with {
                $0.authInfo = authInfo
                $0.body = bodyBytes
                $0.signatures = Signer.getSimulsignatures(authInfo.signerInfos.count)
            }
            return Cosmos_Tx_V1beta1_SimulateRequest.with {
                $0.txBytes = try! simulateTx.serializedData()
            }
        }
        return nil
    }
}



protocol WebSignDelegate {
    
    func onCancleInjection(_ reseon: String, _ requestToSign: JSON, _ messageId: JSON)
    
    func onAcceptInjection(_ signed: JSON, _ docs: JSON, _ messageId: JSON)
    
    
    func onCancleWC2(_ wcRequest: WalletConnectSign.Request)
    
    func onAcceptWC2(_ response: AnyCodable, _ wcRequest: WalletConnectSign.Request)
}

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .allowFragments),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}

extension JSON {
    
    var docs: JSON? {
        if !self["params"]["doc"].isEmpty {
            return self["params"]["doc"]
        }
        if !self["params"]["signDoc"].isEmpty {
            return self["params"]["signDoc"]
        }
        return nil
    }
    
    var chainId: String? {
        if let chainId = self["chain_id"].rawString() {
            return chainId
        }
        if let chainId = self["chainId"].rawString() {
            return chainId
        }
        return nil
    }
    
    var isEditFee: Bool {
        if (self["isEditFee"] == false || self["params"]["isEditFee"] == false) {
            return false
        }
        return true
    }
    
    var bodyBytes: String? {
        if let chainId = self["body_bytes"].rawString() {
            return chainId
        }
        if let chainId = self["bodyBytes"].rawString() {
            return chainId
        }
        return nil
    }
    
    var authInfoBytes: String? {
        if let authInfo = self["auth_info_bytes"].rawString() {
            return authInfo
        }
        if let authInfo = self["authInfoBytes"].rawString() {
            return authInfo
        }
        return nil
    }
}
