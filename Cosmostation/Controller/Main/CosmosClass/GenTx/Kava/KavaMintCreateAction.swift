//
//  KavaMintCreateAction.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf
import Kingfisher

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
    
    var selectedChain: ChainKavaEVM!
    var kavaFetcher: KavaFetcher!
    var feeInfos = [FeeInfo]()
    var selectedFeePosition = 0
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
        
        collateralMsAsset = BaseData.instance.getAsset(selectedChain.apiName, collateralParam.denom)!
        collateralSymbolLabel.text = collateralMsAsset.symbol
        collateralImg.kf.setImage(with: collateralMsAsset.assetImg(), placeholder: UIImage(named: "tokenDefault"))
        
        principalMsAsset = BaseData.instance.getAsset(selectedChain.apiName, "usdx")!
        principalSymbolLabel.text = principalMsAsset.symbol
        principalImg.kf.setImage(with: principalMsAsset.assetImg(), placeholder: UIImage(named: "tokenDefault"))
        
        let balanceAmount = kavaFetcher.balanceAmount(collateralParam.denom)
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
        onStartSheet(amountSheet, 240, 0.6)
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
        onStartSheet(amountSheet, 240, 0.6)
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
            do {
                if let simulReq = try await Signer.genSimul(selectedChain, onBindCreateMsg(), txMemo, txFee, nil),
                   let simulRes = try await kavaFetcher.simulateTx(simulReq) {
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(simulRes)
                    }
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
    
    func onBindCreateMsg() -> [Google_Protobuf_Any] {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateralParam.denom
            $0.amount = toCollateralAmount.stringValue
        }
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = "usdx"
            $0.amount = toPrincipalAmount.stringValue
        }
        let createCdpMsg = Kava_Cdp_V1beta1_MsgCreateCDP.with {
            $0.sender = selectedChain.bechAddress!
            $0.collateral = collateralCoin
            $0.principal = principalCoin
            $0.collateralType = collateralParam.type
        }
        return Signer.genKavaCDPCreateMsg(createCdpMsg)
    }
}

extension KavaMintCreateAction: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, PinDelegate {
    
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
                do {
                    if let broadReq = try await Signer.genTx(selectedChain, onBindCreateMsg(), txMemo, txFee, nil),
                       let broadRes = try await kavaFetcher.broadcastTx(broadReq) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.broadcastTxResponse = broadRes
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }
                    
                } catch {
                    //TODO handle Error
                }
            }
        }
    }
}
