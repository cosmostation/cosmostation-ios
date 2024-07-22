//
//  KavaDefiVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class KavaDefiVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: BaseChain!
    var kavaFetcher: KavaFetcher!
    var incentive: Kava_Incentive_V1beta1_QueryRewardsResponse?
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        kavaFetcher = selectedChain.getCosmosfetcher() as? KavaFetcher
        
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
            if let incentive = try? await kavaFetcher.fetchIncentive(),
               let pricefeed = try? await kavaFetcher.fetchPriceFeed() {
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
        return 5
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
            claimRewards.selectedChain = selectedChain as? ChainKavaEVM
            claimRewards.modalTransitionStyle = .coverVertical
            self.present(claimRewards, animated: true)
            
        } else if (indexPath.row == 1) {
            let mintListVC = KavaMintListVC(nibName: "KavaMintListVC", bundle: nil)
            mintListVC.selectedChain = selectedChain as? ChainKavaEVM
            mintListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(mintListVC, animated: true)
            
        } else if (indexPath.row == 2) {
            let lendListVC = KavaLendListVC(nibName: "KavaLendListVC", bundle: nil)
            lendListVC.selectedChain = selectedChain as? ChainKavaEVM
            lendListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(lendListVC, animated: true)
            
        } else if (indexPath.row == 3) {
            let swapListVC = KavaSwapListVC(nibName: "KavaSwapListVC", bundle: nil)
            swapListVC.selectedChain = selectedChain as? ChainKavaEVM
            swapListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(swapListVC, animated: true)
            
        } else if (indexPath.row == 4) {
            let earnListVC = KavaEarnListVC(nibName: "KavaEarnListVC", bundle: nil)
            earnListVC.selectedChain = selectedChain as? ChainKavaEVM
//            earnListVC.priceFeed = priceFeed
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(earnListVC, animated: true)
            
        }
    }
}



