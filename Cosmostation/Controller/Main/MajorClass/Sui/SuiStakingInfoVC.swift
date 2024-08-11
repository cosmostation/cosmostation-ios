//
//  SuiStakingInfoVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/11/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import SwiftyJSON

class SuiStakingInfoVC: BaseVC {
    
    @IBOutlet weak var epochTitle: UILabel!
    @IBOutlet weak var epochLable: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var guideMsg0: UILabel!
    @IBOutlet weak var guideMsg1: UILabel!
    @IBOutlet weak var guideMsg2: UILabel!
    @IBOutlet weak var guideMsg3: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stakeBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var emptyStakeImg: UIImageView!
    var refresher: UIRefreshControl!
    
    var selectedChain: ChainSui!
    var suiFehcer: SuiFetcher!
    
    var timer: Timer?
    var epoch: Int64?
    var epochStartTimestampMs: Int64?
    var epochDurationMs: Int64?
    var stakedList = [(String, JSON)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        suiFehcer = selectedChain.getSuiFetcher()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        epoch = suiFehcer.suiSystem["epoch"].int64Value
        epochStartTimestampMs = suiFehcer.suiSystem["epochStartTimestampMs"].int64Value
        epochDurationMs = suiFehcer.suiSystem["epochDurationMs"].int64Value
        epochLable.text = "#" + String(epoch!)
        
        guideMsg0.text = NSLocalizedString("msg_sui_guide_0", comment: "")
        guideMsg1.text = String(format: NSLocalizedString("msg_sui_guide_1", comment: ""), "#"+String(epoch!))
        guideMsg2.text = String(format: NSLocalizedString("msg_sui_guide_2", comment: ""), "#"+String(epoch! + 1))
        guideMsg3.text = NSLocalizedString("msg_sui_guide_3", comment: "")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onUpdateTime), userInfo: nil, repeats: true)
        onUpdateTime()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SuiStakingCell", bundle: nil), forCellReuseIdentifier: "SuiStakingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        onUpdateView()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_staking_info", comment: "")
        epochTitle.text = NSLocalizedString("str_current_epoch", comment: "")
        timeTitle.text = NSLocalizedString("str_next_reward_distibution", comment: "")
        stakeBtn.setTitle(NSLocalizedString("str_start_stake", comment: ""), for: .normal)
    }
    
    @objc func onRequestFetch() {
        if (selectedChain.fetchState == .Busy) {
            refresher.endRefreshing()
        } else {
            DispatchQueue.global().async {
                self.selectedChain.fetchData(self.baseAccount.id)
            }
        }
    }
    
    @objc func onUpdateTime() {
        let endEpoch = epochStartTimestampMs! + epochDurationMs!
        let current = Date().millisecondsSince1970
        if (endEpoch > current) {
            let gap = (endEpoch - current) / 1000
            var hours = String(gap / (60 * 60))
            var minutes = String((gap / 60) % 60)
            var second = String(gap % 60)
            if (hours.count == 1) { hours = "0" + hours }
            if (minutes.count == 1) { minutes = "0" + minutes }
            if (second.count == 1) { second = "0" + second }
            timeLabel.text = hours + " : " + minutes + " : " + second
            
        } else {
            timer?.invalidate()
        }
    }
    
    func onUpdateView() {
        stakedList.removeAll()
        suiFehcer.suiStakedList.forEach { suiStaked in
            suiStaked["stakes"].arrayValue.forEach { stakes in
                stakedList.append((suiStaked["validatorAddress"].stringValue, stakes))
            }
        }
        
        stakedList.sort {
            return $0.1["stakeRequestEpoch"].uInt64Value > $1.1["stakeRequestEpoch"].uInt64Value
        }
        
        refresher.endRefreshing()
        loadingView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
        
//        print("stakedList ", stakedList)
        if (stakedList.count == 0) {
            emptyStakeImg.isHidden = false
        } else {
            emptyStakeImg.isHidden = true
        }
    }
    
    @IBAction func onClickStake(_ sender: BaseButton) {
    }
    
}


extension SuiStakingInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = NSLocalizedString("str_my_delegations", comment: "")
        view.cntLabel.text = String(stakedList.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (stakedList.count > 0) ? 40 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stakedList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SuiStakingCell") as! SuiStakingCell
        cell.onBindMyStake(selectedChain, stakedList[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
}
