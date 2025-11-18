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
    @IBOutlet weak var changeBodyCardView: FixCardView!
    @IBOutlet weak var changeToSignTextView: UITextView!

    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeImg: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var balanceChangeCardView: FixCardView!
    @IBOutlet weak var expectedChangedMsgLabel: UILabel!
    @IBOutlet weak var expectedAmountLabel: UILabel!
    @IBOutlet weak var expectedDenomLabel: UILabel!
    @IBOutlet weak var expectedCurrencyLabel: UILabel!
    @IBOutlet weak var expectedValueLabel: UILabel!
    @IBOutlet weak var changedFeeAmountLabel: UILabel!
    @IBOutlet weak var changedFeeDenomLabel: UILabel!
    @IBOutlet weak var changedFeeCurrencyLabel: UILabel!
    @IBOutlet weak var changedFeeValueLabel: UILabel!
    
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
    // sign message
    var signature: String!
    // signTransactions
    var allTransactions = [String]()
    
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
        expectedChangedMsgLabel.text = NSLocalizedString("str_solana_expected_msg", comment: "")
    }
    
    func paringRequest() {
        guard let solanaFetcher = (selectedChain as? ChainSolana)?.getSolanaFetcher() else { return }
        
        Task {
            if method == "solana_signMessage" {
                do {
                    if let parseMessage = try await solanaFetcher.parseMessage(requestToSign!),
                       let signMessage = try await solanaFetcher.signMessage(requestToSign!) {
                        let serializedSignMessageJsonData = try JSON(data: Data(signMessage.utf8))
                        
                        data = serializedSignMessageJsonData["publicKey"].stringValue
                        signature = serializedSignMessageJsonData["signature"].stringValue
                        
                        DispatchQueue.main.async {
                            self.onUpdateView()
                            self.toSignTextView.text = parseMessage
                            self.safeMsgTitle.isHidden = false
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.dismissWithFail()
                    }
                }
                
            } else if method == "solana_signAndSendTransaction" {
                do {
                    if let serializedTx = requestToSign?["serializedTx"].stringValue,
                       let parseInstruction = try await solanaFetcher.parseInstructionsFromTx(serializedTx),
                       let accounts = try await solanaFetcher.accountsToTrack(serializedTx),
                       let serializedTxMessage = try await solanaFetcher.serializedTxMessageFromTx(serializedTx),
                       let feeForMessage = try await solanaFetcher.fetchFeeMessage(serializedTxMessage),
                       let signTransaction = try await solanaFetcher.signTransaction(serializedTx) {
                        
                        let displayJson = JSON(parseInstruction.data(using: .utf8) ?? "")
                        let baseFee = feeForMessage["result"]["value"].uInt64Value
                        data = signTransaction
                        
                        if !accounts.isEmpty {
                            let accountList = try JSONDecoder().decode([String].self, from: Data(accounts.utf8))
                            let simulateValue = try await solanaFetcher.simulateValue(serializedTx, accountList)
                            
                            if simulateValue["err"].type == .null {
                                let multiAccountsValue = try await solanaFetcher.multiAccountsValue(accountList)
                                let changesData = try await solanaFetcher.analyzeTokenChanges(accounts, JSON(multiAccountsValue).rawString(), simulateValue.rawString())
                                let parsingChangesData = JSON(parseJSON: changesData ?? "").arrayValue
                                if parsingChangesData.count > 0 {
                                    let solChangeAmount = parsingChangesData[0]["amount"].doubleValue
                                    
                                    DispatchQueue.main.async {
                                        self.dangerMsgTitle.isHidden = false
                                        self.feeCardView.isHidden = true
                                        self.balanceChangeCardView.isHidden = false
                                        self.onUpdateChangeView(NSDecimalNumber(value: solChangeAmount), NSDecimalNumber(value: baseFee))
                                        self.changeToSignTextView.text = "\(displayJson)"
                                        self.warnMsgLabel.isHidden = false
                                    }
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.dangerMsgTitle.isHidden = false
                                    self.feeCardView.isHidden = false
                                    self.balanceChangeCardView.isHidden = true
                                    self.onUpdateView(NSDecimalNumber(value: baseFee))
                                    self.toSignTextView.text = "\(displayJson)"
                                    self.warnMsgLabel.isHidden = false
                                }
                            }
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.dismissWithFail()
                    }
                }
                
            } else if method == "solana_signTransaction" || method == "solana_signAllTransactions" {
                var parsingResult = [String]()
                var dataResult = [String]()
                var displayJson = ""
                var totalFee: UInt64 = 0
                var totalExpectedSolAmount: Double = 0.0

                guard let transactions = requestToSign?.array else { return }
                do {
                    for json in transactions {
                        let serializedTx = json["serializedTx"].stringValue
                        if let parseInstruction = try await solanaFetcher.parseInstructionsFromTx(serializedTx),
                           let accounts = try await solanaFetcher.accountsToTrack(serializedTx),
                           let serializedTxMessage = try await solanaFetcher.serializedTxMessageFromTx(serializedTx),
                           let feeForMessage = try await solanaFetcher.fetchFeeMessage(serializedTxMessage),
                           let signTransaction = try await solanaFetcher.signTransaction(serializedTx) {
                            
                            parsingResult.append(String(describing: parseInstruction))
                            if parsingResult.count > 1 {
                                displayJson = joinedTransactions(parsingResult)
                            } else {
                                displayJson = "\(JSON(parseInstruction.data(using: .utf8) ?? ""))"
                            }
                            dataResult.append(String(describing: signTransaction))
                            let baseFee = feeForMessage["result"]["value"].uInt64Value
                            totalFee &+= baseFee
                            
                            if !accounts.isEmpty {
                                let accountList = try JSONDecoder().decode([String].self, from: Data(accounts.utf8))
                                let simulateValue = try await solanaFetcher.simulateValue(serializedTx, accountList)
                                
                                if simulateValue["err"].type == .null {
                                    let multiAccountsValue = try await solanaFetcher.multiAccountsValue(accountList)
                                    let changesData = try await solanaFetcher.analyzeTokenChanges(accounts, JSON(multiAccountsValue).rawString(), simulateValue.rawString())
                                    let parsingChangesData = JSON(parseJSON: changesData ?? "").arrayValue
                                    if parsingChangesData.count > 0 {
                                        let solChangeAmount = parsingChangesData[0]["amount"].doubleValue
                                        totalExpectedSolAmount += solChangeAmount
                                    }
                                }
                            }
                        }
                    }
                    allTransactions = dataResult
                    
                    DispatchQueue.main.async {
                        if NSDecimalNumber(value: totalExpectedSolAmount).abs.compare(NSDecimalNumber.zero).rawValue > 0 {
                            DispatchQueue.main.async {
                                self.dangerMsgTitle.isHidden = false
                                self.feeCardView.isHidden = true
                                self.balanceChangeCardView.isHidden = false
                                self.onUpdateChangeView(NSDecimalNumber(value: totalExpectedSolAmount), NSDecimalNumber(value: totalFee))
                                self.changeToSignTextView.text = displayJson
                                self.warnMsgLabel.isHidden = false
                            }
                            
                        } else {
                            self.dangerMsgTitle.isHidden = false
                            self.feeCardView.isHidden = false
                            self.balanceChangeCardView.isHidden = true
                            self.onUpdateView(NSDecimalNumber(value: totalFee))
                            self.toSignTextView.text = displayJson
                            self.warnMsgLabel.isHidden = false
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.dismissWithFail()
                    }
                }
            }
        }
    }
    
    func onUpdateView(_ fee: NSDecimalNumber? = NSDecimalNumber.zero) {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = false
        changeBodyCardView.isHidden = true
        controlStakView.isHidden = false
        barView.isHidden = false
        confirmBtn.isEnabled = true
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.gasAssetDenom()) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeDpBudge = fee?.multiplying(byPowerOf10: -(msAsset.decimals ?? 9), withBehavior: getDivideHandler(msAsset.decimals ?? 9)) ?? NSDecimalNumber.zero
        let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
        feeLabel.text = selectedChain.gasAssetDenom()?.uppercased()
        WDP.dpCoin(msAsset, fee ?? NSDecimalNumber.zero, feeImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    func onUpdateChangeView(_ solAmount: NSDecimalNumber? = NSDecimalNumber.zero, _ fee: NSDecimalNumber? = NSDecimalNumber.zero) {
        loadingView.isHidden = true
        requestTitle.isHidden = false
        warnMsgLabel.isHidden = false
        bodyCardView.isHidden = true
        changeBodyCardView.isHidden = false
        controlStakView.isHidden = false
        barView.isHidden = false
        confirmBtn.isEnabled = true
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.gasAssetDenom()) else { return }
        let price = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeDpBudge = fee?.multiplying(byPowerOf10: -(msAsset.decimals ?? 9), withBehavior: getDivideHandler(msAsset.decimals ?? 9)) ?? NSDecimalNumber.zero
        let solValue = price.multiplying(by: solAmount ?? NSDecimalNumber.zero, withBehavior: getDivideHandler(msAsset.decimals ?? 9)).abs
        let feeValue = price.multiplying(by: feeDpBudge, withBehavior: handler6)
        
        expectedAmountLabel?.attributedText = dpAmount(solAmount?.stringValue, self.expectedAmountLabel!.font, msAsset.decimals)
        expectedDenomLabel.text = msAsset.symbol
        WDP.dpValue(solValue, expectedCurrencyLabel, expectedValueLabel)
        changedFeeAmountLabel?.attributedText = WDP.dpAmount(feeDpBudge.stringValue, self.changedFeeAmountLabel!.font, msAsset.decimals)
        changedFeeDenomLabel.text = msAsset.symbol
        WDP.dpValue(feeValue, changedFeeCurrencyLabel, changedFeeValueLabel)
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
            
        } else if method == "solana_signAndSendTransaction" {
            guard let solanaFetcher = (selectedChain as? ChainSolana)?.getSolanaFetcher() else { return }
            Task {
                if let sendTransaction = try await solanaFetcher.fetchDappSendTransaction(data, requestToSign) {
                    if sendTransaction["error"].exists() {
                        webSignDelegate?.onCancleInjection("Fail Solana Tx Request", requestToSign!, messageId!)
                        
                    } else {
                        let data: JSON = ["publicKey": selectedChain.mainAddress, "signature": sendTransaction["result"].stringValue]
                        webSignDelegate?.onAcceptInjection(data, requestToSign!, messageId!)
                    }
                    
                } else {
                    webSignDelegate?.onCancleInjection("Fail Solana Tx Request", requestToSign!, messageId!)
                }
            }
            
        } else if method == "solana_signTransaction" || method == "solana_signAllTransactions" {
            webSignDelegate?.onAcceptInjection(JSON(allTransactions), requestToSign!, messageId!)
        }
        
        dismiss(animated: true)
    }
}

extension DappSolanaSignRequestSheet {
    
    func joinedTransactions(_ parsingResult: [String]) -> String {
        var out = ""
        for (idx, raw) in parsingResult.enumerated() {
            if idx > 0 { out += "\n\n" }
            out += "Transaction #\(idx + 1)\n"

            if let data = raw.data(using: .utf8),
               let json = try? JSON(data: data),
               let pretty = json.rawString(options: [.prettyPrinted]) {
                out += pretty + "\n"
            } else {
                out += raw + "\n"
            }
        }
        return out
    }
    
    func dpAmount(_ amount: String?,
                  _ font: UIFont,
                  _ showDecimal: Int16? = 6) -> NSMutableAttributedString {
        let decimals = max(0, Int(showDecimal ?? 6))

        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = true
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = decimals
        nf.maximumFractionDigits = decimals
        nf.roundingMode = .down

        let num = NSDecimalNumber(string: (amount?.isEmpty == false) ? amount : "0")
        let safeNumber: NSDecimalNumber = (num == NSDecimalNumber.notANumber) ? .zero : num

        let formatted = nf.string(from: safeNumber) ?? (decimals == 0 ? "0" : "0." + String(repeating: "0", count: decimals))

        let result = NSMutableAttributedString()

        if decimals > 0 {
            let splitIndex = formatted.index(formatted.endIndex, offsetBy: -decimals)
            let pre = String(formatted[..<splitIndex])
            let post = String(formatted[splitIndex...])

            let preAttrs: [NSAttributedString.Key: Any]  = [.font: font]
            let postAttrs: [NSAttributedString.Key: Any] = [.font: font.withSize(CGFloat(Double(font.pointSize) * 0.85))]

            result.append(NSAttributedString(string: pre, attributes: preAttrs))
            result.append(NSAttributedString(string: post, attributes: postAttrs))
        } else {
            result.append(NSAttributedString(string: formatted, attributes: [.font: font]))
        }

        return result
    }
}

extension NSDecimalNumber {
    var abs: NSDecimalNumber {
        if self.compare(NSDecimalNumber.zero) == .orderedAscending {
            return self.multiplying(by: NSDecimalNumber(value: -1))
        } else {
            return self
        }
    }
}
