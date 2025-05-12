//
//  DeriveCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SkeletonView

class DeriveCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bechAddressLabel: UILabel!
    @IBOutlet weak var evmAddressLabel: UILabel!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var btcTag: RoundedPaddingLabel!
    @IBOutlet weak var oldTag: RoundedPaddingLabel!
    @IBOutlet weak var keyTypeTag: RoundedPaddingLabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var coinCntLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var reposeErrorLabel: UILabel!
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        denomLabel.text = ""
        amountLabel.text = ""
        coinCntLabel.text = ""
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        hdPathLabel.text = ""
        bechAddressLabel.alpha = 1.0
        evmAddressLabel.alpha = 1.0
        loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        btcTag.isHidden = true
        oldTag.isHidden = true
        keyTypeTag.isHidden = true
        loadingLabel.isHidden = false
        denomLabel.text = ""
        denomLabel.textColor = .color01
        amountLabel.text = ""
        bechAddressLabel.text = ""
        evmAddressLabel.text = ""
        hdPathLabel.text = ""
        coinCntLabel.text = ""
        reposeErrorLabel.isHidden = true
        bechAddressLabel.alpha = 1.0
        evmAddressLabel.alpha = 1.0
        bechAddressLabel.layer.removeAllAnimations()
        evmAddressLabel.layer.removeAllAnimations()
    }
    
    func bindDeriveChain(_ account: BaseAccount, _ chain: BaseChain, _ selectedList: [String]) {
        nameLabel.text = chain.getChainName()
        logoImg1.image = chain.getChainImage()
        
        if (chain.supportCosmos && chain.supportEvm) {
            bechAddressLabel.text = chain.bechAddress
            evmAddressLabel.text = chain.evmAddress
            starEvmAddressAnimation()
            
        } else if (chain.supportCosmos) {
            bechAddressLabel.text = chain.bechAddress
            
        } else if (chain.supportEvm) {
            evmAddressLabel.text = chain.evmAddress
            
        } else {
            bechAddressLabel.text = chain.mainAddress
        }
        
        if (chain is ChainBitCoin86) {
            if chain.accountKeyType.pubkeyType == .BTC_Legacy {
                btcTag.text = "Legacy"
                btcTag.backgroundColor = .color07
                btcTag.textColor = .color02

            } else if chain.accountKeyType.pubkeyType == .BTC_Nested_Segwit {
                btcTag.text = "Nested Segwit"
                btcTag.backgroundColor = .color07
                btcTag.textColor = .color02

            } else if chain.accountKeyType.pubkeyType == .BTC_Native_Segwit {
                btcTag.text = "Native Segwit"
                btcTag.backgroundColor = .colorNativeSegwit
                btcTag.textColor = .color01
            
            } else if chain.accountKeyType.pubkeyType == .BTC_Taproot {
                btcTag.text = "Taproot"
                btcTag.backgroundColor = .colorBtcTaproot
                btcTag.textColor = .color01
            }
            btcTag.isHidden = false
            
        } else {
            oldTag.isHidden = chain.isDefault
        }
        
//        if (account.type == .withMnemonic) {
//            hdPathLabel.text =  chain.getHDPath(account.lastHDPath)
//            hdPathLabel.adjustsFontSizeToFitWidth = true
//        } else {
//            hdPathLabel.text = ""
//        }
        
        if (chain.name == "OKT" && !chain.supportEvm) {
            keyTypeTag.text = chain.accountKeyType.pubkeyType.algorhythm
            keyTypeTag.isHidden = false
        }
        
        if (selectedList.contains(chain.tag)) {
            rootView.layer.borderWidth = 1.0
            rootView.layer.borderColor = UIColor.white.cgColor
        } else {
            rootView.layer.borderWidth = 0.5
            rootView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
        
        if (chain.fetchState == .Fail) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            reposeErrorLabel.isHidden  = false
            
        } else if (chain.fetchState == .Success) {
            loadingLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
            loadingLabel.isHidden = true
            
            if let okFetcher = (chain as? ChainOktEVM)?.getOktfetcher() {
                let dpAmount = okFetcher.oktBalanceAmount(chain.stakeDenom!)
                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 18)
                
            } else if let suiFetcher = (chain as? ChainSui)?.getSuiFetcher() {
                let dpAmount = suiFetcher.balanceAmount(SUI_MAIN_DENOM).multiplying(byPowerOf10: -9, withBehavior: handler18Down)
                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 9)
                
            } else if let iotaFetcher = (chain as? ChainIota)?.getIotaFetcher() {
                let dpAmount = iotaFetcher.balanceAmount(IOTA_MAIN_DENOM).multiplying(byPowerOf10: -9, withBehavior: handler18Down)
                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 9)
                
            } else if let btcFetcher = (chain as? ChainBitCoin86)?.getBtcFetcher() {
                let avaibaleAmount = btcFetcher.btcBalances.multiplying(byPowerOf10: -8, withBehavior: handler8Down)
                let pendingInputAmount = btcFetcher.btcPendingInput.multiplying(byPowerOf10: -8, withBehavior: handler8Down)
                let totalAmount = avaibaleAmount.adding(pendingInputAmount)
                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(totalAmount.stringValue, amountLabel!.font, 8)
                
            } else if let gnoFetcher = (chain as? ChainGno)?.getGnoFetcher() {
                let stakeDenom = chain.stakeDenom!
                let availableAmount = gnoFetcher.balanceAmount(stakeDenom)
                if let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
                    WDP.dpCoin(msAsset, availableAmount, nil, denomLabel, amountLabel, msAsset.decimals)
                }

            } else if (chain.supportEvm) {
                let dpAmount = chain.getEvmfetcher()?.evmBalances.multiplying(byPowerOf10: -18, withBehavior: handler18Down) ?? NSDecimalNumber.zero
                denomLabel.text = chain.coinSymbol
                amountLabel.attributedText = WDP.dpAmount(dpAmount.stringValue, amountLabel!.font, 18)
                
            } else if (chain.supportCosmos) {
                let stakeDenom = chain.stakeDenom!
                let availableAmount = chain.getCosmosfetcher()?.balanceAmount(stakeDenom) ?? NSDecimalNumber.zero
                if let msAsset = BaseData.instance.getAsset(chain.apiName, stakeDenom) {
                    WDP.dpCoin(msAsset, availableAmount, nil, denomLabel, amountLabel, msAsset.decimals)
                }
            }
            
            coinCntLabel.text =  String(chain.coinsCnt) + " Coins"
            
        } else {
            loadingLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
            loadingLabel.isHidden = false
        }
    }
    
    func starEvmAddressAnimation() {
        bechAddressLabel.layer.removeAllAnimations()
        evmAddressLabel.layer.removeAllAnimations()
        bechAddressLabel.alpha = 0.0
        evmAddressLabel.alpha = 1.0
        
        UIView.animateKeyframes(withDuration: 10.0,
                                delay: 0,
                                options: [.repeat, .calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 4 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.evmAddressLabel.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 5 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.bechAddressLabel.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 14 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.bechAddressLabel.alpha = 0.0
            }
            UIView.addKeyframe(withRelativeStartTime: 15 / 16, relativeDuration: 1 / 16) { [weak self] in
                self?.evmAddressLabel.alpha = 1.0
            }
        }
    }
}
