//
//  CosmosTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class CosmosTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toChainTitle: UILabel!
    @IBOutlet weak var toChainCardView: FixCardView!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainLabel: UILabel!
    
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
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: CosmosClass!
    var feeInfos = [FeeInfo]()
    var selectedFeeInfo = 0
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""
    
    var toSendDenom: String!                        // coin denom or contract addresss
    var transferAssetType: TransferAssetType!       // to send type
    var selectedMsAsset: MintscanAsset!             // to send Coin
    var selectedMsToken: MintscanToken!             // to send Token
    var allCosmosChains = [CosmosClass]()
    
    var availableAmount = NSDecimalNumber.zero
    var toSendAmount = NSDecimalNumber.zero
    var recipientableChains = [CosmosClass]()
    var selectedRecipientChain: CosmosClass!
    var selectedRecipientAddress: String?
    
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
        txFee = selectedChain.getInitFee()
        
        if let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom?.lowercased() == toSendDenom.lowercased() }).first {
            selectedMsAsset = msAsset
            transferAssetType = .CoinTransfer
            
        } else if let msToken = selectedChain.mintscanTokens.filter({ $0.address == toSendDenom }).first {
            selectedMsToken = msToken
            if (toSendDenom.starts(with: "0x")) {
                transferAssetType = .Erc20Transfer
            } else {
                transferAssetType = .Cw20Transfer
            }
        }
        
        allCosmosChains = ALLCOSMOSCLASS()
        
        //Set Recipientable Chains by ms data
        recipientableChains.append(selectedChain)
        BaseData.instance.mintscanAssets?.forEach({ msAsset in
            if (transferAssetType == .CoinTransfer) {
                if (msAsset.chain == selectedChain.apiName && msAsset.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add backward path
                    if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.beforeChain(selectedChain.apiName) }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            print("sendable ", sendable.name)
                            recipientableChains.append(sendable)
                        }
                    }
                    
                } else if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add forward path
                    if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.chain }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            print("sendable ", sendable.name)
                            recipientableChains.append(sendable)
                        }
                    }
                }
                
            } else {
                //add only forward path
                if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.chain }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            print("sendable ", sendable.name)
                            recipientableChains.append(sendable)
                        }
                    }
                }
            }
        })
        recipientableChains.sort {
            if ($0.name == selectedChain.name) { return true }
            if ($1.name == selectedChain.name) { return false }
            if ($0.name == "Cosmos") { return true }
            if ($1.name == "Cosmos") { return false }
            return false
        }
        selectedRecipientChain = recipientableChains[0]
        
        
        //Set To Send Asset
        if (transferAssetType == .CoinTransfer) {
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, toSendDenom) {
                toSendSymbolLabel.text = msAsset.symbol
                toSendAssetImg.af.setImage(withURL: msAsset.assetImg())
            }
            
        } else {
            if let msToken = selectedChain.mintscanTokens.filter({ $0.address == toSendDenom }).first {
                toSendSymbolLabel.text = msToken.symbol
                toSendAssetImg.af.setImage(withURL: msToken.assetImg())
            }
        }
        
        
        toChainCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToChain)))
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        onUpdateToChainView()
        onUpdateFeeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 750
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_transfer_asset", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    
    @objc func onClickToChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.cosmosChainList = recipientableChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectRecipientChain
        onStartSheet(baseSheet, 680)
    }
    
    func onUpdateToChainView() {
        toChainImg.image =  UIImage.init(named: selectedRecipientChain.logo1)
        toChainLabel.text = selectedRecipientChain.name.uppercased()
        
        if (selectedChain.chainId == selectedRecipientChain.chainId) {
            titleLabel.text = NSLocalizedString("str_transfer_asset", comment: "")
        } else {
            titleLabel.text = NSLocalizedString("str_ibc_transfer_asset", comment: "")
        }
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxAddressSheet(nibName: "TxAddressSheet", bundle: nil)
        addressSheet.selectedChain = selectedChain
        if (selectedRecipientAddress?.isEmpty == false) {
            addressSheet.existedAddress = selectedRecipientAddress
        }
        addressSheet.recipientChain = selectedRecipientChain
        addressSheet.addressDelegate = self
        self.onStartSheet(addressSheet)
    }
    
    func onUpdateToAddressView() {
        if (selectedRecipientAddress?.isEmpty == true) {
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
            
        } else {
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = selectedRecipientAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
        }
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.transferAssetType = transferAssetType
        if (transferAssetType == .CoinTransfer) {
            amountSheet.msAsset = selectedMsAsset
        } else {
            amountSheet.msToken = selectedMsToken
        }
        amountSheet.availableAmount = availableAmount
        if (toSendAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toSendAmount
        }
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxTransfer
        self.onStartSheet(amountSheet)
        
    }
    
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toSendAmount = NSDecimalNumber.zero
            toSendAssetHint.isHidden = false
            toAssetAmountLabel.isHidden = true
            toAssetDenomLabel.isHidden = true
            toAssetCurrencyLabel.isHidden = true
            toAssetValueLabel.isHidden = true
            
        } else {
            toSendAmount = NSDecimalNumber(string: amount)
            if (transferAssetType == .CoinTransfer) {
                let msPrice = BaseData.instance.getPrice(selectedMsAsset.coinGeckoId)
                let value = msPrice.multiplying(by: toSendAmount).multiplying(byPowerOf10: -selectedMsAsset.decimals!, withBehavior: getDivideHandler(6))
                
                WDP.dpCoin(selectedMsAsset, toSendAmount, nil, toAssetDenomLabel, toAssetAmountLabel, selectedMsAsset.decimals)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else {
                let msPrice = BaseData.instance.getPrice(selectedMsToken.coinGeckoId)
                let value = msPrice.multiplying(by: toSendAmount).multiplying(byPowerOf10: -selectedMsToken.decimals!, withBehavior: getDivideHandler(6))
                
                WDP.dpToken(selectedMsToken, nil, toAssetDenomLabel, toAssetAmountLabel, selectedMsToken.decimals)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
            }
            toSendAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
            toAssetCurrencyLabel.isHidden = false
            toAssetValueLabel.isHidden = false
        }
        onSimul()
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeeInfo = sender.selectedSegmentIndex
        txFee = selectedChain.getBaseFee(selectedFeeInfo, txFee.amount[0].denom)
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
            let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
        
        if (transferAssetType == .CoinTransfer) {
            let balanceAmount = selectedChain.balanceAmount(toSendDenom)
            if (txFee.amount[0].denom == toSendDenom) {
                let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
                if (feeAmount.compare(balanceAmount).rawValue > 0) {
                    //ERROR short balance!!
                }
                availableAmount = balanceAmount.subtracting(feeAmount)
                
            } else {
                availableAmount = balanceAmount
            }
            
        } else {
            availableAmount = selectedMsToken.getAmount()
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
            memoLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
            memoLabel.textColor = .color03
            return
        }
        memoLabel.text = txMemo
        memoLabel.textColor = .color01
        onSimul()
    }
    
    
    
    @IBAction func onClickSend(_ sender: BaseButton) {
//        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
//        self.present(pinVC, animated: true)
    }
    
    func onSimul() {}
    

}


extension CosmosTransfer: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, AddressDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectFeeCoin) {
            if let position = result.position,
               let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[position].denom {
                txFee.amount[0].denom = selectedDenom
                onSimul()
            }
            
        } else if (sheetType == .SelectRecipientChain) {
            if (result.param != selectedRecipientChain.chainId) {
                selectedRecipientChain = recipientableChains.filter({ $0.chainId == result.param }).first
                selectedRecipientAddress = ""
                onUpdateToChainView()
                onUpdateToAddressView()
            }
            
        }
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedAddress(_ address: String) {
        selectedRecipientAddress = address
        onUpdateToAddressView()
    }
    
    func pinResponse(_ request: LockType, _ result: UnLockResult) {
    }
    
    
}


public enum TransferAssetType: Int {
    case CoinTransfer = 0
    case Cw20Transfer = 1
    case Erc20Transfer = 2
}
