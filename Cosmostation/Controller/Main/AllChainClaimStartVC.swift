//
//  AllChainClaimStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class AllChainClaimStartVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    
    var toDisplayCosmosChains = [CosmosClass]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        toDisplayCosmosChains = baseAccount.getDisplayCosmosChains()
        print("toDisplayCosmosChains ", toDisplayCosmosChains.count)
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClaimAllChainCell", bundle: nil), forCellReuseIdentifier: "ClaimAllChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
    }
    
    override func setLocalizedString() {
//        navigationItem.title = NSLocalizedString("title_staking_info", comment: "")
//        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
    }
    
    
    @IBAction func onClickClaim(_ sender: BaseButton) {
    }
    
}

extension AllChainClaimStartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ClaimAllChainCell") as! ClaimAllChainCell
        return cell
    }
    
}
