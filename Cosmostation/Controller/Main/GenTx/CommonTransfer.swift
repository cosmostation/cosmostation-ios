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
    
    @IBOutlet weak var titleCoinImg: CircleImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toChainCardView: FixCardView!
    @IBOutlet weak var toChainTitle: UILabel!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainLabel: UILabel!
    @IBOutlet weak var ibcSendGuideView: UIView!
    @IBOutlet weak var ibcSendLabel: UILabel!
    
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
    
    fileprivate var VIEW_HEIGHT: CGFloat = 710
    
    var fromChain: BaseChain!
    var sendAssetType: SendAssetType!
    var txStyle: TxStyle!
    
    var toSendDenom: String!                        // coin denom or contract addresss
    var toSendMsAsset: MintscanAsset!               // to send Coin
    var toSendMsToken: MintscanToken!               // to send Token
    var ibcPath: MintscanPath?                      // to IBC send path
    var recipientableChains = [BaseChain]()
    var sendableAmount = NSDecimalNumber.zero
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
    
    var iotaFetcher: IotaFetcher!
    var iotaFeeBudget = NSDecimalNumber.zero
    var iotaGasPrice = NSDecimalNumber.zero

    var btcFetcher: BtcFetcher!
    var btcTxFee = NSDecimalNumber.zero
    var btcTxHex = ""

    var gnoFetcher: GnoFetcher!
    
    var solanaFetcher: SolanaFetcher!
    var solanaFeeAmount = NSDecimalNumber.zero
    var solanaMinimumRentAmount = NSDecimalNumber.zero
    var solanaTxHex = ""

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
                
            } else if (sendAssetType == .IOTA_COIN) {
                txStyle = .IOTA_STYLE
                iotaFetcher = (fromChain as? ChainIota)?.getIotaFetcher()
                iotaGasPrice = try await iotaFetcher.fetchGasprice()
                
            } else if (sendAssetType == .BTC_COIN) {
                txStyle = .BTC_STYLE
                btcFetcher = (fromChain as? ChainBitCoin86)?.getBtcFetcher()
                
            } else if (sendAssetType == .GNO_COIN || sendAssetType == .GNO_GRC20) {
                txStyle = .GNO_STYLE
                gnoFetcher = (fromChain as? ChainGno)?.getGnoFetcher()
                
            } else if (sendAssetType == .SOLANA_COIN) {
                solanaFetcher = (fromChain as? ChainSolana)?.getSolanaFetcher()
                txStyle = .SOLANA_STYLE
                
            } else if (sendAssetType == .SOLANA_SPL) {
                solanaFetcher = (fromChain as? ChainSolana)?.getSolanaFetcher()
                txStyle = .SPL_STYLE
                
            } else {
                txStyle = .COSMOS_STYLE
                cosmosFetcher = fromChain.getCosmosfetcher()
            }
            
            if (fromChain.supportEvm) {
                evmFetcher = fromChain.getEvmfetcher()
                if let url = URL(string: evmFetcher.getEvmRpc()),
                   let web3Provider = try? await Web3HttpProvider.init(url: url, network: .Custom(networkID: fromChain.chainIdEvmBigint)) {
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
    
    
    override func setLocalizedString() {
        toChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        toAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetTitle.text = NSLocalizedString("str_amount", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        memoTitle.text = NSLocalizedString("str_memo_optional", comment: "")
        if fromChain is ChainBitCoin86 {
            memoTitle.text = NSLocalizedString("str_op_return_optional", comment: "")
        }
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
    }
    
    func onInitIbcInfo() {
        recipientableChains = WUtils.checkIBCrecipientableChains(fromChain, toSendDenom)
        if (recipientableChains.count > 1 && txStyle == .COSMOS_STYLE) {
            toChainCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToChain)))
        }
    }
    
    func onInitToChain() {
        toChain = fromChain
        toChainImg.image = toChain.getChainImage()
        toChainLabel.text = toChain.getChainName()
    }
    
    func onInitFee() {
        if (txStyle == .WEB3_STYLE) {
            feeSegments.removeAllSegments()
            for i in 0..<evmGasTitle.count {
                feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
            }
            selectedFeePosition = 1
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectLabel.text = fromChain.mainAssetSymbol()
            
        } else if (txStyle == .SUI_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectLabel.text = fromChain.mainAssetSymbol()
            
            suiFeeBudget = suiFetcher.baseFee(.SUI_SEND_COIN)
            
        } else if (txStyle == .IOTA_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectLabel.text = fromChain.mainAssetSymbol()
            
            iotaFeeBudget = iotaFetcher.baseFee(.IOTA_SEND_COIN)
            
        } else if (txStyle == .BTC_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectLabel.text = fromChain.mainAssetSymbol()
            
            btcInitFee()
            
        } else if (txStyle == .GNO_STYLE) {
            cosmosFeeInfos = fromChain.getFeeInfos()
            feeSegments.removeAllSegments()
            for i in 0..<cosmosFeeInfos.count {
                feeSegments.insertSegment(withTitle: cosmosFeeInfos[i].title, at: i, animated: false)
            }
            selectedFeePosition = fromChain.getBaseFeePosition()
            feeSegments.selectedSegmentIndex = selectedFeePosition
            cosmosTxFee = fromChain.getInitPayableFee()!

        } else if (txStyle == .SOLANA_STYLE || txStyle == .SPL_STYLE) {
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
            selectedFeePosition = 0
            feeSegments.selectedSegmentIndex = selectedFeePosition
            feeSelectLabel.text = fromChain.mainAssetSymbol()
            
            solanaMinimumRentBalance()
            
            solanaFeeAmount = SOLANA_DEFAULT_FEE

        } else if (txStyle == .COSMOS_STYLE) {
            if (cosmosFetcher.cosmosBaseFees.count > 0) {
                feeSegments.removeAllSegments()
                feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
                feeSegments.insertSegment(withTitle: "Fast", at: 1, animated: false)
                feeSegments.insertSegment(withTitle: "Faster", at: 2, animated: false)
                feeSegments.insertSegment(withTitle: "Instant", at: 3, animated: false)
                feeSegments.selectedSegmentIndex = selectedFeePosition
                
                let baseFee = cosmosFetcher.cosmosBaseFees[0]
                let gasAmount: NSDecimalNumber = fromChain.getInitGasLimit()
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
                selectedFeePosition = fromChain.getBaseFeePosition()
                feeSegments.selectedSegmentIndex = selectedFeePosition
                cosmosTxFee = fromChain.getInitPayableFee()!
            }
        }
        onUpdateFeeView()
    }
    
    func onInitView() {
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
        
        var symbol = ""
        if (sendAssetType == .COSMOS_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            sendableAmount = cosmosFetcher.availableAmount(toSendDenom)
            if (cosmosTxFee.amount[0].denom == toSendDenom) {
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                sendableAmount = sendableAmount.subtracting(totalFeeAmount)
            }
            
        } else if (sendAssetType == .EVM_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = 18
            symbol = fromChain.mainAssetSymbol()
            sendableAmount = evmFetcher.evmBalances.subtracting(EVM_BASE_FEE)
            
        } else if (sendAssetType == .COSMOS_WASM || sendAssetType == .EVM_ERC20 || sendAssetType == .GNO_GRC20) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            sendableAmount = toSendMsToken!.getAmount()
            
        } else if (sendAssetType == .SUI_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            sendableAmount = suiFetcher.balanceAmount(toSendDenom)
            
            if (fromChain.stakingAssetDenom() == toSendDenom) {
                sendableAmount = sendableAmount.subtracting(suiFeeBudget)
            }
            
        } else if (sendAssetType == .IOTA_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            sendableAmount = iotaFetcher.balanceAmount(toSendDenom)
            
            if (fromChain.stakingAssetDenom() == toSendDenom) {
                sendableAmount = sendableAmount.subtracting(iotaFeeBudget)
            }
            
        } else if (sendAssetType == .BTC_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            sendableAmount = btcFetcher.btcBalances

        } else if (sendAssetType == .GNO_COIN) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
            sendableAmount = gnoFetcher.balanceAmount(toSendDenom)
            if (cosmosTxFee.amount[0].denom == toSendDenom) {
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                sendableAmount = sendableAmount.subtracting(totalFeeAmount)
            }
            
        } else if (sendAssetType == .SOLANA_COIN || sendAssetType == .SOLANA_SPL) {
            titleCoinImg.sd_setImage(with: fromChain.assetImgUrl(toSendDenom), placeholderImage: UIImage(named: "tokenDefault"))
            decimal = fromChain.assetDecimal(toSendDenom)
            symbol = fromChain.assetSymbol(toSendDenom)
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
    
    
    
    @objc func onClickToChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = fromChain
        baseSheet.recipientChain = toChain
        baseSheet.recipientableChains = recipientableChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectIBCRecipientChain
        onStartSheet(baseSheet, 400, 0.8)
    }
    
    func onUpdateToChain(_ chain: BaseChain) {
        if (chain.tag != toChain.tag) {
            toChain = chain
            toChainLabel.text = toChain.getChainName()
            toChainImg.image = toChain.getChainImage()
            onUpdateToAddressView("")
            sendBtn.isEnabled = false
        }
        
        if fromChain.tag == toChain.tag {
            ibcSendGuideView.isHidden = true
            sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
            
        } else {
            ibcSendGuideView.isHidden = false
            let fromChainName = fromChain.name ?? ""
            let toChainName = toChain.name ?? ""
            let fullText = "IBC Send from \(fromChainName) to \(toChainName) network"
            let attributedString = NSMutableAttributedString(string: fullText)
            let fullRange = (fullText as NSString).range(of: fullText)
            let fromChainRange = (fullText as NSString).range(of: fromChainName)
            let toChainRange = (fullText as NSString).range(of: toChainName)
            attributedString.addAttributes([.font: UIFont.fontSize11Medium, .foregroundColor: UIColor.color03], range: fullRange)
            attributedString.addAttributes([.font: UIFont.fontSize11Bold, .foregroundColor: UIColor.color02], range: fromChainRange)
            attributedString.addAttributes([.font: UIFont.fontSize11Bold, .foregroundColor: UIColor.color02], range: toChainRange)
            ibcSendLabel.attributedText = attributedString
            
            sendBtn.setTitle(NSLocalizedString("title_ibc_transfer", comment: ""), for: .normal)
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
        amountSheet.availableAmount = sendableAmount
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
            if (sendAssetType == .COSMOS_WASM || sendAssetType == .EVM_ERC20 || sendAssetType == .GNO_GRC20 || sendAssetType == .SOLANA_SPL) {
                let msPrice = BaseData.instance.getPrice(toSendMsToken!.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                
                WDP.dpToken(toSendMsToken!, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else if (sendAssetType == .COSMOS_COIN || sendAssetType == .GNO_COIN) {
                let msPrice = BaseData.instance.getPrice(toSendMsAsset!.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                
                WDP.dpCoin(toSendMsAsset, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
            } else if (sendAssetType == .EVM_COIN) {
                guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                toAssetDenomLabel.text = fromChain.mainAssetSymbol()
                toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                                
            } else if (sendAssetType == .SUI_COIN || sendAssetType == .IOTA_COIN) {
                let msPrice = BaseData.instance.getPrice(fromChain.assetGeckoId(toSendDenom))
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                
                toAssetDenomLabel.text = fromChain.assetSymbol(toSendDenom)
                toAssetAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, toAssetAmountLabel!.font, decimal)
                
            } else if (sendAssetType == .BTC_COIN || sendAssetType == .SOLANA_COIN) {
                guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)     //
                let dpAmount = toAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                
                WDP.dpCoin(msAsset, toAmount, nil, toAssetDenomLabel, toAssetAmountLabel, decimal)
                WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
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
        if toChain is ChainBitCoin86 {
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
            
        } else if (txStyle == .GNO_STYLE) {
            cosmosTxFee = fromChain.getUserSelectedFee(selectedFeePosition, cosmosTxFee.amount[0].denom)
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
            
        } else if (txStyle == .GNO_STYLE) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.targetChain = fromChain
            baseSheet.sheetDelegate = self
            baseSheet.feeDatas = cosmosFeeInfos[selectedFeePosition].FeeDatas
            baseSheet.sheetType = .SelectFeeDenom
            onStartSheet(baseSheet, 240, 0.6)
        }
    }
    
    // user changed segment or fee coin denom kinds
    func onUpdateFeeView() {
        sendBtn.isEnabled = false
        errorCardView.isHidden = true
        if (txStyle == .WEB3_STYLE) {
            guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
            let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let totalGasPrice = evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1
            let feeAmount = NSDecimalNumber(string: String(totalGasPrice.multiplied(by: evmGasLimit)))
            let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
            let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
            let deAmount = feeAmount.multiplying(byPowerOf10: -18)
            feeAmountLabel.attributedText = WDP.dpAmount(deAmount.stringValue, feeAmountLabel!.font, 18)
            feeDenomLabel.text = msAsset.symbol
            feeSelectImg.sd_setImage(with: msAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .SUI_STYLE) {
            guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
            let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let feeDpBudge = suiFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
            let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
            WDP.dpCoin(msAsset, suiFeeBudget, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .IOTA_STYLE) {
            guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
            let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let feeDpBudge = iotaFeeBudget.multiplying(byPowerOf10: -(msAsset.decimals ?? 9), withBehavior: getDivideHandler(msAsset.decimals ?? 9))
            let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
            WDP.dpCoin(msAsset, iotaFeeBudget, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .BTC_STYLE) {
            guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
            let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let feeAmount = btcTxFee.multiplying(byPowerOf10: -8, withBehavior: getDivideHandler(8))
            let feeValue = feePrice.multiplying(by: feeAmount, withBehavior: handler6)
            WDP.dpCoin(msAsset, btcTxFee, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            sendableAmount = sendableAmount.subtracting(btcTxFee)
            
        } else if (txStyle == .GNO_STYLE) {
            if let msAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
                feeSelectLabel.text = msAsset.symbol
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
                
                if (sendAssetType == .GNO_COIN) {
                    let balanceAmount = gnoFetcher.balanceAmount(toSendDenom)
                    if (cosmosTxFee.amount[0].denom == toSendDenom) {
                        if (totalFeeAmount.compare(balanceAmount).rawValue > 0) {
                            //ERROR short balance!!
                        }
                        sendableAmount = balanceAmount.subtracting(totalFeeAmount)
                        
                    } else {
                        sendableAmount = balanceAmount
                    }
                }
            }

        } else if (txStyle == .SOLANA_STYLE || txStyle == .SPL_STYLE) {
            guard let msAsset = BaseData.instance.getAsset(fromChain.apiName, fromChain.mainAssetSymbol()) else { return }
            let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let feeAmount = solanaFeeAmount.multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            let feeValue = feePrice.multiplying(by: feeAmount, withBehavior: handler6)
            WDP.dpCoin(msAsset, solanaFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else if (txStyle == .COSMOS_STYLE) {
            if let msAsset = BaseData.instance.getAsset(fromChain.apiName, cosmosTxFee.amount[0].denom) {
                feeSelectLabel.text = msAsset.symbol
                let totalFeeAmount = NSDecimalNumber(string: cosmosTxFee.amount[0].amount)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
                
                if (sendAssetType == .COSMOS_COIN) {
                    let availableAmount = cosmosFetcher.availableAmount(toSendDenom)
                    if (cosmosTxFee.amount[0].denom == toSendDenom) {
                        if (totalFeeAmount.compare(availableAmount).rawValue > 0) {
                            //ERROR short balance!!
                        }
                        sendableAmount = availableAmount.subtracting(totalFeeAmount)
                        
                    } else {
                        sendableAmount = availableAmount
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
            
        } else if (txStyle == .IOTA_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            iotaFeeBudget = NSDecimalNumber.init(value: toGas)
            
        } else if (txStyle == .BTC_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            btcTxFee = NSDecimalNumber.init(value: toGas)
            sendBtn.isHidden = false
            
        } else if (txStyle == .SOLANA_STYLE || txStyle == .SPL_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            solanaFeeAmount = NSDecimalNumber.init(value: toGas)
            sendBtn.isHidden = false
            
        } else if (txStyle == .GNO_STYLE) {
            guard let toGas = gasUsed else {
                sendBtn.isHidden = true
                errorCardView.isHidden = false
                errorMsgLabel.text = errorMessage ?? NSLocalizedString("error_evm_simul", comment: "")
                return
            }
            cosmosTxFee.gasLimit = UInt64(Double(toGas == 0 ? fromChain.getInitGasLimit().uint64Value : toGas) * fromChain.getSimulatedGasMultiply())
            
            if let gasRate = cosmosFeeInfos[selectedFeePosition].FeeDatas.filter({ $0.denom == cosmosTxFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: UInt64(Double(toGas == 0 ? fromChain.getInitGasLimit().uint64Value : toGas) * fromChain.getSimulatedGasMultiply() * fromChain.getSimulatedGasAdjustment()))
                let feeAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                cosmosTxFee.amount[0].amount = feeAmount!.stringValue
            }

            onUpdateFeeView()
            sendBtn.isEnabled = true
            
        } else if (txStyle == .COSMOS_STYLE) {
            if (fromChain.isSimulable() == false) {
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
            cosmosTxFee.gasLimit = UInt64(Double(toGas) * fromChain.getSimulatedGasMultiply())
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
        
        ibcPath = WUtils.getMintscanPath(fromChain, toChain, toSendDenom)       // nil able
//        print("ibcPath ", ibcPath?.direction, "  ", ibcPath?.ibcInfo)
        
        if (txStyle == .WEB3_STYLE) {
            if (fromChain.apiName == toChain.apiName) {
                evmSendSimul()
            } else if (toChain.supportCosmos) {
                evmEurekaSimul()
            }
            
        } else if (txStyle == .SUI_STYLE) {
            suiSendGasCheck()
            
        } else if (txStyle == .IOTA_STYLE) {
            iotaSendGasCheck()
            
        } else if (txStyle == .BTC_STYLE) {
            btcFetchTxHex()
            
        } else if (txStyle == .GNO_STYLE) {
            gnoSimul()
            
        } else if (txStyle == .COSMOS_STYLE) {
            // some chain not support simulate (assetmantle)  24.2.21
            if (fromChain.isSimulable() == false) {                                 // Chain not support imul
                return onUpdateWithSimul(nil)
            }
            
            if (fromChain.chainIdCosmos == toChain.chainIdCosmos) {                 // Inchain Send!
                if (sendAssetType == .COSMOS_WASM) {
                    inChainWasmSendSimul()                                          // Inchain CW20 Send!
                } else {
                    inChainCoinSendSimul()                                          // Inchain Coin Send!  (COSMOS_COIN)
                }
                
            } else if (toChain.supportCosmos == false) {                            // IBC Eureka Send!
                ibcEurekaSendSimul()
                
            } else {                                                                // IBC Send!
                if (sendAssetType == .COSMOS_WASM) {
                    ibcWasmSendSimul()                                              // CW20 IBC Send!
                } else {
                    ibcCoinSendSimul()                                              // Coin IBC Send! (COSMOS_COIN)
                }
            }
            
        } else if (txStyle == .SOLANA_STYLE) {                                      // SOLANA SOL Send
            solSendSimul()
            
        } else if (txStyle == .SPL_STYLE) {                                         // SOLANA SPL TOKEN Send
            splSendSimul()
        }
    }

}



// EVM style tx simul and broadcast
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
                let value = Web3Core.Utilities.parseToBigUInt(self.toAmount.stringValue, decimals: 0)!
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
    
    //This is unused logic (2025.04.15 yongjoo)
    //Not support Eureka (no way to get eureka_fee onchain)
    func evmEurekaSimul() {
        print("evmEurekaSimul")
        Task {
            guard let web3 = self.web3 else {
                evmTxType = nil
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil)
                }
                return
            }
            
            let oracle = Web3Core.Oracle.init(web3.provider)
            if let feeHistory = await oracle.bothFeesPercentiles(),
               feeHistory.baseFee.count > 0 {
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
                evmGas[0].0 = gasprice
                evmGas[1].0 = gasprice * 12 / 10
                evmGas[2].0 = gasprice * 20 / 10
                evmTxType = .legacy
                
            } else {
                evmTxType = nil
                DispatchQueue.main.async {
                    self.onUpdateWithSimul(nil)
                }
                return
            }
            print("evmEurekaSimul evmGas ", evmGas)
            
            let chainID = web3.provider.network?.chainID
            let senderAddress = EthereumAddress.init(fromChain.evmAddress!)!
            let ercContractAddress = EthereumAddress.init(toSendMsToken.address!)!
            let iCS20ContractAddress = EthereumAddress.init(ibcPath!.getICS20ContractAddress()!)!
            let nonce = try? await web3.eth.getTransactionCount(for: senderAddress)
            let calSendAmount = self.toAmount.multiplying(byPowerOf10: -decimal)
            let erc20 = ERC20(web3: web3, provider: web3.provider, address: ercContractAddress)
            let approveWriteOperation = try await erc20.approve(from: senderAddress, spender: iCS20ContractAddress, amount: calSendAmount.stringValue)
            
            if (evmTxType == .eip1559) {
                evmTx = CodableTransaction.init(type: evmTxType, to: ercContractAddress, nonce: nonce!,
                                                       chainID: chainID!, data: approveWriteOperation.data!,
                                                       maxFeePerGas: evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1,
                                                       maxPriorityFeePerGas: evmGas[selectedFeePosition].1)
            } else {
                evmTx = CodableTransaction.init(type: evmTxType, to: ercContractAddress, nonce: nonce!,
                                                       chainID: chainID!, data: approveWriteOperation.data!,
                                                       gasPrice: evmGas[selectedFeePosition].0)
            }
            evmTx?.from = senderAddress
            
            if let estimateGas = try? await web3.eth.estimateGas(for: evmTx!) {
                evmGasLimit = estimateGas * fromChain.evmGasMultiply() / 10 * 3  //check approve and send tx fee sum
                evmTx?.gasLimit = evmGasLimit
            } else {
                print("evmEurekaSimul Error")
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
                print("evmSend error ", error)
            }
            
        }
    }
    
    //This is unused logic (2025.04.15 yongjoo)
    //Not support Eureka (no way to get eureka_fee onchain)
    //Approve than send amount
    func evmEurekaSend() {
        print("evmEurekaSend")
        Task {
            guard let web3 = self.web3 else {
                print("web3 init error")
                return
            }
            
            do {
                let oracle = Web3Core.Oracle.init(web3.provider)
                if let feeHistory = await oracle.bothFeesPercentiles(),
                   feeHistory.baseFee.count > 0 {
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
                    evmGas[0].0 = gasprice
                    evmGas[1].0 = gasprice * 12 / 10
                    evmGas[2].0 = gasprice * 20 / 10
                    evmTxType = .legacy
                    
                } else {
                    evmTxType = nil
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(nil)
                    }
                    return
                }
                print("evmEurekaSend evmGas ", evmGas)
                
                let chainID = web3.provider.network?.chainID
                let senderAddress = EthereumAddress.init(fromChain.evmAddress!)!
                let ercContractAddress = EthereumAddress.init(toSendMsToken.address!)!
                let iCS20ContractAddress = EthereumAddress.init(ibcPath!.getICS20ContractAddress()!)!
                var nonce = try? await web3.eth.getTransactionCount(for: senderAddress)
                let calSendAmount = self.toAmount.multiplying(byPowerOf10: -decimal)
                let bigUIntAmount = Web3Core.Utilities.parseToBigUInt(self.toAmount.stringValue, decimals: 0)!
                let erc20 = ERC20(web3: web3, provider: web3.provider, address: ercContractAddress)
                let approveWriteOperation = try await erc20.approve(from: senderAddress, spender: iCS20ContractAddress, amount: calSendAmount.stringValue)
                
                var evmApproveTx: CodableTransaction?
                if (evmTxType == .eip1559) {
                    evmApproveTx = CodableTransaction.init(type: evmTxType, to: ercContractAddress, nonce: nonce!,
                                                           chainID: chainID!, data: approveWriteOperation.data!,
                                                           maxFeePerGas: evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1,
                                                           maxPriorityFeePerGas: evmGas[selectedFeePosition].1)
                } else {
                    evmApproveTx = CodableTransaction.init(type: evmTxType, to: ercContractAddress, nonce: nonce!,
                                                           chainID: chainID!, data: approveWriteOperation.data!,
                                                           gasPrice: evmGas[selectedFeePosition].0)
                }
                evmApproveTx?.from = senderAddress
                if let estimateApproveGas = try? await web3.eth.estimateGas(for: evmApproveTx!) {
                    evmApproveTx?.gasLimit = estimateApproveGas * fromChain.evmGasMultiply() / 10
                } else {
                    //TODO Handle Error
                    print("estimateApproveGas Error")
                }
                print("evmApproveTx ", evmApproveTx, "\n\n\n")

                try evmApproveTx?.sign(privateKey: fromChain.privateKey!)
                let encodeApproveTx = evmApproveTx?.encode(for: .transaction)
                let resultApprove = try await web3.eth.send(raw : encodeApproveTx!)
                print("resultApprove ", resultApprove)
                
                //TODO check Approve is onchain
                
                
                
                
                /*
                nonce = try? await web3.eth.getTransactionCount(for: senderAddress)
                let time = Date().hourAfter6Int32
                let sourceClient = ibcPath!.getChannel()!
                let destPort = ibcPath!.getPort()!
                let eurekaWriteOperation = try await EUREKA_ICS20Transfer.init(web3: web3, contractAddress: iCS20ContractAddress).sendTransfer(ercContractAddress, bigUIntAmount, toAddress, sourceClient, destPort, time, EUREKA_MEMO)
                
                var evmEurekaTx: CodableTransaction?
                if (evmTxType == .eip1559) {
                    evmEurekaTx = CodableTransaction.init(type: evmTxType, to: iCS20ContractAddress, nonce: nonce!,
                                                          chainID: chainID!, data: eurekaWriteOperation!.data!,
                                                          maxFeePerGas: evmGas[selectedFeePosition].0 + evmGas[selectedFeePosition].1,
                                                          maxPriorityFeePerGas: evmGas[selectedFeePosition].1)
                } else {
                    evmEurekaTx = CodableTransaction.init(type: evmTxType, to: iCS20ContractAddress, nonce: nonce!,
                                                          chainID: chainID!, data: eurekaWriteOperation!.data!,
                                                          gasPrice: evmGas[selectedFeePosition].0)
                }
                evmEurekaTx?.from = senderAddress
                print("evmEurekaTx ", evmEurekaTx)
                
                
                
                if let estimateEurekaGas = try? await web3.eth.estimateGas(for: evmEurekaTx!) {
                    evmEurekaTx?.gasLimit = estimateEurekaGas * fromChain.evmGasMultiply() / 10
                } else {
                    //TODO Handle Error
                    print("estimateEurekaGas Error")
                }
                
                try evmEurekaTx?.sign(privateKey: fromChain.privateKey!)
                let encodeEurekaTx = evmEurekaTx?.encode(for: .transaction)
                let resultEureka = try await web3.eth.send(raw : encodeEurekaTx!)
                print("resultEureka ", resultEureka)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    self.loadingView.isHidden = true
                    let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                    txResult.txStyle = self.txStyle
                    txResult.fromChain = self.fromChain
//                    txResult.toChain = self.toChain
                    txResult.toAddress = self.toAddress
                    txResult.evmHash = resultEureka.hash
                    txResult.modalPresentationStyle = .fullScreen
                    self.present(txResult, animated: true)
                })
                 */
                
            } catch {
                print("error ", error)
            }
        }
    }
}

// GNO style tx
extension CommonTransfer {
    
    func gnoSimul() {
        Task {
            guard let gasRate = self.cosmosTxFee.amount.filter({ $0.denom == self.cosmosTxFee.amount[0].denom }).first else { return }
            let fee = Tm2_Tx_TxFee.with {
                $0.gasWanted = Int64(cosmosTxFee.gasLimit)
                $0.gasFee = gasRate.amount + gasRate.denom
            }
            
            do {
                if let simulReq = Signer.genSimul(fromChain, onBindSendMsg(), txMemo, fee),
                   let simulRes = try await (fromChain as? ChainGno)?.getGnoFetcher()?.simulateTx(simulReq) {
                    
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(UInt64(simulRes.gasUsed))
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
    
    func gnoSend() {
        Task {
            guard let gasRate = self.cosmosTxFee.amount.filter({ $0.denom == self.cosmosTxFee.amount[0].denom }).first else { return }
            let fee = Tm2_Tx_TxFee.with {
                $0.gasWanted = Int64(cosmosTxFee.gasLimit)
                $0.gasFee = gasRate.amount + gasRate.denom
            }
                        
            guard let sig = Signer.gnoSignature(fromChain,
                                                [.init(type: "/bank.MsgSend", from_address: fromChain.bechAddress!, to_address: toAddress, amount: toAmount.stringValue + toSendDenom)],
                                                txMemo,
                                                .init(gas_wanted: String(fee.gasWanted), gas_fee: fee.gasFee)) else { return }

            do {
                let broadReq = Signer.genTx(fromChain, onBindSendMsg(), txMemo, fee, sig)
                if let broadRes = try await (fromChain as? ChainGno)?.getGnoFetcher()?.broadcastTx(broadReq) {
                    
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
                loadingView.isHidden = true
                onShowToast("Error: \(error)")
            }
        }
    }
    
    func gnoGrc20Send() {
        Task {
            guard let gasRate = self.cosmosTxFee.amount.filter({ $0.denom == self.cosmosTxFee.amount[0].denom }).first else { return }
            let fee = Tm2_Tx_TxFee.with {
                $0.gasWanted = Int64(cosmosTxFee.gasLimit)
                $0.gasFee = gasRate.amount + gasRate.denom
            }
            
            guard let sig = Signer.gnoSignature(fromChain,
                                                [.init(type: "/vm.m_call", caller: fromChain.bechAddress!, send: "", pkg_path: toSendMsToken.address!, func: "Transfer", args: [toAddress, toAmount.stringValue])],
                                                txMemo,
                                                .init(gas_wanted: String(fee.gasWanted), gas_fee: fee.gasFee)) else { return }
            do {
                let broadReq = Signer.genTx(fromChain, onBindSendMsg(), txMemo, fee, sig)
                if let broadRes = try await (fromChain as? ChainGno)?.getGnoFetcher()?.broadcastTx(broadReq) {
                    
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
                loadingView.isHidden = true
                onShowToast("Error: \(error)")
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
                    
                    btcTxHex = BtcJS.shared.getTxHex(txString)
                    
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

// SUI style tx dryrun and broadcast
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
            if (object["type"].stringValue.suiCoinType() == toSendDenom) {
                result.append(object["objectId"].stringValue)
            }
        }
        return result
    }
    
}

// IOTA style tx dryrun and broadcast
extension CommonTransfer {
    
    func iotaSendGasCheck() {
        Task {
            if let txBytes = try await iotaFetcher.unsafeCoinSend(toSendDenom, fromChain.mainAddress, iotaInputs(), [toAddress], [toAmount.stringValue], iotaFeeBudget.stringValue),
               let response = try await iotaFetcher.iotaDryrun(txBytes) {
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
    
    func iotaSend() {
        Task {
            do {
                if let txBytes = try await iotaFetcher.unsafeCoinSend(toSendDenom, fromChain.mainAddress, iotaInputs(), [toAddress], [toAmount.stringValue], iotaFeeBudget.stringValue),
                   let dryRes = try await iotaFetcher.iotaDryrun(txBytes), dryRes["error"].isEmpty,
                   let broadRes = try await iotaFetcher.iotaExecuteTx(txBytes, Signer.iotaSignatures(fromChain, txBytes), nil) {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = self.txStyle
                        txResult.fromChain = self.fromChain
                        txResult.toChain = self.toChain
                        txResult.toAddress = self.toAddress
                        txResult.iotaResult = broadRes
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                    })
                }
                
            } catch {
                //TODO handle Error
            }
        }
    }
    
    func iotaInputs() -> [String] {
        var result = [String]()
        iotaFetcher.iotaObjects.forEach { object in
            if (object["type"].stringValue.iotaCoinType() == toSendDenom) {
                result.append(object["objectId"].stringValue)
            }
        }
        return result
    }
    
}

extension CommonTransfer {
    
    func solanaMinimumRentBalance() {
        Task {
            do {
                var dataSize = 0
                if (sendAssetType == .SOLANA_COIN) {
                    dataSize = 0
                } else {
                    dataSize = 165
                }
                if let minimumRentBalance = try await solanaFetcher.fetchMinimumRentBalanceInfo(dataSize) {
                    if (!minimumRentBalance["err"].exists()) {
                        solanaMinimumRentAmount = NSDecimalNumber(value: minimumRentBalance["result"].uInt64Value)
                        if (sendAssetType == .SOLANA_COIN) {
                            sendableAmount = solanaFetcher.balanceAmount().subtracting(solanaMinimumRentAmount).subtracting(SOLANA_MAX_PRIORITY_TIP)
                        } else {
                            sendableAmount = NSDecimalNumber.init(string: toSendMsToken.amount)
                        }
                        
                        if (sendableAmount.compare(NSDecimalNumber.zero).rawValue <= 0) {
                            sendableAmount = NSDecimalNumber.zero
                        }
                    } else {
                        onShowToast(NSLocalizedString("error_evm_simul", comment: ""))
                    }
                }
            }
        }
    }
    
    func solSendSimul() {
        Task {
            do {
                if let recentBlockHash = try await solanaFetcher.fetchLatestBlockHash(),
                   let createTransactionHex = try await solanaFetcher.createTransferTransaction(fromChain.mainAddress, toAddress, toAmount.stringValue, recentBlockHash) {
                    let createTransactionHexJsonData = try JSON(data: Data(createTransactionHex.utf8))
                    
                    let txBase64 = createTransactionHexJsonData["serializedTxWithBase64"].stringValue
                    let txMessageWithBase64 = createTransactionHexJsonData["serializedTxMessageWithBase64"].stringValue
                    
                    if let simulateResponse = try await solanaFetcher.fetchSimulate(txBase64),
                       let feeForMessage = try await solanaFetcher.fetchFeeMessage(txMessageWithBase64),
                       let prioritizationFees = try await solanaFetcher.fetchPrioritizationFee() {
                        
                        if (simulateResponse["result"]["value"]["err"].exists() && simulateResponse["result"]["value"]["err"].type != .null) {
                            DispatchQueue.main.async {
                                self.view.isUserInteractionEnabled = true
                                self.loadingView.isHidden = true
                                self.sendBtn.isEnabled = false
                                if (simulateResponse["result"]["value"]["err"]["InsufficientFundsForRent"].exists()) {
                                    guard let msAsset = BaseData.instance.getAsset(self.fromChain.apiName, self.fromChain.mainAssetSymbol()) else { return }
                                    let dpAmount = String(describing: self.solanaMinimumRentAmount.multiplying(byPowerOf10: -(msAsset.decimals ?? 8), withBehavior: getDivideHandler(msAsset.decimals ?? 8)))
                                    let errorText = String(format: NSLocalizedString("error_minimum_rent", comment: ""), dpAmount)
                                    
                                    self.sendBtn.setTitle(NSLocalizedString(errorText, comment: ""), for: .normal)
                                    self.sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                                } else {
                                    self.sendBtn.setTitle(NSLocalizedString("Simulate Error", comment: ""), for: .normal)
                                }
                                return
                            }

                        } else {
                            let unitsConsumed = simulateResponse["result"]["value"]["unitsConsumed"].uInt64Value
                            let baseFee = feeForMessage["result"]["value"].uInt64Value
                            
                            var sumFee: UInt64 = 0
                            let recentPrioritizationFees = prioritizationFees["result"].arrayValue
                            if (recentPrioritizationFees.count > 0) {
                                recentPrioritizationFees.forEach { fee in
                                    sumFee += fee["prioritizationFee"].uInt64Value
                                }
                            }
                            
                            let tipFee: UInt64 = (sumFee > 0 && recentPrioritizationFees.count > 0) ? (sumFee / UInt64(recentPrioritizationFees.count) / 1_000_000) + baseFee / 10 : baseFee / 10
                            
                            let computeUnitLimit = unitsConsumed + baseFee / 10
                            let computeUnitPrice = Double(tipFee) / Double(computeUnitLimit)
                            
                            solanaTxHex = try await solanaFetcher.overwriteComputeBudgetProgram(txBase64, computeUnitLimit, computeUnitPrice)
                            
                            let tip = Double(computeUnitLimit) * computeUnitPrice
                            let fee = baseFee + UInt64(ceil(tip))
                            
                            DispatchQueue.main.async {
                                self.onUpdateWithSimul(fee)
                                self.sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
                            }
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(nil)
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
    
    func splSendSimul() {
        Task {
            do {
                if let receiverATA = try await solanaFetcher.associatedTokenAddress(toSendDenom, toAddress),
                   let accountATAInfo = try await solanaFetcher.fetchAccountInfo(receiverATA, "base64"),
                   let recentBlockHash = try await solanaFetcher.fetchLatestBlockHash() {
                    let isCreateAssociatedTokenAccount = accountATAInfo["result"]["value"].type == .null
                    
                    if let createSplTransactionHex = try await solanaFetcher.createSplTokenTransferTransaction(fromChain.mainAddress, toAddress, toSendDenom, toAmount.stringValue, recentBlockHash, isCreateAssociatedTokenAccount) {
                        let createSplTransactionHexJsonData = try JSON(data: Data(createSplTransactionHex.utf8))
                        
                        let txBase64 = createSplTransactionHexJsonData["serializedTxWithBase64"].stringValue
                        let txMessageWithBase64 = createSplTransactionHexJsonData["serializedTxMessageWithBase64"].stringValue
                        
                        if let simulateResponse = try await solanaFetcher.fetchSimulate(txBase64),
                           let feeForMessage = try await solanaFetcher.fetchFeeMessage(txMessageWithBase64),
                           let prioritizationFees = try await solanaFetcher.fetchPrioritizationFee() {
                            
                            if (simulateResponse["result"]["value"]["err"].exists() && simulateResponse["result"]["value"]["err"].type != .null) {
                                DispatchQueue.main.async {
                                    self.view.isUserInteractionEnabled = true
                                    self.loadingView.isHidden = true
                                    self.sendBtn.isEnabled = false
                                    let errorMsg = simulateResponse["result"]["value"]["err"]
                                    self.onShowToast(String(describing: errorMsg))
                                    return
                                }
                                
                            } else {
                                let unitsConsumed = simulateResponse["result"]["value"]["unitsConsumed"].uInt64Value
                                let baseFee = feeForMessage["result"]["value"].uInt64Value
                                
                                var sumFee: UInt64 = 0
                                let recentPrioritizationFees = prioritizationFees["result"].arrayValue
                                if (recentPrioritizationFees.count > 0) {
                                    recentPrioritizationFees.forEach { fee in
                                        sumFee += fee["prioritizationFee"].uInt64Value
                                    }
                                }
                                
                                let tipFee: UInt64 = (sumFee > 0 && recentPrioritizationFees.count > 0) ? (sumFee / UInt64(recentPrioritizationFees.count) / 1_000_000) + baseFee / 10 : baseFee / 10
                                
                                let computeUnitLimit = unitsConsumed + baseFee / 10
                                let computeUnitPrice = Double(tipFee) / Double(computeUnitLimit)
                                
                                solanaTxHex = try await solanaFetcher.overwriteComputeBudgetProgram(txBase64, computeUnitLimit, computeUnitPrice)
                                
                                let tip = Double(computeUnitLimit) * computeUnitPrice
                                var fee = baseFee + UInt64(ceil(tip))
                                
                                if (isCreateAssociatedTokenAccount) {
                                    fee = fee + UInt64(truncating: solanaMinimumRentAmount)
                                }
                                
                                DispatchQueue.main.async {
                                    self.onUpdateWithSimul(fee)
                                }
                            }
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.onUpdateWithSimul(nil)
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
    
    func solanaSend() {
        Task {
            do {
                if let privateKey = fromChain.privateKey?.toHexString(),
                   let signTransactionHex = try await solanaFetcher.signTransaction(solanaTxHex, privateKey),
                   let sendTransaction = try await solanaFetcher.fetchSendTransaction(signTransactionHex) {
                       DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                           self.loadingView.isHidden = true
                           let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                           txResult.txStyle = self.txStyle
                           txResult.fromChain = self.fromChain
                           txResult.toChain = self.toChain
                           txResult.toAddress = self.toAddress
                           txResult.solanaResult = sendTransaction
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


// Cosmos style tx simul and broadcast
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
        if (fromChain is ChainThor) {
            let thorSendMSg = Types_MsgSend.with {
                $0.fromAddress = try! SegwitAddrCoder.shared.decode(fromChain.bechAddress!)!
                $0.toAddress = try! SegwitAddrCoder.shared.decode(toAddress)!
                $0.amount = [sendCoin]
            }
            return Signer.genThorSendMsg(thorSendMSg)
            
        } else if sendAssetType == .GNO_GRC20 {
            let gnoSendMsg = Gno_Vm_MsgCall.with {
                $0.args = [toAddress,
                           toAmount.stringValue]
                $0.caller = fromChain.bechAddress!
                $0.func = "Transfer"
                $0.send = ""
                $0.pkgPath = toSendMsToken.address!
            }
            
            return Signer.genGnoSendMsg(gnoSendMsg)

        } else if sendAssetType == .GNO_COIN {
            let gnoSendMsg = Gno_Bank_MsgSend.with {
                $0.fromAddress = fromChain.bechAddress!
                $0.toAddress = toAddress
                $0.amount = toAmount.stringValue + toSendDenom
            }
            return Signer.genGnoSendMsg(gnoSendMsg)
            

        } else {
            let sendMsgs = Cosmos_Bank_V1beta1_MsgSend.with {
                $0.fromAddress = fromChain.bechAddress!
                $0.toAddress = toAddress
                $0.amount = [sendCoin]
            }
            return Signer.genSendMsg(sendMsgs)
        }
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
            $0.revisionHeight = UInt64(lastBlock) + (toChain.getTimeoutPadding() * 10)
        }
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = toSendDenom
            $0.amount = toAmount.stringValue
        }
        let ibcSendMsg = Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = fromChain.bechAddress!
            $0.receiver = toAddress
            $0.sourceChannel = ibcPath!.getChannel()!
            $0.sourcePort = ibcPath!.getPort()!
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
        let jsonMsg: JSON = ["channel" : ibcPath!.getChannel()!, "remote_address" : toAddress, "timeout" : 900]
        let jsonMsgBase64 = try! jsonMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        
        let innerMsg: JSON = ["send" : ["contract" : ibcPath!.getPort()!, "amount" : toAmount.stringValue, "msg" : jsonMsgBase64]]
        let innerMsgBase64 = try! innerMsg.rawData(options: [.sortedKeys]).base64EncodedString()
        let ibcWasmMsg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = fromChain.bechAddress!
            $0.contract = toSendMsToken.address!
            $0.msg = Data(base64Encoded: innerMsgBase64)!
        }
        return Signer.genWasmMsg([ibcWasmMsg])
    }
    
    
    func ibcEurekaSendSimul() {
        Task {
            do {
                if let simulReq = try await Signer.genSimul(fromChain, onBindIbcEurekaMSg(), txMemo, cosmosTxFee, nil),
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
        }    }
    
    func ibcEurekaSend() {
        Task {
            do {
                if let broadReq = try await Signer.genTx(fromChain, onBindIbcEurekaMSg(), txMemo, cosmosTxFee, nil),
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
    
    func onBindIbcEurekaMSg() -> [Google_Protobuf_Any] {
        let recipientAddress = EthereumAddress.init(toAddress)!
        let abiEncoded = ABIEncoder.encode(types: [.string, .string, .string, .uint(bits: 64), .string], values: [toSendDenom, fromChain.bechAddress!, recipientAddress.address.stripHexPrefix(), toAmount.uint64Value, EUREKA_MEMO])!.toHexString()
        let payload = Ibc_Core_Channel_V2_Payload.with {
            $0.sourcePort = ibcPath!.ibcInfo!.counterparty!.port!
            $0.destinationPort = ibcPath!.ibcInfo!.client!.port!
            $0.version = ibcPath!.ibcInfo!.client!.version!
            $0.encoding = ibcPath!.ibcInfo!.client!.encoding!
            $0.value = Data(hex: abiEncoded.addABIPrefix())
        }
        let eurekaSendMsg = Ibc_Core_Channel_V2_MsgSendPacket.with {
            $0.sourceClient = ibcPath!.ibcInfo!.counterparty!.channel!
            $0.timeoutTimestamp = Date().hourAfter6UInt64
            $0.payloads = [payload]
            $0.signer = fromChain.bechAddress!
        }
        return Signer.genIbcEurekaSendMsg([eurekaSendMsg])
    }
}


extension CommonTransfer: BaseSheetDelegate, SendAddressDelegate, SendAmountSheetDelegate, MemoDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectIBCRecipientChain) {
            if let chainTag = result["chainTag"] as? String {
                if (chainTag != toChain.tag) {
                    onUpdateToChain(recipientableChains.filter({ $0.tag == chainTag }).first!)
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
                if (fromChain.apiName == toChain.apiName) {
                    evmSend()
                } else if (toChain.supportCosmos) {
                    evmEurekaSend()
                }
                
            } else if (txStyle == .SUI_STYLE) {
                suiSend()
                
            } else if (txStyle == .IOTA_STYLE) {
                iotaSend()
                
            } else if (txStyle == .BTC_STYLE) {
                btcSend(btcTxHex)
                
            } else if (txStyle == .SOLANA_STYLE || txStyle == .SPL_STYLE) {
                solanaSend()
                
            } else if (txStyle == .GNO_STYLE) {
                if sendAssetType == .GNO_GRC20 {
                    gnoGrc20Send()
                    
                } else if sendAssetType == .GNO_COIN {
                    gnoSend()
                }
                
            } else if (txStyle == .COSMOS_STYLE) {
                if (fromChain.chainIdCosmos == toChain.chainIdCosmos) {                     // Inchain Send!
                    if (sendAssetType == .COSMOS_WASM) {
                        inChainWasmSend()                                                   // Inchain CW20 Send!
                    } else {
                        inChainCoinSend()                                                   // Inchain Coin Send!  (COSMOS_COIN)
                    }
                    
                } else if (toChain.supportCosmos == false) {                                // IBC Eureka Send!
                    ibcEurekaSend()
                    
                } else {                                                                    // IBC Send!
                    if (sendAssetType == .COSMOS_WASM) {
                        ibcWasmSend()                                                       // CW20 IBC Send!
                    } else {
                        ibcCoinSend()                                                       // Coin IBC Send! (COSMOS_COIN)
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
    
    
    case SUI_COIN = 5                       // sui assets
    case SUI_NFT = 6                        // sui nft
    case BTC_COIN = 7                       // bitcoin
    case GNO_COIN = 8
    case GNO_GRC20 = 9
    case IOTA_COIN = 10
    case IOTA_NFT = 11
    case SOLANA_COIN = 12                   // solana sol send
    case SOLANA_SPL = 13                    // solana spl send
}
