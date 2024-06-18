//
//  KavaSwapAction.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaSwapAction: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var depositCard: FixCardView!
    @IBOutlet weak var depositCoin1Img: UIImageView!
    @IBOutlet weak var depositCoin1Symbol: UILabel!
    @IBOutlet weak var depositCoin1AmountLabel: UILabel!
    @IBOutlet weak var depositCoin1DenomLabel: UILabel!
    @IBOutlet weak var depositCoin1CurrencyLabel: UILabel!
    @IBOutlet weak var depositCoin1ValueLabel: UILabel!
    @IBOutlet weak var depositCoin2Img: UIImageView!
    @IBOutlet weak var depositCoin2Symbol: UILabel!
    @IBOutlet weak var depositCoin2AmountLabel: UILabel!
    @IBOutlet weak var depositCoin2DenomLabel: UILabel!
    @IBOutlet weak var depositCoin2CurrencyLabel: UILabel!
    @IBOutlet weak var depositCoin2ValueLabel: UILabel!
    @IBOutlet weak var depositBtnsStackLayer: UIStackView!
    
    @IBOutlet weak var withdrawCard: FixCardView!
    @IBOutlet weak var withdrawHintLabel: UILabel!
    @IBOutlet weak var withdrawAmountLabel: UILabel!
    
    
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
    
    @IBOutlet weak var swpBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var swpActionType: SwpActionType!                     // to action type
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse!
    var swapPool: Kava_Swap_V1beta1_PoolResponse!
    var myDeposit: Kava_Swap_V1beta1_DepositResponse!
    
    var coin1MsAsset: MintscanAsset!
    var coin2MsAsset: MintscanAsset!
    var coin1AvailableAmount = NSDecimalNumber.zero
    var coin2AvailableAmount = NSDecimalNumber.zero
    var coin1ToAmount = NSDecimalNumber.zero
    var coin2ToAmount = NSDecimalNumber.zero
    var swapRate = NSDecimalNumber.zero
    
    var toWithdrawAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
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
        selectedFeeInfo = selectedChain.getFeeBasePosition()
        feeSegments.selectedSegmentIndex = selectedFeeInfo
        txFee = selectedChain.getInitPayableFee()
        
        if (swpActionType == .Deposit) {
            depositCard.isHidden = false
            depositBtnsStackLayer.isHidden = false
            withdrawCard.isHidden = true
            
            coin1MsAsset = BaseData.instance.getAsset(selectedChain.apiName, swapPool.coins[0].denom)
            depositCoin1Img.af.setImage(withURL: coin1MsAsset.assetImg())
            depositCoin1Symbol.text = coin1MsAsset.symbol
            WDP.dpCoin(coin1MsAsset, NSDecimalNumber.zero, nil, depositCoin1DenomLabel, depositCoin1AmountLabel, coin1MsAsset.decimals)
            WDP.dpValue(NSDecimalNumber.zero, depositCoin1CurrencyLabel, depositCoin1ValueLabel)
            
            coin2MsAsset = BaseData.instance.getAsset(selectedChain.apiName, swapPool.coins[1].denom)
            depositCoin2Img.af.setImage(withURL: coin2MsAsset.assetImg())
            depositCoin2Symbol.text = coin2MsAsset.symbol
            WDP.dpCoin(coin2MsAsset, NSDecimalNumber.zero, nil, depositCoin2DenomLabel, depositCoin2AmountLabel, coin2MsAsset.decimals)
            WDP.dpValue(NSDecimalNumber.zero, depositCoin2CurrencyLabel, depositCoin2ValueLabel)
            
            let poolCoin1Amount = swapPool.coins[0].getAmount()
            let poolCoin2Amount = swapPool.coins[1].getAmount()
            var availabelCoin1Amount = selectedChain.getGrpcfetcher()!.balanceAmount(swapPool.coins[0].denom)
            if (txFee.amount[0].denom == swapPool.coins[0].denom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                availabelCoin1Amount = availabelCoin1Amount.subtracting(feeAmount)
            }
            let availabelCoin2Amount = selectedChain.getGrpcfetcher()!.balanceAmount(swapPool.coins[1].denom)
            
            swapRate = poolCoin1Amount.dividing(by: poolCoin2Amount, withBehavior: handler24Down)
            let availabelRate = availabelCoin1Amount.dividing(by: availabelCoin2Amount, withBehavior: handler24Down)
            if (swapRate.compare(availabelRate).rawValue > 0) {
                coin1AvailableAmount = availabelCoin1Amount
                coin2AvailableAmount = availabelCoin1Amount.dividing(by: swapRate, withBehavior: handler0)
            } else {
                coin2AvailableAmount = availabelCoin2Amount
                coin1AvailableAmount = availabelCoin2Amount.multiplying(by: swapRate, withBehavior: handler0)
            }
            
        } else if (swpActionType == .Withdraw) {
            depositCard.isHidden = true
            depositBtnsStackLayer.isHidden = true
            withdrawCard.isHidden = false
        }
        
        depositCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickDepositAmount)))
        withdrawCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickWithdrawAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        if (swpActionType == .Deposit) {
            titleLabel.text = NSLocalizedString("title_pool_join", comment: "")
            swpBtn.setTitle(NSLocalizedString("btn_deposit", comment: ""), for: .normal)
        } else if (swpActionType == .Withdraw) {
            titleLabel.text = NSLocalizedString("title_pool_exit", comment: "")
            swpBtn.setTitle(NSLocalizedString("btn_withdraw", comment: ""), for: .normal)
        }
        withdrawHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
    }
    
    @objc func onClickDepositAmount() {
        let lpAmountSheet = TxAmountLpSheet(nibName: "TxAmountLpSheet", bundle: nil)
        lpAmountSheet.selectedChain = selectedChain
        lpAmountSheet.msAsset1 = coin1MsAsset
        lpAmountSheet.msAsset2 = coin2MsAsset
        lpAmountSheet.available1Amount = coin1AvailableAmount
        lpAmountSheet.available2Amount = coin2AvailableAmount
        lpAmountSheet.swapRate = swapRate
        if (coin1ToAmount != NSDecimalNumber.zero) {
            lpAmountSheet.existed1Amount = coin1ToAmount
        }
        if (coin2ToAmount != NSDecimalNumber.zero) {
            lpAmountSheet.existed2Amount = coin2ToAmount
        }
        lpAmountSheet.sheetDelegate = self
        onStartSheet(lpAmountSheet, 320, 0.6)
    }
    
    func onUpdateDepositAmountView(_ amount1: String?, _ amount2: String?) {
        if (amount1?.isEmpty == true || amount2?.isEmpty == true) {
            coin1ToAmount = NSDecimalNumber.zero
            coin2ToAmount = NSDecimalNumber.zero
            return
        } else {
            coin1ToAmount = NSDecimalNumber(string: amount1)
            let coin1Price = BaseData.instance.getPrice(coin1MsAsset.coinGeckoId)
            let coin1Value = coin1Price.multiplying(by: coin1ToAmount).multiplying(byPowerOf10: -coin1MsAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(coin1MsAsset, coin1ToAmount, nil, depositCoin1DenomLabel, depositCoin1AmountLabel, coin1MsAsset.decimals)
            WDP.dpValue(coin1Value, depositCoin1CurrencyLabel, depositCoin1ValueLabel)
            
            coin2ToAmount = NSDecimalNumber(string: amount2)
            let coin2Price = BaseData.instance.getPrice(coin2MsAsset.coinGeckoId)
            let coin2Value = coin2Price.multiplying(by: coin2ToAmount).multiplying(byPowerOf10: -coin2MsAsset.decimals!, withBehavior: handler6)
            WDP.dpCoin(coin2MsAsset, coin2ToAmount, nil, depositCoin2DenomLabel, depositCoin2AmountLabel, coin2MsAsset.decimals)
            WDP.dpValue(coin2Value, depositCoin2CurrencyLabel, depositCoin2ValueLabel)
        }
        onSimul()
    }
    
    @objc func onClickWithdrawAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.availableAmount = NSDecimalNumber(string: myDeposit.sharesOwned)
        if (toWithdrawAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toWithdrawAmount
        }
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxSwpWithdraw
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    //update with withdraw amount
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toWithdrawAmount = NSDecimalNumber.zero
            withdrawHintLabel.isHidden = false
            withdrawAmountLabel.isHidden = true
            
        } else {
            toWithdrawAmount = NSDecimalNumber(string: amount)
            withdrawAmountLabel.attributedText = WDP.dpAmount(toWithdrawAmount.multiplying(byPowerOf10: -6).stringValue, withdrawAmountLabel.font, 6)
            withdrawHintLabel.isHidden = true
            withdrawAmountLabel.isHidden = false
        }
        onSimul()
    }
    
    
    @IBAction func onClickQuarter(_ sender: UIButton) {
        let coin1QuarterAmount = coin1AvailableAmount.multiplying(by: NSDecimalNumber(0.25), withBehavior: handler0Down)
        let coin2QuarterAmount = coin2AvailableAmount.multiplying(by: NSDecimalNumber(0.25), withBehavior: handler0Down)
        onUpdateDepositAmountView(coin1QuarterAmount.stringValue, coin2QuarterAmount.stringValue)
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let coin1HalfAmount = coin1AvailableAmount.dividing(by: NSDecimalNumber(2), withBehavior: handler0Down)
        let coin2HalfAmount = coin2AvailableAmount.dividing(by: NSDecimalNumber(2), withBehavior: handler0Down)
        onUpdateDepositAmountView(coin1HalfAmount.stringValue, coin2HalfAmount.stringValue)
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        onUpdateDepositAmountView(coin1AvailableAmount.stringValue, coin2AvailableAmount.stringValue)
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
        selectedFeeInfo = sender.selectedSegmentIndex
        txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, txFee.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.feeDatas = feeInfos[selectedFeeInfo].FeeDatas
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
    
    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        if let toGas = simul?.gasInfo.gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * selectedChain.gasMultiply())
            if let gasRate = feeInfos[selectedFeeInfo].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeCoinAmount!.stringValue
            }
        }
        
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        swpBtn.isEnabled = true
    }
    
    
    @IBAction func onClickSwp(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (swpActionType == .Deposit) {
            if (coin1ToAmount == NSDecimalNumber.zero || coin2ToAmount == NSDecimalNumber.zero) { return }
            view.isUserInteractionEnabled = false
            swpBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress!) {
                    do {
                        let simul = try await simulDepositTx(channel, auth!, onBindDepsoitMsg())
                        DispatchQueue.main.async {
                            self.onUpdateWithSimul(simul)
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
            
        } else if (swpActionType == .Withdraw) {
            if (toWithdrawAmount == NSDecimalNumber.zero) { return }
            view.isUserInteractionEnabled = false
            swpBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress!) {
                    do {
                        let simul = try await simulWithdrawTx(channel, auth!, onBindWithdrawMsg())
                        DispatchQueue.main.async {
                            self.onUpdateWithSimul(simul)
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
        }
    }
    
    func onBindDepsoitMsg() -> Kava_Swap_V1beta1_MsgDeposit {
        let slippage = "30000000000000000"
        let deadline = (Date().millisecondsSince1970 / 1000) + 300
        let depositCoin1 = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = swapPool.coins[0].denom
            $0.amount = coin1ToAmount.stringValue
        }
        let depositCoin2 = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = swapPool.coins[1].denom
            $0.amount = coin2ToAmount.stringValue
        }
        return Kava_Swap_V1beta1_MsgDeposit.with {
            $0.depositor = selectedChain.bechAddress!
            $0.tokenA = depositCoin1
            $0.tokenB = depositCoin2
            $0.slippage = slippage
            $0.deadline = deadline
        }
    }
    
    func onBindWithdrawMsg() -> Kava_Swap_V1beta1_MsgWithdraw {
        let totalShares = NSDecimalNumber.init(string: swapPool.totalShares)
        let padding = NSDecimalNumber(string: "0.97")
        let mintCoin1Amount = swapPool.coins[0].getAmount().multiplying(by: toWithdrawAmount).dividing(by: totalShares, withBehavior: handler0Down).multiplying(by: padding, withBehavior: handler0Down)
        let mintCoin2Amount = swapPool.coins[1].getAmount().multiplying(by: toWithdrawAmount).dividing(by: totalShares, withBehavior: handler0Down).multiplying(by: padding, withBehavior: handler0Down)
        let deadline = (Date().millisecondsSince1970 / 1000) + 300
        return  Kava_Swap_V1beta1_MsgWithdraw.with {
            $0.from = selectedChain.bechAddress!
            $0.shares = toWithdrawAmount.stringValue
            $0.minTokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = swapPool.coins[0].denom; $0.amount = mintCoin1Amount.stringValue }
            $0.minTokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = swapPool.coins[1].denom; $0.amount = mintCoin2Amount.stringValue }
            $0.deadline = deadline
        }
    }

}

