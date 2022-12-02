//
//  AuthzClaimComisstion1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class AuthzClaimCommisstion1ViewController: BaseViewController {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var commissionAmountLabel: UILabel!
    @IBOutlet weak var commissionDenomLabel: UILabel!
    @IBOutlet weak var commissionFromLabel: UILabel!
    @IBOutlet weak var commissionToAddressTitle: UILabel!
    @IBOutlet weak var commissionToAddressLabel: UILabel!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.loadingImg.onStartAnimation()
        self.onFetchRewardAddress_gRPC(pageHolderVC.mGranterData.address)
        
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.font05
        nextBtn.borderColor = UIColor.photon
    }
    
    override func enableUserInteraction() {
        self.cancelBtn.isUserInteractionEnabled = true
        self.nextBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        let mainCommision = pageHolderVC.mGranterData.commission
        WDP.dpCoin(chainConfig, mainCommision, commissionDenomLabel, commissionAmountLabel)
        
        let opAddress = WKey.getOpAddressFromAddress(pageHolderVC.mGranterData.address, chainConfig)
        let validatorInfo = BaseData.instance.searchValidator(withAddress: opAddress)
        commissionFromLabel.text = validatorInfo?.description_p.moniker
        
        commissionToAddressLabel.text = pageHolderVC.mRewardAddress
        commissionToAddressLabel.adjustsFontSizeToFitWidth = true
        if (pageHolderVC.mGranterData.address == pageHolderVC.mRewardAddress) {
            self.commissionToAddressTitle.isHidden = true
            self.commissionToAddressLabel.isHidden = true
        } else {
            self.commissionToAddressTitle.isHidden = false
            self.commissionToAddressLabel.isHidden = false
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
