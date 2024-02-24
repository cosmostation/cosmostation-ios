//
//  CosmosHistoryVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/22.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class CosmosHistoryVC: BaseVC {
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataView: UIView!
    var refresher: UIRefreshControl!
    
    var selectedChain: CosmosClass!
    var msHistoryGroup = Array<MintscanHistoryGroup>()
    var msHistoyID = ""
    var msHasMore = false
    let BATCH_CNT = 30
    
    var beaconHistoey = Array<BeaconHistory>()  //For BNB Beacon chain
    var oktHistoey = Array<OktHistory>()        //For OKT chain

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
        if (selectedChain is ChainBinanceBeacon) {
            onFetchBnbHistory(selectedChain.bechAddress)
            
        } else if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            onFetchOktHistory(selectedChain.evmAddress)
            
        } else {
            msHistoyID = ""
            msHasMore = false
            onFetchMsHistory(selectedChain.bechAddress, msHistoyID)
        }
    }
    
    func onFetchMsHistory(_ address: String?, _ id: String) {
        let url = BaseNetWork.getAccountHistoryUrl(selectedChain!, address!)
        AF.request(url, method: .get, parameters: ["limit":String(BATCH_CNT), "search_after":id]).responseDecodable(of: [MintscanHistory].self, queue: .main, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let value):
                if (id == "") { self.msHistoryGroup.removeAll() }
                if (value.count > 0) {
                    value.forEach { history in
                        let headerDate  = WDP.dpDate(history.header?.timestamp)
                        if let index = self.msHistoryGroup.firstIndex(where: { $0.date == headerDate }) {
                            self.msHistoryGroup[index].values.append(history)
                        } else {
                            self.msHistoryGroup.append(MintscanHistoryGroup.init(headerDate, [history]))
                        }
                    }
                    self.msHistoyID = value.last?.search_after ?? ""
                    self.msHasMore = value.count >= self.BATCH_CNT
                    
                } else {
                    self.msHasMore = false
                    self.msHistoyID = ""
                }
                
                self.loadingView.isHidden = true
                if (self.msHistoryGroup.count > 0) {
                    self.tableView.reloadData()
                    self.tableView.isHidden = false
                    self.emptyDataView.isHidden = true
                } else {
                    self.tableView.isHidden = true
                    self.emptyDataView.isHidden = false
                }
                
            case .failure:
                print("onFetchMsHistory error")
            }
            self.refresher.endRefreshing()
        }
    }
    
    func onFetchBnbHistory(_ address: String?) {
        let url = BaseNetWork.getAccountHistoryUrl(selectedChain!, address!)
        AF.request(url, method: .get, parameters: ["address": address!, "startTime" : Date().Stringmilli3MonthAgo, "endTime" : Date().millisecondsSince1970]).responseDecodable(of: BeaconHistories.self, queue: .main, decoder: JSONDecoder())  { response in
            switch response.result {
            case .success(let value):
                if let txs = value.tx {
                    self.beaconHistoey = txs
                }
                self.loadingView.isHidden = true
                if (self.beaconHistoey.count > 0) {
                    self.tableView.reloadData()
                    self.emptyDataView.isHidden = true
                } else {
                    self.emptyDataView.isHidden = false
                }
                
            case .failure:
                print("onFetchBnbHistory error")
            }
            self.refresher.endRefreshing()
        }
    }
    
    func onFetchOktHistory(_ evmAddress: String) {
        let url = BaseNetWork.getAccountHistoryUrl(selectedChain!, evmAddress)
        AF.request(url, method: .get, parameters: [:]).responseDecodable(of: OkHistoryRoot.self, queue: .main, decoder: JSONDecoder())  { response in
            switch response.result {
            case .success(let value):
                if let txs = value.data?[0].transactionLists {
                    self.oktHistoey = txs
                }
                self.loadingView.isHidden = true
                if (self.oktHistoey.count > 0) {
                    self.tableView.reloadData()
                    self.emptyDataView.isHidden = true
                } else {
                    self.emptyDataView.isHidden = false
                }
                
                
            case .failure:
                print("onFetchOktHistory error", response.error)
            }
            self.refresher.endRefreshing()
        }
    }

}


extension CosmosHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (selectedChain is ChainBinanceBeacon ||
            selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            return 1
        } else {
            return msHistoryGroup.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (selectedChain is ChainBinanceBeacon) {
            view.titleLabel.text = "History"
            view.cntLabel.text = String(beaconHistoey.count)
            
        } else if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            view.titleLabel.text = "History"
            view.cntLabel.text = String(oktHistoey.count)
            
        } else {
            let today = WDP.dpDate(Int(Date().timeIntervalSince1970) * 1000)
            if (msHistoryGroup[section].date == today) {
                view.titleLabel.text = "Today"
            } else {
                view.titleLabel.text = msHistoryGroup[section].date
            }
            view.cntLabel.text = ""
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedChain is ChainBinanceBeacon) {
            return beaconHistoey.count
            
        } else if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            return oktHistoey.count
            
        } else {
            return msHistoryGroup[section].values.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as! HistoryCell
        if (selectedChain is ChainBinanceBeacon) {
            let history = beaconHistoey[indexPath.row]
            cell.bindBeaconHistory(baseAccount, selectedChain, history)
            
        } else if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            let history = oktHistoey[indexPath.row]
            cell.bindOktHistory(baseAccount, selectedChain, history)
            
        } else {
            let history = msHistoryGroup[indexPath.section].values[indexPath.row]
            cell.bindCosmosClassHistory(baseAccount, selectedChain, history)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (!(selectedChain is ChainBinanceBeacon) &&
            !(selectedChain is ChainOktEVM) && !(selectedChain is ChainOkt996Keccak)) {
            if (indexPath.section == self.msHistoryGroup.count - 1
                && indexPath.row == self.msHistoryGroup.last!.values.count - 1
                && msHasMore == true) {
                msHasMore = false
                onFetchMsHistory(selectedChain.bechAddress, msHistoyID)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedChain is ChainBinanceBeacon) {
            let history = beaconHistoey[indexPath.row]
            guard let url = BaseNetWork.getTxDetailUrl(selectedChain, history.txHash!) else { return }
            self.onShowSafariWeb(url)
            
        } else if (selectedChain is ChainOktEVM || selectedChain is ChainOkt996Keccak) {
            let history = oktHistoey[indexPath.row]
            guard let url = BaseNetWork.getTxDetailUrl(selectedChain, history.txId!) else { return }
            self.onShowSafariWeb(url)
            
        } else {
            let history = msHistoryGroup[indexPath.section].values[indexPath.row]
            guard let url = BaseNetWork.getTxDetailUrl(selectedChain, history.data!.txhash!) else { return }
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

struct MintscanHistoryGroup {
    var date : String!
    var values = Array<MintscanHistory>()
    
    init(_ date: String!, _ values: Array<MintscanHistory>) {
        self.date = date
        self.values = values
    }
}
