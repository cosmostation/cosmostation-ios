//
//  NftTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class NftTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toChainCardView: FixCardView!
    @IBOutlet weak var toChainTitle: UILabel!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var toSendNftCard: FixCardView!
    @IBOutlet weak var toSendNftImage: UIImageView!
    @IBOutlet weak var toSendNftName: UILabel!
    @IBOutlet weak var toSendNftCollectionName: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var sendType: SendAssetType = .Only_Cosmos_CW20
    var txStyle: TxStyle = .COSMOS_STYLE
    
    var fromChain: BaseChain!
    var toSendNFT: Cw721Model!
    
    var toChain: BaseChain!
    var toAddress = ""
    var toMemo = ""
    
    var selectedFeePosition = 0
    var cosmosFeeInfos = [FeeInfo]()
    var cosmosTxFee: Cosmos_Tx_V1beta1_Fee!
    
    
    //NOW only Support CW721

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        onInitToChain()                     // set init toChain UI
        onInitNft()                         // set nft
        onInitFee()                         // set init fee for set send available
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeDenom)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 685
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        titleLabel.text = String(format: NSLocalizedString("str_send_asset", comment: ""), "NFT")
        toChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        toAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        memoTitle.text = NSLocalizedString("str_memo_optional", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    func onInitToChain() {
        toChain = fromChain
        toChainImg.image = UIImage.init(named: toChain.logo1)
        toChainLabel.text = toChain.name.uppercased()
    }
    
    func onInitNft() {
        if let url = toSendNFT.tokens[0].tokenDetails["url"].string {
            toSendNftImage?.af.setImage(withURL: URL(string: url)!)
        }
        toSendNftName.text = "#" + toSendNFT.tokens[0].tokenId
        toSendNftCollectionName.text = toSendNFT.info["name"].string
    }
    
    func onInitFee() {
        cosmosFeeInfos = fromChain.getFeeInfos()
        feeSegments.removeAllSegments()
        for i in 0..<cosmosFeeInfos.count {
            feeSegments.insertSegment(withTitle: cosmosFeeInfos[i].title, at: i, animated: false)
        }
        selectedFeePosition = fromChain.getFeeBasePosition()
        cosmosTxFee = fromChain.getInitPayableFee()
        feeSegments.selectedSegmentIndex = selectedFeePosition
        
        if let feeAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
            feeSelectImg.af.setImage(withURL: feeAsset.assetImg())
            feeSelectLabel.text = feeAsset.symbol
            feeDenomLabel.text = feeAsset.symbol
            
            let feePrice = BaseData.instance.getPrice(feeAsset.coinGeckoId)
            let feeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
            let feeDpAmount = feeAmount.multiplying(byPowerOf10: -feeAsset.decimals!, withBehavior: getDivideHandler(feeAsset.decimals!))
            let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, feeAsset.decimals!)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxSendAddressSheet(nibName: "TxSendAddressSheet", bundle: nil)
        addressSheet.fromChain = fromChain
        addressSheet.toChain = toChain
        addressSheet.sendType = sendType
        addressSheet.senderBechAddress = fromChain.bechAddress
        addressSheet.senderEvmAddress = fromChain.evmAddress
        addressSheet.existedAddress = toAddress
        addressSheet.sendAddressDelegate = self
        onStartSheet(addressSheet, 220, 0.6)
    }
    
    func onUpdateToAddressView(_ address: String) {
        if (address.isEmpty == true) {
            toAddress = ""
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
            
        } else {
            toAddress = address
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = toAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
            onSimul()
        }
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = toMemo
        memoSheet.memoDelegate = self
        onStartSheet(memoSheet, 260, 0.6)
    }
    
    func onUpdateMemoView(_ memo: String) {
        if (toMemo != memo) {
            toMemo = memo
            if (toMemo.isEmpty) {
                memoLabel.isHidden = true
                memoHintLabel.isHidden = false
            } else {
                memoLabel.text = toMemo
                memoLabel.isHidden = false
                memoHintLabel.isHidden = true
            }
            onSimul()
        }
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, cosmosTxFee.amount[0].denom)
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeDenom() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = fromChain
        baseSheet.feeDatas = cosmosFeeInfos[selectedFeePosition].FeeDatas
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectFeeDenom
        onStartSheet(baseSheet, 240, 0.6)
    }
    
    func onUpdateFeeView() {
        if let feeAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
            feeSelectImg.af.setImage(withURL: feeAsset.assetImg())
            feeSelectLabel.text = feeAsset.symbol
            feeDenomLabel.text = feeAsset.symbol
            
            let feePrice = BaseData.instance.getPrice(feeAsset.coinGeckoId)
            let feeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
            let feeDpAmount = feeAmount.multiplying(byPowerOf10: -feeAsset.decimals!, withBehavior: getDivideHandler(feeAsset.decimals!))
            let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, feeAsset.decimals!)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    func onUpdateFeeViewAfterSimul(_ simul: Cosmos_Tx_V1beta1_SimulateResponse?) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        
        if (fromChain.isGasSimulable() == false) {
            onUpdateFeeView()
            sendBtn.isEnabled = true
            return
        }
        guard let toGas = simul?.gasInfo.gasUsed else {
            feeCardView.isHidden = true
            errorCardView.isHidden = false
            errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
            return
        }
        cosmosTxFee.gasLimit = UInt64(Double(toGas) * fromChain.gasMultiply())
        if let gasRate = cosmosFeeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
            let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
            let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
            cosmosTxFee.amount[0].amount = feeCoinAmount!.stringValue
        }
        onUpdateFeeView()
        sendBtn.isEnabled = true
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        sendBtn.isEnabled = false
        if (toAddress.isEmpty == true) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        
        if (fromChain.isGasSimulable() == false) {
            return onUpdateFeeViewAfterSimul(nil)
        }
        cw721SendSimul()
    }
    
    func cw721SendSimul() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, fromChain.bechAddress!) {
                do {
                    let simul = try await simulCw721SendTx(channel, auth!, onBindCw20Send())
                    DispatchQueue.main.async {
                        self.onUpdateFeeViewAfterSimul(simul)
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
    
    func cw721Send() {
        Task {
            let channel = getConnection()
            if let auth = try? await fetchAuth(channel, fromChain.bechAddress!),
               let response = try await broadcast721SendTx(channel, auth!, onBindCw20Send()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
                    let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                    txResult.txStyle = self.txStyle
                    txResult.fromChain = self.fromChain
                    txResult.toChain = self.toChain
                    txResult.toAddress = self.toAddress
                    txResult.toMemo = self.toMemo
                    txResult.cosmosBroadcastTxResponse = response
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
            }
        }
    }
    
    func onBindCw20Send() -> Cosmwasm_Wasm_V1_MsgExecuteContract {
        let msg: JSON = ["transfer_nft" : ["token_id" : toSendNFT.tokens[0].tokenId, "recipient" : toAddress]]
        let msgBase64 = try! msg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        return Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = fromChain.bechAddress!
            $0.contract = toSendNFT.info["contractAddress"].stringValue
            $0.msg = Data(base64Encoded: msgBase64)!
        }
    }
}


extension NftTransfer: BaseSheetDelegate, SendAddressDelegate, MemoDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = cosmosFeeInfos[selectedFeePosition].FeeDatas[index].denom {
                cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        if let Memo = memo {
            toMemo = Memo
            if (toMemo.isEmpty) {
                memoLabel.isHidden = true
                memoHintLabel.isHidden = false
            } else {
                memoLabel.text = toMemo
                memoLabel.isHidden = false
                memoHintLabel.isHidden = true
            }
        }
        onUpdateToAddressView(address)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            cw721Send()
        }
    }
}


extension NftTransfer {
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Cosmos_Auth_V1beta1_QueryAccountResponse? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get()
    }
    
    func simulCw721SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        let simulTx = Signer.genWasmSimul(auth, [toWasmSend], cosmosTxFee, toMemo, fromChain)
        do {
            return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).simulate(simulTx, callOptions: getCallOptions()).response.get()
        } catch {
            throw error
        }
    }
    
    func broadcast721SendTx(_ channel: ClientConnection, _ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toWasmSend: Cosmwasm_Wasm_V1_MsgExecuteContract) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let reqTx = Signer.genWasmTx(auth, [toWasmSend], cosmosTxFee, toMemo, fromChain)
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: channel).broadcastTx(reqTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: fromChain.getGrpcfetcher()!.getGrpc().0, port: fromChain.getGrpcfetcher()!.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}
