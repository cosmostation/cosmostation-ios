//
//  EvmDelegate.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/17/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import web3swift
import BigInt

class EvmDelegate: BaseVC {}

/*
//only for bera chain evm staking!!
class EvmDelegate: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var monikerImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!
    
    @IBOutlet weak var stakingAmountCardView: FixCardView!
    @IBOutlet weak var stakingAmountTitle: UILabel!
    @IBOutlet weak var stakingAmountHintLabel: UILabel!
    @IBOutlet weak var stakingAmountLabel: UILabel!
    @IBOutlet weak var stakingDenomLabel: UILabel!
    
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
    
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedFeePosition = 0
    var toValidator: Cosmos_Staking_V1beta1_Validator?
    var availableAmount = NSDecimalNumber.zero
    var delegateAmount: NSDecimalNumber? = NSDecimalNumber.zero
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
        
        if (toValidator == nil) {
            if let validator = selectedChain.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
                toValidator = validator
            } else {
                toValidator = selectedChain.cosmosValidators[0]
            }
        }
        availableAmount = selectedChain.balanceAmount(selectedChain.stakeDenom)
        
        onInitFee()
        onUpdateValidatorView()
        
        if let url = URL(string: selectedChain.getEvmRpc()) {
            DispatchQueue.global().async { [self] in
                do {
                    self.web3 = try Web3.new(url)
                    let web3Provider = try? await Web3HttpProvider.init(url: url, network: nil)
 
                } catch {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
    }
    
    override func setLocalizedString() {
        stakingAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
    }
    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.validators = selectedChain.cosmosValidators
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectValidator
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateValidatorView() {
        monikerImg.image = UIImage(named: "validatorDefault")
        monikerImg.af.setImage(withURL: selectedChain.monikerImg(toValidator!.operatorAddress))
        monikerLabel.text = toValidator!.description_p.moniker
        if (toValidator!.jailed) {
            jailedTag.isHidden = false
        } else {
            inactiveTag.isHidden = toValidator!.status == .bonded
        }
        
        let commission = NSDecimalNumber(string: toValidator!.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
        commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
        amountSheet.availableAmount = availableAmount
        if let delegateAmount = delegateAmount {
            amountSheet.existedAmount = delegateAmount
        }
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxDelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        let stakeDenom = selectedChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            delegateAmount = NSDecimalNumber(string: amount)
            WDP.dpCoin(msAsset, delegateAmount!, nil, stakingDenomLabel, stakingAmountLabel, msAsset.decimals)
            stakingAmountHintLabel.isHidden = true
            stakingAmountLabel.isHidden = false
            stakingDenomLabel.isHidden = false
        } else {
            delegateAmount = nil
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
        stakeBtn.isEnabled = true
    }
    
    
    func onSimul() {
        stakeBtn.isEnabled = false
        if (toValidator == nil) { return }
        if (delegateAmount == nil || delegateAmount == NSDecimalNumber.zero ) { return }
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        evmTx = nil
        
        DispatchQueue.global().async { [self] in
            guard let web3 = self.web3 else { return }
            
            let chainID = web3.provider.network?.chainID
            let delegatorAddress = EthereumAddress.init(selectedChain.evmAddress)
            let validatorAddress = EthereumAddress.init(KeyFac.convertBech32ToEvm(toValidator!.operatorAddress))
            let nonce = try? web3.eth.getTransactionCount(address: delegatorAddress!)
            let stakingContract = EthereumAddress.init(fromHex: BERA_CONT_STAKING)
            let stakingABI = BERA_Staking(web3: web3, provider: web3.provider, address: stakingContract!)
            print("myAddress ", delegatorAddress)
            print("validatorAddress ", validatorAddress)
            
            guard let wTx = try? stakingABI.delegate(delegatorAddress!, validatorAddress!, delegateAmount!.stringValue) else {
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

extension EvmDelegate: BaseSheetDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
            }
        }
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            stakeBtn.isEnabled = false
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
*/
