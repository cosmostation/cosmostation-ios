//
//  SelectDisplayTokenCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SDWebImage
import SkeletonView

class SelectDisplayTokenCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var coinImg: CircleImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var contractLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var loadingAmountLabel: UILabel!
    @IBOutlet weak var loadingValueLabel: UILabel!
    
    let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        loadingAmountLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
        loadingValueLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color04, .color03]), animation: skeletonAnimation, transition: .none)
    }
    
    override func prepareForReuse() {
        coinImg.sd_cancelCurrentImageLoad()
        coinImg.image = UIImage(named: "tokenDefault")
        symbolLabel.text = ""
        contractLabel.text = ""
        amountLabel.text = ""
        valueCurrencyLabel.text = ""
        valueLabel.text = ""
    }
    
    func bindToken(_ chain: BaseChain, _ token: MintscanToken, _ selectedList: [String]) {
        if (selectedList.contains(token.address!)) {
            rootView.layer.borderWidth = 1.0
            rootView.layer.borderColor = UIColor.white.cgColor
        } else {
            rootView.layer.borderWidth = 0.5
            rootView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
        
        coinImg?.sd_setImage(with: token.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
        symbolLabel.text = token.symbol
        contractLabel.text = token.address
        
        Task {
            if !SelectDisplayTokenListSheet.tokenWithAmount.map({$0.address}).contains(token.address) {
                showLoadingView()
                await fetchTokenBalance(chain, token)
                hideLoadingView()
            }
            
            if let index = SelectDisplayTokenListSheet.tokenWithAmount.firstIndex(where: { $0.address == token.address }) {
                let token = SelectDisplayTokenListSheet.tokenWithAmount[index]
                let amount = token.getAmount().multiplying(byPowerOf10: -token.decimals!)
                amountLabel.attributedText = WDP.dpAmount(amount.stringValue, amountLabel!.font)
                let msPrice = BaseData.instance.getPrice(token.coinGeckoId)
                let value = msPrice.multiplying(by: token.getAmount()).multiplying(byPowerOf10: -token.decimals!, withBehavior: handler6)
                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
            }
        }
    }
    
    
    private func fetchTokenBalance(_ chain: BaseChain, _ token: MintscanToken) async {
        if chain.isSupportGrc20() {
            await (chain as? ChainGno)?.getGnoFetcher()?.fetchGrc20Balance(token)
            
        } else if chain.isSupportErc20() {
            await chain.getEvmfetcher()?.fetchErc20Balance(token)
            
        } else if chain.isSupportCw20() {
            await chain.getCosmosfetcher()?.fetchCw20Balance(token)
        }
        
        SelectDisplayTokenListSheet.tokenWithAmount.append(token)
    }
    
    private func showLoadingView() {
        loadingAmountLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), animation: skeletonAnimation, transition: .none)
        loadingAmountLabel.isHidden = false
        loadingValueLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color04, .color03]), animation: skeletonAnimation, transition: .none)
        loadingValueLabel.isHidden = false
    }
    
    private func hideLoadingView() {
        loadingAmountLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
        loadingAmountLabel.isHidden = true
        loadingValueLabel.hideSkeleton(reloadDataAfter: true, transition: SkeletonTransitionStyle.none)
        loadingValueLabel.isHidden = true
    }
    
}
