//
//  ReInvestAmountViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/06/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import GRPC
import NIO

class ReInvestAmountViewController: BaseViewController {

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
        pageHolderVC = self.parent as? StepGenTxViewController
        WUtils.setDenomTitle(pageHolderVC.chainType!, rewardDenomLabel)
        
        self.loadingImg.onStartAnimation()
        self.onFetchRewards_gRPC(pageHolderVC.mAccount!.account_address)
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
        mDpDecimal = WUtils.mainDivideDecimal(pageHolderVC.chainType)
        
        let cReward = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(pageHolderVC.chainType), pageHolderVC.mTargetValidator_gRPC?.operatorAddress)
        rewardAmountLabel.attributedText = WUtils.displayAmount2(cReward.stringValue, rewardAmountLabel.font, mDpDecimal, mDpDecimal)
        validatorLabel.text = pageHolderVC.mTargetValidator_gRPC?.description_p.moniker
        
        let coin = Coin(WUtils.getMainDenom(pageHolderVC.chainType), cReward.rounding(accordingToBehavior: WUtils.handler0Down).stringValue)
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
