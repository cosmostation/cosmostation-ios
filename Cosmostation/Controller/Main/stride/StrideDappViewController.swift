//
//  StrideDappViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class StrideDappViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var stakingView: UIView!
    @IBOutlet weak var unstakingView: UIView!
    
    var hostZones = Array<Stride_Stakeibc_HostZone>()
    var dayEpoch: Stride_Stakeibc_EpochTracker?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        stakingView.alpha = 1
        unstakingView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.dAppsSegment.selectedSegmentTintColor = chainConfig?.chainColor
        self.onFetchData()
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            stakingView.alpha = 1
            unstakingView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            stakingView.alpha = 0
            unstakingView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_liquidity_staking", comment: "");
        self.navigationItem.title = NSLocalizedString("title_liquidity_staking", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    var mFetchCnt = 0
    @objc func onFetchData() {
        if (self.mFetchCnt > 0)  {
            return
        }
        self.mFetchCnt = 2
        hostZones.removeAll()
        dayEpoch = nil

        self.onFetchAllHostZone()
        self.onFetchDayEpoch()
        
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            NotificationCenter.default.post(name: Notification.Name("strideFetchDone"), object: nil, userInfo: nil)
        })
    }
    
    func onFetchAllHostZone() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 1000 }
                let req = Stride_Stakeibc_QueryAllHostZoneRequest.with { $0.pagination = page }
                if let response = try? Stride_Stakeibc_QueryClient(channel: channel).hostZoneAll(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.hostZones = response.hostZone
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchAllHostZone failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchDayEpoch() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Stride_Stakeibc_QueryGetEpochTrackerRequest.with { $0.epochIdentifier = "day" }
                if let response = try? Stride_Stakeibc_QueryClient(channel: channel).epochTracker(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.dayEpoch = response.epochTracker
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchDayEpoch failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }

}
