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

class DappCosmosSignRequestSheet: BaseVC {
    
    var webSignDelegate: WebSignDelegate?
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var safeMsgTitle: UILabel!
    @IBOutlet weak var dangerMsgTitle: UILabel!
    @IBOutlet weak var warnMsgLabel: UILabel!
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
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var controlStakView: UIStackView!
    @IBOutlet weak var cancelBtn: BaseButton!
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
    var txFee: Cosmos_Tx_V1beta1_Fee!
    
    var authInfo: Cosmos_Tx_V1beta1_AuthInfo!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        confirmBtn.isEnabled = false
        
        print("DappCosmosSignRequestSheet ", requestToSign)
        if (requestToSign == nil) {
            dismissWithFail()
            return
        }
        
        Task {
            try await onParsingRequest()
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.onInitView()
            }
        }
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeDenom)))
    }
    
    func onInitView() {
        if (targetChain == nil) {
            errorMsgLabel.text = "Not Supported Chain"
            errorCardView.isHidden = false
            return
        }
        
        onInitFeeView()
        
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        feeCardView.isHidden = false
        controlStakView.isHidden = false
        
        wcMsgTextView.text = try! targetDocs?.rawData().prettyJson
        
        
        print("txFee ", txFee)
    }
    
    func onInitFeeView() {
        feeSegments.removeAllSegments()
        if (method == "cos_signAmino" || method == "cosmos_signAmino") {
            feeSegments.insertSegment(withTitle: NSLocalizedString("str_fixed", comment: ""), at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            confirmBtn.isEnabled = true
            
        } else if (method == "cos_signDirect" || method == "cosmos_signDirect") {
            if (isEditFee == false) {
                feeSegments.insertSegment(withTitle: NSLocalizedString("str_fixed", comment: ""), at: 0, animated: false)
                selectedFeePosition = 0
                feeSegments.selectedSegmentIndex = selectedFeePosition
                confirmBtn.isEnabled = true
                
            } else {
                feeInfos = selectedChain.getFeeInfos()
                for i in 0..<feeInfos.count {
                    feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
                }
                selectedFeePosition = selectedChain.getFeeBasePosition()
                feeSegments.selectedSegmentIndex = selectedFeePosition
//                txFee = selectedChain.getInitPayableFee()   <- no balance!!
//                confirmBtn.isEnabled = true
//                
//                print("feeInfos ", feeInfos)
//                print("txFee ", txFee)
//                onSimul()
            }
        }
        onUpdateFeeView()
    }
    
    func onUpdateFeeView() {
        if let feeAsset = BaseData.instance.getAsset(targetChain.apiName, txFee.amount[0].denom) {
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
            if (isEditFee == false) {
                let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                baseSheet.targetChain = selectedChain
                baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
                baseSheet.sheetDelegate = self
                baseSheet.sheetType = .SelectFeeDenom
                onStartSheet(baseSheet, 240, 0.6)
            }
        }
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
//        selectedFeePosition = sender.selectedSegmentIndex
//        if (txStyle == .COSMOS_STYLE) {
//            txFee = fromChain.getUserSelectedFee(selectedFeePosition, txFee.amount[0].denom)
//        }
//        onUpdateFeeView()
//        onSimul()
    }
    
    func onParsingRequest() async throws {
        if (method == "cos_signAmino" || method == "cosmos_signAmino") {
//            var signDoc: JSON!
            if (requestToSign?["params"]["doc"].isEmpty == false) {
                targetDocs = requestToSign?["params"]["doc"]
            } else if (requestToSign?["params"]["signDoc"].isEmpty == false) {
                targetDocs = requestToSign?["params"]["signDoc"]
            }
            print("targetDocs ", targetDocs)
            if (targetDocs == nil) { return }
            
            let chainId = targetDocs!["chain_id"].stringValue
            print("chainId ", chainId)
            
            targetChain = allChains.filter({ $0.chainIdCosmos == chainId }).first
            print("targetChain", targetChain)
            if (targetChain == nil) { return }
            
            if (requestToSign?["isEditFee"] == false || requestToSign?["params"]["isEditFee"] == false) {
                isEditFee = false
            }
            print("isEditFee ", isEditFee)
            
            if (isEditFee == false && (targetDocs!["fee"]["amount"].isEmpty || targetDocs!["fee"]["gas"] == "0") || isEditFee == true) {
                let baseFeeDatas = targetChain.getBaseFeeInfo().FeeDatas
                let gasLimit = targetDocs!["fee"]["gas"].string ?? targetChain.getFeeBaseGasAmountS()
                let feeDenom = targetDocs!["fee"]["amount"][0]["denom"].string ?? baseFeeDatas[0].denom
                let gasRate = baseFeeDatas.filter { $0.denom == feeDenom }.first?.gasRate ?? NSDecimalNumber.zero
                let feeAmount = NSDecimalNumber(string: gasLimit).multiplying(by: gasRate, withBehavior: handler0Up)
//                print("gasLimit ", gasLimit)
//                print("feeDenom ", feeDenom)
//                print("gasRate ", gasRate)
//                print("feeAmount ", feeAmount.stringValue)
                targetDocs!["fee"]["amount"] = [["amount": feeAmount.stringValue, "denom": feeDenom]]
                targetDocs!["fee"]["gas"].stringValue = gasLimit
            }
            
            txFee = setFeeData(targetDocs!["fee"]["gas"].stringValue,
                                     targetDocs!["fee"]["amount"][0]["denom"].stringValue, 
                                     targetDocs!["fee"]["amount"][0]["amount"].stringValue)
            
            
        } else if (method == "cos_signDirect" || method == "cosmos_signDirect") {
            if (requestToSign?["params"]["doc"].isEmpty == false) {
                targetDocs = requestToSign?["params"]["doc"]
            } else if (requestToSign?["params"]["signDoc"].isEmpty == false) {
                targetDocs = requestToSign?["params"]["signDoc"]
            }
            print("targetDocs ", targetDocs)
            if (targetDocs == nil) { return }
            
            let chainId = targetDocs!["chain_id"].stringValue
            print("chainId ", chainId)
            
            targetChain = allChains.filter({ $0.chainIdCosmos == chainId }).first
            print("targetChain", targetChain)
            if (targetChain == nil) { return }
            
            
            if (requestToSign?["isEditFee"] == false || requestToSign?["params"]["isEditFee"] == false) {
                isEditFee = false
            }
            print("isEditFee ", isEditFee)
            
            
            if let authInfoBase64Decoded = Data.dataFromHex(targetDocs["auth_info_bytes"].stringValue) {
                if let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
                    print("authInfo ", authInfo)
                    print("authInfo fee ", authInfo.fee)
                    txFee = authInfo.fee
                }
            }
            
        }
    }
    
    func dismissWithFail() {
        if (method == "cos_signAmino") {
            webSignDelegate?.onCancleInjection("Cancel", requestToSign!, messageId!)
            
        } else if (method == "cosmos_signAmino") {
            webSignDelegate?.onCancleWC2(wcRequest!)
        }
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        if (method == "cos_signAmino") {
            var signed = JSON()
            let sortedJsonData = try! targetDocs!.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let sig = getSignatureResponse(targetChain!.privateKey!, sortedJsonData)
            signed["pub_key"] = sig.pubKey!
            signed["signature"].stringValue = sig.signature!
            signed["signed_doc"] = targetDocs
            
            print("signed ", signed)
            print("targetDocs ", targetDocs)
            webSignDelegate?.onAcceptInjection(signed, targetDocs!, messageId!)
            
        } else if (method == "cosmos_signAmino") {
            let sortedJsonData = try? targetDocs.rawData(options: [.sortedKeys, .withoutEscapingSlashes])
            let sig = getSignatureResponse(self.targetChain.privateKey!, sortedJsonData!)
            let signature: JSON = ["signature" : sig.signature, "pub_key" : sig.pubKey]
            let response: JSON = ["signed" : targetDocs.rawValue, "signDoc" : targetDocs.rawValue, "signature" : signature.dictionaryValue]
            
            print("sig ", sig)
            print("signature ", signature)
            print("response ", response)
            webSignDelegate?.onAcceptWC2(AnyCodable(response), wcRequest!)
            
        } else if (method == "cos_signDirect") {
            var signed = JSON()
            if let chainId = targetDocs["chain_id"].rawString(),
               let bodyBase64Decoded = Data.dataFromHex(targetDocs["body_bytes"].stringValue),
               let authInfoBase64Decoded = Data.dataFromHex(targetDocs["auth_info_bytes"].stringValue),
               let bodyBytes = try? Cosmos_Tx_V1beta1_TxBody.init(serializedData: bodyBase64Decoded),
               let authInfo = try? Cosmos_Tx_V1beta1_AuthInfo.init(serializedData: authInfoBase64Decoded) {
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
                webSignDelegate?.onAcceptInjection(signed, targetDocs!, messageId!)
            }
            
        } else if (method == "cosmos_signDirect") {
            if let chainId = targetDocs["chainId"].rawString(),
               let bodyString = targetDocs["bodyBytes"].rawString(),
               let authInfoString = targetDocs["authInfoBytes"].rawString(),
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
    
    private func getSignatureResponse(_ privateKey: Data, _ signData: Data) -> (signature: String?, pubKey: JSON?) {
        var result: (String?, JSON?)
        var sig: Data?
        var pubkey: JSON?
        var type: String?
        if (targetChain.accountKeyType.pubkeyType == .INJECTIVE_Secp256k1) {
            sig = SECP256K1.compactsign(signData.sha3(.keccak256), privateKey: privateKey)!
            type = INJECTIVE_KEY_TYPE_PUBLIC
            
        } else if (targetChain.accountKeyType.pubkeyType == .ETH_Keccak256) {
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
//                onSimul()
            }
        }
    }
    
    func onSimul() {
//        if (toCoin == nil) { return }
//        view.isUserInteractionEnabled = false
//        unStakeBtn.isEnabled = false
//        loadingView.isHidden = false
//        
//        toUndelegate = Cosmos_Staking_V1beta1_MsgUndelegate.with {
//            $0.delegatorAddress = selectedChain.bechAddress!
//            $0.validatorAddress = fromValidator!.operatorAddress
//            $0.amount = toCoin!
//        }
//        if (selectedChain.isGasSimulable() == false) {
//            return onUpdateWithSimul(nil)
//        }
        
        Task {
//            do {
//                let account = try await grpcFetcher.fetchAuth()
//                let simulReq = Signer.genUndelegateSimul(account!, toUndelegate, txFee, txMemo, selectedChain)
//                let simulRes = try await grpcFetcher.simulateTx(simulReq)
//                DispatchQueue.main.async {
//                    self.onUpdateWithSimul(simulRes)
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    self.view.isUserInteractionEnabled = true
//                    self.loadingView.isHidden = true
//                    self.onShowToast("Error : " + "\n" + "\(error)")
//                    return
//                }
//            }
        }
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
