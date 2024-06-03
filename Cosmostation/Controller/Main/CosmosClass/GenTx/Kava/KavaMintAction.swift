//
//  KavaMintAction.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaMintAction: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toMintAssetCard: FixCardView!
    @IBOutlet weak var toMintAssetTitle: UILabel!
    @IBOutlet weak var toMintAssetImg: UIImageView!
    @IBOutlet weak var toMintSymbolLabel: UILabel!
    @IBOutlet weak var toMintAssetHint: UILabel!
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
    
    @IBOutlet weak var mintBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: CosmosClass!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var mintActionType: CdpActionType!                     // to action type
    var collateralParam: Kava_Cdp_V1beta1_CollateralParam!
    var myCdp: Kava_Cdp_V1beta1_CDPResponse!
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var collateralMsAsset: MintscanAsset!
    var principalMsAsset: MintscanAsset!
    var collateralAvailableAmount = NSDecimalNumber.zero
    var principalAvailableAmount = NSDecimalNumber.zero
    var toCollateralAmount = NSDecimalNumber.zero
    var toPrincipalAmount = NSDecimalNumber.zero

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
        
        collateralMsAsset = BaseData.instance.getAsset(selectedChain.apiName, collateralParam.denom)!
        principalMsAsset = BaseData.instance.getAsset(selectedChain.apiName, "usdx")!
        
        if (mintActionType == .Deposit) {
            toMintSymbolLabel.text = collateralMsAsset.symbol
            toMintAssetImg.af.setImage(withURL: collateralMsAsset.assetImg())
            let balanceAmount = selectedChain.balanceAmount(collateralParam.denom)
            if (txFee.amount[0].denom == collateralParam.denom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                collateralAvailableAmount = balanceAmount.subtracting(feeAmount)
            }
            collateralAvailableAmount = balanceAmount
            
        } else if (mintActionType == .Withdraw) {
            toMintSymbolLabel.text = collateralMsAsset.symbol
            toMintAssetImg.af.setImage(withURL: collateralMsAsset.assetImg())
            collateralAvailableAmount = myCdp.collateral.getAmount()
            
            
        } else if (mintActionType == .DrawDebt) {
            toMintSymbolLabel.text = principalMsAsset.symbol
            toMintAssetImg.af.setImage(withURL: principalMsAsset.assetImg())
            let padding = NSDecimalNumber(string: "0.95")
            let collateralValue = myCdp.collateralValue.getAmount()
            let ltvAmount = collateralValue.dividing(by: collateralParam.getLiquidationRatioAmount())
                .multiplying(by: padding, withBehavior: handler0)
            let currentBorrowed = myCdp.getDebtAmount()
            if (ltvAmount.subtracting(currentBorrowed).compare(NSDecimalNumber.zero).rawValue > 0) {
                principalAvailableAmount = ltvAmount.subtracting(currentBorrowed)
            }
            
        } else if (mintActionType == .Repay) {
            toMintSymbolLabel.text = principalMsAsset.symbol
            toMintAssetImg.af.setImage(withURL: principalMsAsset.assetImg())
            principalAvailableAmount = selectedChain.balanceAmount("usdx")
        }
        
        
        toMintAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        if (mintActionType == .Deposit) {
            titleLabel.text = NSLocalizedString("title_deposit_cdp", comment: "")
            toMintAssetTitle.text = NSLocalizedString("str_deposit_amount", comment: "")
            mintBtn.setTitle(NSLocalizedString("btn_deposit", comment: ""), for: .normal)
            
        } else if (mintActionType == .Withdraw) {
            titleLabel.text = NSLocalizedString("title_withdraw_cdp", comment: "")
            toMintAssetTitle.text = NSLocalizedString("str_withdraw_amount", comment: "")
            mintBtn.setTitle(NSLocalizedString("btn_withdraw", comment: ""), for: .normal)
            
        } else if (mintActionType == .DrawDebt) {
            titleLabel.text = NSLocalizedString("title_drawdebt_cdp", comment: "")
            toMintAssetTitle.text = NSLocalizedString("str_borrow_amount", comment: "")
            mintBtn.setTitle(NSLocalizedString("btn_borrow", comment: ""), for: .normal)
            
        } else if (mintActionType == .Repay) {
            titleLabel.text = NSLocalizedString("title_repay_cdp", comment: "")
            toMintAssetTitle.text = NSLocalizedString("str_repay_amount", comment: "")
            mintBtn.setTitle(NSLocalizedString("btn_repay", comment: ""), for: .normal)
        }
        toMintAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
    }

    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        if (mintActionType == .Deposit) {
            amountSheet.sheetType = .TxMintDeposit
            if (toCollateralAmount != NSDecimalNumber.zero) {
                amountSheet.existedAmount = toCollateralAmount
            }
            amountSheet.availableAmount = collateralAvailableAmount
            amountSheet.msAsset = collateralMsAsset
            
        } else if (mintActionType == .Withdraw) {
            amountSheet.sheetType = .TxMintWithdraw
            if (toCollateralAmount != NSDecimalNumber.zero) {
                amountSheet.existedAmount = toCollateralAmount
            }
            amountSheet.availableAmount = collateralAvailableAmount
            amountSheet.msAsset = collateralMsAsset
            
        } else if (mintActionType == .DrawDebt) {
            amountSheet.sheetType = .TxMintDrawDebt
            if (toPrincipalAmount != NSDecimalNumber.zero) {
                amountSheet.existedAmount = toPrincipalAmount
            }
            amountSheet.availableAmount = principalAvailableAmount
            amountSheet.msAsset = principalMsAsset
            
        } else if (mintActionType == .Repay) {
            amountSheet.sheetType = .TxMintRepay
            if (toPrincipalAmount != NSDecimalNumber.zero) {
                amountSheet.existedAmount = toPrincipalAmount
            }
            amountSheet.availableAmount = principalAvailableAmount
            amountSheet.msAsset = principalMsAsset
        }
        amountSheet.sheetDelegate = self
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            if (mintActionType == .Deposit || mintActionType == .Withdraw) {
                toCollateralAmount = NSDecimalNumber.zero
            } else {
                toPrincipalAmount = NSDecimalNumber.zero
            }
            toMintAssetHint.isHidden = false
            toAssetAmountLabel.isHidden = true
            toAssetDenomLabel.isHidden = true
            toAssetCurrencyLabel.isHidden = true
            toAssetValueLabel.isHidden = true
            
        } else {
            if (mintActionType == .Deposit || mintActionType == .Withdraw) {
                toCollateralAmount = NSDecimalNumber(string: amount)
                let msPrice = BaseData.instance.getPrice(collateralMsAsset.coinGeckoId)
                let value = msPrice.multiplying(by: toCollateralAmount).multiplying(byPowerOf10: -collateralMsAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(collateralMsAsset!, toCollateralAmount, nil, toAssetDenomLabel, toAssetAmountLabel, collateralMsAsset.decimals)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else {
                toPrincipalAmount = NSDecimalNumber(string: amount)
                let msPrice = BaseData.instance.getPrice(principalMsAsset.coinGeckoId)
                let value = msPrice.multiplying(by: toPrincipalAmount).multiplying(byPowerOf10: -principalMsAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(principalMsAsset!, toPrincipalAmount, nil, toAssetDenomLabel, toAssetAmountLabel, principalMsAsset.decimals)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
            }
            toMintAssetHint.isHidden = true
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
        mintBtn.isEnabled = true
    }
    
    @IBAction func onClickAction(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (mintActionType == .Deposit) {
            if (toCollateralAmount == NSDecimalNumber.zero ) { return }
            view.isUserInteractionEnabled = false
            mintBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
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
            
        } else if (mintActionType == .Withdraw) {
            if (toCollateralAmount == NSDecimalNumber.zero ) { return }
            view.isUserInteractionEnabled = false
            mintBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
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
            
        } else if (mintActionType == .DrawDebt) {
            if (toPrincipalAmount == NSDecimalNumber.zero ) { return }
            view.isUserInteractionEnabled = false
            mintBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                    do {
                        let simul = try await simulBorrowTx(channel, auth!, onBindDrawDebtMsg())
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
            
        } else if (mintActionType == .Repay) {
            if (toPrincipalAmount == NSDecimalNumber.zero ) { return }
            view.isUserInteractionEnabled = false
            mintBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                    do {
                        let simul = try await simulRepayTx(channel, auth!, onBindRepayMsg())
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
    
    func onBindDepsoitMsg() -> Kava_Cdp_V1beta1_MsgDeposit {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateralParam.denom
            $0.amount = toCollateralAmount.stringValue
        }
        return Kava_Cdp_V1beta1_MsgDeposit.with {
            $0.depositor = selectedChain.bechAddress
            $0.owner = selectedChain.bechAddress
            $0.collateral = collateralCoin
            $0.collateralType = collateralParam.type
        }
    }
    
    func onBindWithdrawMsg() -> Kava_Cdp_V1beta1_MsgWithdraw {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateralParam.denom
            $0.amount = toCollateralAmount.stringValue
        }
        return Kava_Cdp_V1beta1_MsgWithdraw.with {
            $0.depositor = selectedChain.bechAddress
            $0.owner = selectedChain.bechAddress
            $0.collateral = collateralCoin
            $0.collateralType = collateralParam.type
        }
    }
    
    func onBindDrawDebtMsg() -> Kava_Cdp_V1beta1_MsgDrawDebt {
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = "usdx"
            $0.amount = toPrincipalAmount.stringValue
        }
        return Kava_Cdp_V1beta1_MsgDrawDebt.with {
            $0.sender = selectedChain.bechAddress
            $0.collateralType = collateralParam.type
            $0.principal = principalCoin
        }
    }
    
    func onBindRepayMsg() -> Kava_Cdp_V1beta1_MsgRepayDebt {
        let paymentCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = "usdx"
            $0.amount = toPrincipalAmount.stringValue
        }
        return Kava_Cdp_V1beta1_MsgRepayDebt.with {
            $0.sender = selectedChain.bechAddress
            $0.collateralType = collateralParam.type
            $0.payment = paymentCoin
        }
    }
}


extension KavaMintAction: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
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
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            mintBtn.isEnabled = false
            loadingView.isHidden = false
            
            if (mintActionType == .Deposit) {
                Task {
                    let channel = getConnection()
                    if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
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
                
            } else if (mintActionType == .Withdraw) {
                Task {
                    let channel = getConnection()
                    if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
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
                
            } else if (mintActionType == .DrawDebt) {
                Task {
                    let channel = getConnection()
                    if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
                       let response = try await broadcastBorrowTx(channel, auth!, onBindDrawDebtMsg()) {
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
                
            } else if (mintActionType == .Repay) {
                Task {
                    let channel = getConnection()
                    if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
                       let response = try await broadcastRepayTx(channel, auth!, onBindRepayMsg()) {
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

extension KavaMintAction {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    
    //CDP Deposit
    func simulDepositTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toDeposit: Kava_Cdp_V1beta1_MsgDeposit) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.KavaCDPDepositSimul(auth, toDeposit, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastDepositTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toDeposit: Kava_Cdp_V1beta1_MsgDeposit) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaCDPDepositTx(auth, toDeposit, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    //CDP Withdraw
    func simulWithdrawTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWithdraw: Kava_Cdp_V1beta1_MsgWithdraw) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genKavaCDPWithdrawSimul(auth, toWithdraw, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastWithdrawTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWithdraw: Kava_Cdp_V1beta1_MsgWithdraw) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaCDPWithdrawTx(auth, toWithdraw, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    //CDP DrawDebt
    func simulBorrowTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toDrawDebt: Kava_Cdp_V1beta1_MsgDrawDebt) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genKavaCDPDrawDebtSimul(auth, toDrawDebt, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastBorrowTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toDrawDebt: Kava_Cdp_V1beta1_MsgDrawDebt) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaCDPDrawDebtTx(auth, toDrawDebt, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    //CDP Repay
    func simulRepayTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toRepay: Kava_Cdp_V1beta1_MsgRepayDebt) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genKavaCDPRepaySimul(auth, toRepay, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastRepayTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toRepay: Kava_Cdp_V1beta1_MsgRepayDebt) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaCDPRepayTx(auth, toRepay, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}

public enum CdpActionType: Int {
    case Deposit = 0
    case Withdraw = 1
    case DrawDebt = 2
    case Repay = 3
}
