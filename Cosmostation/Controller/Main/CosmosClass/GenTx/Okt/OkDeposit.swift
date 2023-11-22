//
//  OkDeposit.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire
import AlamofireImage

class OkDeposit: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toDepositAssetCard: FixCardView!
    @IBOutlet weak var toDepositAssetTitle: UILabel!
    @IBOutlet weak var toDepositAssetImg: UIImageView!
    @IBOutlet weak var toDepositSymbolLabel: UILabel!
    @IBOutlet weak var toDepositAssetHint: UILabel!
    @IBOutlet weak var toDepositAmountLabel: UILabel!
    @IBOutlet weak var toDepositDenomLabel: UILabel!
    @IBOutlet weak var toDepositCurrencyLabel: UILabel!
    @IBOutlet weak var toDepositValueLabel: UILabel!
    
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
    
    @IBOutlet weak var depositBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: CosmosClass!
    var stakeDenom: String!
    var tokenInfo: JSON!
    var availableAmount = NSDecimalNumber.zero
    var toDepositAmount = NSDecimalNumber.zero
    var txMemo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        stakeDenom = selectedChain.stakeDenom
        
        if let okChain = selectedChain as? ChainOkt60Keccak {
            tokenInfo = okChain.lcdOktTokens.filter({ $0["symbol"].string == stakeDenom }).first!
            let original_symbol = tokenInfo["original_symbol"].stringValue
            toDepositAssetImg.af.setImage(withURL: ChainOkt60Keccak.assetImg(original_symbol))
            toDepositSymbolLabel.text = original_symbol.uppercased()
            
            let available = okChain.lcdBalanceAmount(stakeDenom)
            availableAmount = available.subtracting(NSDecimalNumber(string: OKT_BASE_FEE))
        }
        
        toDepositAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_deposit", comment: "")
        toDepositAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        depositBtn.setTitle(NSLocalizedString("str_deposit", comment: ""), for: .normal)
    }

    @objc func onClickAmount() {
        let amountSheet = TxAmountLegacySheet(nibName: "TxAmountLegacySheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.tokenInfo = tokenInfo
        amountSheet.availableAmount = availableAmount
        if (toDepositAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toDepositAmount
        }
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        toDepositAssetHint.isHidden = false
        toDepositAmountLabel.isHidden = true
        toDepositDenomLabel.isHidden = true
        toDepositCurrencyLabel.isHidden = true
        toDepositValueLabel.isHidden = true
        
        if (amount?.isEmpty == true) {
            toDepositAmount = NSDecimalNumber.zero
            
        } else {
            toDepositAmount = NSDecimalNumber(string: amount)
            toDepositDenomLabel.text = tokenInfo["original_symbol"].stringValue.uppercased()
            toDepositAmountLabel?.attributedText = WDP.dpAmount(toDepositAmount.stringValue, toDepositAmountLabel!.font, 18)
            toDepositAssetHint.isHidden = true
            toDepositAmountLabel.isHidden = false
            toDepositDenomLabel.isHidden = false
            
            let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID)
            let toSendValue = msPrice.multiplying(by: toDepositAmount, withBehavior: handler6)
            WDP.dpValue(toSendValue, toDepositCurrencyLabel, toDepositValueLabel)
            toDepositCurrencyLabel.isHidden = false
            toDepositValueLabel.isHidden = false
            
        }
        onValidate()
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet, 260)
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
        feeSelectImg.af.setImage(withURL: ChainOkt60Keccak.assetImg(stakeDenom))
        feeSelectLabel.text = stakeDenom.uppercased()
        
        let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID)
        let feeAmount = NSDecimalNumber(string: OKT_BASE_FEE)
        let feeValue = msPrice.multiplying(by: feeAmount, withBehavior: handler6)
        feeAmountLabel?.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 18)
        feeDenomLabel.text = stakeDenom.uppercased()
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    @IBAction func onClickDeposit(_ sender: UIButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onValidate() {
        depositBtn.isEnabled = false
        if (toDepositAmount == NSDecimalNumber.zero ) { return }
        if (txMemo.count > 300) { return }
        depositBtn.isEnabled = true
    }
    
}

extension OkDeposit: LegacyAmountSheetDelegate, MemoDelegate, PinDelegate {
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            depositBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                if let response = try? await broadcastOktDepositTx() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        print("response ", response)
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

extension OkDeposit {
    
    func broadcastOktDepositTx() async throws -> JSON? {
        
        let depositCoin = L_Coin(stakeDenom, WUtils.getFormattedNumber(toDepositAmount, 18))
        let gasCoin = L_Coin(stakeDenom, WUtils.getFormattedNumber(NSDecimalNumber(string: OKT_BASE_FEE), 18))
        let fee = L_Fee(BASE_GAS_AMOUNT, [gasCoin])
        
        let okMsg = L_Generator.oktDepositMsg(selectedChain.bechAddress, depositCoin)
        let postData = L_Generator.postData([okMsg], fee, txMemo, selectedChain)
        let param = try! JSONSerialization.jsonObject(with: postData, options: .allowFragments) as? [String: Any]
        
        return try? await AF.request(BaseNetWork.broadcastUrl(self.selectedChain), method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
}
