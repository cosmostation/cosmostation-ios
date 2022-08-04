//
//  AuthzClaimReward1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzClaimReward1ViewController: BaseViewController {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var rewardFromLabel: UILabel!
    @IBOutlet weak var rewardToAddressTitle: UILabel!
    @IBOutlet weak var rewardToAddressLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.loadingImg.onStartAnimation()
        self.onFetchRewardAddress_gRPC(pageHolderVC.mGranterAddress!)
        
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        let mainReward = getRewardSum()
        WDP.dpCoin(chainConfig, mainReward, rewardDenomLabel, rewardAmountLabel)
        
        var monikers = ""
        BaseData.instance.mAllValidators_gRPC.forEach { validator in
            pageHolderVC.mGranterReward.forEach { myValidator in
                if (validator.operatorAddress == myValidator.validatorAddress) {
                    if (monikers.count > 0) {
                        monikers = monikers + ",   " + validator.description_p.moniker
                    } else {
                        monikers = validator.description_p.moniker
                    }
                }
            }
        }
        rewardFromLabel.text = monikers
        
        rewardToAddressLabel.text = pageHolderVC.mRewardAddress
        rewardToAddressLabel.adjustsFontSizeToFitWidth = true
        if (pageHolderVC.mGranterAddress == pageHolderVC.mRewardAddress) {
            self.rewardToAddressTitle.isHidden = true
            self.rewardToAddressLabel.isHidden = true
        } else {
            self.rewardToAddressTitle.isHidden = false
            self.rewardToAddressLabel.isHidden = false
        }
        
        self.loadingImg.isHidden = true
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    func getRewardSum() -> Coin {
        var sum = NSDecimalNumber.zero
        pageHolderVC.mGranterReward.forEach { reward in
            reward.reward.forEach { rewardCoin in
                if (rewardCoin.denom == chainConfig!.stakeDenom) {
                    sum = sum.adding(WUtils.plainStringToDecimal(rewardCoin.amount))
                }
            }
        }
        sum = sum.multiplying(byPowerOf10: -18)
        return Coin.init(chainConfig!.stakeDenom, sum.stringValue)
    }
    
    func onFetchRewardAddress_gRPC(_ address: String) {
        DispatchQueue.global().async {
            var responseAddress = ""
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = address }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegatorWithdrawAddress(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    responseAddress = response.withdrawAddress.replacingOccurrences(of: "\"", with: "")
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchRewardAddress_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.pageHolderVC.mRewardAddress = responseAddress
                self.onUpdateView()
            });
        }
    }

}
