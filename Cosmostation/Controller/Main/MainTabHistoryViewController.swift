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
    
    @IBOutlet weak var chainBg: UIImageView!
    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleWalletName: UILabel!
    @IBOutlet weak var titleAlarmBtn: UIButton!
    @IBOutlet weak var titleChainName: UILabel!
    
    @IBOutlet weak var totalCard: CardView!
    @IBOutlet weak var totalKeyState: UIImageView!
    @IBOutlet weak var totalDpAddress: UILabel!
    @IBOutlet weak var totalValue: UILabel!

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var comingLabel: UILabel!
    
    var mainTabVC: MainTabViewController!
    var refresher: UIRefreshControl!
    var mBnbHistories = Array<BnbHistory>()
    var mOkHistories = Array<OKHistoryHit>()
    var mApiCustomNewHistories = Array<ApiHistoryNewCustom>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory().getChainConfig(chainType)
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        self.historyTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.historyTableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        self.historyTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        self.historyTableView.rowHeight = UITableView.automaticDimension
        self.historyTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            self.historyTableView.sectionHeaderTopPadding = 0.0
        }
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor.white
        self.historyTableView.addSubview(refresher)
        
        self.onRequestFetch()
        
        let tapTotalCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickActionShare))
        self.totalCard.addGestureRecognizer(tapTotalCard)
        
        self.emptyLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(testClick(tapGestureRecognizer:)))
        self.emptyLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func testClick(tapGestureRecognizer: UITapGestureRecognizer) {
//        let txDetailVC = TxDetailViewController(nibName: "TxDetailViewController", bundle: nil)
//        txDetailVC.mIsGen = false
//        txDetailVC.mTxHash = "E139E2803B57CDA9BA59751ED398EDDD16B5E8633A71DCF5A78C6E60FEFDE723"
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
        self.updateTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchPrice"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.historyTableView.reloadData()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
    }
    
    func updateTitle() {
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory().getChainConfig(chainType)
        
        self.titleChainImg.image = chainConfig?.chainImg
        self.titleChainName.text = chainConfig?.chainTitle
        self.titleChainName.textColor = chainConfig?.chainColor
        self.titleWalletName.text = account?.getDpName()
        self.titleAlarmBtn.isHidden = !(chainConfig?.pushSupport ?? false)
        
        self.totalCard.backgroundColor = chainConfig?.chainColorBG
        self.totalDpAddress.text = account?.account_address
        self.totalDpAddress.adjustsFontSizeToFitWidth = true
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
        if (account?.account_has_private == true) {
            self.totalKeyState.image = totalKeyState.image?.withRenderingMode(.alwaysTemplate)
            self.totalKeyState.tintColor = chainConfig?.chainColor
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    if (self.account!.account_push_alarm) {
                        self.titleAlarmBtn.setImage(UIImage(named: "btnAlramOn"), for: .normal)
                    } else {
                        self.titleAlarmBtn.setImage(UIImage(named: "btnAlramOff"), for: .normal)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.titleAlarmBtn.setImage(UIImage(named: "btnAlramOff"), for: .normal)
                }
            }
        }
    }
    
    @objc func onRequestFetch() {
        if (chainType == ChainType.BINANCE_MAIN) {
            onFetchBnbHistory(account!.account_address)
        } else if (chainType == ChainType.OKEX_MAIN) {
            onFetchOkHistory(account!.account_address)
        } else {
            onFetchNewApiHistoryCustom(account!.account_address)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
            cntString = String(self.mApiCustomNewHistories.count)
        }
        view.headerCntLabel.text = cntString
        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (chainType == ChainType.BINANCE_MAIN) {
            return self.mBnbHistories.count
        } else if (chainType == ChainType.OKEX_MAIN) {
            return self.mOkHistories.count
        } else {
            return self.mApiCustomNewHistories.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (chainType == ChainType.BINANCE_MAIN) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as? HistoryCell
            cell?.bindHistoryBnbView(mBnbHistories[indexPath.row], account!.account_address)
            return cell!
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"HistoryCell") as? HistoryCell
            cell?.bindHistoryOkView(mOkHistories[indexPath.row], account!.account_address)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
            cell?.bindHistoryView(chainType!, mApiCustomNewHistories[indexPath.row], account!.account_address)
            return cell!
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (chainType == ChainType.BINANCE_MAIN) {
            let bnbHistory = mBnbHistories[indexPath.row]
            guard let url = URL(string: "https://binance.mintscan.io/txs/" + bnbHistory.txHash) else { return }
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.modalPresentationStyle = .popover
            present(safariViewController, animated: true, completion: nil)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            let okHistory = mOkHistories[indexPath.row]
            guard let url = URL(string: EXPLORER_OEC_TX + "tx/" + okHistory.hash!) else { return }
            self.onShowSafariWeb(url)
            
        } else {
//            let history = mApiCustomNewHistories[indexPath.row]
//            let link = WUtils.getTxExplorer(self.chainType!, history.data!.txhash!)
//            guard let url = URL(string: link) else { return }
//            self.onShowSafariWeb(url)
            
            //TODO temp added
            let history = mApiCustomNewHistories[indexPath.row]
            let txDetailVC = TxDetailgRPCViewController(nibName: "TxDetailgRPCViewController", bundle: nil)
            txDetailVC.mIsGen = false
            txDetailVC.mTxHash = history.data!.txhash!
            self.navigationItem.title = ""
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
            self.navigationController?.pushViewController(txDetailVC, animated: true)
        }
    }
    
    func onFetchBnbHistory(_ address:String) {
        let request = Alamofire.request(BaseNetWork.bnbHistoryUrl(chainType), method: .get, parameters: ["address":address, "startTime":Date().Stringmilli3MonthAgo, "endTime":Date().millisecondsSince1970], encoding: URLEncoding.default, headers: [:])
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
        let request = Alamofire.request(BaseNetWork.historyOkUrl(chainType, address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        print("onFetchOkHistory url ", request.request?.url)
        request.responseJSON { response in
            switch response.result {
            case .success(let res):
                self.mOkHistories.removeAll()
                if let histories = res as? NSDictionary, let hits = OkHistory.init(histories).data?.hits {
                    self.mOkHistories = hits
                }
                if (self.mOkHistories.count > 0) {
                    self.historyTableView.reloadData()
                    self.emptyLabel.isHidden = true
                } else {
                    self.emptyLabel.isHidden = false
                }

            case .failure(let error):
                print("error ", error)
            }
        }
        self.refresher.endRefreshing()
    }
    
    func onFetchNewApiHistoryCustom(_ address:String) {
        let url = BaseNetWork.accountHistory(chainType!, address)
        let request = Alamofire.request(url, method: .get, parameters: ["limit":"50"], encoding: URLEncoding.default, headers: [:])
        print("onFetchNewApiHistoryCustom url ", request.request?.url)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                self.mApiCustomNewHistories.removeAll()
                if let histories = res as? Array<NSDictionary> {
                    for rawHistory in histories {
                        self.mApiCustomNewHistories.append(ApiHistoryNewCustom.init(rawHistory))
                    }
                }
                if (self.mApiCustomNewHistories.count > 0) {
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
    
    
    @IBAction func onClickSwitchAccount(_ sender: Any) {
        self.mainTabVC.onShowAccountSwicth()
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        let link = WUtils.getAccountExplorer(chainType!, account!.account_address)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    @IBAction func onClickAlaram(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(named: "btnAlramOff")) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.showWaittingAlert()
                        self.onToggleAlarm(self.mainTabVC.mAccount!) { (success) in
                            self.mainTabVC.onUpdateAccountDB()
                            self.updateTitle()
                            self.dismissAlertController()
                        }
                    }
                    
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("permission_push_title", comment: ""), message: NSLocalizedString("permission_push_msg", comment: ""), preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            })
                        }
                    }
                    let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showWaittingAlert()
                self.onToggleAlarm(self.mainTabVC.mAccount!) { (success) in
                    self.mainTabVC.onUpdateAccountDB()
                    self.updateTitle()
                    self.dismissAlertController()
                }
            }
        }
    }
    
    @objc func onClickActionShare() {
        self.shareAddress(account!.account_address, WUtils.getWalletName(account))
    }
    
}
