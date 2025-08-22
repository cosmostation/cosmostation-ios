//
//  EvmCancelUnbonding.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import web3swift
import BigInt

class EvmCancelUnbonding: BaseVC {}

/*
class EvmCancelUnbonding: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorsLabel: UILabel!
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
    
    @IBOutlet weak var cancelBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedFeePosition = 0
    var unbondingEntry: UnbondingEntry!
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
        
        onInitView()
        onInitFee()
        
        if let url = URL(string: selectedChain.getEvmRpc()) {
            DispatchQueue.global().async { [self] in
                do {
                    self.web3 = try Web3.new(url)
 let web3Provider = try? await Web3HttpProvider.init(url: url, network: .Custom(networkID: fromChain.chainIdEvmBigint))
                    DispatchQueue.main.async {
                        self.onSimul()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    override func setLocalizedString() {
        cancelBtn.setTitle(NSLocalizedString("str_cancle_unstake", comment: ""), for: .normal)
    }
    
    func onInitView() {
        if let validator = selectedChain.cosmosValidators.filter({ $0.operatorAddress == unbondingEntry.validatorAddress }).first {
            validatorsLabel.text = validator.description_p.moniker
        }
        
        let stakeDenom = selectedChain.stakingAssetDenom()
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, stakeDenom) {
            let unbondingAmount = NSDecimalNumber(string: unbondingEntry.entry.balance).multiplying(byPowerOf10: -msAsset.decimals!)
            amountLabel?.attributedText = WDP.dpAmount(unbondingAmount.stringValue, amountLabel!.font, msAsset.decimals!)
            amountDenomLabel.text = msAsset.symbol
        }
    }
    
    func onInitFee() {
        feeSegments.removeAllSegments()
        for i in 0..<evmGasTitle.count {
            feeSegments.insertSegment(withTitle: evmGasTitle[i], at: i, animated: false)
        }
        selectedFeePosition = 1
        feeSegments.selectedSegmentIndex = selectedFeePosition
        feeSelectImg.image =  UIImage.init(named: selectedChain.coinLogo)
        feeSelectLabel.text = selectedChain.mainAssetSymbol()
        feeDenomLabel.text = selectedChain.mainAssetSymbol()
        
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
        cancelBtn.isEnabled = true
    }
    
    
    func onSimul() {
        cancelBtn.isEnabled = false
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        evmTx = nil
        
        DispatchQueue.global().async { [self] in
            guard let web3 = self.web3 else { return }
            
            let chainID = web3.provider.network?.chainID
            let delegatorAddress = EthereumAddress.init(selectedChain.evmAddress)
            let validatorAddress = EthereumAddress.init(KeyFac.convertBech32ToEvm(unbondingEntry.validatorAddress))
            let cancelAmount = unbondingEntry.entry.balance
            let creationHeight = unbondingEntry.entry.creationHeight
            let nonce = try? web3.eth.getTransactionCount(address: delegatorAddress!)
            let stakingContract = EthereumAddress.init(fromHex: BERA_CONT_STAKING)
            let stakingABI = BERA_Staking(web3: web3, provider: web3.provider, address: stakingContract!)
            
            guard let wTx = try? stakingABI.cancelUnbondingDelegation(delegatorAddress!, validatorAddress!, cancelAmount, creationHeight) else {
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

extension EvmCancelUnbonding: PinDelegate {
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            cancelBtn.isEnabled = false
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
