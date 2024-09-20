//
//  CommonTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/18.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import web3swift
import Web3Core
import BigInt
import SwiftProtobuf
import SDWebImage


class CommonTransfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleCoinImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toChainCardView: FixCardView!
    @IBOutlet weak var toChainTitle: UILabel!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var toSendAssetCard: FixCardView!
    @IBOutlet weak var toSendAssetTitle: UILabel!
    @IBOutlet weak var toSendAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    @IBOutlet weak var arrowDownImage: UIImageView!
    
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var fromChain: BaseChain!
    var sendAssetType: SendAssetType!
    var txStyle: TxStyle!                   // .COSMOS_EVM_MAIN_COIN is only change tx style
    
    var toSendDenom: String!                        // coin denom or contract addresss
    var toSendMsAsset: MintscanAsset!               // to send Coin
    var toSendMsToken: MintscanToken!               // to send Token
    var ibcPath: MintscanPath?                      // to IBC send path
    var recipientableChains = [BaseChain]()
    var availableAmount = NSDecimalNumber.zero
    var decimal: Int16!
    
    var toChain: BaseChain!
    var toAddress = ""
    var toAmount = NSDecimalNumber.zero
    var txMemo = ""
    var selectedFeePosition = 0
    
    var cosmosFetcher: CosmosFetcher!
    var cosmosFeeInfos = [FeeInfo]()
    var cosmosTxFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()
    var cosmosTxTip: Cosmos_Tx_V1beta1_Tip?
    
    var evmFetcher: EvmFetcher!
    var evmTx: CodableTransaction?
    var evmTxType : TransactionType?
    var evmGasTitle: [String] = [NSLocalizedString("str_low", comment: ""), NSLocalizedString("str_average", comment: ""), NSLocalizedString("str_high", comment: "")]
    var evmGas: [(BigUInt, BigUInt)] = [(500000000, 1000000000), (500000000, 1000000000), (500000000, 1000000000)]
    var evmGasLimit: BigUInt = 21000
    var web3: Web3?
    
    var suiFetcher: SuiFetcher!
    var suiFeeBudget = NSDecimalNumber.zero
    var suiGasPrice = NSDecimalNumber.zero
    
    var btcFetcher: BtcFetcher!
    var btcTxFee = NSDecimalNumber.zero
    var btcTxHex = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        view.isUserInteractionEnabled = false
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        feeSelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFeeCoin)))
        
        //set Txstyle and init
        Task {
            if (sendAssetType == .EVM_COIN || sendAssetType == .EVM_ERC20) {
                txStyle = .WEB3_STYLE
                
            } else if (sendAssetType == .SUI_COIN) {
                txStyle = .SUI_STYLE
                suiFetcher = (fromChain as? ChainSui)?.getSuiFetcher()
                suiGasPrice = try await suiFetcher.fetchGasprice()
            } else if (sendAssetType == .BTC_COIN) {
                txStyle = .BTC_STYLE
                btcFetcher = (fromChain as? ChainBitCoin84)?.getBtcFetcher()
                
            } else {
                txStyle = .COSMOS_STYLE
                cosmosFetcher = fromChain.getCosmosfetcher()
            }
            
            if (fromChain.supportEvm) {
                evmFetcher = fromChain.getEvmfetcher()
                if let url = URL(string: evmFetcher.getEvmRpc()),
                   let web3Provider = try? await Web3HttpProvider.init(url: url, network: nil) {
                    self.web3 = Web3.init(provider: web3Provider)
                } else {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                self.onInitIbcInfo()                        // set recipientable chains for IBC tx
                self.onInitToChain()                        // set init toChain UI
                self.onInitFee()                            // set init fee for set send available
                self.onInitView()                           // set selected asset display symbol, sendable amount, display decimal
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 685
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        toChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        toAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetTitle.text = NSLocalizedString("str_amount", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoTitle.text = NSLocalizedString("str_memo_optional", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    func onInitIbcInfo() {
        recipientableChains.append(fromChain)
        // check IBC support case for recipient chain
        let allIbcChains = ALLCHAINS().filter({ $0.isTestnet == false && $0.supportCosmos })
        BaseData.instance.mintscanAssets?.forEach({ msAsset in
            if (sendAssetType == .COSMOS_COIN || sendAssetType == .COSMOS_EVM_MAIN_COIN) {
                if (msAsset.chain == fromChain.apiName && msAsset.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add backward path
                    if let sendable = allIbcChains.filter({ $0.apiName == msAsset.beforeChain(fromChain.apiName) }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                    }
                } else if (msAsset.getjustBeforeChain() == fromChain.apiName && msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add forward path
                    if let sendable = allIbcChains.filter({ $0.apiName == msAsset.chain }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                    }
                }
                
            } else if (sendAssetType == .COSMOS_WASM ) {
                //CW20 only support forward IBC path
                if (msAsset.origin_chain == fromChain.apiName && msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    if let sendable = allIbcChains.filter({ $0.apiName == msAsset.chain }).first {
                        if !recipientableChains.contains(where: { $0.apiName == sendable.apiName }) {
                            recipientableChains.append(sendable)
                        }
                    }
                }
            }
        })
        recipientableChains.sort {
            if ($0.name == fromChain.name) { return true }
            if ($1.name == fromChain.name) { return false }
            if ($0.name == "Cosmos") { return true }
            if ($1.name == "Cosmos") { return false }
            return false
        }
        if (recipientableChains.count > 1) {
            toChainCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToChain)))
        }
    }
    
    func onInitToChain() {
        toChain = fromChain
        toChainImg.image = UIImage.init(named: toChain.logo1)
        toChainLabel.text = toChain.name.uppercased()
    }
    
    func onInitFee() {
        if (txStyle == .WEB3_STYLE) {
            feeSegments.removeAllSegments()
            for i in 0..<evmGasTitle.count {
                feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
            }
            selectedFeePosition = 1
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectImg.image =  UIImage.init(named: fromChain.coinLogo)
            
            feeSelectLabel.text = fromChain.coinSymbol
            feeDenomLabel.text = fromChain.coinSymbol
            
        } else if (txStyle == .SUI_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectImg.image =  UIImage.init(named: fromChain.coinLogo)
            
            feeSelectLabel.text = fromChain.coinSymbol
            feeDenomLabel.text = fromChain.coinSymbol
            
            suiFeeBudget = suiFetcher.baseFee(.SUI_SEND_COIN)
            
        } else if (txStyle == .BTC_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectImg.image =  UIImage.init(named: fromChain.coinLogo)
            
            feeSelectLabel.text = fromChain.coinSymbol
            feeDenomLabel.text = fromChain.coinSymbol
            
            btcInitFee()
            
        } else if (txStyle == .COSMOS_STYLE) {
            if (cosmosFetcher.cosmosBaseFees.count > 0) {
                feeSegments.removeAllSegments()
                feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
                feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
                feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
                feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
                feeSegments.selectedSegmentIndex = selectedFeePosition
                
                let baseFee = cosmosFetcher.cosmosBaseFees[0]
                let gasAmount: NSDecimalNumber = fromChain.getFeeBaseGasAmount()
                let feeDenom = baseFee.denom
                let feeAmount = baseFee.getdAmount().multiplying(by: gasAmount, withBehavior: handler0Down)
                cosmosTxFee.gasLimit = gasAmount.uint64Value
                cosmosTxFee.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount)]
                
            } else {
                cosmosFeeInfos = fromChain.getFeeInfos()
                feeSegments.removeAllSegments()
                for i in 0..<cosmosFeeInfos.count {
                    feeSegments.insertSegment(withTitle: cosmosFeeInfos[i].title, at: i, animated: false)
                }
                selectedFeePosition = fromChain.getFeeBasePosition()
                feeSegments.selectedSegmentIndex = selectedFeePosition
                cosmosTxFee = fromChain.getInitPayableFee()!
            }
        }
        onUpdateFeeView()
    }
    
    func onInitView() {
        var symbol = ""
        if (sendAssetType == .COSMOS_COIN || sendAssetType == .COSMOS_EVM_MAIN_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            availableAmount = cosmosFetcher.balanceAmount(toSendDenom)
            if (cosmosTxFee.amount[0].denom == toSendDenom) {
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                availableAmount = availableAmount.subtracting(totalFeeAmount)
            }
            
        } else if (sendAssetType == .EVM_COIN) {
            titleCoinImg.image =  UIImage.init(named: fromChain.coinLogo)
            decimal = 18
            symbol = fromChain.coinSymbol
            availableAmount = evmFetcher.evmBalances.subtracting(EVM_BASE_FEE)
            
        } else if (sendAssetType == .COSMOS_WASM || sendAssetType == .EVM_ERC20) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            availableAmount = toSendMsToken!.getAmount()
            
        } else if (sendAssetType == .SUI_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            availableAmount = suiFetcher.balanceAmount(toSendDenom)
            
            if (fromChain.stakeDenom == toSendDenom) {
                availableAmount = availableAmount.subtracting(suiFeeBudget)
            }
            
        } else if (sendAssetType == .BTC_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            availableAmount = btcFetcher.btcBalances

        }
        
        if txStyle != .COSMOS_STYLE {
            arrowDownImage.isHidden = true
        }
        
        titleLabel.text = String(format: NSLocalizedString("str_send_asset", comment: ""), symbol)
        
        loadingView.isHidden = true
        titleCoinImg.isHidden = false
        titleLabel.isHidden = false
        toChainCardView.isHidden = false
        toAddressCardView.isHidden = false
        toSendAssetCard.isHidden = false
        memoCardView.isHidden = (txStyle != .COSMOS_STYLE && txStyle != .BTC_STYLE)
        feeCardView.isHidden = false
        sendBtn.isHidden = false
        view.isUserInteractionEnabled = true
    }
    
    
    
    
    func onUpdateTxStyle(_ style: TxStyle) {
        if (sendAssetType == .COSMOS_EVM_MAIN_COIN && style != txStyle) {
            txStyle = style
            if (txStyle == .WEB3_STYLE) {
                decimal = 18
                availableAmount = evmFetcher.evmBalances.subtracting(EVM_BASE_FEE)
                memoCardView.isHidden = true
                
            } else if (txStyle == .COSMOS_STYLE) {
                decimal = toSendMsAsset!.decimals
                availableAmount = cosmosFetcher.balanceAmount(toSendDenom)
                if (cosmosTxFee.amount[0].denom == toSendDenom) {
                    let feeAmount = NSDecimalNumber.init(string: cosmosTxFee.amount[0].amount)
                    availableAmount = availableAmount.subtracting(feeAmount)
                }
                memoCardView.isHidden = false
            }
            onInitFee()
            onUpdateAmountView("")
        }
    }
    
    
    @objc func onClickToChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.cosmosChainList = recipientableChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectCosmosRecipientChain
        onStartSheet(baseSheet, 400, 0.8)
    }
    
    func onUpdateToChain(_ chain: BaseChain) {
        if (chain.tag != toChain.tag) {
            toChain = chain
            toChainImg.image = UIImage.init(named: toChain.logo1)
            toChainLabel.text = toChain.name.uppercased()
            onUpdateToAddressView("")
            
            if (sendAssetType == .COSMOS_EVM_MAIN_COIN && fromChain.tag != toChain.tag) {
                onUpdateTxStyle(.COSMOS_STYLE)
            }
        }
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxSendAddressSheet(nibName: "TxSendAddressSheet", bundle: nil)
        addressSheet.fromChain = fromChain
        addressSheet.toChain = toChain
        addressSheet.sendType = sendAssetType
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
            
            if (sendAssetType == .COSMOS_EVM_MAIN_COIN) {
                if (toAddress.starts(with: "0x")) {
                    onUpdateTxStyle(.WEB3_STYLE)
                } else {
                    onUpdateTxStyle(.COSMOS_STYLE)
                }
            }
            onSimul()
        }
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxSendAmountSheet(nibName: "TxSendAmountSheet", bundle: nil)
        amountSheet.fromChain = fromChain
        amountSheet.sendAssetType = sendAssetType
        amountSheet.txStyle = txStyle
        amountSheet.toSendDenom = toSendDenom
        amountSheet.toSendMsAsset = toSendMsAsset
        amountSheet.toSendMsToken = toSendMsToken
        amountSheet.availableAmount = availableAmount
        amountSheet.existedAmount = toAmount
        amountSheet.decimal = decimal
        amountSheet.sheetDelegate = self
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        if (amount?.isEmpty == true) {
            toAmount = NSDecimalNumber.zero
            toSendAssetHint.isHidden = false
            toAssetAmountLabel.isHidden = true
            toAssetDenomLabel.isHidden = true
            toAssetCurrencyLabel.isHidden = true
            toAssetValueLabel.isHidden = true
            
        } else {
            toAmount = NSDecimalNumber(string: amount)
            if (sendAssetType == .COSMOS_WASM || sendAssetType == .EVM_ERC20) {
                let msPrice = BaseData.instance.getPrice(toSendMsToken!.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpToken(toSendMsToken!, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else if (sendAssetType == .COSMOS_COIN) {
                let msPrice = BaseData.instance.getPrice(toSendMsAsset!.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpCoin(toSendMsAsset, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else if (sendAssetType == .EVM_COIN) {
                let msPrice = BaseData.instance.getPrice(fromChain.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                toAssetDenomLabel.text = fromChain.coinSymbol
                toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                
            } else if (sendAssetType == .COSMOS_EVM_MAIN_COIN) {
                let msPrice = BaseData.instance.getPrice(fromChain.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                if (txStyle == .WEB3_STYLE) {
                    toAssetDenomLabel.text = fromChain.coinSymbol
                    toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                    
                } else if (txStyle == .COSMOS_STYLE) {
                    WDP.dpCoin(toSendMsAsset, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                }
                
            } else if (sendAssetType == .SUI_COIN) {
                let msPrice = BaseData.instance.getPrice(fromChain.assetGeckoId(toSendDenom))
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                toAssetDenomLabel.text = fromChain.assetSymbol(toSendDenom)
                toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                
            } else if (sendAssetType == .BTC_COIN) {
                let msPrice = BaseData.instance.getPrice(fromChain.coinGeckoId)     //
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                toAssetDenomLabel.text = fromChain.assetSymbol(toSendDenom)
                toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)

            }
            toSendAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
            toAssetCurrencyLabel.isHidden = false
            toAssetValueLabel.isHidden = false
            
            onSimul()
        }
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        if toChain is ChainBitCoin84 {
            memoSheet.isSendBTC = true
        }
        onStartSheet(memoSheet, 260, 0.6)
    }
    
    func onUpdateMemoView(_ memo: String) {
        if (txMemo != memo) {
            txMemo = memo
            if (txMemo.isEmpty) {
                memoLabel.isHidden = true
                memoHintLabel.isHidden = false
                onSimul()
            } else {
                memoLabel.text = txMemo
                memoLabel.isHidden = false
                memoHintLabel.isHidden = true
                onSimul()
            }
        }
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        if (txStyle == .COSMOS_STYLE) {
            if (cosmosFetcher.cosmosBaseFees.count > 0) {
                if let baseFee = cosmosFetcher.cosmosBaseFees.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                    let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                    cosmosTxFee.amount[0].amount = feeAmount.stringValue
                    cosmosTxFee = Signer.setFee(selectedFeePosition, cosmosTxFee)
                }
            } else {
                cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, cosmosTxFee.amount[0].denom)
            }
        }
        onUpdateFeeView()
        onSimul()
    }
    
    @objc func onSelectFeeCoin() {
        if (txStyle == .COSMOS_STYLE) {                                     // only cosmos style support multi type fee denom
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.targetChain = fromChain
            baseSheet.sheetDelegate = self
            if (cosmosFetcher.cosmosBaseFees.count > 0) {
                baseSheet.baseFeesDatas = cosmosFetcher.cosmosBaseFees
                baseSheet.sheetType = .SelectBaseFeeDenom
            } else {
                baseSheet.feeDatas = cosmosFeeInfos[selectedFeePosition].FeeDatas
                baseSheet.sheetType = .SelectFeeDenom
            }
            onStartSheet(baseSheet, 240, 0.6)
        }
    }
    
    // user changed segment or fee coin denom kinds
    func onUpdateFeeView() {
        sendBtn.isEnabled = false
        errorCardView.isHidden = true
        if (txStyle == .WEB3_STYLE) {
            let feePrice = BaseData.instance.getPrice(fromChain.coinGeckoId)
            let totalGasPrice = evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1
            let feeAmount = NSDecimalNumber(string: String(totalGasPrice.multiplied(by: evmGasLimit)))
            let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
            let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .SUI_STYLE) {
            let feePrice = BaseData.instance.getPrice(fromChain.coinGeckoId)
            let feeDpBudge = suiFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
            let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeDpBudge.stringValue, feeAmountLabel!.font, 9)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .BTC_STYLE) {
            let feePrice = BaseData.instance.getPrice(fromChain.coinGeckoId)
            let feeAmount = btcTxFee.multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8))
            let feeValue = feePrice.multiplying(by: feeAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 8)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            availableAmount = availableAmount.subtracting(btcTxFee)

        } else if (txStyle == .COSMOS_STYLE) {
            if let msAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
                feeSelectLabel.text = msAsset.symbol
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
                
                if (sendAssetType == .COSMOS_COIN || (sendAssetType == .COSMOS_EVM_MAIN_COIN && txStyle == .COSMOS_STYLE)) {
                    let stakeDenom = fromChain.stakeDenom!
                    let balanceAmount = cosmosFetcher.balanceAmount(toSendDenom)
                    if (cosmosTxFee.amount[0].denom == stakeDenom) {
                        if (totalFeeAmount.compare(balanceAmount).rawValue > 0) {
                            //ERROR short balance!!
                        }
                        availableAmount = balanceAmount.subtracting(totalFeeAmount)
                        
                    } else {
                        availableAmount = balanceAmount
                    }
                }
            }
        }
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?, _ errorMessage: String? = nil) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        if (txStyle == .WEB3_STYLE) {
            guard evmTx != nil else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            
        } else if (txStyle == .SUI_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            suiFeeBudget = NSDecimalNumber.init(value: toGas)
            
        } else if (txStyle == .BTC_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            btcTxFee = NSDecimalNumber.init(value: toGas)
            sendBtn.isHidden = false

        } else if (txStyle == .COSMOS_STYLE) {
            if (fromChain.isGasSimulable() == false) {
                onUpdateFeeView()
                sendBtn.isEnabled = true
                return
            }
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            cosmosTxFee.gasLimit = UInt64(Double(toGas) * fromChain.gasMultiply())
            if (cosmosFetcher.cosmosBaseFees.count > 0) {
                if let baseFee = cosmosFetcher.cosmosBaseFees.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                    let feeAmount = baseFee.getdAmount().multiplying(by: gasLimit, withBehavior: handler0Up)
                    cosmosTxFee.amount[0].amount = feeAmount.stringValue
                    cosmosTxFee = Signer.setFee(selectedFeePosition, cosmosTxFee)
                }
                
            } else {
                if let gasRate = cosmosFeeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                    let gasLimit = NSDecimalNumber.init(value: cosmosTxFee.gasLimit)
                    let feeAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                    cosmosTxFee.amount[0].amount = feeAmount!.stringValue
                }
            }
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
        if (toAmount == NSDecimalNumber.zero ) { return }
        if (toAddress.isEmpty == true) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        
        if (txStyle == .WEB3_STYLE) {
            evmSendSimul()
            
        } else if (txStyle == .SUI_STYLE) {
            suiSendGasCheck()
            
        } else if (txStyle == .BTC_STYLE) {
            btcFetchTxHex()

        } else if (txStyle == .COSMOS_STYLE) {
            // some chain not support simulate (assetmantle)  24.2.21
            if (fromChain.isGasSimulable() == false) {
                if (fromChain.chainIdCosmos != toChain.chainIdCosmos) {
                    ibcPath = WUtils.getMintscanPath(fromChain, toChain, toSendDenom)
                }
                return onUpdateWithSimul(nil)
            }
            if (fromChain.chainIdCosmos == toChain.chainIdCosmos) {                 // Inchain Send!
                if (sendAssetType == .COSMOS_WASM) {                                // Inchain CW20 Send!
                    inChainWasmSendSimul()
                } else {                                                            // Inchain Coin Send!  (COSMOS_COIN, COSMOS_EVM_MAIN_COIN)
                    inChainCoinSendSimul()
                }
            } else {                                                                // IBC Send!
                ibcPath = WUtils.getMintscanPath(fromChain, toChain, toSendDenom)
                if (sendAssetType == .COSMOS_WASM) {                                // CW20 IBC Send!
                    ibcWasmSendSimul()
                } else {                                                            // Coin IBC Send! (COSMOS_COIN, COSMOS_EVM_MAIN_COIN)
                    ibcCoinSendSimul()
                }
            }
        }
    }

}



