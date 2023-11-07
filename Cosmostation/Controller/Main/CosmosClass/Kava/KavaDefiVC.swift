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
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "KavaIncentiveCell", bundle: nil), forCellReuseIdentifier: "KavaIncentiveCell")
        tableView.register(UINib(nibName: "KavaDefiCell", bundle: nil), forCellReuseIdentifier: "KavaDefiCell")
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
            if let incentive = try? await fetchIncentive(channel, selectedChain.bechAddress),
               let pricefeed = try? await fetchPriceFeed(channel) {
                self.incentive = incentive
                self.priceFeed = pricefeed
                
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.loadingView.isHidden = true
                    self.tableView.reloadData()
                }
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}

extension KavaDefiVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            if (incentive == nil || incentive?.allIncentiveCoins().count == 0) {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaIncentiveCell") as! KavaIncentiveCell
            cell.onBindIncentive(selectedChain, incentive)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaDefiCell") as! KavaDefiCell
            cell.onBindKava(indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let claimRewards = KavaClaimIncentives(nibName: "KavaClaimIncentives", bundle: nil)
            claimRewards.incentive = incentive
            claimRewards.selectedChain = selectedChain
            claimRewards.modalTransitionStyle = .coverVertical
            self.present(claimRewards, animated: true)
            
        } else if (indexPath.row == 1) {
            let mintListVC = KavaMintListVC(nibName: "KavaMintListVC", bundle: nil)
            mintListVC.selectedChain = selectedChain
            mintListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(mintListVC, animated: true)
            
        } else if (indexPath.row == 2) {
            let lendListVC = KavaLendListVC(nibName: "KavaLendListVC", bundle: nil)
            lendListVC.selectedChain = selectedChain
            lendListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(lendListVC, animated: true)
            
        } else if (indexPath.row == 3) {
            let swapListVC = KavaSwapListVC(nibName: "KavaSwapListVC", bundle: nil)
            swapListVC.selectedChain = selectedChain
            swapListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(swapListVC, animated: true)
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
    
    func fetchPriceFeed(_ channel: ClientConnection) async throws -> Kava_Pricefeed_V1beta1_QueryPricesResponse? {
        let req = Kava_Pricefeed_V1beta1_QueryPricesRequest()
        return try? await Kava_Pricefeed_V1beta1_QueryNIOClient(channel: channel).prices(req, callOptions: getCallOptions()).response.get()
    }
    
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: selectedChain.getGrpc().0, port: selectedChain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}


extension Kava_Pricefeed_V1beta1_QueryPricesResponse {
    
    func getKavaOraclePrice(_ marketId: String?) -> NSDecimalNumber {
        if let price = prices.filter({ $0.marketID == marketId }).first {
            return NSDecimalNumber.init(string: price.price).multiplying(byPowerOf10: -18, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
}