extension KavaSwapAction: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, LpAmountSheetDelegate, PinDelegate {
    
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedLpAmount(_ amount1: String, _ amount2: String) {
        onUpdateDepositAmountView(amount1, amount2)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            swpBtn.isEnabled = false
            loadingView.isHidden = false
            
            if (swpActionType == .Deposit) {
                Task {
                    let channel = getConnection()
                    if let auth = try? await fetchAuth(channel, selectedChain.bechAddress!),
                       let response = try await broadcastDepositTx(channel, auth!, onBindDepsoitMsg()) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.broadcastTxResponse = response
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }
                }
                
            } else if (swpActionType == .Withdraw) {
                Task {
                    let channel = getConnection()
                    if let auth = try? await fetchAuth(channel, selectedChain.bechAddress!),
                       let response = try await broadcastWithdrawTx(channel, auth!, onBindWithdrawMsg()) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.broadcastTxResponse = response
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }
                }
                
            }
        }
    }
    
}


extension KavaSwapAction {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    //Swp Deposit
    func simulDepositTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toDeposit: Kava_Swap_V1beta1_MsgDeposit) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.geKavaSwpDepositSimul(auth, toDeposit, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastDepositTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toDeposit: Kava_Swap_V1beta1_MsgDeposit) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaSwpDepositTx(auth, toDeposit, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    //Swp Withdraw
    func simulWithdrawTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWithdraw: Kava_Swap_V1beta1_MsgWithdraw) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.geKavaSwpWithdrawSimul(auth, toWithdraw, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastWithdrawTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWithdraw: Kava_Swap_V1beta1_MsgWithdraw) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaSwpwithdrawTx(auth, toWithdraw, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpcfetcher()!.getGrpc().0, port: selectedChain.getGrpcfetcher()!.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}



public enum SwpActionType: Int {
    case Deposit = 0
    case Withdraw = 1
}
