//
//  IotaStake.swift
//  Cosmostation
//
//  Created by 차소민 on 4/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import SDWebImage

class IotaStake: BaseVC {
    
    @IBOutlet weak var titleCoinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var monikerImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!
    
    @IBOutlet weak var stakingAmountCardView: FixCardView!
    @IBOutlet weak var stakingAmountTitle: UILabel!
    @IBOutlet weak var stakingAmountHintLabel: UILabel!
    @IBOutlet weak var stakingAmountLabel: UILabel!
    @IBOutlet weak var stakingDenomLabel: UILabel!
    @IBOutlet weak var stakingCurrencyLabel: UILabel!
    @IBOutlet weak var stakingValueLabel: UILabel!

    
    @IBOutlet weak var feeCardView: FixCardView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainIota!
    
    var iotaFetcher: IotaFetcher!
    var iotaFeeBudget = NSDecimalNumber.zero
    var iotaGasPrice = NSDecimalNumber.zero
    
    var availableAmount = NSDecimalNumber.zero
    var toStakeAmount = NSDecimalNumber.zero
    var toValidator: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        
        Task {
            iotaFetcher = selectedChain.getIotaFetcher()
            iotaGasPrice = try await iotaFetcher.fetchGasprice()
            
            DispatchQueue.main.async {
                self.onInitFee()                            // set init fee for set send available
                self.onInitView()                           // set selected asset display symbol, sendable amount, display decimal
            }
        }
    }
    
    override func setLocalizedString() {
        titleLabel.text = String(format: NSLocalizedString("title_coin_stake", comment: ""), "IOTA")
        stakingAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
    }
    
    func onInitFee() {
        feeSegments.removeAllSegments()
        feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
        feeSegments.selectedSegmentIndex = 0
        feeSelectImg.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakingAssetDenom()), placeholderImage: UIImage(named: "tokenDefault"))
        
        feeSelectLabel.text = selectedChain.mainAssetSymbol()
        feeDenomLabel.text = selectedChain.mainAssetSymbol()
        iotaFeeBudget = iotaFetcher.baseFee(.IOTA_STAKE)
        onUpdateFeeView()
    }
    
    func onInitView() {
        toValidator = iotaFetcher.iotaValidators[0]
        onUpdateValidatorView()
        
        availableAmount = iotaFetcher.balanceAmount(IOTA_MAIN_DENOM).subtracting(iotaFeeBudget)
        
        titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakingAssetDenom()), placeholderImage: UIImage(named: "tokenDefault"))
        
        loadingView.isHidden = true
        titleLabel.isHidden = false
        validatorCardView.isHidden = false
        stakingAmountCardView.isHidden = false
        feeCardView.isHidden = false
        stakeBtn.isHidden = false
        view.isUserInteractionEnabled = true
    }

    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectIotaValidator
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateValidatorView() {
        monikerImg.sd_setImage(with: toValidator.iotaValidatorImg(), placeholderImage: UIImage(named: "iconValidatorDefault"))
        monikerLabel.text = toValidator.iotaValidatorName()
        commLabel?.attributedText = WDP.dpAmount(toValidator.iotaValidatorCommission().stringValue, commLabel!.font, 2)
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.availableAmount = availableAmount
        amountSheet.existedAmount = toStakeAmount == NSDecimalNumber.zero ? nil : toStakeAmount
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxIotaStake
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        toStakeAmount = NSDecimalNumber(string: amount)
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.mainAssetSymbol()) else { return }
        let dpAmount = toStakeAmount.multiplying(byPowerOf10: -9, withBehavior: handler18Down)
        let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
        WDP.dpValue(value, stakingCurrencyLabel, stakingValueLabel)
        stakingAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, stakingAmountLabel!.font, 9)
        stakingDenomLabel.text = selectedChain.mainAssetSymbol()
        stakingAmountHintLabel.isHidden = true
        stakingAmountLabel.isHidden = false
        stakingDenomLabel.isHidden = false
        stakingCurrencyLabel.isHidden = false
        stakingValueLabel.isHidden = false
        onSimul()
        
        if (toStakeAmount.compare(IOTA_MIN_STAKE).rawValue < 0) {
            onShowToast(NSLocalizedString("error_staking_min_iota", comment: ""))
        }
    }
    
    func onUpdateFeeView() {
        stakeBtn.isEnabled = false
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.mainAssetSymbol()) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeDpBudge = iotaFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
        let feeValue = feePrice.multiplying(by: feeDpBudge, withBehavior: handler6)
        feeAmountLabel.attributedText = WDP.dpAmount(feeDpBudge.stringValue, feeAmountLabel!.font, 9)
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    @IBAction func onClickStake(_ sender: Any) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    
    func onSimul() {
        stakeBtn.isEnabled = false
        if (toValidator == nil ) { return }
        if (toStakeAmount.compare(IOTA_MIN_STAKE).rawValue < 0) { return }
        
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        iotaStakeGasCheck()
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
        stakeBtn.isEnabled = true
    }
}


extension IotaStake {
    
    func iotaStakeGasCheck() {
        Task {
            if let txBytes = try await iotaFetcher.unsafeStake(selectedChain.mainAddress, iotaInputs(), toStakeAmount.stringValue, toValidator["iotaAddress"].stringValue, iotaFeeBudget.stringValue),
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
    
    func iotaStake() {
        Task {
            do {
                if let txBytes = try await iotaFetcher.unsafeStake(selectedChain.mainAddress, iotaInputs(), toStakeAmount.stringValue, toValidator["iotaAddress"].stringValue, iotaFeeBudget.stringValue),
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
    
    func iotaInputs() -> [String] {
        var result = [String]()
        iotaFetcher.iotaObjects.forEach { object in
            if (object["type"].stringValue.contains(IOTA_MAIN_DENOM)) {
                result.append(object["objectId"].stringValue)
            }
        }
        return result
    }
}


extension IotaStake: BaseSheetDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectIotaValidator) {
            if let iotaAddress = result["iotaAddress"] as? String {
                toValidator = iotaFetcher.iotaValidators.filter { $0["iotaAddress"].stringValue == iotaAddress }.first!
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
            
            iotaStake()
        }
    }
}