//Evm style tx simul and broadcast
extension CommonTransfer {
    
    func evmSendSimul() {
        Task {
            guard let web3 = self.web3 else {
                print("web3 init error")
                evmTxType = nil
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil)
                }
                return
            }
            
            let oracle = Web3Core.Oracle.init(web3.provider)
            if let feeHistory = await oracle.bothFeesPercentiles(),
               feeHistory.baseFee.count > 0 {
                //support EIP1559
//                print("feeHistory ", feeHistory)
                if (fromChain.evmSupportEip1559()) {
                    for i in 0..<3 {
                        let baseFee = feeHistory.baseFee[i]
                        let tip = feeHistory.tip[i]
                        evmGas[i] = (baseFee, tip)
                    }
                    
                } else {
                    for i in 0..<3 {
                        let baseFee = feeHistory.baseFee[i] > 500000000 ? feeHistory.baseFee[i] : 500000000
                        let tip = feeHistory.tip[i] > 1000000000 ? feeHistory.tip[i] : 1000000000
                        evmGas[i] = (baseFee, tip)
                    }
                }
                evmTxType = .eip1559
                
            } else if let gasprice = try? await web3.eth.gasPrice() {
                //only Legacy
//                print("gasprice ", gasprice)
                evmGas[0].0 = gasprice
                evmGas[1].0 = gasprice * 12 / 10
                evmGas[2].0 = gasprice * 20 / 10
                evmTxType = .legacy
                
            } else {
//                print("no gas error")
                evmTxType = nil
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil)
                }
                return
            }
