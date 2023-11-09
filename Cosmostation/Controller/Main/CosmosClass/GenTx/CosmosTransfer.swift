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
    @IBOutlet weak var memoHintLabel: UILabel!
    
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
    var selectedMsAsset: MintscanAsset?             // to send Coin
    var selectedMsToken: MintscanToken?             // to send Token
    var mintscanPath: MintscanPath?                 // to IBC send path
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
        txFee = selectedChain.getInitPayableFee()
        
        if let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom?.lowercased() == toSendDenom.lowercased() }).first {
            selectedMsAsset = msAsset
            transferAssetType = .CoinTransfer
            
        } else if let msToken = selectedChain.mintscanTokens.filter({ $0.address == toSendDenom }).first {
            selectedMsToken = msToken
            transferAssetType = .Cw20Transfer
        }
        
        allCosmosChains = ALLCOSMOSCLASS()
        
        //Set Recipientable Chains by ms data
        recipientableChains.append(selectedChain)
        BaseData.instance.mintscanAssets?.forEach({ msAsset in
            if (transferAssetType == .CoinTransfer) {
                if (msAsset.chain == selectedChain.apiName && msAsset.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add backward path
                    if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.beforeChain(selectedChain.apiName) && $0.evmCompatible == true }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                        
                    } else if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.beforeChain(selectedChain.apiName) }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                    }
                    
                } else if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add forward path
                    if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.chain && $0.evmCompatible == true }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                        
                    } else if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.chain }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                    }
                }
                
            } else {
                //add only forward path
                if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    if let sendable = allCosmosChains.filter({ $0.apiName == msAsset.chain }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
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
        let gap = UIScreen.main.bounds.size.height - 740
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_transfer_asset", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
        qrScanVC.scanDelegate = self
        present(qrScanVC, animated: true)
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
        self.onStartSheet(addressSheet, 220)
    }
    
    func onUpdateToAddressView() {
        if (selectedRecipientAddress == nil ||
            selectedRecipientAddress?.isEmpty == true) {
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
                let msPrice = BaseData.instance.getPrice(selectedMsAsset!.coinGeckoId)
                let value = msPrice.multiplying(by: toSendAmount).multiplying(byPowerOf10: -selectedMsAsset!.decimals!, withBehavior: handler6)
                
                WDP.dpCoin(selectedMsAsset!, toSendAmount, nil, toAssetDenomLabel, toAssetAmountLabel, selectedMsAsset!.decimals)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else {
                let msPrice = BaseData.instance.getPrice(selectedMsToken!.coinGeckoId)
                let value = msPrice.multiplying(by: toSendAmount).multiplying(byPowerOf10: -selectedMsToken!.decimals!, withBehavior: handler6)
                
                WDP.dpToken(selectedMsToken!, toSendAmount, nil, toAssetDenomLabel, toAssetAmountLabel, selectedMsToken!.decimals)
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
            availableAmount = selectedMsToken!.getAmount()
        }
        
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        self.onStartSheet(memoSheet, 260)
    }
    
    func onUpdateMemoView(_ memo: String, _ skipSimul: Bool? = false) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.isHidden = true
            memoHintLabel.isHidden = false
        } else {
            memoLabel.text = txMemo
            memoLabel.isHidden = false
            memoHintLabel.isHidden = true
        }
        
        if (skipSimul == false) {
            onSimul()
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
        sendBtn.isEnabled = true
    }
    
    func onUpdateWithEvmSimul() {
        onUpdateFeeView()
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        sendBtn.isEnabled = true
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toSendAmount == NSDecimalNumber.zero ) { return }
        if (selectedRecipientAddress == nil || selectedRecipientAddress?.isEmpty == true) { return }
        
        view.isUserInteractionEnabled = false
        sendBtn.isEnabled = false
        loadingView.isHidden = false
        
        if (selectedChain.isGasSimulable() == false) {
            return onUpdateWithSimul(nil)
        }
        
        if (selectedChain.chainId == selectedRecipientChain.chainId) {
            //Inchain Send!
            if (transferAssetType == .CoinTransfer) {
                inChainCoinSendSimul()
                
            } else if (transferAssetType == .Cw20Transfer) {
                inChainWasmSendSimul()
                
            }
            
        } else {
            // IBC Send!
            mintscanPath = WUtils.getMintscanPath(selectedChain, selectedRecipientChain, toSendDenom)
            if (transferAssetType == .CoinTransfer) {
                ibcCoinSendSimul()
            } else if (transferAssetType == .Cw20Transfer) {
                ibcWasmSendSimul()
            }
        }
    }
    
    func inChainCoinSendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                do {
                    let simul = try await simulSendTx(channel, auth!, onBindSend())
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
    
    func inChainWasmSendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                do {
                    let simul = try await simulCw20SendTx(channel, auth!, onBindCw20Send())
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
    
    func ibcCoinSendSimul() {
        Task {
            let channel = getConnection()
            let recipientChannel = getRecipientConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
               let ibcClient = try? await fetchIbcClient(channel),
               let lastBlock = try? await fetchLastBlock(recipientChannel) {
                do {
                    let simul = try await simulIbcSendTx(channel, auth!, onBindIbcSend(ibcClient!, lastBlock!))
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
    
    func ibcWasmSendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress) {
                do {
                    let simul = try await simulCw20IbcSendTx(channel, auth!, onBindCw20IbcSend())
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
    
    
    
     
    func onBindSend() -> Cosmos_Bank_V1beta1_MsgSend {
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toSendAmount.stringValue
        }
        return Cosmos_Bank_V1beta1_MsgSend.with {
            $0.fromAddress = selectedChain.bechAddress
            $0.toAddress = selectedRecipientAddress!
            $0.amount = [sendCoin]
        }
    }
    
    func onBindCw20Send() -> Cosmwasm_Wasm_V1_MsgExecuteContract {
        let msg: JSON = ["transfer" : ["recipient" : selectedRecipientAddress! , "amount" : toSendAmount.stringValue]]
        let msgBase64 = try! msg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        return Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = selectedChain.bechAddress
            $0.contract = selectedMsToken!.address!
            $0.msg = Data(base64Encoded: msgBase64)!
        }
    }
    
    func onBindIbcSend(_ ibcClient: Ibc_Core_Channel_V1_QueryChannelClientStateResponse,
                       _ lastBlock: Cosmos_Base_Tendermint_V1beta1_GetLatestBlockResponse) -> Ibc_Applications_Transfer_V1_MsgTransfer {
        let latestHeight = try! Ibc_Lightclients_Tendermint_V1_ClientState.init(serializedData: ibcClient.identifiedClientState.clientState.value).latestHeight
        let height = Ibc_Core_Client_V1_Height.with {
            $0.revisionNumber = latestHeight.revisionNumber
            $0.revisionHeight = UInt64(lastBlock.block.header.height + 200)
        }
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toSendAmount.stringValue
        }
        return Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = selectedChain.bechAddress
            $0.receiver = selectedRecipientAddress!
            $0.sourceChannel = mintscanPath!.channel!
            $0.sourcePort = mintscanPath!.port!
            $0.timeoutHeight = height
            $0.timeoutTimestamp = 0
            $0.token = sendCoin
        }
    }
    
    func onBindCw20IbcSend() -> Cosmwasm_Wasm_V1_MsgExecuteContract {
        let jsonMsg: JSON = ["channel" : mintscanPath!.channel!, "remote_address" : selectedRecipientAddress!, "timeout" : 900]
        let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        
        let innerMsg: JSON = ["send" : ["contract" : mintscanPath!.getIBCContract(), "amount" : toSendAmount.stringValue, "msg" : jsonMsgBase64]]
        let innerMsgBase64 = try! innerMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        return Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = selectedChain.bechAddress
            $0.contract = selectedMsToken!.address!
            $0.msg = Data(base64Encoded: innerMsgBase64)!
        }
    }

}


extension CosmosTransfer: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, AddressDelegate, QrScanDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeCoin) {
            if let index = result["index"] as? Int,
               let selectedDenom = feeInfos[selectedFeeInfo].FeeDatas[index].denom {
                txFee = selectedChain.getUserSelectedFee(selectedFeeInfo, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
            
        } else if (sheetType == .SelectRecipientChain) {
            if let chainId = result["chainId"] as? String {
                if (chainId != selectedRecipientChain.chainId) {
                    selectedRecipientChain = recipientableChains.filter({ $0.chainId == chainId }).first
                    selectedRecipientAddress = ""
                    onUpdateToChainView()
                    onUpdateToAddressView()
                }
            }
        }
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        selectedRecipientAddress = address
        onUpdateToAddressView()
        if (memo != nil && memo?.isEmpty == false) {
            onUpdateMemoView(memo!)
        }
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
        if (addressScan == selectedChain.bechAddress) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (WUtils.isValidBechAddress(selectedRecipientChain, addressScan)) {
            selectedRecipientAddress = addressScan.trimmingCharacters(in: .whitespaces)
            if (scanedString.count > 1) {
                onUpdateMemoView(memoScan.trimmingCharacters(in: .whitespaces), true)
            }
            onUpdateToAddressView()
            
        } else {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            
            if (selectedChain.chainId == selectedRecipientChain.chainId) {
                //Inchain Send!
                if (transferAssetType == .CoinTransfer) {
                    inChainCoinSend()
                } else if (transferAssetType == .Cw20Transfer) {
                    inChainWasmSend()
                }
                
            } else {
                // IBC Send!
                if (transferAssetType == .CoinTransfer) {
                    ibcCoinSend()
                } else if (transferAssetType == .Cw20Transfer) {
                    ibcWasmSend()
                }
            }
        }
    }
    
