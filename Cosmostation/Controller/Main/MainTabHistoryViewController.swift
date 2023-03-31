//
//  MainTabHistoryViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import UserNotifications

class MainTabHistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleWalletName: UILabel!

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
    var mBnbHistories = Array<BnbHistory>()
    var mOkHistories = Array<OKTransactionList>()
    
    var mApiHistories = Array<ApiHistoryNewCustom>()
    var mApiHistoyID: Int64 = 0
    var mApiHasMore = false
    let mApiBatchCnt = 30
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        self.historyTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.historyTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        self.historyTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        self.historyTableView.rowHeight = UITableView.automaticDimension
        self.historyTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            self.historyTableView.sectionHeaderTopPadding = 0.0
        }
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor.font05
        self.historyTableView.addSubview(refresher)

        
        self.onRequestFetch()
        
//        self.emptyLabel.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(testClick(tapGestureRecognizer:)))
//        self.emptyLabel.addGestureRecognizer(tapGesture)
//        historyTableView.isHidden = true
//        emptyLabel.isHidden = false
//        print("emptyLabel ", emptyLabel.isHidden, "   ", emptyLabel.text)
    }
    
    @objc func testClick(tapGestureRecognizer: UITapGestureRecognizer) {
//        let txDetailVC = TxDetailgRPCViewController(nibName: "TxDetailgRPCViewController", bundle: nil)
//        txDetailVC.mIsGen = false
//        txDetailVC.mTxHash = "DB6BD420C64A0DEFAC7CD134B1FDE40F0F50A291CBEDA2A46BB347D44CA94219"
//        txDetailVC.hidesBottomBarWhenPushed = true
//        self.navigationItem.title = ""
//        self.navigationController?.pushViewController(txDetailVC, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchPrice(_:)), name: Notification.Name("onFetchPrice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTitle), name: Notification.Name("onNameCheckDone"), object: nil)
        self.updateTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchPrice"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onNameCheckDone"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.historyTableView.reloadData()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.historyTableView.reloadData()
    }
    
    @objc func updateTitle() {
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.titleChainImg.image = chainConfig?.chainImg
        self.titleWalletName.text = account?.getDpName()
    }
    
    @objc func onRequestFetch() {
        if (chainType == ChainType.BINANCE_MAIN) {
            onFetchBnbHistory(account!.account_address)
        } else if (chainType == ChainType.OKEX_MAIN) {
            onFetchOkHistory(account!.account_address)
        } else {
            mApiHistoyID = 0
            mApiHasMore = false
            onFetchNewApiHistoryCustom(account!.account_address, mApiHistoyID)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) { return 0 }
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.headerTitleLabel.text = NSLocalizedString("recent_history", comment: "")
        var cntString = "0"
        if (chainType == ChainType.BINANCE_MAIN) {
            cntString = String(self.mBnbHistories.count)
        } else if (chainType == ChainType.OKEX_MAIN) {
            cntString = String(self.mOkHistories.count)
        } else {
            cntString = String(self.mApiHistories.count)
        }
        view.headerCntLabel.text = cntString
        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
            
        } else {
            if (chainType == .BINANCE_MAIN) {
                return self.mBnbHistories.count
            } else if (chainType == .OKEX_MAIN) {
                return self.mOkHistories.count
            } else {
                return self.mApiHistories.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return onSetAddressItems(tableView, indexPath);
            
        } else {
            if (chainType == .BINANCE_MAIN) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as? HistoryCell
                cell?.bindHistoryBnbView(mBnbHistories[indexPath.row], account!.account_address)
                return cell!
                
            } else if (chainType == .OKEX_MAIN) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as? HistoryCell
                cell?.bindHistoryOkView(mOkHistories[indexPath.row], account!.account_address)
                return cell!
            
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
                cell?.bindHistoryView(chainConfig!, mApiHistories[indexPath.row], account!.account_address)
                return cell!
            }
        }
    }
    
    func onSetAddressItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
        cell?.updateView(account, chainConfig)
        cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (chainType == ChainType.BINANCE_MAIN) {
            let bnbHistory = mBnbHistories[indexPath.row]
            let link = WUtils.getTxExplorer(chainConfig, bnbHistory.txHash)
            guard let url = URL(string: link) else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            let okHistory = mOkHistories[indexPath.row]
            let link = WUtils.getTxExplorer(chainConfig, okHistory.txId!)
            guard let url = URL(string: link) else { return }
            self.onShowSafariWeb(url)
            
        } else {
            let history = mApiHistories[indexPath.row]
            let link = WUtils.getTxExplorer(chainConfig, history.data!.txhash!)
            guard let url = URL(string: link) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (chainConfig?.isGrpc == true) {
            if indexPath.row == self.mApiHistories.count - 1 {
                if (mApiHasMore == true) {
                    mApiHasMore = false
                    onFetchNewApiHistoryCustom(account!.account_address, mApiHistoyID)
                }
            }
        }
    }
    
    func onFetchBnbHistory(_ address:String) {
        let url = BaseNetWork.accountHistory(chainConfig, address)
        let request = Alamofire.request(url, method: .get, parameters: ["address":address, "startTime":Date().Stringmilli3MonthAgo, "endTime":Date().millisecondsSince1970], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { response in
            switch response.result {
            case .success(let res):
                if let data = res as? NSDictionary, let rawHistory = data.object(forKey: "tx") as? Array<NSDictionary> {
                    self.mBnbHistories.removeAll()
                    for raw in rawHistory {
                        self.mBnbHistories.append(BnbHistory.init(raw as! [String : Any]))
                    }
                    if(self.mBnbHistories.count > 0) {
                        self.historyTableView.reloadData()
                        self.emptyLabel.isHidden = true
                    } else {
                        self.emptyLabel.isHidden = false
                    }
                    
                } else {
                    self.emptyLabel.isHidden = false
                }
                
            case .failure(let error):
                print("error ", error)
            }
        }
        self.refresher.endRefreshing()
    }
    
    func onFetchOkHistory(_ address: String) {
        let url = BaseNetWork.accountHistory(chainConfig, address)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { response in
            switch response.result {
            case .success(let res):
                if let histories = res as? NSDictionary {
                    self.mOkHistories.removeAll()
                    if let hitDatas = histories.object(forKey: "data") as? Array<NSDictionary> {
                        hitDatas.forEach { hitData in
                            self.mOkHistories = OKHistoryData.init(hitData).transactionLists
                        }
                    }
                    if (self.mOkHistories.count > 0) {
                        self.historyTableView.reloadData()
                        self.emptyLabel.isHidden = true
                    } else {
                        self.emptyLabel.isHidden = false
                    }
                
                } else {
                    self.emptyLabel.isHidden = false
                }

            case .failure(let error):
                print("error ", error)
            }
        }
        self.refresher.endRefreshing()
    }
    
    func onFetchNewApiHistoryCustom(_ address: String, _ id: Int64) {
        let url = BaseNetWork.accountHistory(chainConfig, address)
        let request = Alamofire.request(url, method: .get, parameters: ["limit":String(self.mApiBatchCnt), "from":String(id)], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if (id == 0) { self.mApiHistories.removeAll() }
                if let histories = res as? Array<NSDictionary> {
                    for rawHistory in histories {
                        self.mApiHistories.append(ApiHistoryNewCustom.init(rawHistory))
                    }
                    self.mApiHistoyID = self.mApiHistories.last?.header?.id ?? 0
                    self.mApiHasMore = histories.count >= self.mApiBatchCnt
                    
                } else {
                    self.mApiHasMore = false
                    self.mApiHistoyID = 0
                }
                
                if (self.mApiHistories.count > 0) {
                    self.historyTableView.reloadData()
                    self.emptyLabel.isHidden = true
                } else {
                    self.emptyLabel.isHidden = false
                }

            case .failure(let error):
                self.emptyLabel.isHidden = false
                print("onFetchNewApiHistoryCustom ", error)
            }
            self.refresher.endRefreshing()
        }
    }
    
    
    @IBAction func onClickSwitchAccount(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.mainTabVC.onShowAccountSwicth {
            sender.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        let link = WUtils.getAccountExplorer(chainConfig, account!.account_address)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
}
