//
//  EvmRedelegate.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import web3swift
import BigInt

class EvmRedelegate: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var fromCardView: FixCardView!
    @IBOutlet weak var fromMonikerImg: UIImageView!
    @IBOutlet weak var fromInactiveTag: UIImageView!
    @IBOutlet weak var fromJailedTag: UIImageView!
    @IBOutlet weak var fromMonikerLabel: UILabel!
    @IBOutlet weak var fromStakedLabel: UILabel!
    
    @IBOutlet weak var toCardView: FixCardView!
    @IBOutlet weak var toMonikerImg: UIImageView!
    @IBOutlet weak var toInactiveTag: UIImageView!
    @IBOutlet weak var toJailedTag: UIImageView!
    @IBOutlet weak var toMonikerLabel: UILabel!
    @IBOutlet weak var toCommLabel: UILabel!
    @IBOutlet weak var toCommPercentLabel: UILabel!
    
    @IBOutlet weak var amountCardView: FixCardView!
    @IBOutlet weak var amountTitle: UILabel!
    @IBOutlet weak var amountHintLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var reStakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedFeePosition = 0
    var fromValidator: Cosmos_Staking_V1beta1_Validator?
    var toValidator: Cosmos_Staking_V1beta1_Validator?
    var availableAmount = NSDecimalNumber.zero
    var redelegateAmount: NSDecimalNumber? = NSDecimalNumber.zero
    var decimal: Int16 = 18
    
    var selectedChain: EvmClass!
    var evmTx: EthereumTransaction?
    var evmGasTitle: [String] = [NSLocalizedString("str_low", comment: ""), NSLocalizedString("str_average", comment: ""), NSLocalizedString("str_high", comment: "")]
    var evmGasPrice: [(BigUInt, BigUInt)] = [(500000000, 1000000000), (500000000, 1000000000), (500000000, 1000000000)]
    var evmGasLimit: BigUInt = 21000
    var web3: web3?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        let cosmostation = selectedChain.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first
        if (fromValidator?.operatorAddress == cosmostation?.operatorAddress) {
            toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress != cosmostation!.operatorAddress }).first
        } else {
            toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress != fromValidator?.operatorAddress }).first
        }
        
        onInitFee()
        onInitFromValidatorView()
        onUpdateToValidatorView()
        
        if let url = URL(string: selectedChain.getEvmRpc()) {
            DispatchQueue.global().async { [self] in
                do {
                    self.web3 = try Web3.new(url)
                } catch {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
        toCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToValidator)))
        amountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
    }
    
    override func setLocalizedString() {
        amountTitle.text = NSLocalizedString("str_redelegate_amount", comment: "")
        amountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        reStakeBtn.setTitle(NSLocalizedString("str_switch_validator", comment: ""), for: .normal)
    }
    
    func onInitFromValidatorView() {
        fromMonikerImg.image = UIImage(named: "validatorDefault")
        fromMonikerImg.af.setImage(withURL: selectedChain.monikerImg(fromValidator!.operatorAddress))
        fromMonikerLabel.text = fromValidator!.description_p.moniker
        if (fromValidator!.jailed) {
            fromJailedTag.isHidden = false
        } else {
            fromInactiveTag.isHidden = fromValidator!.status == .bonded
        }
        
        let stakeDenom = selectedChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            let staked = selectedChain.cosmosDelegations.filter { $0.delegation.validatorAddress == fromValidator?.operatorAddress }.first?.balance.amount
            availableAmount = NSDecimalNumber(string: staked)
            fromStakedLabel?.attributedText = WDP.dpAmount(availableAmount.multiplying(byPowerOf10: -msAsset.decimals!).stringValue, fromStakedLabel!.font, 6)
        }
        print("onInitFromValidatorView ", availableAmount)
    }
    
    @objc func onClickToValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.validators = selectedChain.cosmosValidators
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectValidator
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateToValidatorView() {
        toMonikerImg.image = UIImage(named: "validatorDefault")
        toMonikerImg.af.setImage(withURL: selectedChain.monikerImg(toValidator!.operatorAddress))
        toMonikerLabel.text = toValidator!.description_p.moniker
        if (toValidator!.jailed) {
            toJailedTag.isHidden = false
        } else {
            toInactiveTag.isHidden = toValidator!.status == .bonded
        }
        
        let commission = NSDecimalNumber(string: toValidator!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
        toCommLabel?.attributedText = WDP.dpAmount(commission.stringValue, toCommLabel!.font, 2)
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
        amountSheet.availableAmount = availableAmount
        if let redelegateAmount = redelegateAmount {
            amountSheet.existedAmount = redelegateAmount
        }
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxDelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        let stakeDenom = selectedChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            redelegateAmount = NSDecimalNumber(string: amount)
            WDP.dpCoin(msAsset, redelegateAmount!, nil, amountDenomLabel, amountLabel, msAsset.decimals)
            amountHintLabel.isHidden = true
            amountLabel.isHidden = false
            amountDenomLabel.isHidden = false
        } else {
            redelegateAmount = nil
        }
        onSimul()
    }
    
    
    func onInitFee() {
        feeSegments.removeAllSegments()
        for i in 0..<evmGasTitle.count {
            feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
        }
        selectedFeePosition = 1
        feeSegments.selectedSegmentIndex = selectedFeePosition
        feeSelectImg.image =  UIImage.init(named: selectedChain.coinLogo)
        feeSelectLabel.text = selectedChain.coinSymbol
        feeDenomLabel.text = selectedChain.coinSymbol
        
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let totalGasPrice = evmGasPrice[selectedFeePosition].0 + evmGasPrice[selectedFeePosition].1
        let feeAmount = NSDecimalNumber(string: String(totalGasPrice.multiplied(by: evmGasLimit)))
        let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
        let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
        selectedFeePosition = sender.selectedSegmentIndex
        onUpdateFeeView()
        onSimul()
    }
    
    func onUpdateFeeView() {
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let totalGasPrice = evmGasPrice[selectedFeePosition].0 + evmGasPrice[selectedFeePosition].1
        let feeAmount = NSDecimalNumber(string: String(totalGasPrice.multiplied(by: evmGasLimit)))
        let feeDpAmount = feeAmount.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(18))
        let feeValue = feePrice.multiplying(by: feeDpAmount, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpAmount.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    func onUpdateFeeViewAfterSimul() {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        guard evmTx != nil else {
            feeCardView.isHidden = true
            errorCardView.isHidden = false
            errorMsgLabel.text = NSLocalizedString("error_evm_simul", comment: "")
            return
        }
        onUpdateFeeView()
        feeCardView.isHidden = false
        errorCardView.isHidden = true
        reStakeBtn.isEnabled = true
    }

    func onSimul() {
        reStakeBtn.isEnabled = false
        if (toValidator == nil) { return }
        if (redelegateAmount == nil || redelegateAmount == NSDecimalNumber.zero ) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        evmTx = nil
        
        DispatchQueue.global().async { [self] in
            guard let web3 = self.web3 else { return }
            
            let chainID = web3.provider.network?.chainID
            let delegatorAddress = EthereumAddress.init(selectedChain.evmAddress)
            let srcValidatorAddress = EthereumAddress.init(KeyFac.convertBech32ToEvm(fromValidator!.operatorAddress))
            let dstValidatorAddress = EthereumAddress.init(KeyFac.convertBech32ToEvm(toValidator!.operatorAddress))
            let nonce = try? web3.eth.getTransactionCount(address: delegatorAddress!)
            let stakingContract = EthereumAddress.init(fromHex: BERA_CONT_STAKING)
            let stakingABI = BERA_Staking(web3: web3, provider: web3.provider, address: stakingContract!)
            
            guard let wTx = try? stakingABI.beginRedelegate(delegatorAddress!, srcValidatorAddress!, dstValidatorAddress!, redelegateAmount!.stringValue) else {
                DispatchQueue.main.async {
                    self.onUpdateFeeViewAfterSimul()
                }
                return
            }
            
            if let estimateGas = try? wTx.estimateGas(transactionOptions: .defaultOptions) {
                evmGasLimit = estimateGas
            }
            print("evmGasLimit ", evmGasLimit)
            
            let oracle = Web3.Oracle.init(web3)
            let feeHistory = oracle.bothFeesPercentiles
            print("feeHistory ", feeHistory)
            
            if (feeHistory?.baseFee.count ?? 0 > 0 && feeHistory?.tip.count ?? 0 > 0) {
                for i in 0..<3 {
                    var baseFee = feeHistory?.baseFee[i] ?? 500000000
                    baseFee = baseFee > 500000000 ? baseFee : 500000000
                    var tip = feeHistory?.tip[i] ?? 1000000000
                    tip = tip > 1000000000 ? tip : 1000000000
                    evmGasPrice[i] = (baseFee, tip)
                }
                print("evmGasPrice eip1559 ", evmGasPrice)
                let eip1559 = EIP1559Envelope(to: stakingContract!, nonce: nonce!, chainID: chainID!, value: 0,
                                              data: wTx.transaction.data, maxPriorityFeePerGas: evmGasPrice[selectedFeePosition].1,
                                              maxFeePerGas: evmGasPrice[selectedFeePosition].0 + evmGasPrice[selectedFeePosition].1, gasLimit: evmGasLimit)
                evmTx = EthereumTransaction(with: eip1559)
            }
            
            DispatchQueue.main.async {
                self.onUpdateFeeViewAfterSimul()
            }
            
        }
    }
    
    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
}


extension EvmRedelegate: BaseSheetDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateToValidatorView()
            }
        }
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            reStakeBtn.isEnabled = false
            loadingView.isHidden = false
            DispatchQueue.global().async { [self] in
                guard let web3 = self.web3 else {
                    return
                }
                do {
                    try evmTx?.sign(privateKey: selectedChain.privateKey!)
                    print("evmTx ", evmTx)
                    let result = try web3.eth.sendRawTransaction(evmTx!)
                    print("result ", result)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = .WEB3_STYLE
                        txResult.fromChain = self.selectedChain
                        txResult.toChain = self.selectedChain
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
}