//            print("evmGas ", evmGas)
            
            let chainID = web3.provider.network?.chainID
            let senderAddress = EthereumAddress.init(fromChain.evmAddress!)
            let recipientAddress = EthereumAddress.init(toAddress)
            let nonce = try? await web3.eth.getTransactionCount(for: senderAddress!)
            let calSendAmount = self.toAmount.multiplying(byPowerOf10: -decimal)
            var toAddress: EthereumAddress!
            
            if (sendAssetType == .EVM_ERC20) {
                toAddress = EthereumAddress.init(toSendMsToken.address!)
                let erc20token = ERC20(web3: web3, provider: web3.provider, address: toAddress!)
                let writeOperation = try await erc20token.transfer(from: senderAddress!, to: recipientAddress!, amount: calSendAmount.stringValue)
                if (evmTxType == .eip1559) {
                    evmTx = CodableTransaction.init(type: evmTxType, to: toAddress, nonce: nonce!,
                                                    chainID: chainID!, data: writeOperation.data!,
                                                    maxFeePerGas: evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1, 
                                                    maxPriorityFeePerGas: evmGas[selectedFeePosition].1)
                } else {
                    evmTx = CodableTransaction.init(type: evmTxType, to: toAddress, nonce: nonce!,
                                                    chainID: chainID!, data: writeOperation.data!,
                                                    gasPrice: evmGas[selectedFeePosition].0)
                }
                
            } else {
                toAddress = recipientAddress
                let value = Web3Core.Utilities.parseToBigUInt(calSendAmount.stringValue, units: .ether)!
                if (evmTxType == .eip1559) {
                    evmTx = CodableTransaction.init(type: evmTxType, to: toAddress, nonce: nonce!,
                                                    chainID: chainID!, value: value,
                                                    maxFeePerGas: evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1,
                                                    maxPriorityFeePerGas: evmGas[selectedFeePosition].1)
                } else {
                    evmTx = CodableTransaction.init(type: evmTxType, to: toAddress, nonce: nonce!,
                                                    chainID: chainID!, value: value,
                                                    gasPrice: evmGas[selectedFeePosition].0)
                }
            }
            evmTx?.from = senderAddress
            
