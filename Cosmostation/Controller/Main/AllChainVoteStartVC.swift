//
//  AllChainVoteStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/14/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie

class AllChainVoteStartVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        voteBtn.isEnabled = false
    }

    @IBAction func onClickVote(_ sender: BaseButton) {
    }
}
