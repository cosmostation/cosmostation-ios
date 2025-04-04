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

    @IBOutlet weak var feeSelectView: DropDownView!
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

    var selectedChain: BaseChain!
    var babylonBTCFetcher: BabylonBTCFetcher!
    
    var availableAmount = NSDecimalNumber.zero
    var toProvider: FinalityProvider?
    var sendAmount: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        babylonBTCFetcher = (selectedChain as? ChainBabylon)?.getBabylonBtcFetcher()
        
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
            if let validator = babylonBTCFetcher.finalityProviders.filter({ $0.moniker == "Cosmostation" }).first {
                toProvider = validator
            } else {
                toProvider = babylonBTCFetcher.finalityProviders.first
            }
        }
        
        Task {
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.onUpdateValidatorView()
//                self.oninitFeeView()
            }
        }


    }
    override func setLocalizedString() {
        let symbol = selectedChain.coinSymbol
        titleLabel.text = String(format: NSLocalizedString("title_coin_stake", comment: ""), symbol)
    }
    
    func onUpdateValidatorView() {
        monikerImg.sd_setImage(with: URL(string: ResourceBase + selectedChain.apiName + "/finality-provider/" + toProvider!.btcPk + ".png"), placeholderImage: UIImage(named: "validatorDefault"))
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
    
    @objc func onClickValidator() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.targetChain = selectedChain
        
        baseSheet.finalityProviders = babylonBTCFetcher.finalityProviders
        baseSheet.sheetType = .SelectFinalityProvider

        baseSheet.sheetDelegate = self
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountSheet(nibName: "TxAmountSheet", bundle: nil)
//        amountSheet.selectedChain = selectedChain
//        amountSheet.msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom!)
//        amountSheet.availableAmount = availableAmount
//        if let existedAmount = toCoin?.amount {
//            amountSheet.existedAmount = NSDecimalNumber(string: existedAmount)
//        }
//        amountSheet.sheetDelegate = self
        amountSheet.sheetType = .TxDelegate
        onStartSheet(amountSheet, 240, 0.6)
    }
    
    func onSimul() {
//        if (toCoin == nil ) { return }
//        view.isUserInteractionEnabled = false
//        stakeBtn.isEnabled = false
//        loadingView.isHidden = false
//        
//        if (selectedChain.isSimulable() == false) {
//            return onUpdateWithSimul(nil)
//        }
//        
//        Task {
//            do {
//                if let simulReq = try await Signer.genSimul(selectedChain, onBindDelegateMsg(), txMemo, txFee, nil),
//                   let simulRes = try await cosmosFetcher.simulateTx(simulReq) {
//                    DispatchQueue.main.async {
//                        self.onUpdateWithSimul(simulRes)
//                    }
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    self.view.isUserInteractionEnabled = true
//                    self.loadingView.isHidden = true
//                    self.onShowToast("Error : " + "\n" + "\(error)")
//                    return
//                }
//            }
//        }
    }

}

extension BtcDelegate: BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectFinalityProvider) {
            if let pk = result["finalityProviderBtcPk"] as? String {
                toProvider = babylonBTCFetcher.finalityProviders.filter({ $0.btcPk == pk }).first
                onUpdateValidatorView()
            }

        }
    }
}
