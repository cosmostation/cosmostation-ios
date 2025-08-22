//
//  IotaUnstake.swift
//  Cosmostation
//
//  Created by 차소민 on 4/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON

class IotaUnstake: BaseVC {
    
    @IBOutlet weak var titleCoinImage: UIImageView!
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
    
    var selectedChain: ChainIota!
    var fromValidator: (String, JSON)!

    var iotaFetcher: IotaFetcher!
    var iotaFeeBudget = NSDecimalNumber.zero
    var iotaGasPrice = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()

        Task {
            iotaFetcher = selectedChain.getIotaFetcher()
            iotaGasPrice = try await iotaFetcher.fetchGasprice()
            
            DispatchQueue.main.async {
                self.onInitFee()    // set init fee for set send available
                self.onInitView()   // set selected asset display symbol, sendable amount, display decimal
            }
        }
    }
    
    override func setLocalizedString() {
        titleLabel.text = String(format: NSLocalizedString("title_coin_unstake", comment: ""), "IOTA")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        unstakeBtn.setTitle(NSLocalizedString("str_unstake", comment: ""), for: .normal)
    }

    func onInitFee() {
        feeSegments.removeAllSegments()
        feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
        feeSegments.selectedSegmentIndex = 0
        feeSelectImg.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakingAssetDenom()), placeholderImage: UIImage(named: "tokenDefault"))
        
        feeSelectLabel.text = selectedChain.mainAssetSymbol()
        feeDenomLabel.text = selectedChain.mainAssetSymbol()
        iotaFeeBudget = iotaFetcher.baseFee(.IOTA_UNSTAKE)
        onUpdateFeeView()
    }
    
    func onInitView() {
        onUpdateValidatorView()
        titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakingAssetDenom()), placeholderImage: UIImage(named: "tokenDefault"))
        titleLabel.isHidden = false
        validatorCardView.isHidden = false
        feeCardView.isHidden = false
        unstakeBtn.isHidden = false
        view.isUserInteractionEnabled = true
    }
    
    func onUpdateValidatorView() {
        if let validator = iotaFetcher.iotaValidators.filter({ $0["iotaAddress"].stringValue == fromValidator.0 }).first {
            logoImg.sd_setImage(with: validator.iotaValidatorImg(), placeholderImage: UIImage(named: "tokenDefault"))
            nameLabel.text = validator.iotaValidatorName()
        }
        objectIdLabel.text = fromValidator.1["stakedIotaId"].stringValue
        let principal = NSDecimalNumber(value: fromValidator.1["principal"].uInt64Value).multiplying(byPowerOf10: -9)
        let estimatedReward = NSDecimalNumber(value: fromValidator.1["estimatedReward"].uInt64Value).multiplying(byPowerOf10: -9)
        principalLabel?.attributedText = WDP.dpAmount(principal.stringValue, principalLabel!.font, 9)
        estimatedRewardLabel?.attributedText = WDP.dpAmount(estimatedReward.stringValue, principalLabel!.font, 9)
        totalStakedLabel?.attributedText = WDP.dpAmount(estimatedReward.adding(principal).stringValue, totalStakedLabel!.font, 9)
        startEaringLabel.text = "Epoch #" + fromValidator.1["stakeActiveEpoch"].stringValue
        
        onSimul()
    }
    
    func onUpdateFeeView() {
        unstakeBtn.isEnabled = false
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.mainAssetSymbol()) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeDpBudge = iotaFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
        let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpBudge.stringValue, feeAmountLabel!.font, 9)
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
        iotaUnstakeGasCheck()
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?, _ errorMessage: String? = nil) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        guard let toGas = gasUsed else {
            onShowToast(errorMessage ?? NSLocalizedString("error_evm_simul", comment: ""))
            return
        }
        iotaFeeBudget = NSDecimalNumber.init(value: toGas)
        onUpdateFeeView()
        unstakeBtn.isEnabled = true
    }
}



extension IotaUnstake {
    
    func iotaUnstakeGasCheck() {
        Task {
            if let txBytes = try await iotaFetcher.unsafeUnstake(selectedChain.mainAddress, fromValidator.1["stakedIotaId"].stringValue, iotaFeeBudget.stringValue),
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
    
    func iotaUnstake() {
        Task {
            do {
                if let txBytes = try await iotaFetcher.unsafeUnstake(selectedChain.mainAddress, fromValidator.1["stakedIotaId"].stringValue, iotaFeeBudget.stringValue),
                   let dryRes = try await iotaFetcher.iotaDryrun(txBytes), dryRes["error"].isEmpty,
                   let broadRes = try await iotaFetcher.iotaExecuteTx(txBytes, Signer.iotaSignatures(selectedChain, txBytes), nil) {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        self.loadingView.isHidden = true
                        let txResult = CommonTransferResult(nibName: "CommonTransferResult", bundle: nil)
                        txResult.txStyle = .IOTA_STYLE
                        txResult.fromChain = self.selectedChain
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
}


extension IotaUnstake: PinDelegate {
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            unstakeBtn.isEnabled = false
            loadingView.isHidden = false
            
            iotaUnstake()
        }
    }
}
