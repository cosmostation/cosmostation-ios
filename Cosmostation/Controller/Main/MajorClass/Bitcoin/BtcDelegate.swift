//
//  BtcDelegate.swift
//  Cosmostation
//
//  Created by 차소민 on 2/26/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SDWebImage
import SwiftyJSON
import SwiftProtobuf

class BtcDelegate: BaseVC {
    @IBOutlet weak var titleCoinImage: UIImageView!
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
    @IBOutlet weak var stakingCurrencyLabel: UILabel!
    @IBOutlet weak var stakingValueLabel: UILabel!

    @IBOutlet weak var rewardView: FixCardView!
    @IBOutlet weak var rewardInfoLabel: UILabel!
    @IBOutlet weak var rewardAddressLabel: UILabel!
    @IBOutlet weak var rewardDescriptionLabel: UILabel!
    
    @IBOutlet weak var feeView: FixCardView!
    @IBOutlet weak var feeSelectView: DropDownView!
    @IBOutlet weak var feeMsgLabel: UILabel!
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var feeSegments: UISegmentedControl!
    
    @IBOutlet weak var nextBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!

    var selectedChain: BaseChain!
    var chainBabylon: BaseChain!
    var btcFetcher: BtcFetcher!
    var babylonBtcfetcher: BabylonBTCFetcher!
    var cosmosFetcher: CosmosFetcher!
    
    var availableAmount = NSDecimalNumber.zero
    var toProvider: FinalityProvider?
    var sendAmount: NSDecimalNumber?
    var estimateBtcStakingFee: String?
    
    var babylonBtcTipHeight: UInt64 = 0
    var inputUTXOs = [JSON]()
    var feeRate = 0
    
    var preStakeResult = JSON()
    var stakingTxHash: String = ""
    
    var babylonFeeInfos = [FeeInfo]()
    var babylonTxFee: Cosmos_Tx_V1beta1_Fee = Cosmos_Tx_V1beta1_Fee.init()


    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            cosmosFetcher = chainBabylon.getCosmosfetcher()
            babylonBtcfetcher = (selectedChain as? ChainBitCoin86)?.getBabylonBtcFetcher()
            btcFetcher = (selectedChain as? ChainBitCoin86)?.getBtcFetcher()
            
            loadingView.isHidden = false
            loadingView.animation = LottieAnimation.named("loading")
            loadingView.contentMode = .scaleAspectFit
            loadingView.loopMode = .loop
            loadingView.animationSpeed = 1.3
            loadingView.play()
            
            titleCoinImage.sd_setImage(with: selectedChain.assetImgUrl(selectedChain.coinSymbol), placeholderImage: UIImage(named: "tokenDefault"))
            
            validatorCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickValidator)))
            stakingAmountCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
            
            if (toProvider == nil) {
                if let validator = babylonBtcfetcher.finalityProviders.filter({ $0.moniker == "Cosmostation" }).first {
                    toProvider = validator
                } else {
                    toProvider = babylonBtcfetcher.finalityProviders.first
                }
            }

            do {
                
                //init
                let network = selectedChain.isTestnet ? "testnet" : "mainnet"
                let privateKeyHex = selectedChain.privateKey?.toHexString()
                let signerAddress = selectedChain.mainAddress
                let stakingParams = JSON(babylonBtcfetcher.networkInfo).rawString() ?? ""
                
                let initValue = BtcJS.shared.callJSValue(key: "initBTCStaking", param: [network, privateKeyHex, signerAddress, stakingParams])
                
                if initValue != "true" {
                    onShowToast("fail to init")
                    return
                }
                
                babylonBtcTipHeight = try await babylonBtcfetcher.fetchTipHeight()["height"].uInt64Value
                inputUTXOs = try await babylonBtcfetcher.fetchAvailableUTXOs(address: selectedChain.mainAddress)
                feeRate = btcFetcher.fastestFee ?? 0
                
                
            } catch {
                print("ERROR: ", error)
            }
            
            oninitBabylonFee()
            
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.stakingAmountCardView.isHidden = false
                self.onUpdateValidatorView()
                self.onUpdateRewardView()
                self.onUpdateFeeView()
            }
        }


    }
    override func setLocalizedString() {
        let symbol = selectedChain.coinSymbol
        titleLabel.text = String(format: NSLocalizedString("title_coin_stake", comment: ""), symbol)
    }
    
    func onUpdateValidatorView() {
        validatorCardView.isHidden = false
        monikerImg.sd_setImage(with: URL(string: ResourceBase + chainBabylon.apiName + "/finality-provider/" + toProvider!.btcPk + ".png"), placeholderImage: UIImage(named: "validatorDefault"))
        monikerLabel.text = toProvider!.moniker
        
        if toProvider!.jailed {
            jailedTag.isHidden = false
        } else if toProvider!.votingPower == "0" {
            inactiveTag.isHidden = false
        }

        var commission = NSDecimalNumber.zero
        if NSDecimalNumber(string: toProvider!.commission).compare(1) == .orderedDescending {
            commission = NSDecimalNumber(string: toProvider!.commission).multiplying(byPowerOf10: -16)
        } else {
            commission = NSDecimalNumber(string: toProvider!.commission).multiplying(byPowerOf10: 2)
        }

        commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)

        onSimul()
    }
    
    func onUpdateRewardView() {
        rewardView.isHidden = false
        let coinSymbol = chainBabylon.assetSymbol(chainBabylon.stakeDenom ?? "")
        rewardInfoLabel.text = "$\(coinSymbol) Reward Distribution"
        rewardAddressLabel.text = chainBabylon.bechAddress
        rewardDescriptionLabel.text = "Rewards are paid in $\(coinSymbol) to your BABYLON address."
    }
    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = chainBabylon
        
        baseSheet.finalityProviders = babylonBtcfetcher.finalityProviders
        baseSheet.sheetType = .SelectFinalityProvider

        baseSheet.sheetDelegate = self
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
        amountSheet.selectedChain = selectedChain
        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.coinSymbol)
        amountSheet.availableAmount = availableAmount
        amountSheet.existedAmount = sendAmount
        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxDelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onUpdateFeeView() {
        Task {
            feeView.isHidden = false
            
            feeSegments.removeAllSegments()
            feeSegments.insertSegment(withTitle: "Fixed", at: 0, animated: false)
            feeSegments.selectedSegmentIndex = 0
            
            try await callEstimateStakingFee()
            
            if estimateBtcStakingFee == nil || Int(estimateBtcStakingFee!) == nil {
                onShowToast("fail to fetch fee")
                return
            }
            
            if let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.coinSymbol) {
                feeSelectLabel.text = msAsset.symbol
                
                let totalFeeAmount = NSDecimalNumber(string: estimateBtcStakingFee)
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let value = msPrice.multiplying(by: totalFeeAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                WDP.dpCoin(msAsset, totalFeeAmount, feeSelectImg, feeDenomLabel, feeAmountLabel, msAsset.decimals)
                WDP.dpValue(value, feeCurrencyLabel, feeValueLabel)
                
                let balanceAmount = btcFetcher.btcBalances
                availableAmount = balanceAmount.subtracting(totalFeeAmount)
            }
            

        }
    }
    
    func onUpdateAmountView(_ amount: String) {
        Task {
            sendAmount = NSDecimalNumber(string: amount)
            
            if let sendAmount,
               let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.coinSymbol) {
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                let dpAmount = sendAmount.multiplying(byPowerOf10: -msAsset.decimals!)
                let value = msPrice.multiplying(by: dpAmount, withBehavior: handler6)
                WDP.dpValue(value, stakingCurrencyLabel, stakingValueLabel)
                WDP.dpCoin(msAsset, sendAmount, nil, stakingDenomLabel, stakingAmountLabel, msAsset.decimals)
                stakingAmountHintLabel.isHidden = true
                stakingAmountLabel.isHidden = false
                stakingDenomLabel.isHidden = false
                stakingCurrencyLabel.isHidden = false
                stakingValueLabel.isHidden = false
            }
            
            do {
               try await callPreStakeTx()
                
            } catch {
                onShowToast("Error: \(error)")
                return
            }
            
            onSimul()
        }
    }

    func onSimul() {
        Task {
            if (sendAmount == nil ) { return }
            view.isUserInteractionEnabled = false
            nextBtn.isEnabled = false
            loadingView.isHidden = false

            do {
                if let simulReq = try await Signer.genSimul(chainBabylon!, onBindDelegateMsg(preStakeResult), "", babylonTxFee, nil),
                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
                    babylonTxFee.gasLimit = UInt64(Double(simulRes) * chainBabylon.getSimulatedGasMultiply())
                    if let gasRate = babylonFeeInfos[0].FeeDatas.filter({ $0.denom == babylonTxFee.amount[0].denom }).first {
                        let gasLimit = NSDecimalNumber.init(value: babylonTxFee.gasLimit)
                        let feeAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                        babylonTxFee.amount[0].amount = feeAmount!.stringValue
                    }
                    
                    view.isUserInteractionEnabled = true
                    nextBtn.isEnabled = true
                    loadingView.isHidden = true

                }
            } catch {
                view.isUserInteractionEnabled = true
                nextBtn.isEnabled = false
                loadingView.isHidden = true
                self.onShowToast("Error: \(error)")
            }
        }
    }
    
    
    func callPreStakeTx() async throws {
        if let networkInfo = babylonBtcfetcher.networkInfo.last,
           let publicKeyString = selectedChain.publicKey?.toHexString(),
           let toProvider,
           let sendAmount {
            
            let stakerBtcInfo: JSON = ["address":selectedChain.mainAddress, "stakerPublicKeyHex": publicKeyString]
            let stakingInput: JSON = ["finalityProviderPkNoCoordHex": toProvider.btcPk,
                                      "stakingAmountSat": sendAmount.intValue,
                                      "stakingTimelock": networkInfo["max_staking_time_blocks"].intValue]
            let babylonAddress = chainBabylon.bechAddress
            
            let res = BtcJS.shared.callJSValue(key: "preStakeRegistrationBabylonTransaction",
                                               param: [stakerBtcInfo.rawString(),
                                                       stakingInput.rawString(),
                                                       babylonBtcTipHeight,
                                                       JSON(inputUTXOs).rawString(),
                                                       feeRate,
                                                       babylonAddress
                                                      ])
            
            if let data = res.data(using: .utf8),
               let json = try? JSON(data: data) {
                let value = json["msg"]["value"]
                preStakeResult = value
                stakingTxHash = json["stakingTxHash"].stringValue
                
            } else {
                throw EmptyDataError.error(message: res)
            }
        }
        
    }
    
    
    func callEstimateStakingFee() async throws {
        if let networkInfo = babylonBtcfetcher.networkInfo.last,
           let publicKeyString = selectedChain.publicKey?.toHexString(),
           let toProvider {
            
            let stakerBtcInfo: JSON = ["address":selectedChain.mainAddress, "stakerPublicKeyHex": publicKeyString]
            let stakingInput: JSON = ["finalityProviderPkNoCoordHex": toProvider.btcPk,
                                      "stakingAmountSat": sendAmount?.intValue ?? networkInfo["min_staking_value_sat"].int64Value,
                                      "stakingTimelock": networkInfo["max_staking_time_blocks"].intValue]
            estimateBtcStakingFee = BtcJS.shared.callJSValue(key: "estimateBtcStakingFee",
                                                             param: [stakerBtcInfo.rawString(),
                                                                     babylonBtcTipHeight,
                                                                     stakingInput.rawString(),
                                                                     JSON(inputUTXOs).rawString(),
                                                                     feeRate
                                                                    ])
        }

    }
    

    
    @IBAction func onNextSheet(_ sender: Any) {
        let sheet = AdditionalFeeSheet(nibName: "AdditionalFeeSheet", bundle: nil)
        sheet.babylon = chainBabylon
        sheet.bitcoin = selectedChain
        sheet.babylonTxFee = babylonTxFee
        sheet.btcStakingDelegate = self
        onStartSheet(sheet, 375, 0.5)
    }
    
    func onBindDelegateMsg(_ value: JSON) -> [Google_Protobuf_Any] {
        
        let msg = Babylon_Btcstaking_V1_MsgCreateBTCDelegation.with {
            $0.stakerAddr = value["stakerAddr"].stringValue
            $0.pop = Babylon_Btcstaking_V1_ProofOfPossessionBTC.with {
                $0.btcSigType = Babylon_Btcstaking_V1_BTCSigType.init(rawValue: value["pop"]["btcSigType"].intValue) ?? .bip340
                $0.btcSig = Data(base64Encoded: value["pop"]["btcSig"].stringValue) ?? Data()
            }
            $0.btcPk = Data(hex: value["btcPk"].stringValue)
            $0.fpBtcPkList = value["fpBtcPkList"].arrayValue.map { Data(hex: $0.stringValue) }
            $0.stakingTime = value["stakingTime"].uInt32Value
            $0.stakingValue = value["stakingValue"].int64Value
            $0.stakingTx = Data(hex: value["stakingTx"].stringValue)
            $0.slashingTx = Data(hex: value["slashingTx"].stringValue)
            $0.delegatorSlashingSig = Data(base64Encoded: value["delegatorSlashingSig"].stringValue) ?? Data()
            $0.unbondingTime = value["unbondingTime"].uInt32Value
            $0.unbondingTx = Data(hex: value["unbondingTx"].stringValue)
            $0.unbondingValue = value["unbondingValue"].int64Value
            $0.unbondingSlashingTx = Data(hex: value["unbondingSlashingTx"].stringValue)
            $0.delegatorUnbondingSlashingSig = Data(base64Encoded: value["delegatorUnbondingSlashingSig"].stringValue) ?? Data()
        }
        return Signer.genDelegateMsg(msg)

    }
    
    func oninitBabylonFee() {
        if (cosmosFetcher.cosmosBaseFees.count > 0) {
            
            let baseFee = cosmosFetcher.cosmosBaseFees[0]
            let gasAmount: NSDecimalNumber = chainBabylon.getInitGasLimit()
            let feeDenom = baseFee.denom
            let feeAmount = baseFee.getdAmount().multiplying(by: gasAmount, withBehavior: handler0Down)
            babylonTxFee.gasLimit = gasAmount.uint64Value
            babylonTxFee.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount)]
            
        } else {
            babylonFeeInfos = chainBabylon.getFeeInfos()
            babylonTxFee = chainBabylon.getInitPayableFee()!
        }
    }

}

