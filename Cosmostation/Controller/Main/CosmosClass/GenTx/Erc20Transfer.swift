//
//  Erc20Transfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/25.
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

class Erc20Transfer: BaseVC {
    
    @IBOutlet weak var midGapConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var toSendAssetCard: FixCardView!
    @IBOutlet weak var toSendAssetTitle: UILabel!
    @IBOutlet weak var toSendAssetImg: UIImageView!
    @IBOutlet weak var toSendSymbolLabel: UILabel!
    @IBOutlet weak var toSendAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressMasterLabel: UILabel!
    @IBOutlet weak var toAddressSlaveLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: CosmosClass!
    var selectedMsToken: MintscanToken!             // to send Token
    var toSendDenom: String!                        // coin denom or contract addresss
    
    var availableAmount = NSDecimalNumber.zero
    var toSendAmount = NSDecimalNumber.zero
    var userInputAddress: String?
    var recipientBechAddress: String?
    var recipientEvmAddress: String?
    var ethereumTransaction: EthereumTransaction?
    var feeAmount = NSDecimalNumber(string: "600000000000000")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        selectedMsToken = selectedChain.mintscanErc20Tokens.filter({ $0.address == toSendDenom }).first!
        toSendAssetImg.af.setImage(withURL: selectedMsToken.assetImg())
        toSendSymbolLabel.text = selectedMsToken.symbol
        availableAmount = selectedMsToken.getAmount()
        
