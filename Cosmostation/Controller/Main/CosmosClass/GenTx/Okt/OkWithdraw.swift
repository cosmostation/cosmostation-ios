//
//  OkWithdraw.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire
import SDWebImage

class OkWithdraw: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toWithdrawAssetCard: FixCardView!
    @IBOutlet weak var toWithdrawAssetTitle: UILabel!
    @IBOutlet weak var toWithdrawAssetImg: UIImageView!
    @IBOutlet weak var toWithdrawSymbolLabel: UILabel!
    @IBOutlet weak var toWithdrawAssetHint: UILabel!
    @IBOutlet weak var toWithdrawAmountLabel: UILabel!
    @IBOutlet weak var toWithdrawDenomLabel: UILabel!
    @IBOutlet weak var toWithdrawCurrencyLabel: UILabel!
    @IBOutlet weak var toWithdrawValueLabel: UILabel!
    
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
    
    @IBOutlet weak var withdrawBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainOktEVM!
    var oktFetcher: OktFetcher!
    var stakeDenom: String!
    var msAsset: MintscanAsset!
    var availableAmount = NSDecimalNumber.zero
    var toWithdrawAmount = NSDecimalNumber.zero
    var txMemo = ""
    
    var gasAmount = NSDecimalNumber(string: BASE_GAS_AMOUNT)
    var gasFee = NSDecimalNumber(string: OKT_BASE_FEE)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        oktFetcher = selectedChain.getOktfetcher()
        stakeDenom = selectedChain.stakeDenom
        msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom)
        
        toWithdrawAssetImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        toWithdrawSymbolLabel.text = msAsset.symbol?.uppercased()
        availableAmount = oktFetcher.oktDepositAmount()
        
        toWithdrawAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_withdraw", comment: "")
        toWithdrawAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        withdrawBtn.setTitle(NSLocalizedString("str_withdraw", comment: ""), for: .normal)
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountLegacySheet(nibName: "TxAmountLegacySheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.tokenSymbol = msAsset.symbol?.uppercased()
        amountSheet.availableAmount = availableAmount
        if (toWithdrawAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toWithdrawAmount
        }
        amountSheet.sheetDelegate = self
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        toWithdrawAssetHint.isHidden = false
        toWithdrawAmountLabel.isHidden = true
        toWithdrawDenomLabel.isHidden = true
        toWithdrawCurrencyLabel.isHidden = true
        toWithdrawValueLabel.isHidden = true
        
        if (amount?.isEmpty == true) {
            toWithdrawAmount = NSDecimalNumber.zero
            
        } else {
            toWithdrawAmount = NSDecimalNumber(string: amount)
            toWithdrawDenomLabel.text = msAsset.symbol?.uppercased()
            toWithdrawAmountLabel?.attributedText = WDP.dpAmount(toWithdrawAmount.stringValue, toWithdrawAmountLabel!.font, 18)
            toWithdrawAssetHint.isHidden = true
            toWithdrawAmountLabel.isHidden = false
            toWithdrawDenomLabel.isHidden = false
            
            guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom ?? selectedChain.coinSymbol) else { return }
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let toSendValue = msPrice.multiplying(by: toWithdrawAmount, withBehavior: handler6)
            WDP.dpValue(toSendValue, toWithdrawCurrencyLabel, toWithdrawValueLabel)
            toWithdrawCurrencyLabel.isHidden = false
            toWithdrawValueLabel.isHidden = false
            
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
        feeSelectImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        feeSelectLabel.text = stakeDenom.uppercased()
        
        let existCnt = oktFetcher.oktDeposits["validator_address"].arrayValue.count
        
        
        gasAmount = NSDecimalNumber(string: BASE_GAS_AMOUNT)
        gasFee = NSDecimalNumber(string: OKT_BASE_FEE)
        if (existCnt > 10) {
            gasFee = gasFee.multiplying(by: NSDecimalNumber(string: "3"))
            gasAmount = gasAmount.multiplying(by: NSDecimalNumber(string: "3"))
        } else if (existCnt > 20) {
            gasFee = gasFee.multiplying(by: NSDecimalNumber(string: "4"))
            gasAmount = gasAmount.multiplying(by: NSDecimalNumber(string: "4"))
        }
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom ?? selectedChain.coinSymbol) else { return }
        let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeValue = msPrice.multiplying(by: gasFee, withBehavior: handler6)
        feeAmountLabel?.attributedText = WDP.dpAmount(gasFee.stringValue, feeAmountLabel!.font, 18)
        feeDenomLabel.text = stakeDenom.uppercased()
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }

    @IBAction func onClickWithdraw(_ sender: UIButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onValidate() {
        withdrawBtn.isEnabled = false
        if (toWithdrawAmount == NSDecimalNumber.zero ) { return }
        if (txMemo.count > 300) { return }
        withdrawBtn.isEnabled = true
    }
}

extension OkWithdraw: LegacyAmountSheetDelegate, MemoDelegate, PinDelegate {
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            withdrawBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                if let response = try? await broadcastOktWithdrawTx() {
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

extension OkWithdraw {
    
    func broadcastOktWithdrawTx() async throws -> JSON? {
        let withdrawCoin = L_Coin(stakeDenom, WUtils.getFormattedNumber(toWithdrawAmount, 18))
        let gasCoin = L_Coin(stakeDenom, WUtils.getFormattedNumber(gasFee, 18))
        let fee = L_Fee(gasAmount.stringValue, [gasCoin])
        
        let okMsg = L_Generator.oktWithdrawMsg(selectedChain.bechAddress!, withdrawCoin)
        let postData = L_Generator.postData([okMsg], fee, txMemo, selectedChain)
        let param = try! JSONSerialization.jsonObject(with: postData, options: .allowFragments) as? [String: Any]
        
        let url = oktFetcher.getLcd() + "txs"
        return try? await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
}
