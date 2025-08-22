//
//  BtcUndelegate.swift
//  Cosmostation
//
//  Created by 차소민 on 4/10/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftProtobuf
import SwiftyJSON

class BtcUndelegate: BaseVC {
    @IBOutlet weak var titleCoinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var validatorCardView: FixCardView!
    @IBOutlet weak var monikerImg: UIImageView!
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    
    @IBOutlet weak var unStakingAmountTitle: UILabel!
    @IBOutlet weak var stakedLabel: UILabel!
    @IBOutlet weak var stakedSymbolLabel: UILabel!
    @IBOutlet weak var unStakingCurrencyLabel: UILabel!
    @IBOutlet weak var unStakingValueLabel: UILabel!

    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var unStakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    //unstake , withdraw
    var actionType: BtcStakeActionType?
    
    var selectedChain: BaseChain!
    var selectedFeePosition = 0
    
    var btcFee: UInt64?
    
    var availableAmount = NSDecimalNumber.zero
    var toCoin: Cosmos_Base_V1beta1_Coin?
    
    var delegation: BtcDelegation?
    var fromProvider: FinalityProvider?
    var babylonBtcfetcher: BabylonBTCFetcher!
    
    
    var transactionHex: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        babylonBtcfetcher  = (selectedChain as? ChainBitCoin86)?.getBabylonBtcFetcher()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.stakingAssetDenom()), placeholderImage: UIImage(named: "tokenDefault"))
        
        validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
        
        fromProvider = babylonBtcfetcher.finalityProviders.filter({ fp in
            fp.btcPk == delegation?.providerPk
        }).first
        
        Task {
            
            //init
            let network = selectedChain.isTestnet ? "testnet" : "mainnet"
            let privateKeyHex = selectedChain.privateKey?.toHexString()
            let signerAddress = selectedChain.mainAddress
            let stakingParams = JSON(babylonBtcfetcher.networkInfo).rawString() ?? ""
            
            let initValue = BtcJS.shared.callJSValue(key: "initBTCStaking", param: [network, privateKeyHex, signerAddress, stakingParams])
            
            if initValue != "true" {
                self.loadingView.isHidden = true
                onShowToast("fail to init")
                return
            }
            
            if actionType == .unstake {
                if let networkInfo = babylonBtcfetcher.networkInfo.last {
                    btcFee = networkInfo["unbonding_fee_sat"].uInt64Value
                }
            }
            
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.oninitFeeView()
                self.onUpdateValidatorView()
            }
        }
    }
    
    override func setLocalizedString() {
        let symbol = selectedChain.assetSymbol(selectedChain.mainAssetSymbol())
        
        if actionType == .unstake {
            titleLabel.text = String(format: NSLocalizedString("title_coin_unstake", comment: ""), symbol)
            unStakeBtn.setTitle(NSLocalizedString("str_unstake", comment: ""), for: .normal)
            unStakingAmountTitle.text = NSLocalizedString("str_undelegate_amount", comment: "")

        } else {
            titleLabel.text = String(format: NSLocalizedString("title_coin_withdraw", comment: ""), symbol)
            unStakeBtn.setTitle(NSLocalizedString("str_withdraw", comment: ""), for: .normal)
            unStakingAmountTitle.text = NSLocalizedString("str_withdraw_amount", comment: "")

        }
        
        feeMsgLabel.text = NSLocalizedString("msg_about_fee_tip", comment: "")
    }
    
    @objc func onClickValidator() {
        if actionType == .unstake {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.targetChain = selectedChain
            baseSheet.sheetDelegate = self
            baseSheet.sheetType = .SelectUnstakeFinalityProvider
            onStartSheet(baseSheet, 680, 0.8)
            
        } else {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.targetChain = selectedChain
            baseSheet.sheetDelegate = self
            baseSheet.sheetType = .SelectBtcWithdraw
            onStartSheet(baseSheet, 680, 0.8)

        }
    }
    
    func onUpdateValidatorView() {
        monikerImg.image = UIImage(named: "iconValidatorDefault")
        let chainBabylon = selectedChain.isTestnet ? ChainBabylon_T() : ChainBabylon()
        monikerImg.sd_setImage(with: URL(string: ResourceBase + chainBabylon.apiName + "/finality-provider/" + fromProvider!.btcPk + ".png"), placeholderImage: UIImage(named: "iconValidatorDefault"))
        monikerLabel.text = fromProvider!.moniker
        
        if fromProvider!.jailed {
            jailedTag.isHidden = false
        } else if fromProvider!.votingPower == "0" {
            inactiveTag.isHidden = false
        } else {
            jailedTag.isHidden = true
            inactiveTag.isHidden = true
        }
        
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.mainAssetSymbol()),
           let staked = delegation?.amount {
            let stakingAmount = NSDecimalNumber(integerLiteral: staked).multiplying(byPowerOf10: -msAsset.decimals!)
            stakedLabel?.attributedText = WDP.dpAmount(stakingAmount.stringValue, stakedLabel!.font, 8)
            stakedSymbolLabel.text = selectedChain.mainAssetSymbol()
            
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: stakingAmount, withBehavior: handler6)

            WDP.dpValue(value, unStakingCurrencyLabel, unStakingValueLabel)
            stakedLabel.isHidden = false
            stakedSymbolLabel.isHidden = false
            unStakingCurrencyLabel.isHidden = false
            unStakingValueLabel.isHidden = false
        }
        
        if actionType == .unstake {
            onSimulUnstake()
        } else {
            onSimulWithdraw()
        }
    }
    
    
    func oninitFeeView() {
        feeSegments.removeAllSegments()
        feeSegments.insertSegment(withTitle: "Fixed", at: 0, animated: false)
        feeSegments.selectedSegmentIndex = 0
        
        onUpdateFeeView()
    }
    
    
    @IBAction func feeSegmentSelected(_ sender: UISegmentedControl) {
    }
    
    func onUpdateFeeView() {
        if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.mainAssetSymbol()),
           let btcFee {
            let totalFeeAmount  = NSDecimalNumber(value: btcFee)
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
            let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            feeSelectLabel.text = selectedChain.mainAssetSymbol()
            WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
            WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
        }
    }
    
    @IBAction func onClickUnstake(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onSimulUnstake() {
        unStakeBtn.isEnabled = false
        loadingView.isHidden = false
        view.isUserInteractionEnabled = false
        
        Task {
            if let networkInfo = babylonBtcfetcher.networkInfo.last,
               let publicKeyString = selectedChain.publicKey?.toHexString(),
               let delegation,
               let fromProvider {
                
                let stakerBtcInfo: JSON = ["address":selectedChain.mainAddress, "stakerPublicKeyHex": publicKeyString]
                let stakingInput: JSON = ["finalityProviderPkNoCoordHex": fromProvider.btcPk,
                                          "stakingAmountSat": delegation.amount,
                                          "stakingTimelock": networkInfo["max_staking_time_blocks"].intValue]
                
                let stakingParamsVersion = delegation.version
                let stakingTxHex = delegation.stakingTxHex
                let unsignedUnbondingTxHex = delegation.delegationUnbonding["unbonding_tx"].stringValue
                let covenantUnbondingSignatures = JSON(delegation.delegationUnbonding["covenant_unbonding_signatures"].arrayValue).rawString()
                
                let unbonding = BtcJS.shared.callJSValue(key: "createSignedBtcUnbondingTransaction", param: [stakerBtcInfo.rawString(),
                                                                                                             stakingInput.rawString(),
                                                                                                             stakingParamsVersion,
                                                                                                             stakingTxHex,
                                                                                                             unsignedUnbondingTxHex,
                                                                                                             covenantUnbondingSignatures])
                
                
                if let data = unbonding.data(using: .utf8),
                   let json = try? JSON(data: data) {
                    
                    btcFee = json["fee"].uInt64Value
                    onUpdateFeeView()

                    
                    
                    self.transactionHex = json["transactionHex"].stringValue
                    
                    
                    unStakeBtn.isEnabled = true
                } else {
                    onShowToast("fail to simul")
                }
                
            } else {
                onShowToast("fail to simul")

            }
            
            loadingView.isHidden = true
            view.isUserInteractionEnabled = true

        }
    }
    
    func onSimulWithdraw() {
        unStakeBtn.isEnabled = false
        loadingView.isHidden = false
        view.isUserInteractionEnabled = false
        
        Task {
            if let networkInfo = babylonBtcfetcher.networkInfo.last,
               let publicKeyString = selectedChain.publicKey?.toHexString(),
               let delegation,
               let fromProvider,
               let btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher() {
                
                let stakerBtcInfo: JSON = ["address":selectedChain.mainAddress, "stakerPublicKeyHex": publicKeyString]
                let stakingInput: JSON = ["finalityProviderPkNoCoordHex": fromProvider.btcPk,
                                          "stakingAmountSat": delegation.amount,
                                          "stakingTimelock": networkInfo["max_staking_time_blocks"].intValue]
                
                let stakingParamsVersion = delegation.version
                
                
                
                let txHex = delegation.delegationUnbonding["unbonding_tx"].stringValue
                let feeRate = btcFetcher.fastestFee 
                if delegation.state == "EARLY_UNBONDING_WITHDRAWABLE" {
                    let withdraw = BtcJS.shared.callJSValue(key: "createSignedBtcWithdrawEarlyUnbondedTransaction", param: [stakerBtcInfo.rawString(),
                                                                                                                             stakingInput.rawString(),
                                                                                                                             stakingParamsVersion,
                                                                                                                             txHex,
                                                                                                                             feeRate])
                    
                    if let data = withdraw.data(using: .utf8),
                       let json = try? JSON(data: data) {
                        
                        btcFee = json["fee"].uInt64Value
                        onUpdateFeeView()

                        self.transactionHex = json["transactionHex"].stringValue
                        
                        unStakeBtn.isEnabled = true
                    } else {
                        onShowToast("fail to simul")
                    }
                    

                } else if delegation.state == "TIMELOCK_WITHDRAWABLE" {
                    
                    let withdraw = BtcJS.shared.callJSValue(key: "createSignedBtcWithdrawStakingExpiredTransaction", param: [stakerBtcInfo.rawString(),
                                                                                                                             stakingInput.rawString(),
                                                                                                                             stakingParamsVersion,
                                                                                                                             txHex,
                                                                                                                             feeRate])
                    if let data = withdraw.data(using: .utf8),
                        let json = try? JSON(data: data) {
                        
                        btcFee = json["fee"].uInt64Value
                        onUpdateFeeView()

                        self.transactionHex = json["transactionHex"].stringValue
                        
                        unStakeBtn.isEnabled = true
                    } else {
                        onShowToast("fail to simul")
                    }

                } else {
                    
                    let withdraw = BtcJS.shared.callJSValue(key: "createSignedBtcWithdrawSlashingTransaction", param: [stakerBtcInfo.rawString(),
                                                                                                                             stakingInput.rawString(),
                                                                                                                             stakingParamsVersion,
                                                                                                                             txHex,
                                                                                                                             feeRate])
                    if let data = withdraw.data(using: .utf8),
                        let json = try? JSON(data: data) {
                        
                        btcFee = json["fee"].uInt64Value
                        onUpdateFeeView()

                        self.transactionHex = json["transactionHex"].stringValue
                        
                        unStakeBtn.isEnabled = true
                    } else {
                        onShowToast("fail to simul")
                    }


                }
                
                
            } else {
                onShowToast("fail to simul")

            }
            
            loadingView.isHidden = true
            view.isUserInteractionEnabled = true

        }
    }
}

extension BtcUndelegate: BaseSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectUnstakeFinalityProvider || sheetType == .SelectBtcWithdraw) {
            if let delegation = result["delegation"] as? BtcDelegation {
                self.delegation = delegation
                fromProvider = babylonBtcfetcher.finalityProviders.filter({ $0.btcPk == delegation.providerPk }).first!
                onUpdateValidatorView()
                onUpdateFeeView()
            }
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            unStakeBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    if let transactionHex ,
                       let btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher() {
                        let result = try await btcFetcher.sendRawtransaction(transactionHex)
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            self.loadingView.isHidden = true
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = self.selectedChain
                            txResult.bitcoin = self.selectedChain
                            txResult.btcResult = result
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }

                } catch {
                    onShowToast(error.localizedDescription)
                    view.isUserInteractionEnabled = true
                    unStakeBtn.isEnabled = false
                    loadingView.isHidden = false
                }
            }
        }
    }

}

enum BtcStakeActionType {
    case unstake
    case withdraw
}
