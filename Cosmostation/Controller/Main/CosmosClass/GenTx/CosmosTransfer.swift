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
import web3swift
import BigInt

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
    var selectedMsAsset: MintscanAsset?             // to send Coin
    var selectedMsToken: MintscanToken?             // to send Token
    var mintscanPath: MintscanPath?                // to IBC send path
    var allCosmosChains = [CosmosClass]()
    
    var availableAmount = NSDecimalNumber.zero
    var toSendAmount = NSDecimalNumber.zero
    var recipientableChains = [CosmosClass]()
    var selectedRecipientChain: CosmosClass!
    var selectedRecipientAddress: String?
    var ethereumTransaction: EthereumTransaction?
    
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
        self.onStartSheet(addressSheet)
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
        self.onStartSheet(memoSheet)
    }
    
    func onUpdateMemoView(_ memo: String, _ skipSimul: Bool? = false) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
            memoLabel.textColor = .color03
            return
        }
        memoLabel.text = txMemo
        memoLabel.textColor = .color01
        
        if (skipSimul == true) {
            onSimul()
        }
    }
    
    func onUpdateWithSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        if let toGas = simul?.gasInfo.gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * 1.5)
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
        
        if (selectedChain.chainId == selectedRecipientChain.chainId) {
            //Inchain Send!
            if (transferAssetType == .CoinTransfer) {
                inChainCoinSendSimul()
                
            } else if (transferAssetType == .Cw20Transfer) {
                inChainWasmSendSimul()
                
            } else if (transferAssetType == .Erc20Transfer) {
                inChainEvmSendSimul()
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
            if let auth = try? await fetchAuth(channel, selectedChain.address!) {
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
            if let auth = try? await fetchAuth(channel, selectedChain.address!) {
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
    
    func inChainEvmSendSimul() {
        Task {
            guard let url = URL(string: selectedChain.rpcURL) else { return }
            guard let web3 = try? Web3.new(url) else { return }
            
            let chainID = web3.provider.network?.chainID
            let contractAddress = EthereumAddress.init(fromHex: selectedMsToken!.address!)
            let senderAddress = EthereumAddress.init(fromHex: KeyFac.convertBech32ToEvm(selectedChain.address!))
            let recipientAddress = EthereumAddress.init(fromHex: KeyFac.convertBech32ToEvm(selectedRecipientAddress!))
            let erc20token = ERC20(web3: web3, provider: web3.provider, address: contractAddress!)
            
            let calSendAmount = toSendAmount.multiplying(byPowerOf10: -selectedMsToken!.decimals!)
            
            let nonce = try? web3.eth.getTransactionCount(address: senderAddress!)
            let wTx = try? erc20token.transfer(from: senderAddress!, to: recipientAddress!, amount: calSendAmount.stringValue)
            let gasPrice = try? web3.eth.getGasPrice()
            var tx: EthereumTransaction
            var multipleGas: BigUInt
            
            if (selectedChain.tag == "evmos60") {
                let eip1559 = EIP1559Envelope(to: contractAddress!, nonce: nonce!, chainID: chainID!, value: wTx!.transaction.value, data: wTx!.transaction.data,
                                              maxPriorityFeePerGas: BigUInt(500000000),
                                              maxFeePerGas: BigUInt(27500000000),
                                              gasLimit: BigUInt(900000))
                tx = EthereumTransaction(with: eip1559)
                multipleGas = eip1559.maxFeePerGas
            } else {
                let legacy = LegacyEnvelope(to: contractAddress!, nonce: nonce!, chainID: chainID, value: wTx!.transaction.value, data: wTx!.transaction.data, 
                                            gasPrice: gasPrice!, gasLimit: BigUInt(900000))
                tx = EthereumTransaction(with: legacy)
                multipleGas = legacy.gasPrice
            }
            
            if let gasLimit = try? web3.eth.estimateGas(tx, transactionOptions: wTx?.transactionOptions) {
                let newLimit = NSDecimalNumber(string: String(gasLimit)).multiplying(by: NSDecimalNumber(string: "1.3"), withBehavior: handler0Up)
                tx.parameters.gasLimit = Web3.Utils.parseToBigUInt(newLimit.stringValue, decimals: 0)
                txFee.gasLimit = UInt64(gasLimit)
                txFee.amount[0].denom = selectedChain.stakeDenom
                txFee.amount[0].amount = String(gasLimit.multiplied(by: multipleGas))
                
                ethereumTransaction = tx
            }
            
            DispatchQueue.main.async {
                self.onUpdateWithEvmSimul()
            }
        }
    }
    
    
    func ibcCoinSendSimul() {
        Task {
            let channel = getConnection()
            let recipientChannel = getRecipientConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.address!),
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
            if let auth = try? await fetchAuth(channel, selectedChain.address!) {
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
            $0.fromAddress = selectedChain.address!
            $0.toAddress = selectedRecipientAddress!
            $0.amount = [sendCoin]
        }
    }
    
    func onBindCw20Send() -> Cosmwasm_Wasm_V1_MsgExecuteContract {
        let msg: JSON = ["transfer" : ["recipient" : selectedRecipientAddress! , "amount" : toSendAmount.stringValue]]
        let msgBase64 = try! msg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        return Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = selectedChain.address!
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
            $0.sender = selectedChain.address!
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
            $0.sender = selectedChain.address!
            $0.contract = selectedMsToken!.address!
            $0.msg = Data(base64Encoded: innerMsgBase64)!
        }
    }

}


extension CosmosTransfer: BaseSheetDelegate, MemoDelegate, AmountSheetDelegate, AddressDelegate, QrScanDelegate, PinDelegate {
    
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
    
    func onScanned(_ result: String) {
        let scanedString = result.components(separatedBy: "(MEMO)")
        if (scanedString[0].isEmpty == true || scanedString[0].count < 5) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        if (scanedString[0] == selectedChain.address) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (WUtils.isValidChainAddress(selectedRecipientChain, scanedString[0])) {
            selectedRecipientAddress = scanedString[0]
            if (scanedString.count > 1) {
                onUpdateMemoView(scanedString[1], true)
            }
            onUpdateToAddressView()
            
        } else {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
        }
    }
    
    func pinResponse(_ request: LockType, _ result: UnLockResult) {
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
                } else if (transferAssetType == .Erc20Transfer) {
                    inChainEvmSend()
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
            if let auth = try? await fetchAuth(channel, selectedChain.address!),
               let response = try await broadcastSendTx(channel, auth!, onBindSend()) {
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
    
    func inChainWasmSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.address!),
               let response = try await broadcastCw20SendTx(channel, auth!, onBindCw20Send()) {
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
    
    func inChainEvmSend() {
        Task {
            guard let url = URL(string: selectedChain.rpcURL) else { return }
            guard let web3 = try? Web3.new(url) else { return }
            try? ethereumTransaction!.sign(privateKey: selectedChain.privateKey!)
            
            if let result = try? web3.eth.sendRawTransaction(ethereumTransaction!) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    self.loadingView.isHidden = true
                    
                    let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                    txResult.resultType = .Evm
                    txResult.selectedChain = self.selectedChain
                    txResult.evmHash = result.hash
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
            if let auth = try? await fetchAuth(channel, selectedChain.address!),
               let ibcClient = try? await fetchIbcClient(channel),
               let lastBlock = try? await fetchLastBlock(recipientChannel),
               let response = try await broadcastIbcSendTx(channel, auth!, onBindIbcSend(ibcClient!, lastBlock!)) {
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
    
    func ibcWasmSend() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, selectedChain.address!),
               let response = try await broadcastCw20IbcSendTx(channel, auth!, onBindCw20IbcSend()) {
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
        let simulTx = Signer.genWasmSimul(auth, toWasmSend, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCw20SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, toWasmSend, txFee, txMemo, selectedChain)
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
        let simulTx = Signer.genWasmSimul(auth, ibcWasmSend, txFee, txMemo, selectedChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcastCw20IbcSendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ibcWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, ibcWasmSend, txFee, txMemo, selectedChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.grpcHost, port: selectedChain.grpcPort)
    }
    
    func getRecipientConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedRecipientChain.grpcHost, port: selectedRecipientChain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}


public enum TransferAssetType: Int {
    case CoinTransfer = 0
    case Cw20Transfer = 1
    case Erc20Transfer = 2
}
