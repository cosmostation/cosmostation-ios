//
//  LegacyTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire
import AlamofireImage
import web3swift

class LegacyTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var toSendAssetCard: FixCardView!
    @IBOutlet weak var toSendAssetTitle: UILabel!
    @IBOutlet weak var toSendAssetImg: UIImageView!
    @IBOutlet weak var toSendSymbolLabel: UILabel!
    @IBOutlet weak var toSendAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var toSendDenom: String!
    var stakeDenom: String!
    var availableAmount = NSDecimalNumber.zero
    var toSendAmount = NSDecimalNumber.zero
    var recipientAddress: String?
    var txMemo = ""
    
    var tokenInfo: JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        stakeDenom = selectedChain.stakeDenom
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        //display to send asset info
        if let oktFetcher = selectedChain.getLcdfetcher() as? OktFetcher {
            tokenInfo = oktFetcher.lcdOktTokens.filter({ $0["symbol"].string == toSendDenom }).first!
            let original_symbol = tokenInfo["original_symbol"].stringValue
            toSendAssetImg.af.setImage(withURL: ChainOktEVM.assetImg(original_symbol))
            toSendSymbolLabel.text = original_symbol.uppercased()
            
            let available = oktFetcher.lcdBalanceAmount(toSendDenom)
            if (toSendDenom == stakeDenom) {
                availableAmount = available.subtracting(NSDecimalNumber(string: OKT_BASE_FEE))
            } else {
                availableAmount = available
            }
        }
        
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_transfer_asset", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 600
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
        qrScanVC.scanDelegate = self
        present(qrScanVC, animated: true)
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountLegacySheet(nibName: "TxAmountLegacySheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.tokenInfo = tokenInfo
        amountSheet.availableAmount = availableAmount
        if (toSendAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toSendAmount
        }
        amountSheet.sheetDelegate = self
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        toSendAssetHint.isHidden = false
        toAssetAmountLabel.isHidden = true
        toAssetDenomLabel.isHidden = true
        toAssetCurrencyLabel.isHidden = true
        toAssetValueLabel.isHidden = true
        
        if (amount?.isEmpty == true) {
            toSendAmount = NSDecimalNumber.zero
            
        } else {
            toSendAmount = NSDecimalNumber(string: amount)
            
            if (selectedChain.name == "OKT") {
                toAssetDenomLabel.text = tokenInfo["original_symbol"].stringValue.uppercased()
                toAssetAmountLabel?.attributedText = WDP.dpAmount(toSendAmount.stringValue, toAssetAmountLabel!.font, 18)
                toSendAssetHint.isHidden = true
                toAssetAmountLabel.isHidden = false
                toAssetDenomLabel.isHidden = false
                
                if (toSendDenom == stakeDenom) {
                    let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID)
                    let toSendValue = msPrice.multiplying(by: toSendAmount, withBehavior: handler6)
                    WDP.dpValue(toSendValue, toAssetCurrencyLabel, toAssetValueLabel)
                    toAssetCurrencyLabel.isHidden = false
                    toAssetValueLabel.isHidden = false
                }
            }
        }
        onValidate()
    }
    
    
    @objc func onClickToAddress() {
        let addressSheet = TxAddressLegacySheet(nibName: "TxAddressLegacySheet", bundle: nil)
        addressSheet.selectedChain = selectedChain
        addressSheet.existedAddress = recipientAddress
        addressSheet.addressLegacySheetType = .SelectAddress_CosmosLegacySend
        addressSheet.addressLegacyDelegate = self
        onStartSheet(addressSheet, 220, 0.6)
    }
    
    func onUpdateToAddressView(_ address: String) {
        if (address.isEmpty == true) {
            recipientAddress = ""
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
            
        } else {
            recipientAddress = address
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = recipientAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
        }
        onValidate()
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        onStartSheet(memoSheet, 260, 0.6)
    }
    
    func onUpdateMemoView(_ memo: String) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.isHidden = true
            memoHintLabel.isHidden = false
        } else {
            memoLabel.text = txMemo
            memoLabel.isHidden = false
            memoHintLabel.isHidden = true
        }
    }
    
    func onUpdateFeeView() {
        if (selectedChain.name == "OKT") {
            feeSelectImg.af.setImage(withURL: ChainOktEVM.assetImg(stakeDenom))
            feeSelectLabel.text = stakeDenom.uppercased()
            
            let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID)
            let feeAmount = NSDecimalNumber(string: OKT_BASE_FEE)
            let feeValue = msPrice.multiplying(by: feeAmount, withBehavior: handler6)
            feeAmountLabel?.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 18)
            feeDenomLabel.text = stakeDenom.uppercased()
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onValidate() {
        sendBtn.isEnabled = false
        if (toSendAmount == NSDecimalNumber.zero ) { return }
        if (recipientAddress?.isEmpty == true) { return }
        if (txMemo.count > 300) { return }
        sendBtn.isEnabled = true
    }
}


extension LegacyTransfer: LegacyAmountSheetDelegate, AddressLegacyDelegate, MemoDelegate , QrScanDelegate, PinDelegate {
    
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        onUpdateToAddressView(address)
        if let cMemo = memo {
            onUpdateMemoView(cMemo)
        }
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onScanned(_ result: String) {
        let scanedString = result.components(separatedBy: "(MEMO)")
        var addressScan = ""
        var memoScan = ""
        if (scanedString.count == 2) {
            addressScan = scanedString[0].trimmingCharacters(in: .whitespaces)
            memoScan = scanedString[1].trimmingCharacters(in: .whitespaces)
        } else {
            addressScan = scanedString[0].trimmingCharacters(in: .whitespaces)
        }
        
        if (addressScan.isEmpty == true || addressScan.count < 5) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        if (addressScan == selectedChain.bechAddress || addressScan == selectedChain.evmAddress) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (WUtils.isValidBechAddress(selectedChain, addressScan)) {
            if (scanedString.count > 1) {
                onUpdateMemoView(memoScan)
            }
            onUpdateToAddressView(addressScan)
            return
        }
        self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
                    if let response = try? await broadcastOktSendTx() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.legacyResult = response
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                            
                        });
                    }
                }
            }
        }
    }
}

extension LegacyTransfer {
    
    //only for okt legacy lcd
    func broadcastOktSendTx() async throws -> JSON? {
        let sendCoin = L_Coin(toSendDenom, WUtils.getFormattedNumber(toSendAmount, 18))
        let gasCoin = L_Coin(stakeDenom, WUtils.getFormattedNumber(NSDecimalNumber(string: OKT_BASE_FEE), 18))
        let fee = L_Fee(BASE_GAS_AMOUNT, [gasCoin])
        
        let okMsg = L_Generator.oktSendMsg(selectedChain.bechAddress!, recipientAddress!, [sendCoin])
        let postData = L_Generator.postData([okMsg], fee, txMemo, selectedChain)
        let param = try! JSONSerialization.jsonObject(with: postData, options: .allowFragments) as? [String: Any]
        
        let url = OKT_LCD + "txs"
        return try? await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
    
}
