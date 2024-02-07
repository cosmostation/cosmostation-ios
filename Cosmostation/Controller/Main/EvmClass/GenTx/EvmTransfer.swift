//
//  EvmTransfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/31/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import web3swift
import BigInt

class EvmTransfer: BaseVC {
    
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
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
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
    
    var selectedChain: EvmClass!
    var selectedMsToken: MintscanToken?
    
    
    var selectedFee = 0
    var feeAmount = NSDecimalNumber.zero
    
    var availableAmount = NSDecimalNumber.zero
    var toSendAmount = NSDecimalNumber.zero
    var recipientAddress: String?
    var ethereumTx: EthereumTransaction?
    var decimal: Int16 = 18
    var msPrice = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        
        //set init fee UI
        feeSelectImg.image =  UIImage.init(named: selectedChain.coinLogo)
        feeSelectLabel.text = selectedChain.coinSymbol
        feeDenomLabel.text = selectedChain.coinSymbol
        
        if (selectedMsToken == nil) {
            //send eth
            toSendAssetImg.image =  UIImage.init(named: selectedChain.coinLogo)
            toSendSymbolLabel.text = selectedChain.coinSymbol
            toAssetDenomLabel.text = selectedChain.coinSymbol
            availableAmount = selectedChain.evmBalances
            decimal = 18
            msPrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
            
        } else {
            //send erc20
            toSendAssetImg.af.setImage(withURL: selectedMsToken!.assetImg())
            toSendSymbolLabel.text = selectedMsToken!.symbol
            toAssetDenomLabel.text = selectedMsToken!.symbol
            availableAmount = selectedMsToken!.getAmount()
            decimal = selectedMsToken!.decimals ?? 18
            msPrice = BaseData.instance.getPrice(selectedMsToken!.coinGeckoId)
            
        }
        
        onSimul()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 540
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
        let amountSheet = EvmTxAmountSheet(nibName: "EvmTxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msToken = selectedMsToken
        if (toSendAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toSendAmount
        }
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet, 280)
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
            
            let dpSendAmount = toSendAmount.multiplying(byPowerOf10: -decimal, withBehavior: getDivideHandler(decimal))
            toAssetAmountLabel.attributedText = WDP.dpAmount(dpSendAmount.stringValue, toAssetAmountLabel!.font, decimal)
            
