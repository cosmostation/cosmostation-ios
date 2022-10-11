//
//  ReInvest1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class ReInvest1ViewController: BaseViewController {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var rewardAmountLabel: UILabel!
    @IBOutlet weak var rewardDenomLabel: UILabel!
    @IBOutlet weak var validatorLabel: UILabel!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var controlLayer: UIStackView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mDpDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        WUtils.setDenomTitle(pageHolderVC.chainType!, rewardDenomLabel)
        
        self.loadingImg.onStartAnimation()
        self.onFetchRewards_gRPC(pageHolderVC.mAccount!.account_address)
        
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        cancelBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        cancelBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func updateView() {
        let cReward = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), pageHolderVC.mTargetValidator_gRPC?.operatorAddress)
        rewardAmountLabel.attributedText = WDP.dpAmount(cReward.stringValue, rewardAmountLabel.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        validatorLabel.text = pageHolderVC.mTargetValidator_gRPC?.description_p.moniker
        
        let coin = Coin(WUtils.getMainDenom(chainConfig), cReward.rounding(accordingToBehavior: WUtils.handler0Down).stringValue)
        self.pageHolderVC.mReinvestReward = coin
        
        self.loadingImg.isHidden = true
        self.controlLayer.isHidden = false
        self.cardView.isHidden = false
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
//            print("onFetchgRPCRewards: \(response.rewards.count)")
                response.rewards.forEach { reward in
                    BaseData.instance.mMyReward_gRPC.append(reward)
                }
            } catch {
                print("onFetchgRPCRewards failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.updateView()
            });
        }
    }

}
