//
//  MajorHistoryVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class MajorHistoryVC: BaseVC {
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataView: UIView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!
    var historyGroup = [HistoryGroup]()

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
        tableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestHistory), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        onRequestHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHistoryDone(_:)), name: Notification.Name("fetchHistory"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("fetchHistory"), object: nil)
    }
    
    @objc func onRequestHistory() {
        if let suiChain = selectedChain as? ChainSui {
            suiChain.fetchHistory()
            
        } else if let btcChain = selectedChain as? ChainBitCoin84 {
            btcChain.fetchHistory()
            
        }
    }
    
    @objc func onHistoryDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        if (selectedChain != nil && selectedChain.tag == tag) {
            DispatchQueue.main.async {
                self.onUpdateView()
            }
        }
    }
    
    func onUpdateView() {
        refresher.endRefreshing()
        
        if let suiFetcher = (selectedChain as? ChainSui)?.getSuiFetcher() {
            historyGroup.removeAll()
            suiFetcher.suiHistory.forEach { history in
                let date = WDP.dpDate(history["timestampMs"].intValue)
                var matched = -1
                for i in 0 ..< historyGroup.count {
                    if (historyGroup[i].date == date) {
                        matched = i
                    }
                }
                if (matched >= 0) {
                    var updated = historyGroup[matched].values
                    updated.append(history)
                    historyGroup[matched].values = updated
                } else {
                    historyGroup.append(HistoryGroup.init(date, [history]))
                }
            }
            
            loadingView.isHidden = true
            if (historyGroup.count <= 0) {
                emptyDataView.isHidden = false
            } else {
                emptyDataView.isHidden = true
                tableView.reloadData()
            }
            
        } else if let btcFetcher = (selectedChain as? ChainBitCoin84)?.getBtcFetcher() {
            historyGroup.removeAll()
            btcFetcher.btcHistory.forEach { history in
                let date = history["status"]["confirmed"] == false ? "Pending" : WDP.dpDate(history["status"]["block_time"].intValue * 1000)
                var matched = -1
                for i in 0 ..< historyGroup.count {
                    if (historyGroup[i].date == date) {
                        matched = i
                    }
                }
                if (matched >= 0) {
                    var updated = historyGroup[matched].values
                    updated.append(history)
                    historyGroup[matched].values = updated.sorted{ $0["status"]["block_time"].intValue > $1["status"]["block_time"].intValue }
                } else {
                    historyGroup.append(HistoryGroup.init(date, [history]))
                }
            }
            
            historyGroup.sort {
                $0.date > $1.date
            }
            
            loadingView.isHidden = true
            if (historyGroup.count <= 0) {
                emptyDataView.isHidden = false
            } else {
                emptyDataView.isHidden = true
                tableView.reloadData()
            }
        }
    }
}


//else if let btcChain = selectedChain as? ChainBitCoin84 {

extension MajorHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedChain is ChainSui {
            return historyGroup.count
        } else if selectedChain is ChainBitCoin84 {
            return historyGroup.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if selectedChain is ChainSui {
            let today = WDP.dpDate(Int(Date().timeIntervalSince1970) * 1000)
            if (historyGroup[section].date == today) {
                view.titleLabel.text = "Today"
            } else {
                view.titleLabel.text = historyGroup[section].date
            }
            view.cntLabel.text = ""
            
        } else if selectedChain is ChainBitCoin84 {
            if (historyGroup[section].date == "Pending") {
                view.titleLabel.text = "Mempool"
            } else {
                view.titleLabel.text = historyGroup[section].date
            }
            view.cntLabel.text = ""
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedChain is ChainSui {
            return historyGroup[section].values.count
        } else if selectedChain is ChainBitCoin84 {
            return historyGroup[section].values.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as! HistoryCell
        if let suiChain = selectedChain as? ChainSui {
            cell.bindSuiHistory(suiChain, historyGroup[indexPath.section].values[indexPath.row])
        } else if let btcChain = selectedChain as? ChainBitCoin84 {
            cell.bindBtcHistory(btcChain, historyGroup[indexPath.section].values[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let suiChain = selectedChain as? ChainSui {
            let hash = historyGroup[indexPath.section].values[indexPath.row]["digest"].stringValue
            guard let url = selectedChain.getExplorerTx(hash) else { return }
            self.onShowSafariWeb(url)
        } else if let btcChain = selectedChain as? ChainBitCoin84 {
            let hash = historyGroup[indexPath.section].values[indexPath.row]["txid"].stringValue
            guard let url = selectedChain.getExplorerTx(hash) else { return }
            self.onShowSafariWeb(url)
        }
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


struct HistoryGroup {
    var date : String!
    var values = [JSON]()
    
    init(_ date: String!, _ values: [JSON]) {
        self.date = date
        self.values = values
    }
}