            let value = msPrice.multiplying(by: dpSendAmount, withBehavior: handler6)
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
        let addressSheet = EvmTxAddressSheet(nibName: "EvmTxAddressSheet", bundle: nil)
        addressSheet.selectedChain = selectedChain
        if (recipientAddress?.isEmpty == false) {
            addressSheet.existedAddress = recipientAddress
        }
        addressSheet.addressDelegate = self
        self.onStartSheet(addressSheet, 280)
    }
    
    func onUpdateToAddressView() {
        if (recipientAddress == nil || recipientAddress?.isEmpty == true) {
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
        } else {
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = recipientAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
        }
        onSimul()
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFee = sender.selectedSegmentIndex
        onSimul()
    }
    
    func onUpdateFeeView() {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        
        if (feeAmount != NSDecimalNumber.zero) {
            //TODO check available!!!!
            let calFeeAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: handler18)
            let value = msPrice.multiplying(by: calFeeAmount, withBehavior: handler6)
            feeAmountLabel.attributedText = WDP.dpAmount(calFeeAmount.stringValue, feeAmountLabel.font, 18)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
            
            feeCardView.isHidden = false
            errorCardView.isHidden = true
            sendBtn.isEnabled = true
            
        } else {
            // display ERROR
            
            feeCardView.isHidden = true
            errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
            errorCardView.isHidden = false
            sendBtn.isEnabled = false
        }
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        if (toSendAmount == NSDecimalNumber.zero ) { return }
        if (recipientAddress == nil || recipientAddress?.isEmpty == true) { return }
        view.isUserInteractionEnabled = false
        sendBtn.isEnabled = false
        loadingView.isHidden = false
        
        DispatchQueue.global().async { [self] in
            let web3 = selectedChain.getWeb3Connection()!
            let chainID = web3.provider.network?.chainID
            let senderAddress = EthereumAddress.init(selectedChain.evmAddress)
            let recipientAddress = EthereumAddress.init(recipientAddress!)
            let nonce = try? web3.eth.getTransactionCount(address: senderAddress!)
            let calSendAmount = toSendAmount.multiplying(byPowerOf10: -decimal)
            
            var toAddress: EthereumAddress!
            var wTx: WriteTransaction?
            var gasLimit: BigUInt = 21000
            feeAmount = NSDecimalNumber.zero
            
            if (selectedMsToken == nil) {
                toAddress = recipientAddress
                //NOTICE set value not work this web3swift version library
                let amountssssss = Web3.Utils.parseToBigUInt(calSendAmount.stringValue, units: .eth)
                wTx = web3.eth.sendETH(to: recipientAddress!, amount: "0")
                wTx?.transaction.value = amountssssss!
                
            } else {
                toAddress = EthereumAddress.init(fromHex: selectedMsToken!.address!)
                let erc20token = ERC20(web3: web3, provider: web3.provider, address: toAddress!)
                wTx = try! erc20token.transfer(from: senderAddress!, to: recipientAddress!, amount: calSendAmount.stringValue)
            }
            
            if let estimateGas = try? wTx!.estimateGas(transactionOptions: .defaultOptions) {
                gasLimit = estimateGas
            }
            print("wTx ", wTx)
            print("wTx ", wTx?.transaction.value)
            
            let oracle = Web3.Oracle.init(web3)
            let bothFeesPercentiles = oracle.bothFeesPercentiles
            print("bothFeesPercentiles ", bothFeesPercentiles)
            if (bothFeesPercentiles?.baseFee.count ?? 0 > 0 && bothFeesPercentiles?.tip.count ?? 0 > 0) {
                let baseFee = bothFeesPercentiles?.baseFee[selectedFee] ?? 27500000000
                let tip = bothFeesPercentiles?.tip[selectedFee] ?? 500000000
                let totalPerGas = baseFee + tip
                let eip1559 = EIP1559Envelope(to: toAddress, nonce: nonce!, chainID: chainID!, value: wTx!.transaction.value,
                                              data: wTx!.transaction.data, maxPriorityFeePerGas: tip, maxFeePerGas: baseFee, gasLimit: gasLimit)
                ethereumTx = EthereumTransaction(with: eip1559)
                feeAmount = NSDecimalNumber(string: String(gasLimit.multiplied(by: totalPerGas)))
                
                print("ethereumTx ", ethereumTx?.value)
//                print("gasLimit ", legacy.gasLimit)
//                print("totalPerGas ", totalPerGas)
//                print("feeAmount ", feeAmount)
                
            } else {
                var gasPrice: BigUInt = 27500000000
                if let gasprice = try? web3.eth.getGasPrice() {
                    gasPrice = gasprice
                }
//                print("gasPrice ", gasPrice)
                let legacy = LegacyEnvelope(to: toAddress, nonce: nonce!, chainID: chainID, value: wTx!.transaction.value,
                                            data: wTx!.transaction.data, gasPrice: gasPrice, gasLimit: gasLimit)
                ethereumTx = EthereumTransaction(with: legacy)
                feeAmount = NSDecimalNumber(string: String(gasLimit.multiplied(by: gasPrice)))
//                print("gasLimit ", legacy.gasLimit)
//                print("gasPrice ", gasPrice)
//                print("feeAmount ", feeAmount)
            }
            
            DispatchQueue.main.async {
                self.onUpdateFeeView()
            }
        }
    }

}


extension EvmTransfer: AddressDelegate, EvmAmountSheetDelegate, PinDelegate {
    
    func onInputedAddress(_ address: String, _ memo: String?) {
        recipientAddress = address
        onUpdateToAddressView()
    }
    
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            sendBtn.isEnabled = false
            loadingView.isHidden = false
            
            DispatchQueue.global().async { [self] in
                let web3 = selectedChain.getWeb3Connection()!
                try? ethereumTx!.sign(privateKey: selectedChain.privateKey!)
                if let result = try? web3.eth.sendRawTransaction(ethereumTx!) {
                    print("result ", result)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        
                        let txResult = EvmTxResult(nibName: "EvmTxResult", bundle: nil)
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