        if let okChain = selectedChain as? ChainOkt60Keccak {
            feeSelectImg.af.setImage(withURL: ChainOkt60Keccak.assetImg(selectedChain.stakeDenom))
            feeSelectLabel.text = selectedChain.stakeDenom.uppercased()
            
        } else {
            let stakingAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom == selectedChain.stakeDenom }).first!
            feeSelectImg.af.setImage(withURL: stakingAsset!.assetImg())
            feeSelectLabel.text = stakingAsset!.symbol
        }
        
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        
        onUpdateFeeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 510
        if (gap > 0) { midGapConstraint.constant = gap }
        else { midGapConstraint.constant = 60 }
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_transfer_asset", comment: "")
        toAddressHint.text = NSLocalizedString("msg_tap_for_add_address", comment: "")
        toSendAssetHint.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        sendBtn.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.transferAssetType = .Erc20Transfer
        amountSheet.msToken = selectedMsToken
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
            
            let msPrice = BaseData.instance.getPrice(selectedMsToken!.coinGeckoId)
            let value = msPrice.multiplying(by: toSendAmount).multiplying(byPowerOf10: -selectedMsToken!.decimals!, withBehavior: handler6)
            WDP.dpToken(selectedMsToken!, toSendAmount, nil, toAssetDenomLabel, toAssetAmountLabel, selectedMsToken!.decimals)
            WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
            
            toSendAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
            toAssetCurrencyLabel.isHidden = false
            toAssetValueLabel.isHidden = false
        }
        onSimul()
    }
    
    @objc func onClickToAddress() {
        let addressSheet = TxAddressSheet(nibName: "TxAddressSheet", bundle: nil)
        addressSheet.selectedChain = selectedChain
        addressSheet.recipientChain = selectedChain
        if (userInputAddress?.isEmpty == false) {
            addressSheet.existedAddress = userInputAddress
        }
        addressSheet.addressSheetType = .Erc20Transfer
        addressSheet.addressDelegate = self
        self.onStartSheet(addressSheet, 220)
    }
    
    func onUpdateToAddressView() {
        if (userInputAddress == nil ||
            userInputAddress?.isEmpty == true) {
            recipientBechAddress = nil
            recipientEvmAddress = nil
            toAddressHint.isHidden = false
            toAddressMasterLabel.isHidden = true
            toAddressSlaveLabel.isHidden = true
            
        } else {
            toAddressHint.isHidden = true
            toAddressMasterLabel.text = recipientEvmAddress
            toAddressMasterLabel.isHidden = false
            toAddressMasterLabel.adjustsFontSizeToFitWidth = true
            
            toAddressSlaveLabel.text = "(" + recipientBechAddress! + ")"
            toAddressSlaveLabel.isHidden = false
            toAddressSlaveLabel.adjustsFontSizeToFitWidth = true
        }
        onSimul()
    }
    
    func onUpdateFeeView() {
        if let okChain = selectedChain as? ChainOkt60Keccak {
            let msPrice = BaseData.instance.getPrice(OKT_GECKO_ID)
            let feeAmount = NSDecimalNumber(string: OKT_BASE_FEE)
            let feeValue = msPrice.multiplying(by: feeAmount, withBehavior: handler6)
            feeAmountLabel?.attributedText = WDP.dpAmount(feeAmount.stringValue, feeAmountLabel!.font, 18)
            feeDenomLabel.text = selectedChain.stakeDenom.uppercased()
            WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
            
        } else {
            let stakingAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom == selectedChain.stakeDenom }).first!
            let calFeeAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: handler18)
            let msPrice = BaseData.instance.getPrice(stakingAsset!.coinGeckoId)
            let value = msPrice.multiplying(by: calFeeAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(calFeeAmount.stringValue, feeAmountLabel.font, 18)
            feeDenomLabel.text = stakingAsset!.symbol
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }

    func onSimul() {
        if (toSendAmount == NSDecimalNumber.zero ) { return }
        if (recipientEvmAddress == nil || recipientEvmAddress?.isEmpty == true) { return }
        view.isUserInteractionEnabled = false
        sendBtn.isEnabled = false
        loadingView.isHidden = false
        
        DispatchQueue.global().async { [self] in
            guard let url = URL(string: selectedChain.rpcURL) else { return }
            guard let web3 = try? Web3.new(url) else { return }
            
            let chainID = web3.provider.network?.chainID
            let contractAddress = EthereumAddress.init(fromHex: selectedMsToken!.address!)
            let senderAddress = EthereumAddress.init(selectedChain.evmAddress)
            let recipientAddress = EthereumAddress.init(recipientEvmAddress!)
            let erc20token = ERC20(web3: web3, provider: web3.provider, address: contractAddress!)
            let calSendAmount = toSendAmount.multiplying(byPowerOf10: -selectedMsToken!.decimals!)
            let nonce = try? web3.eth.getTransactionCount(address: senderAddress!)
            let wTx = try? erc20token.transfer(from: senderAddress!, to: recipientAddress!, amount: calSendAmount.stringValue)
            let gasPrice = try? web3.eth.getGasPrice()
            
            var tx: EthereumTransaction
            var multipleGas: BigUInt
            
            let oracle = Web3.Oracle.init(web3)
            let bothFeesPercentiles = oracle.bothFeesPercentiles
            if (bothFeesPercentiles?.baseFee.count ?? 0 > 0 && bothFeesPercentiles?.tip.count ?? 0 > 0) {
                let baseFee = bothFeesPercentiles?.baseFee[1] ?? 27500000000
                let tip = bothFeesPercentiles?.tip[1] ?? 500000000
                let eip1559 = EIP1559Envelope(to: contractAddress!, nonce: nonce!, chainID: chainID!, value: wTx!.transaction.value,
                                              data: wTx!.transaction.data, maxPriorityFeePerGas: tip, maxFeePerGas: baseFee, gasLimit: BigUInt(900000))
                tx = EthereumTransaction(with: eip1559)
                multipleGas = eip1559.maxFeePerGas
                
            } else {
                let legacy = LegacyEnvelope(to: contractAddress!, nonce: nonce!, chainID: chainID, value: wTx!.transaction.value,
                                            data: wTx!.transaction.data, gasPrice: gasPrice!, gasLimit: BigUInt(900000))
                tx = EthereumTransaction(with: legacy)
                multipleGas = legacy.gasPrice
            }
            
//            if let gasLimit = try? web3.eth.estimateGas(tx, transactionOptions: wTx?.transactionOptions) {
//                print("gasLimit ", gasLimit)
//                let newLimit = NSDecimalNumber(string: String(gasLimit)).multiplying(by: NSDecimalNumber(string: "1.3"), withBehavior: handler0Up)
//                tx.parameters.gasLimit = Web3.Utils.parseToBigUInt(newLimit.stringValue, decimals: 0)
            ethereumTransaction = tx
            feeAmount = NSDecimalNumber(string: String(ethereumTransaction!.gasLimit.multiplied(by: multipleGas)))
            DispatchQueue.main.async {
                self.onUpdateFeeView()
                self.view.isUserInteractionEnabled = true
                self.sendBtn.isEnabled = true
                self.loadingView.isHidden = true
            }
//            }
        }
    }
}

extension Erc20Transfer: AmountSheetDelegate, AddressDelegate, PinDelegate {
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        recipientEvmAddress = nil
        userInputAddress = address
        if (WUtils.isValidBechAddress(selectedChain, userInputAddress)) {
            recipientBechAddress = userInputAddress
            recipientEvmAddress = KeyFac.convertBech32ToEvm(userInputAddress!)
        }
        if (WUtils.isValidEvmAddress(userInputAddress)) {
            recipientBechAddress = KeyFac.convertEvmToBech32(userInputAddress!, selectedChain.bechAccountPrefix!)
            recipientEvmAddress = userInputAddress
        }
        onUpdateToAddressView()
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            
            DispatchQueue.global().async { [self] in
                guard let url = URL(string: selectedChain.rpcURL) else { return }
                guard let web3 = try? Web3.new(url) else { return }
                try? ethereumTransaction!.sign(privateKey: selectedChain.privateKey!)
                
                if let result = try? web3.eth.sendRawTransaction(ethereumTransaction!) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
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
    }
    
    
}
