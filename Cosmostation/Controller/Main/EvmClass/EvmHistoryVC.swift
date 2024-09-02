//
//  EvmHistoryVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/01/25.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class EvmHistoryVC: BaseVC {
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataView: UIView!
    var refresher: UIRefreshControl!
    
    var selectedChain: BaseChain!

    var historyGroup = Array<EvmHistoryGroup>()
    var histoyID = ""
    var hasMore = false
    let BATCH_CNT = 20


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
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = .color01
        tableView.addSubview(refresher)
        
        onRequestFetch()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refresher.endRefreshing()
    }
    
    @objc func onRequestFetch() {
        Task {
            try await onFetchHistory(selectedChain.evmAddress!, histoyID)
        }
    }

    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        guard let url = selectedChain.getExplorerAccount() else { return }
        self.onShowSafariWeb(url)
    }
    
    
    func onFetchHistory(_ evmAddress: String, _ id: String) async throws {
        let url = BaseNetWork.getAccountHistoryUrl(selectedChain!, evmAddress)
        do {
            let histortJson = try await AF.request(url, 
                                                   method: .get,
                                                   parameters: ["search_after": histoyID,
                                                                "limit" : "\(BATCH_CNT)"]).serializingDecodable(JSON.self).value
            if (id == "") { self.historyGroup.removeAll() }
            if (histortJson["txs"].count > 0) {
                histortJson["txs"].arrayValue.forEach { history in
                    let headerDate  = WDP.dpDate(history["txTime"].intValue)
                    if let index = self.historyGroup.firstIndex(where: { $0.date == headerDate }) {
                        self.historyGroup[index].values.append(history)
                    } else {
                        self.historyGroup.append(EvmHistoryGroup.init(headerDate, [history]))
                    }
                }
                self.histoyID = String(histortJson["search_after"].intValue - 1)
                self.hasMore = histortJson["txs"].count >= self.BATCH_CNT
                
            } else {
                self.hasMore = false
                self.histoyID = ""
            }
            
            self.loadingView.isHidden = true
            if (self.historyGroup.count > 0) {
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.emptyDataView.isHidden = true
            } else {
                self.tableView.isHidden = true
                self.emptyDataView.isHidden = false
            }
        } catch {
            print("onFetchEVMHistory error", error)

        }
        self.refresher.endRefreshing()
    }

}


extension EvmHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return historyGroup.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let today = WDP.dpDate(Int(Date().timeIntervalSince1970) * 1000)
        if (historyGroup[section].date == today) {
            view.titleLabel.text = "Today"
        } else {
            view.titleLabel.text = historyGroup[section].date
        }
        view.cntLabel.text = ""
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyGroup[section].values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as! HistoryCell
            let history = historyGroup[indexPath.section].values[indexPath.row]
            cell.bindEvmClassHistory(baseAccount, selectedChain, history)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == self.historyGroup.count - 1
            && indexPath.row == self.historyGroup.last!.values.count - 1
            && hasMore == true) {
            hasMore = false
            Task {
                try await onFetchHistory(selectedChain.evmAddress!, histoyID)
            }
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hash = historyGroup[indexPath.section].values[indexPath.row]["txHash"].stringValue
        guard let url = selectedChain.getExplorerTx(hash) else { return }
        self.onShowSafariWeb(url)
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


struct EvmHistoryGroup {
    var date : String!
    var values = [JSON]()
    
    init(_ date: String!, _ values: [JSON]) {
        self.date = date
        self.values = values
    }
}
