//
//  DappBtcSignRequestSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 1/13/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON

class DappBtcSignRequestSheet: BaseVC {
    
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
    var toSign: JSON!
    var messageId: JSON!
    var selectedChain: BaseChain!

    var toAddress: String = ""
    var amount: NSDecimalNumber = 0
    
    var btcTxFee: UInt64?
    var txHex: String?
    var txId: String?
    
    var utxos: [JSON]?
    
    var inOutputs: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("tx_loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        confirmBtn.isEnabled = false
        
        if method == "bit_sendBitcoin" {
            toAddress = toSign["to"].stringValue
            amount = NSDecimalNumber(integerLiteral: toSign["satAmount"].intValue)
            onInitFeeView()
            
        } else if method == "bit_signMessage" {
            onSuccessInitView()
            
        } else if method == "bit_signPsbt" {
            let network = self.selectedChain.isTestnet ? "testnet" : "mainnet"
            inOutputs = BtcJS.shared.callJSValue(key: "getInOutPuts", param: [toSign.stringValue, network])
            onInitFeeView()

        }
            
        
    }
    
    override func setLocalizedString() {
        if method == "bit_sendBitcoin" || method == "bit_signPsbt" {
            requestTitle.text = NSLocalizedString("str_tx_request", comment: "")
            
        } else if method == "bit_signMessage" {
            requestTitle.text = NSLocalizedString("str_permit_request", comment: "")
            
        }
        
        warnMsgLabel.text = NSLocalizedString("str_dapp_warn_msg", comment: "")
        safeMsgTitle.text = NSLocalizedString("str_affect_safe", comment: "")
        dangerMsgTitle.text = NSLocalizedString("str_affect_danger", comment: "")
    }
    
