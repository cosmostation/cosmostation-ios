//
//  MajorCryptoVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lottie

class MajorCryptoVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AssetSuiCell", bundle: nil), forCellReuseIdentifier: "AssetSuiCell")
        tableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
//        refresher = UIRefreshControl()
//        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
//        refresher.tintColor = .color01
//        tableView.addSubview(refresher)
//        
//        onUpdateView()
    }

    
    
}

extension MajorCryptoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedChain is ChainSui) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if section == 0 {
            view.titleLabel.text = "Native Coins"
            if let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() {
                view.cntLabel.text = String(suiFetcher.suiBalances.count)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() {
            return suiFetcher.suiBalances.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetSuiCell") as! AssetSuiCell
                cell.bindStakeAsset(selectedChain)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as! AssetCell
//                cell.bindOktAsset(oktChain, searchOktBalances[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
}