//            print("evmTxA ", evmTx)
            if let estimateGas = try? await web3.eth.estimateGas(for: evmTx!) {
                evmGasLimit = estimateGas * fromChain.evmGasMultiply() / 10
                evmTx?.gasLimit = evmGasLimit
            } else {
                evmTxType = nil
            }
            
            DispatchQueue.main.async {
                self.onUpdateWithSimul(nil)
            }
        }
    }
    
    func evmSend() {
        Task {
            guard let web3 = self.web3 else {
                print("web3 init error")
                return
            }
            
            do {
                try self.evmTx?.sign(privateKey: fromChain.privateKey!)
                let encodeTx = self.evmTx?.encode(for: .transaction)
                let result = try await web3.eth.send(raw : encodeTx!)
//                print("result ", result)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
                    let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                    txResult.txStyle = self.txStyle
                    txResult.fromChain = self.fromChain
                    txResult.toChain = self.toChain
                    txResult.toAddress = self.toAddress
                    txResult.evmHash = result.hash
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
                
            } catch {
                print("error ", error)
            }
            
        }
    }
}

// BTC style tx getFee and broadcast
extension CommonTransfer {
    
    func btcInitFee() {
        Task {
            do {
                if let fee = try await btcFetcher.initFee() {
                    btcTxFee = NSDecimalNumber(value: fee)
                    onUpdateFeeView()

                } else {
                    print("Fail fetch fee rate")
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    
    func btcFetchTxHex() {
        Task {
            do {
                if let utxos = try await btcFetcher.fetchUtxos()?.filter({ $0["status"]["confirmed"].boolValue }) {
                    
                    let type = BtcTxType.init(rawValue: fromChain.accountKeyType.pubkeyType.algorhythm!)!
                    let opReturnVbyte = !txMemo.isEmpty ? 83 : 0
                    let vbyte = (type.vbyte.overhead) + (type.vbyte.inputs * utxos.count) + (type.vbyte.output * (!txMemo.isEmpty ? 3 : 2)) + (opReturnVbyte)
                    let estimatesmartfee = try await btcFetcher.fetchEstimatesmartfee()
                    let feeRate = estimatesmartfee["result"]["feerate"].doubleValue
                    
                    let fee = UInt64(ceil(Double(vbyte) * feeRate * 100000))
                    if let error = estimatesmartfee["error"]["message"].string {
                        DispatchQueue.main.async {
                            self.onUpdateWithSimul(nil, error)
                        }
                        print("Fail fetch estimatesmartfee", error)
                        return
                    }
                    
                
                    if UInt64(truncating: toAmount) < fee {
                        self.onUpdateWithSimul(nil, "Unable to transfer less than fee (dust transaction)")
                        
                        let feeAmount = NSDecimalNumber.init(value: fee).multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8))
                        feeAmountLabel.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 8)

                        return
                    }
                    
                    let txString = await btcFetcher.getTxString(utxos, fromChain, toAddress, toAmount, fee, !txMemo.isEmpty ? txMemo : nil)
                    
                    btcTxHex = BtcJS().getTxHex(txString)
                    
                    if btcTxHex == "undefined" {
                        self.onUpdateWithSimul(nil, "Invalid transaction hex value")
                        return
                    }

                    
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(fee)
                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil, error.localizedDescription)
                }
                
                print("Fail BTC Fetch Tx Hex", error)
            }
        }
    }
    