extension BtcDelegate: BtcStakingDelegate {
    func onBindStake() {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
}

extension BtcDelegate: BaseSheetDelegate, AmountSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFinalityProvider) {
            if let pk = result["finalityProviderBtcPk"] as? String {
                toProvider = babylonBtcfetcher.finalityProviders.filter({ $0.btcPk == pk }).first
                onUpdateValidatorView()
            }

        }
    }
    
    func onInputedAmount(_ type: AmountSheetType?, _ amount: String) {
        if let min = babylonBtcfetcher.networkInfo.last?["min_staking_value_sat"].uInt64Value,
           let max = babylonBtcfetcher.networkInfo.last?["max_staking_value_sat"].uInt64Value,
           let amountIntValue = UInt64(amount),
           let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.coinSymbol) {
            
            if amountIntValue < min {
                onShowToast("Staking amount must be at least \(NSDecimalNumber(value: min).multiplying(byPowerOf10: -msAsset.decimals!)) \(selectedChain.coinSymbol).")
                return
                
            } else if amountIntValue > availableAmount.uint64Value {
                onShowToast("Staking amount exceeds your balance (\(availableAmount.multiplying(byPowerOf10: -msAsset.decimals!)) \(selectedChain.coinSymbol))!")
                return
                
            } else if amountIntValue > max {
                onShowToast("Staking amount must be no more than \(NSDecimalNumber(value: max).multiplying(byPowerOf10: -msAsset.decimals!)) \(selectedChain.coinSymbol).")
                return
                
            } else {
                onUpdateAmountView(amount)
            }
        }
    }
}