    func inChainCoinSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
               let response = try await broadcastSendTx(channel, auth!, onBindSend()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.loadingView.isHidden = true
                    
                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                    txResult.selectedChain = self.selectedChain
                    txResult.recipientChain = self.selectedRecipientChain
                    txResult.recipinetAddress = self.selectedRecipientAddress
                    txResult.memo = self.txMemo
                    txResult.broadcastTxResponse = response
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func inChainWasmSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
               let response = try await broadcastCw20SendTx(channel, auth!, onBindCw20Send()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.loadingView.isHidden = true
                    
                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                    txResult.selectedChain = self.selectedChain
                    txResult.recipientChain = self.selectedRecipientChain
                    txResult.recipinetAddress = self.selectedRecipientAddress
                    txResult.memo = self.txMemo
                    txResult.broadcastTxResponse = response
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    
    func ibcCoinSend() {
        Task {
            let channel = getConnection()
            let recipientChannel = getRecipientConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
               let ibcClient = try? await fetchIbcClient(channel),
               let lastBlock = try? await fetchLastBlock(recipientChannel),
               let response = try await broadcastIbcSendTx(channel, auth!, onBindIbcSend(ibcClient!, lastBlock!)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.loadingView.isHidden = true
                    
                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                    txResult.selectedChain = self.selectedChain
                    txResult.recipientChain = self.selectedRecipientChain
                    txResult.recipinetAddress = self.selectedRecipientAddress
                    txResult.memo = self.txMemo
                    txResult.broadcastTxResponse = response
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func ibcWasmSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.bechAddress),
               let response = try await broadcastCw20IbcSendTx(channel, auth!, onBindCw20IbcSend()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.loadingView.isHidden = true
                    
                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                    txResult.selectedChain = self.selectedChain
                    txResult.recipientChain = self.selectedRecipientChain
                    txResult.recipinetAddress = self.selectedRecipientAddress
                    txResult.memo = self.txMemo
                    txResult.broadcastTxResponse = response
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
}

extension CosmosTransfer {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchIbcClient(_ channel: ClientConnection) async throws -> Ibc_Core_Channel_V1_QueryChannelClientStateResponse? {
        let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
            $0.channelID = mintscanPath!.channel!
            $0.portID = mintscanPath!.port!
        }
        return try? await Ibc_Core_Channel_V1_QueryNIOClient(channel: channel).channelClientState(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLastBlock(_ channel: ClientConnection) async throws -> Cosmos_Base_Tendermint_V1beta1_GetLatestBlockResponse? {
        let req = Cosmos_Base_Tendermint_V1beta1_GetLatestBlockRequest()
        return try? await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getLatestBlock(req, callOptions: getCallOptions()).response.get()
    }
    
    
    //Simple Send
    func simulSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toSend: Cosmos_Bank_V1beta1_MsgSend) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genSendSimul(auth, toSend, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toSend: Cosmos_Bank_V1beta1_MsgSend) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genSendTx(auth, toSend, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    //Wasm Send
    func simulCw20SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genWasmSimul(auth, [toWasmSend], txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCw20SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, [toWasmSend], txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    //ibc Send
    func simulIbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcTransfer: Ibc_Applications_Transfer_V1_MsgTransfer) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genIbcSendSimul(auth, ibcTransfer, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastIbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcTransfer: Ibc_Applications_Transfer_V1_MsgTransfer) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genIbcSendTx(auth, ibcTransfer, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    //Wasm ibc Send
    func simulCw20IbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genWasmSimul(auth, [ibcWasmSend], txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCw20IbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, [ibcWasmSend], txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getRecipientConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedRecipientChain.getGrpc().0, port: selectedRecipientChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}


public enum TransferAssetType: Int {
    case CoinTransfer = 0
    case Cw20Transfer = 1
    case Erc20Transfer = 2
}
