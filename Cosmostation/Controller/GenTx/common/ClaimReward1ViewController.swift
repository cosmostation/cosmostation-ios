//
//  ClaimReward1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class ClaimReward1ViewController: BaseViewController {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var controlLayer: UIStackView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var rewardFromLabel: UILabel!
    @IBOutlet weak var rewardToAddressTitle: UILabel!
    @IBOutlet weak var rewardToAddressLabel: UILabel!
    
    @IBOutlet weak var rewardAmountTitle: UILabel!
    @IBOutlet weak var rewardFromTitle: UILabel!
    @IBOutlet weak var rewardAddressTitle: UILabel!
    @IBOutlet weak var rewardMsgTitle: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var mFetchCnt = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        WUtils.setDenomTitle(pageHolderVC.chainType!, rewardDenomLabel)
        
        if (pageHolderVC.mRewardTargetValidators_gRPC.count == 16) {
            self.onShowToast(NSLocalizedString("reward_claim_top_16", comment: ""))
        }
        
        self.loadingImg.onStartAnimation()
        self.onFetchRewardsInfoData()
        
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
        rewardAmountTitle.text = NSLocalizedString("str_reward_amount", comment: "")
        rewardFromTitle.text = NSLocalizedString("str_reward_from", comment: "")
        rewardAddressTitle.text = NSLocalizedString("str_reward_recipient_address", comment: "")
        rewardMsgTitle.text = NSLocalizedString("msg_reward", comment: "")
        cancelBtn.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        nextBtn.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
    }
    
    func onFetchRewardsInfoData()  {
        if (self.mFetchCnt > 0)  {
            return
        }
        mFetchCnt = 2
        self.onFetchRewards_gRPC(pageHolderVC.mAccount!.account_address)
        self.onFetchRewardAddress_gRPC(pageHolderVC.mAccount!.account_address)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            updateView()
        }
    }
    
    func updateView() {
        var selectedRewardSum = NSDecimalNumber.zero
        for validator in pageHolderVC.mRewardTargetValidators_gRPC {
            let amount = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), validator.operatorAddress)
            selectedRewardSum = selectedRewardSum.adding(amount)
        }
        rewardAmountLabel.attributedText = WDP.dpAmount(selectedRewardSum.stringValue, rewardAmountLabel.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        
        var monikers = ""
        for validator in pageHolderVC.mRewardTargetValidators_gRPC {
            if (monikers.count > 0) {
                monikers = monikers + ",   " + validator.description_p.moniker
            } else {
                monikers = validator.description_p.moniker
            }
        }
        rewardFromLabel.text = monikers
        
        rewardToAddressLabel.text = pageHolderVC.mRewardAddress
        rewardToAddressLabel.adjustsFontSizeToFitWidth = true
        if (pageHolderVC.mAccount?.account_address == pageHolderVC.mRewardAddress) {
            self.rewardToAddressTitle.isHidden = true
            self.rewardToAddressLabel.isHidden = true
        } else {
            self.rewardToAddressTitle.isHidden = false
            self.rewardToAddressLabel.isHidden = false
        }
        
        self.loadingImg.isHidden = true
        self.controlLayer.isHidden = false
        self.cardView.isHidden = false
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }

    
    func onFetchRewards_gRPC(_ address: String) {
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.pageHolderVC.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with {
                $0.delegatorAddress = address
            }
            do {
                let response = try Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegationTotalRewards(req).response.wait()
                BaseData.instance.mMyReward_gRPC.removeAll()
                response.rewards.forEach { reward in
                    BaseData.instance.mMyReward_gRPC.append(reward)
                }
            } catch {
                print("onFetchgRPCRewards failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.onFetchFinished()
            });
        }
    }
    
    func onFetchRewardAddress_gRPC(_ address: String) {
        DispatchQueue.global().async {
            var responseAddress = ""
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.pageHolderVC.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with {
                $0.delegatorAddress = address
            }
            do {
                let response = try Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegatorWithdrawAddress(req).response.wait()
                responseAddress = response.withdrawAddress.replacingOccurrences(of: "\"", with: "")
            } catch {
                print("onFetchRedelegation_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.pageHolderVC.mRewardAddress = responseAddress
                self.onFetchFinished()
            });
        }
    }

}
