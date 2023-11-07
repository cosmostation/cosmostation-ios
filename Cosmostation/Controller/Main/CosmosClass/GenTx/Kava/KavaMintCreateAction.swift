//
//  KavaMintCreateAction.swift
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

class KavaMintCreateAction: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collateralCard: FixCardView!
    @IBOutlet weak var collateralTitle: UILabel!
    @IBOutlet weak var collateralImg: UIImageView!
    @IBOutlet weak var collateralSymbolLabel: UILabel!
    @IBOutlet weak var collateralHint: UILabel!
    @IBOutlet weak var collateralAmountLabel: UILabel!
    @IBOutlet weak var collateralDenomLabel: UILabel!
    
    @IBOutlet weak var principalCard: FixCardView!
    @IBOutlet weak var principalTitle: UILabel!
    @IBOutlet weak var principalImg: UIImageView!
    @IBOutlet weak var principalSymbolLabel: UILabel!
    @IBOutlet weak var principalHint: UILabel!
    @IBOutlet weak var principalAmountLabel: UILabel!
    @IBOutlet weak var principalDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var cdpBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKava60!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var collateralParam: Kava_Cdp_V1beta1_CollateralParam!
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
        collateralSymbolLabel.text = collateralMsAsset.symbol
        collateralImg.af.setImage(withURL: collateralMsAsset.assetImg())
        
        principalMsAsset = BaseData.instance.getAsset(selectedChain.apiName, "usdx")!
        principalSymbolLabel.text = principalMsAsset.symbol
        principalImg.af.setImage(withURL: principalMsAsset.assetImg())
        
        let balanceAmount = selectedChain.balanceAmount(collateralParam.denom)
        if (txFee.amount[0].denom == collateralParam.denom) {
            let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
            collateralAvailableAmount = balanceAmount.subtracting(feeAmount)
        }
        collateralAvailableAmount = balanceAmount
        
        collateralCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickCollateralAmount)))
        principalCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickPrincipalAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateFeeView()
    }
    
    @objc func onClickCollateralAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = collateralMsAsset
        amountSheet.availableAmount = collateralAvailableAmount
        if (toCollateralAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toCollateralAmount
        }
        amountSheet.sheetType = .TxMintCreateCollateral
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet)
    }
    
    func onUpdateCollateralAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toCollateralAmount = NSDecimalNumber.zero
            collateralHint.isHidden = false
            collateralAmountLabel.isHidden = true
            collateralDenomLabel.isHidden = true
            toPrincipalAmount = NSDecimalNumber.zero
            principalCard.isHidden = true
            
        } else {
            toCollateralAmount = NSDecimalNumber(string: amount)
            WDP.dpCoin(collateralMsAsset!, toCollateralAmount, nil, collateralDenomLabel, collateralAmountLabel, collateralMsAsset.decimals)
            collateralHint.isHidden = true
            collateralAmountLabel.isHidden = false
            collateralDenomLabel.isHidden = false
            principalCard.isHidden = false
        }
        onSimul()
    }
    
    @objc func onClickPrincipalAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = principalMsAsset
        amountSheet.availableAmount = collateralParam.getExpectUsdxLTV(toCollateralAmount, priceFeed!)
        if (toPrincipalAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toPrincipalAmount
        }
        amountSheet.sheetType = .TxMintCreatePrincipal
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet)
    }
    
    func onUpdatePrincipalAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toPrincipalAmount = NSDecimalNumber.zero
            principalHint.isHidden = false
            principalAmountLabel.isHidden = true
            principalDenomLabel.isHidden = true
            
        } else {
            toPrincipalAmount = NSDecimalNumber(string: amount)
            WDP.dpCoin(principalMsAsset!, toPrincipalAmount, nil, principalDenomLabel, principalAmountLabel, principalMsAsset.decimals)
            principalHint.isHidden = true
            principalAmountLabel.isHidden = false
            principalDenomLabel.isHidden = false
        }
        onSimul()
    }
    
    override func setLocalizedString() {
        collateralHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        principalHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        cdpBtn.setTitle(NSLocalizedString("title_create_cdp", comment: ""), for: .normal)
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
        baseSheet.sheetType = .SelectFeeCoin
        onStartSheet(baseSheet, 240)
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
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet)
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
        cdpBtn.isEnabled = true
    }
    
    @IBAction func onClickCreateCdp(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }

    func onSimul() {
        if (toCollateralAmount == NSDecimalNumber.zero || toPrincipalAmount == NSDecimalNumber.zero) { return }
        view.isUserInteractionEnabled = false
        cdpBtn.isEnabled = false
        loadingView.isHidden = false
        
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                do {
                    let simul = try await simulCretaeTx(channel, auth!, onBindCreateMsg())
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
    
    func onBindCreateMsg() -> Kava_Cdp_V1beta1_MsgCreateCDP {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateralParam.denom
            $0.amount = toCollateralAmount.stringValue
        }
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = "usdx"
            $0.amount = toPrincipalAmount.stringValue
        }
        return Kava_Cdp_V1beta1_MsgCreateCDP.with {
            $0.sender = selectedChain.bechAddress
            $0.collateral = collateralCoin
            $0.principal = principalCoin
            $0.collateralType = collateralParam.type
        }
    }
}

extension KavaMintCreateAction: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeCoin) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[index].denom {
                txFee.amount[0].denom = selectedDenom
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        if (type == .TxMintCreateCollateral) {
            onUpdateCollateralAmountView(amount)
        } else if (type == .TxMintCreatePrincipal) {
            onUpdatePrincipalAmountView(amount)
        }
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            cdpBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                let channel = getConnection()
                if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
                   let response = try await broadcastCreateTx(channel, auth!, onBindCreateMsg()) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
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

extension KavaMintCreateAction {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func simulCretaeTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toCreate: Kava_Cdp_V1beta1_MsgCreateCDP) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genKavaCDPCreateSimul(auth, toCreate, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCreateTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toCreate: Kava_Cdp_V1beta1_MsgCreateCDP) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genKavaCDPCreateTx(auth, toCreate, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
    
}