    func btcSend(_ txHex: String) {
        Task {
            do {
                let result = try await btcFetcher.sendRawtransaction(txHex)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
                    let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                    txResult.txStyle = self.txStyle
                    txResult.fromChain = self.fromChain
                    txResult.toChain = self.toChain
                    txResult.toAddress = self.toAddress
                    txResult.btcResult = result
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
                
            } catch {
                print("Fail Btc send",error)
                onShowToast(error.localizedDescription)
            }
        }
    }
}


//Sui style tx dryrun and broadcast
extension CommonTransfer {
    
    func suiSendGasCheck() {
        Task {
            if let txBytes = try await suiFetcher.unsafeCoinSend(toSendDenom, fromChain.mainAddress, suiInputs(), [toAddress], [toAmount.stringValue], suiFeeBudget.stringValue),
               let response = try await suiFetcher.suiDryrun(txBytes) {   
                if let error = response["error"]["message"].string {
                   DispatchQueue.main.async {
                       self.onUpdateWithSimul(nil, error)
                   }
                   return
               }

                let computationCost = NSDecimalNumber(string: response["result"]["effects"]["gasUsed"]["computationCost"].stringValue)
                let storageCost = NSDecimalNumber(string: response["result"]["effects"]["gasUsed"]["storageCost"].stringValue)
                let storageRebate = NSDecimalNumber(string: response["result"]["effects"]["gasUsed"]["storageRebate"].stringValue)
                
                var gasCost: UInt64 = 0
                if (storageCost.compare(storageRebate).rawValue > 0) {
                    gasCost = computationCost.adding(storageCost).subtracting(storageRebate).multiplying(by: NSDecimalNumber(string: "1.3") , withBehavior: handler0Down).uint64Value
                } else {
                    gasCost = computationCost.multiplying(by: NSDecimalNumber(string: "1.3") , withBehavior: handler0Down).uint64Value
                }
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(gasCost)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil)
                }
            }
        }
    }
    
    func suiSend() {
        Task {
            do {
                if let txBytes = try await suiFetcher.unsafeCoinSend(toSendDenom, fromChain.mainAddress, suiInputs(), [toAddress], [toAmount.stringValue], suiFeeBudget.stringValue),
                   let dryRes = try await suiFetcher.suiDryrun(txBytes), dryRes["error"].isEmpty,
                   let broadRes = try await suiFetcher.suiExecuteTx(txBytes, Signer.suiSignatures(fromChain, txBytes), nil) {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.suiResult = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }
    
    func suiInputs() -> [String] {
        var result = [String]()
        suiFetcher.suiObjects.forEach { object in
            if (object["type"].stringValue.contains(toSendDenom)) {
                result.append(object["objectId"].stringValue)
            }
        }
        return result
    }
    
}

//Cosmos style tx simul and broadcast
extension CommonTransfer {
   
    func inChainCoinSendSimul() {
        Task {
            do {
                if let simulReq = try await Signer.genSimul(fromChain, onBindSendMsg(), txMemo, cosmosTxFee, nil),
                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
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
    
    func inChainCoinSend() {
        Task {
            do {
                if let broadReq = try await Signer.genTx(fromChain, onBindSendMsg(), txMemo, cosmosTxFee, nil),
                   let broadRes = try await cosmosFetcher.broadcastTx(broadReq) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.txMemo = self.txMemo
                        txResult.cosmosBroadcastTxResponse = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }
    
    func onBindSendMsg() -> [Google_Protobuf_Any] {
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toAmount.stringValue
        }
        let sendMsgs = Cosmos_Bank_V1beta1_MsgSend.with {
            $0.fromAddress = fromChain.bechAddress!
            $0.toAddress = toAddress
            $0.amount = [sendCoin]
        }
        return Signer.genSendMsg(sendMsgs)
    }
    
    
    
    func inChainWasmSendSimul() {
        Task {
            do {
                if let simulReq = try await Signer.genSimul(fromChain, onBindCw20SendMsg(), txMemo, cosmosTxFee, nil),
                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
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
    
    func inChainWasmSend() {
        Task {
            do {
                if let broadReq = try await Signer.genTx(fromChain, onBindCw20SendMsg(), txMemo, cosmosTxFee, nil),
                   let broadRes = try await cosmosFetcher.broadcastTx(broadReq) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.txMemo = self.txMemo
                        txResult.cosmosBroadcastTxResponse = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }
    
    
    func onBindCw20SendMsg() -> [Google_Protobuf_Any]  {
        let msg: JSON = ["transfer" : ["recipient" : toAddress , "amount" : toAmount.stringValue]]
        let msgBase64 = try! msg.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let wasmMsg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = fromChain.bechAddress!
            $0.contract = toSendMsToken.address!
            $0.msg = Data(base64Encoded: msgBase64)!
        }
        return Signer.genWasmMsg([wasmMsg])
    }
    
    
    
    func ibcCoinSendSimul() {
        Task {
            do {
                let revisionNumber = try! await cosmosFetcher.fetchIbcClient(ibcPath!)
                let toCosmosFetcher = toChain!.getCosmosfetcher()
                let toLastBlock = try await toCosmosFetcher!.fetchLastBlock()
                if let simulReq = try await Signer.genSimul(fromChain, onBindIbcSendMsg(revisionNumber!, toLastBlock!), txMemo, cosmosTxFee, nil),
                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
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
    
    func ibcCoinSend() {
        Task {
            do {
                let revisionNumber = try! await cosmosFetcher.fetchIbcClient(ibcPath!)
                let toCosmosFetcher = toChain!.getCosmosfetcher()
                let toLastBlock = try await toCosmosFetcher!.fetchLastBlock()
                if let broadReq = try await Signer.genTx(fromChain, onBindIbcSendMsg(revisionNumber!, toLastBlock!), txMemo, cosmosTxFee, nil),
                   let broadRes = try await cosmosFetcher.broadcastTx(broadReq) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.txMemo = self.txMemo
                        txResult.cosmosBroadcastTxResponse = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }

    
    func onBindIbcSendMsg(_ revisionNumber: UInt64, _ lastBlock: Int64) -> [Google_Protobuf_Any] {
        let height = Ibc_Core_Client_V1_Height.with {
            $0.revisionNumber = revisionNumber
            $0.revisionHeight = UInt64(lastBlock) + (toChain.getTimeoutAdding() * 10)
        }
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toAmount.stringValue
        }
        let ibcSendMsg = Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = fromChain.bechAddress!
            $0.receiver = toAddress
            $0.sourceChannel = ibcPath!.channel!
            $0.sourcePort = ibcPath!.port!
            $0.timeoutHeight = height
            $0.timeoutTimestamp = 0
            $0.token = sendCoin
        }
        return Signer.genIbcSendMsg(ibcSendMsg)
    }
    
    
    
    func ibcWasmSendSimul() {
        Task {
            do {
                if let simulReq = try await Signer.genSimul(fromChain, onBindCw20IbcSendMsg(), txMemo, cosmosTxFee, nil),
                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
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
    
    func ibcWasmSend() {
        Task {
            do {
                if let broadReq = try await Signer.genTx(fromChain, onBindCw20IbcSendMsg(), txMemo, cosmosTxFee, nil),
                   let broadRes = try await cosmosFetcher.broadcastTx(broadReq) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.txMemo = self.txMemo
                        txResult.cosmosBroadcastTxResponse = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }
    
    
    func onBindCw20IbcSendMsg() -> [Google_Protobuf_Any] {
        let jsonMsg: JSON = ["channel" : ibcPath!.channel!, "remote_address" : toAddress, "timeout" : 900]
        let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        
        let innerMsg: JSON = ["send" : ["contract" : ibcPath!.getIBCContract(), "amount" : toAmount.stringValue, "msg" : jsonMsgBase64]]
        let innerMsgBase64 = try! innerMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        let ibcWasmMsg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = fromChain.bechAddress!
            $0.contract = toSendMsToken.address!
            $0.msg = Data(base64Encoded: innerMsgBase64)!
        }
        return Signer.genWasmMsg([ibcWasmMsg])
    }
}

extension CommonTransfer: BaseSheetDelegate, SendAddressDelegate, SendAmountSheetDelegate, MemoDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCosmosRecipientChain) {
            if let chainId = result["chainId"] as? String {
                if (chainId != toChain.chainIdCosmos) {
                    onUpdateToChain(recipientableChains.filter({ $0.chainIdCosmos == chainId }).first!)
                }
            }
        } else if (sheetType == .SelectFeeDenom) {
            if let index = result["index"] as? Int,
               let selectedDenom = cosmosFeeInfos[selectedFeePosition].FeeDatas[index].denom {
                cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, selectedDenom)
                onUpdateFeeView()
                onSimul()
            }
        } else if (sheetType == .SelectBaseFeeDenom) {
            if let index = result["index"] as? Int {
               let selectedDenom = cosmosFetcher.cosmosBaseFees[index].denom
                cosmosTxFee.amount[0].denom = selectedDenom
                onUpdateFeeView()
                onSimul()
            }
        }
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        if let Memo = memo {
            txMemo = Memo
            if (txMemo.isEmpty) {
                memoLabel.isHidden = true
                memoHintLabel.isHidden = false
            } else {
                memoLabel.text = txMemo
                memoLabel.isHidden = false
                memoHintLabel.isHidden = true
            }
        }
        onUpdateToAddressView(address)
    }
    
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            
            if (txStyle == .WEB3_STYLE) {
                evmSend()
                
            } else if (txStyle == .SUI_STYLE) {
                suiSend()
                
            } else if (txStyle == .BTC_STYLE) {
                btcSend(btcTxHex)
                
            } else if (txStyle == .COSMOS_STYLE) {
                if (fromChain.chainIdCosmos == toChain.chainIdCosmos) {                     // Inchain Send!
                    if (sendAssetType == .COSMOS_WASM) {                                         // Inchain CW20 Send!
                        inChainWasmSend()
                    } else {                                                                // Inchain Coin Send!  (COSMOS_COIN, COSMOS_EVM_MAIN_COIN)
                        inChainCoinSend()
                    }
                } else {                                                                    // IBC Send!
                    ibcPath = WUtils.getMintscanPath(fromChain, toChain, toSendDenom)
                    if (sendAssetType == .COSMOS_WASM) {                                         // CW20 IBC Send!
                        ibcWasmSend()
                    } else {                                                                // Coin IBC Send! (COSMOS_COIN, COSMOS_EVM_MAIN_COIN)
                        ibcCoinSend()
                    }
                }
            }
        }
    }
}

public enum SendAssetType: Int {
    case COSMOS_COIN = 0                    // support IBC, bank send                 (staking, ibc, native coins)
    case COSMOS_WASM = 1                    // support IBC, wasm send                 (cw20 tokens)
    case EVM_COIN = 2                       // not support IBC, only support Web3 tx  (evm main coin)
    case EVM_ERC20 = 3                      // not support IBC, only support Web3 tx  (erc20 tokens)
    case COSMOS_EVM_MAIN_COIN = 4           // support IBC, bank send, Web3 tx        (staking, both tx style)
    case SUI_COIN = 5                       // sui assets
    case SUI_NFT = 6                        // sui nft
    case BTC_COIN = 7                       // bitcoin
}


