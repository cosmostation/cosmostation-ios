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
    
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedFeePosition = 0
    var toValidator: Cosmos_Staking_V1beta1_Validator?
    var availableAmount = NSDecimalNumber.zero
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
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        
        if (toValidator == nil) {
            if let validator = selectedChain.cosmosValidators.filter({ $0.description_p.moniker == "Cosmostation" }).first {
                toValidator = validator
            } else {
                toValidator = selectedChain.cosmosValidators[0]
            }
        }
        onUpdateValidatorView()
        
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
    }
    
    override func setLocalizedString() {
        stakingAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
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
//        onSimul()
    }
    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.validators = selectedChain.cosmosValidators
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectValidator
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onClickAmount() {
    }

}

extension EvmDelegate: BaseSheetDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectValidator) {
            if let validatorAddress = result["validatorAddress"] as? String {
                toValidator = selectedChain.cosmosValidators.filter({ $0.operatorAddress == validatorAddress }).first!
                onUpdateValidatorView()
            }
            
        }
    }
}
