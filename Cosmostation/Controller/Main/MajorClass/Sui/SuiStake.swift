//
//  SuiStake.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import SDWebImage

class SuiStake: BaseVC {
    
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
    
    var selectedChain: ChainSui!
    
    var suiFetcher: SuiFetcher!
    var suiFeeBudget = NSDecimalNumber.zero
    var suiGasPrice = NSDecimalNumber.zero
    
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
            suiFetcher = selectedChain.getSuiFetcher()
            suiGasPrice = try await suiFetcher.fetchGasprice()
            
            DispatchQueue.main.async {
                self.onInitFee()                            // set init fee for set send available
                self.onInitView()                           // set selected asset display symbol, sendable amount, display decimal
            }
        }
    }
    
    override func setLocalizedString() {
        titleLabel.text = String(format: NSLocalizedString("title_coin_stake", comment: ""), "SUI")
        stakingAmountTitle.text = NSLocalizedString("str_delegate_amount", comment: "")
        stakingAmountHintLabel.text = NSLocalizedString("msg_tap_for_add_amount", comment: "")
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_stake", comment: ""), for: .normal)
    }
    
    func onInitFee() {
        feeSegments.removeAllSegments()
        feeSegments.insertSegment(withTitle: "Default", at: 0, animated: false)
        feeSegments.selectedSegmentIndex = 0
        feeSelectImg.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakeDenom ?? selectedChain.coinSymbol), placeholderImage: UIImage(named: "tokenDefault"))
        
        feeSelectLabel.text = selectedChain.coinSymbol
        feeDenomLabel.text = selectedChain.coinSymbol
        suiFeeBudget = suiFetcher.baseFee(.SUI_STAKE)
        onUpdateFeeView()
    }
    
    func onInitView() {
        toValidator = suiFetcher.suiValidators[0]
        onUpdateValidatorView()
        
        availableAmount = suiFetcher.balanceAmount(SUI_MAIN_DENOM).subtracting(suiFeeBudget)
        
        titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakeDenom ?? ""), placeholderImage: UIImage(named: "tokenDefault"))
        
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
        baseSheet.sheetType = .SelectSuiValidator
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    func onUpdateValidatorView() {
        monikerImg.sd_setImage(with: toValidator.suiValidatorImg(), placeholderImage: UIImage(named: "validatorDefault"))
        monikerLabel.text = toValidator.suiValidatorName()
        commLabel?.attributedText = WDP.dpAmount(toValidator.suiValidatorCommission().stringValue, commLabel!.font, 2)
        onSimul()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.availableAmount = availableAmount
        amountSheet.existedAmount = toStakeAmount == NSDecimalNumber.zero ? nil : toStakeAmount
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxSuiStake
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateAmountView(_ amount: String) {
        toStakeAmount = NSDecimalNumber(string: amount)
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.coinSymbol) else { return }
        let dpAmount = toStakeAmount.multiplying(byPowerOf10: -9, withBehavior: handler18Down)
        let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
        WDP.dpValue(value, stakingCurrencyLabel, stakingValueLabel)
        stakingAmountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, stakingAmountLabel!.font, 9)
        stakingDenomLabel.text = selectedChain.coinSymbol
        stakingAmountHintLabel.isHidden = true
        stakingAmountLabel.isHidden = false
        stakingDenomLabel.isHidden = false
        stakingCurrencyLabel.isHidden = false
        stakingValueLabel.isHidden = false
        onSimul()
        
        if (toStakeAmount.compare(SUI_MIN_STAKE).rawValue < 0) {
            onShowToast(NSLocalizedString("error_staking_min_sui", comment: ""))
        }
    }
    
    func onUpdateFeeView() {
        stakeBtn.isEnabled = false
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.coinSymbol) else { return }
        let feePrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeDpBudge = suiFeeBudget.multiplying(byPowerOf10: -9, withBehavior: getDivideHandler(9))
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
        if (toStakeAmount.compare(SUI_MIN_STAKE).rawValue < 0) { return }
        
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        suiStakeGasCheck()
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?, _ errorMessage: String? = nil) {
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        guard let toGas = gasUsed else {
            onShowToast(errorMessage ?? NSLocalizedString("error_evm_simul", comment: ""))
            return
        }
        suiFeeBudget = NSDecimalNumber.init(value: toGas)
        onUpdateFeeView()
        stakeBtn.isEnabled = true
    }
}

extension SuiStake {
    
    func suiStakeGasCheck() {
        Task {
            if let txBytes = try await suiFetcher.unsafeStake(selectedChain.mainAddress, suiInputs(), toStakeAmount.stringValue, toValidator["suiAddress"].stringValue, suiFeeBudget.stringValue),
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
    
    func suiStake() {
        Task {
            do {
                if let txBytes = try await suiFetcher.unsafeStake(selectedChain.mainAddress, suiInputs(), toStakeAmount.stringValue, toValidator["suiAddress"].stringValue, suiFeeBudget.stringValue),
                   let dryRes = try await suiFetcher.suiDryrun(txBytes), dryRes["error"].isEmpty,
                   let broadRes = try await suiFetcher.suiExecuteTx(txBytes, Signer.suiSignatures(selectedChain, txBytes), nil) {
                    
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
    
    func suiInputs() -> [String] {
        var result = [String]()
        suiFetcher.suiObjects.forEach { object in
            if (object["type"].stringValue.contains(SUI_MAIN_DENOM)) {
                result.append(object["objectId"].stringValue)
            }
        }
        return result
    }
}


extension SuiStake: BaseSheetDelegate, AmountSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectSuiValidator) {
            if let suiAddress = result["suiAddress"] as? String {
                toValidator = suiFetcher.suiValidators.filter { $0["suiAddress"].stringValue == suiAddress }.first!
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
            
            suiStake()
        }
    }
}
