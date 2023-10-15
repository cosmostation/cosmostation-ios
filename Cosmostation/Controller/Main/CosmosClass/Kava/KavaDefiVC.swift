//
//  KavaDefiVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class KavaDefiVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKava60!
    var incentive: Kava_Incentive_V1beta1_QueryRewardsResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.isHidden = false
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "KavaIncentiveCell", bundle: nil), forCellReuseIdentifier: "KavaIncentiveCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_dapp_market", comment: "")
    }
    
    func onFetchData() {
        Task {
            let channel = getConnection()
            if let incentive = try? await fetchIncentive(channel, selectedChain.address!) {
                self.incentive = incentive
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } else {
                print("error")
            }
        }
    }

}

extension KavaDefiVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"KavaIncentiveCell") as! KavaIncentiveCell
        cell.onBindIncentive(selectedChain, incentive)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let claimRewards = KavaClaimIncentives(nibName: "KavaClaimIncentives", bundle: nil)
            claimRewards.incentive = incentive
            claimRewards.selectedChain = selectedChain
            claimRewards.modalTransitionStyle = .coverVertical
            self.present(claimRewards, animated: true)
        }
    }
}


extension KavaDefiVC {
    
    func fetchIncentive(_ channel: ClientConnection, _ address: String) async throws -> Kava_Incentive_V1beta1_QueryRewardsResponse? {
        let req = Kava_Incentive_V1beta1_QueryRewardsRequest.with { $0.owner = address }
        return try? await Kava_Incentive_V1beta1_QueryNIOClient(channel: channel).rewards(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchRewardFactor(_ channel: ClientConnection) async throws -> Kava_Incentive_V1beta1_QueryRewardFactorsResponse? {
        let req = Kava_Incentive_V1beta1_QueryRewardFactorsRequest()
        return try? await Kava_Incentive_V1beta1_QueryNIOClient(channel: channel).rewardFactors(req, callOptions: getCallOptions()).response.get()
    }
    
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.grpcHost, port: selectedChain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}
