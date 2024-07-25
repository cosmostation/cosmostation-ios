//
//  KavaLendAction.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf
import Kingfisher

class KavaLendAction: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toHardAssetCard: FixCardView!
    @IBOutlet weak var toHardAssetTitle: UILabel!
    @IBOutlet weak var toHardAssetImg: UIImageView!
    @IBOutlet weak var toHardSymbolLabel: UILabel!
    @IBOutlet weak var toHardAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var hardBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKavaEVM!
    var kavaFetcher: KavaFetcher!
    var feeInfos = [FeeInfo]()
    var selectedFeePosition = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var hardActionType: HardActionType!                     // to action type
    var hardMarket: Kava_Hard_V1beta1_MoneyMarket!
//    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var hardTotalBorrow: [Cosmos_Base_V1beta1_Coin]?
    var hardMyDeposit: [Cosmos_Base_V1beta1_Coin]?
    var hardMyBorrow: [Cosmos_Base_V1beta1_Coin]?
    var hardBorrowableAmount = NSDecimalNumber.zero
    
    
    var msAsset: MintscanAsset!
    var availableAmount = NSDecimalNumber.zero
    var toAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        kavaFetcher = selectedChain.getKavaFetcher()
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        feeInfos = selectedChain.getFeeInfos()
        feeSegments.removeAllSegments()
        for i in 0..<feeInfos.count {
            feeSegments.insertSegment(withTitle: feeInfos[i].title, at: i, animated: false)
        }
        selectedFeePosition = selectedChain.getFeeBasePosition()
        feeSegments.selectedSegmentIndex = selectedFeePosition
        txFee = selectedChain.getInitPayableFee()
        
        msAsset = BaseData.instance.getAsset(selectedChain.apiName, hardMarket.denom)
        toHardSymbolLabel.text = msAsset.symbol
        toHardAssetImg.kf.setImage(with: msAsset.assetImg(), placeholder: UIImage(named: "tokenDefault"))
        
        if (hardActionType == .Deposit) {
            let balanceAmount = kavaFetcher.balanceAmount(hardMarket.denom)
            if (txFee.amount[0].denom == hardMarket.denom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                availableAmount = balanceAmount.subtracting(feeAmount)
            }
            availableAmount = balanceAmount
            
        } else if (hardActionType == .Withdraw) {
            availableAmount = hardMyDeposit?.filter({ $0.denom == hardMarket.denom }).first?.getAmount() ?? NSDecimalNumber.zero
            
        } else if (hardActionType == .Borrow) {
            availableAmount = hardBorrowableAmount
            
        } else if (hardActionType == .Repay) {
            var borrowedAmount = hardMyBorrow?.filter({ $0.denom == hardMarket.denom }).first?.getAmount() ?? NSDecimalNumber.zero
            borrowedAmount = borrowedAmount.multiplying(by: NSDecimalNumber.init(string: "1.1"), withBehavior: handler0Down)
            
            var balanceAmount = kavaFetcher.balanceAmount(hardMarket.denom)
            if (txFee.amount[0].denom == hardMarket.denom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                balanceAmount = balanceAmount.subtracting(feeAmount)
            }
            availableAmount = balanceAmount.compare(borrowedAmount).rawValue > 0 ? borrowedAmount : balanceAmount
        }
        
        toHardAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        if (hardActionType == .Deposit) {
            titleLabel.text = NSLocalizedString("title_deposit_hardpool", comment: "")
            toHardAssetTitle.text = NSLocalizedString("str_deposit_amount", comment: "")
            hardBtn.setTitle(NSLocalizedString("btn_deposit", comment: ""), for: .normal)
            
        } else if (hardActionType == .Withdraw) {
            titleLabel.text = NSLocalizedString("title_withdraw_hardpool", comment: "")
            toHardAssetTitle.text = NSLocalizedString("str_withdraw_amount", comment: "")
            hardBtn.setTitle(NSLocalizedString("btn_withdraw", comment: ""), for: .normal)
            
        } else if (hardActionType == .Borrow) {
            titleLabel.text = NSLocalizedString("title_borrow_hardpool", comment: "")
            toHardAssetTitle.text = NSLocalizedString("str_borrow_amount", comment: "")
            hardBtn.setTitle(NSLocalizedString("btn_borrow", comment: ""), for: .normal)
            
        } else if (hardActionType == .Repay) {
            titleLabel.text = NSLocalizedString("title_repay_hardpool", comment: "")
            toHardAssetTitle.text = NSLocalizedString("str_repay_amount", comment: "")
            hardBtn.setTitle(NSLocalizedString("btn_repay", comment: ""), for: .normal)
            
        }
        toHardAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = msAsset
        amountSheet.availableAmount = availableAmount
        if (toAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toAmount
        }
        
        if (hardActionType == .Deposit) {
            amountSheet.sheetType = .TxHardDeposit
        } else if (hardActionType == .Withdraw) {
            amountSheet.sheetType = .TxHardWithdraw
        } else if (hardActionType == .Borrow) {
            amountSheet.sheetType = .TxHardBorrow
        } else if (hardActionType == .Repay) {
            amountSheet.sheetType = .TxHardRepay
        }
        amountSheet.sheetDelegate = self
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toAmount = NSDecimalNumber.zero
            toHardAssetHint.isHidden = false
            toAssetAmountLabel.isHidden = true
            toAssetDenomLabel.isHidden = true
            toAssetCurrencyLabel.isHidden = true
            toAssetValueLabel.isHidden = true
        } else {
            toAmount = NSDecimalNumber(string: amount)
            
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: toAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(msAsset!, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, msAsset.decimals)
            WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
            
            toHardAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
            toAssetCurrencyLabel.isHidden = false
            toAssetValueLabel.isHidden = false
        }
        onSimul()
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
        onSimul()
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        txFee = selectedChain.getUserSelectedFee(selectedFeePosition, txFee.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.feeDatas = feeInfos[selectedFeePosition].FeeDatas
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectFeeDenom
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, txFee.amount[0].denom) {
            feeSelectLabel.text = msAsset.symbol
            WDP.dpCoin(msAsset, txFee.amount[0], feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let amount = NSDecimalNumber(string: txFee.amount[0].amount)
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        if let toGas = gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.gasMultiply())
            if let gasRate = feeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeCoinAmount!.stringValue
            }
        }
        
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        hardBtn.isEnabled = true
    }
    
    @IBAction func onClickAction(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toAmount == NSDecimalNumber.zero ) { return }
        view.isUserInteractionEnabled = false
        hardBtn.isEnabled = false
        loadingView.isHidden = false
        
        Task {
            do {
                var simulReq: Cosmos_Tx_V1beta1_SimulateRequest!
                if (hardActionType == .Deposit) {
                    simulReq = try await Signer.genSimul(selectedChain, onBindDepsoitMsg(), txMemo, txFee, nil)
                    
                } else if (hardActionType == .Withdraw) {
                    simulReq = try await Signer.genSimul(selectedChain, onBindWithdrawMsg(), txMemo, txFee, nil)
                    
                } else if (hardActionType == .Borrow) {
                    simulReq = try await Signer.genSimul(selectedChain, onBindBorrowMsg(), txMemo, txFee, nil)
                    
                } else if (hardActionType == .Repay) {
                    simulReq = try await Signer.genSimul(selectedChain, onBindRepayMsg(), txMemo, txFee, nil)
                }
                let simulRes = try await kavaFetcher.simulateTx(simulReq)
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(simulRes)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.loadingView.isHidden = true
                    self.onShowToast("Error : " + "\n" + "\(error)")
                    return
                }
            }
        }
    }
    
    func onBindDepsoitMsg() -> [Google_Protobuf_Any] {
        let depositCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = hardMarket.denom
            $0.amount = toAmount.stringValue
        }
        let msg = Kava_Hard_V1beta1_MsgDeposit.with {
            $0.depositor = selectedChain.bechAddress!
            $0.amount = [depositCoin]
        }
        return Signer.genKavaHardDepositMsg(msg)
    }
    
    func onBindWithdrawMsg() -> [Google_Protobuf_Any] {
        let withdrawCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = hardMarket.denom
            $0.amount = toAmount.stringValue
        }
        let msg = Kava_Hard_V1beta1_MsgWithdraw.with {
            $0.depositor = selectedChain.bechAddress!
            $0.amount = [withdrawCoin]
        }
        return Signer.genKavaHardWithdrawMsg(msg)
    }
    
    func onBindBorrowMsg() -> [Google_Protobuf_Any] {
        let borrowCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = hardMarket.denom
            $0.amount = toAmount.stringValue
        }
        let msg = Kava_Hard_V1beta1_MsgBorrow.with {
            $0.borrower = selectedChain.bechAddress!
            $0.amount = [borrowCoin]
        }
        return Signer.genKavaHardBorrowMsg(msg)
    }
    
    func onBindRepayMsg() -> [Google_Protobuf_Any] {
        let repayCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = hardMarket.denom
            $0.amount = toAmount.stringValue
        }
        let msg = Kava_Hard_V1beta1_MsgRepay.with {
            $0.sender = selectedChain.bechAddress!
            $0.owner = selectedChain.bechAddress!
            $0.amount = [repayCoin]
        }
        return Signer.genKavaHardRepayMsg(msg)
    }

}


extension KavaLendAction: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
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
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            hardBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    var broadReq: Cosmos_Tx_V1beta1_BroadcastTxRequest!
                    if (hardActionType == .Deposit) {
                        broadReq = try await Signer.genTx(selectedChain, onBindDepsoitMsg(), txMemo, txFee, nil)
                        
                    } else if (hardActionType == .Withdraw) {
                        broadReq = try await Signer.genTx(selectedChain, onBindWithdrawMsg(), txMemo, txFee, nil)
                        
                    } else if (hardActionType == .Borrow) {
                        broadReq = try await Signer.genTx(selectedChain, onBindBorrowMsg(), txMemo, txFee, nil)
                        
                    } else if (hardActionType == .Repay) {
                        broadReq = try await Signer.genTx(selectedChain, onBindRepayMsg(), txMemo, txFee, nil)
                        
                    }
                    let response = try await kavaFetcher.broadcastTx(broadReq)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        
                        let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                        txResult.selectedChain = self.selectedChain
                        txResult.broadcastTxResponse = response
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                    
                } catch {
                    //TODO handle Error
                }
            }
        }
    }
}

public enum HardActionType: Int {
    case Deposit = 0
    case Withdraw = 1
    case Borrow = 2
    case Repay = 3
}