    func onSuccessInitView() {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false
        confirmBtn.isEnabled = true
        
        if (method == "bit_sendBitcoin") {
            toSignTextView.text = "To: " + toAddress + "\n\nAmount: " + amount.multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8)).stringValue
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false
            
        } else if (method == "bit_signMessage") {
            toSignTextView.text = toSign["message"].stringValue
            safeMsgTitle.isHidden = false
            
        } else if method == "bit_signPsbt" {
            
            if let data = inOutputs?.data(using: .utf8) {
                let json = try? JSON(data: data)
                
                if let prettyString = json?.rawString(options: .prettyPrinted) {
                    toSignTextView.text = prettyString
                }
            }
            
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false

        }
    }
    
    func onFailInitView(_ error: String) {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        controlStakView.isHidden = true
        barView.isHidden = false
        confirmBtn.isEnabled = false
        errorCardView.isHidden = false
        
        if (method == "bit_sendBitcoin") {
            toSignTextView.text = "To: " + toAddress + "\n\nAmount: " + amount.multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8)).stringValue
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false
            
        } else if method == "bit_signPsbt" {
            
            if let data = inOutputs?.data(using: .utf8) {
                let json = try? JSON(data: data)
                
                if let prettyString = json?.rawString(options: .prettyPrinted) {
                    toSignTextView.text = prettyString
                }
            }
            
            dangerMsgTitle.isHidden = false
            feeCardView.isHidden = false
        }
        
        errorMsgLabel.text = error
    }

    func onInitFeeView() {
        Task {
            feeDenomLabel.text = selectedChain.coinSymbol
            feeLabel.text = selectedChain.coinSymbol
            do {
                try await onUpdateFeeView()
                try checkValidate()
                onSuccessInitView()
                
            } catch {
                if let error = (error as? DappBtcSignError) {
                    onFailInitView(error.errorDescription)
                } else {
                    onFailInitView(error.localizedDescription)
                }
            }
        }
    }
    
    func onUpdateFeeView() async throws {
        if method == "bit_sendBitcoin" {
            try await getFee()
            let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
            let feeAmount = NSDecimalNumber.init(value: btcTxFee!).multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8))
            let feeValue = feePrice.multiplying(by: feeAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 8)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
            try await getTxHex()
            
        } else if method == "bit_signPsbt" {
            try await getFee()
            let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
            let feeAmount = NSDecimalNumber.init(value: btcTxFee!).multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8))
            let feeValue = feePrice.multiplying(by: feeAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 8)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        }
    }

    func checkValidate() throws {
        
        var allValue = 0
        
        utxos!.forEach { utxo in
            allValue += utxo["value"].intValue
        }
                
        if method == "bit_sendBitcoin" {
            if allValue < (amount.uint64Value + btcTxFee!) {
                throw DappBtcSignError.notEnoughBalance
            }
            
        } else if method == "bit_signPsbt" {
            if inOutputs == "undefined" {
                throw DappBtcSignError.failLoadData
            }
        }
    }
    
    func getFee() async throws {
        guard let btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher() else { return }
        
        if let utxos = try await btcFetcher.fetchUtxos()?.filter({ $0["status"]["confirmed"].boolValue }) {
            
            self.utxos = utxos
            
            let type = BtcTxType.init(rawValue: selectedChain.accountKeyType.pubkeyType.algorhythm!)!
            
            let vbyte = (type.vbyte.overhead) + (type.vbyte.inputs * utxos.count) + (type.vbyte.output * 2)
            
            let estimatesmartfee = try await btcFetcher.fetchEstimatesmartfee()
            if let _ = estimatesmartfee["error"]["message"].string {
                self.btcTxFee = 0
                throw DappBtcSignError.invalidFee
            }
            
            let feeRate = estimatesmartfee["result"]["feerate"].doubleValue
            
            let fee = UInt64(ceil(Double(vbyte) * feeRate * 100000))
            
            self.btcTxFee = fee
            
            
        } else {
            throw DappBtcSignError.invalidFee
        }
        
    }
    
    func getTxHex() async throws {
        guard let btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher() else { return }
        
        let txString = await btcFetcher.getTxString(utxos!, selectedChain, toAddress, amount, btcTxFee!, nil)
        txHex = BtcJS.shared.getTxHex(txString)
        
        if txHex == "undefined" {
            throw DappBtcSignError.invalidTxHex
            
        }
        
    }
    
    func dismissWithFail() {
        webSignDelegate?.onCancleInjection("Cancel", toSign, messageId)
        dismiss(animated: true)
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        dismissWithFail()
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        
        if method == "bit_sendBitcoin" {
            Task {
                guard let btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher(),
                      let txHex else { return }
                do {
                    let result = try await btcFetcher.sendRawtransaction(txHex)
                    
                    
                    if !result["error"]["message"].stringValue.isEmpty {
                        dismissWithFail()
                        
                    } else {
                        txId = result["result"].stringValue
                        webSignDelegate?.onAcceptInjection(JSON(txId!), toSign, messageId)
                    }
                    
                } catch {
                    dismissWithFail()
                }
            }
            
        } else if (method == "bit_signMessage") {
            var result = ""
            
            if toSign["type"].stringValue == "ecdsa" {
                let message = toSign["message"].stringValue
                result = BtcJS.shared.callJSValue(key: "signMessageECDSA", param: [message, selectedChain.privateKey?.toHexString()])
                
            } else if toSign["type"].stringValue == "bip322-simple" {
                let message = toSign["message"].stringValue
                result = BtcJS.shared.callJSValue(key:"signMessageBIP322", param: [message, selectedChain.privateKey?.toHexString(), selectedChain.mainAddress])
            }
                        
            if result == "undefined" {
                dismissWithFail()
                return
            }
            
            webSignDelegate?.onAcceptInjection(JSON(result), toSign, messageId)

        } else if method == "bit_signPsbt" {
            let psbtValidate = BtcJS.shared.callJSValue(key: "formatPsbtHex", param: [toSign.stringValue])
            
            if psbtValidate == "undefined" {
                dismissWithFail()
                return
                
            } else {
                let network = self.selectedChain.isTestnet ? "testnet" : "mainnet"
                let hex = BtcJS.shared.callJSValue(key: "signPsbt", param: [toSign.stringValue, selectedChain.privateKey?.toHexString(), network])

                if hex == "undefined" {
                    dismissWithFail()
                    return
                }
                webSignDelegate?.onAcceptInjection(JSON(hex), toSign, messageId)
            }
        }
        
        dismiss(animated: true)
    }
    
    
    enum DappBtcSignError: String, LocalizedError {
        case invalidTxHex = "tx hex value is invalid"
        case invalidFee = "Failed to get fee value"
        case notEnoughBalance = "Not enough balance"
        case failLoadData = "Failed to load data"
        
        var errorDescription: String {
            switch self {
            case .invalidTxHex:
                return self.rawValue
            case .invalidFee:
                return self.rawValue
            case .notEnoughBalance:
                return self.rawValue
            case .failLoadData:
                return self.rawValue
            }
        }
    }
}