extension BtcDelegate: PinDelegate {
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            nextBtn.isEnabled = false
            loadingView.isHidden = false
            Task {
                do {
                    if let broadReq = try await Signer.genTx(chainBabylon, onBindDelegateMsg(preStakeResult), "", babylonTxFee, nil),
                       let broadRes = try await cosmosFetcher.broadcastTx(broadReq) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: { [weak self] in
                            guard let self else {return}
                            loadingView.isHidden = true
                            let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                            txResult.selectedChain = chainBabylon
                            txResult.broadcastTxResponse = broadRes
                            txResult.bitcoin = selectedChain
                            txResult.stakingTxHash = stakingTxHash
                            txResult.stakerBtcInfo = JSON(["address":selectedChain.mainAddress, "stakerPublicKeyHex": selectedChain.publicKey?.toHexString()]).rawString()
                            txResult.stakingInput = JSON(["finalityProviderPkNoCoordHex": toProvider?.btcPk,
                                                          "stakingAmountSat": sendAmount?.intValue,
                                                          "stakingTimelock": babylonBtcfetcher.networkInfo.last?["max_staking_time_blocks"].intValue]).rawString()
                            txResult.inputUTXOs = JSON(inputUTXOs).rawString()


                            
                            txResult.modalPresentationStyle = .fullScreen
                            self.present(txResult, animated: true)
                        })
                    }
                    
                } catch {
                    self.loadingView.isHidden = true
                    onShowToast("fail")
                }
            }
        }
    }
}



