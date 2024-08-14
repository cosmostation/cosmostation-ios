//
//  SuiUnstake.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON

class SuiUnstake: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var objectIdLabel: UILabel!
    @IBOutlet weak var totalStakedLabel: UILabel!
    @IBOutlet weak var principalLabel: UILabel!
    @IBOutlet weak var estimatedRewardLabel: UILabel!
    @IBOutlet weak var startEaringLabel: UILabel!
    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var unstakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainSui!
    var fromValidator: (String, JSON)!

    var suiFetcher: SuiFetcher!
    var suiFeeBudget = NSDecimalNumber.zero
    var suiGasPrice = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()

        Task {
            suiFetcher = selectedChain.getSuiFetcher()
            suiGasPrice = try await suiFetcher.fetchGasprice()
            
            DispatchQueue.main.async {
                self.onInitFee()    // set init fee for set send available
                self.onInitView()   // set selected asset display symbol, sendable amount, display decimal
            }
        }
    }
    
    override func setLocalizedString() {
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        unstakeBtn.setTitle(NSLocalizedString("str_unstake", comment: ""), for: .normal)
    }

    func onInitFee() {
        feeSegments.removeAllSegments()
        feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
        feeSegments.selectedSegmentIndex = 0
        feeSelectImg.image =  UIImage.init(named: selectedChain.coinLogo)
        
        feeSelectLabel.text = selectedChain.coinSymbol
        feeDenomLabel.text = selectedChain.coinSymbol
        suiFeeBudget = suiFetcher.baseFee(.SUI_UNSTAKE)
        onUpdateFeeView()
    }
    
    func onInitView() {
        onUpdateValidatorView()

        titleLabel.isHidden = false
        validatorCardView.isHidden = false
        feeCardView.isHidden = false
        unstakeBtn.isHidden = false
        view.isUserInteractionEnabled = true
    }
    
    func onUpdateValidatorView() {
        if let validator = suiFetcher.suiValidators.filter({ $0["suiAddress"].stringValue == fromValidator.0 }).first {
            logoImg.sd_setImage(with: validator.suiValidatorImg(), placeholderImage: UIImage(named: "tokenDefault"))
            nameLabel.text = validator.suiValidatorName()
        }
        objectIdLabel.text = fromValidator.1["stakedSuiId"].stringValue
        let principal = NSDecimalNumber(value: fromValidator.1["principal"].uInt64Value).multiplying(byPowerOf10: -9)
        let estimatedReward = NSDecimalNumber(value: fromValidator.1["estimatedReward"].uInt64Value).multiplying(byPowerOf10: -9)
        principalLabel?.attributedText = WDP.dpAmount(principal.stringValue, principalLabel!.font, 9)
        estimatedRewardLabel?.attributedText = WDP.dpAmount(estimatedReward.stringValue, principalLabel!.font, 9)
        totalStakedLabel?.attributedText = WDP.dpAmount(estimatedReward.adding(principal).stringValue, principalLabel!.font, 9)
        startEaringLabel.text = "Epoch #" + fromValidator.1["stakeActiveEpoch"].stringValue
        
        onSimul()
    }
    
    func onUpdateFeeView() {
        unstakeBtn.isEnabled = false
        
        let feePrice = BaseData.instance.getPrice(selectedChain.coinGeckoId)
        let feeDpBudge = suiFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
        let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpBudge.stringValue, feeAmountLabel!.font, 18)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    @IBAction func onClickUnstake(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimul() {
        unstakeBtn.isEnabled = false
        if (fromValidator == nil ) { return }
        
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        suiUnstakeGasCheck()
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        guard let toGas = gasUsed else {
            onShowToast(NSLocalizedString("error_evm_simul", comment: ""))
            return
        }
        suiFeeBudget = NSDecimalNumber.init(value: toGas)
        onUpdateFeeView()
        unstakeBtn.isEnabled = true
    }
}


extension SuiUnstake {
    
    func suiUnstakeGasCheck() {
        Task {
            if let txBytes = try await suiFetcher.unsafeUnstake(selectedChain.mainAddress, fromValidator.1["stakedSuiId"].stringValue, suiFeeBudget.stringValue),
               let response = try await suiFetcher.suiDryrun(txBytes) {
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
    
    func suiUnstake() {
        Task {
            do {
                if let txBytes = try await suiFetcher.unsafeUnstake(selectedChain.mainAddress, fromValidator.1["stakedSuiId"].stringValue, suiFeeBudget.stringValue),
                   let dryRes = try await suiFetcher.suiDryrun(txBytes), dryRes["error"].isEmpty,
                   let broadRes = try await suiFetcher.suiExecuteTx(txBytes, Signer.suiSignatures(selectedChain, txBytes)) {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = .SUI_STYLE
                        txResult.fromChain = self.selectedChain
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
}


extension SuiUnstake: PinDelegate {
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            unstakeBtn.isEnabled = false
            loadingView.isHidden = false
            
            suiUnstake()
        }
    }
}
