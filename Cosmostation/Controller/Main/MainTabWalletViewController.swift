//
//  MainTabWalletViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 27/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import Floaty
import SafariServices
import StoreKit

class MainTabWalletViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate, QrScannerDelegate, PasswordViewDelegate {

    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleAlarmBtn: UIButton!
    @IBOutlet weak var titleWalletName: UILabel!
    
    @IBOutlet weak var walletTableView: UITableView!
    var refresher: UIRefreshControl!
    
    var mainTabVC: MainTabViewController!
    var wcURL:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)

        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        self.walletTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.walletTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.walletTableView.register(UINib(nibName: "WalletIrisCell", bundle: nil), forCellReuseIdentifier: "WalletIrisCell")
        self.walletTableView.register(UINib(nibName: "WalletBnbCell", bundle: nil), forCellReuseIdentifier: "WalletBnbCell")
        self.walletTableView.register(UINib(nibName: "WalletKavaCell", bundle: nil), forCellReuseIdentifier: "WalletKavaCell")
        self.walletTableView.register(UINib(nibName: "WalletKavaIncentiveCell", bundle: nil), forCellReuseIdentifier: "WalletKavaIncentiveCell")
        self.walletTableView.register(UINib(nibName: "WalletIovCell", bundle: nil), forCellReuseIdentifier: "WalletIovCell")
        self.walletTableView.register(UINib(nibName: "WalletOkCell", bundle: nil), forCellReuseIdentifier: "WalletOkCell")
        self.walletTableView.register(UINib(nibName: "WalletCrytoCell", bundle: nil), forCellReuseIdentifier: "WalletCrytoCell")
        self.walletTableView.register(UINib(nibName: "WalletSifCell", bundle: nil), forCellReuseIdentifier: "WalletSifCell")
        self.walletTableView.register(UINib(nibName: "WalletOsmoCell", bundle: nil), forCellReuseIdentifier: "WalletOsmoCell")
        self.walletTableView.register(UINib(nibName: "WalletDesmosCell", bundle: nil), forCellReuseIdentifier: "WalletDesmosCell")
        self.walletTableView.register(UINib(nibName: "WalletDesmosEventCell", bundle: nil), forCellReuseIdentifier: "WalletDesmosEventCell")
        self.walletTableView.register(UINib(nibName: "WalletMediblocEventCell", bundle: nil), forCellReuseIdentifier: "WalletMediblocEventCell")
        self.walletTableView.register(UINib(nibName: "WalletCrescentCell", bundle: nil), forCellReuseIdentifier: "WalletCrescentCell")
        self.walletTableView.register(UINib(nibName: "WalletStationCell", bundle: nil), forCellReuseIdentifier: "WalletStationCell")
        self.walletTableView.register(UINib(nibName: "WalletBaseChainCell", bundle: nil), forCellReuseIdentifier: "WalletBaseChainCell")
        self.walletTableView.register(UINib(nibName: "WalletUnbondingInfoCellTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletUnbondingInfoCellTableViewCell")
        self.walletTableView.register(UINib(nibName: "WalletPriceCell", bundle: nil), forCellReuseIdentifier: "WalletPriceCell")
        self.walletTableView.register(UINib(nibName: "WalletInflationCell", bundle: nil), forCellReuseIdentifier: "WalletInflationCell")
        self.walletTableView.register(UINib(nibName: "WalletGuideCell", bundle: nil), forCellReuseIdentifier: "WalletGuideCell")
        self.walletTableView.rowHeight = UITableView.automaticDimension
        self.walletTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        self.refresher.tintColor = UIColor(named: "_font05")
        self.walletTableView.addSubview(refresher)
        
        #if RELEASE
        SKStoreReviewController.requestReview()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchPrice(_:)), name: Notification.Name("onFetchPrice"), object: nil)
        self.updateTitle()
        self.walletTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchPrice"), object: nil)
    }
    
    func updateTitle() {
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.titleChainImg.image = chainConfig?.chainImg
        self.titleWalletName.text = account?.getDpName()
        self.titleAlarmBtn.isHidden = !(chainConfig?.pushSupport ?? false)
        
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
        self.updateFloaty()
    }
    
    func updateFloaty() {
        let floaty = Floaty()
        floaty.buttonShadowColor = UIColor.init(named: "floating_shadow")!
        floaty.buttonImage = chainConfig?.stakeSendImg
        floaty.buttonColor = chainConfig?.stakeSendBg ?? .black
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }

    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.walletTableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.walletTableView.reloadData()
    }
    
    func emptyFloatySelected(_ floaty: Floaty) {
        self.onClickMainSend()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1;
            
        } else {
            if (chainType == .KAVA_MAIN || chainType == .DESMOS_MAIN || chainType == .MEDI_MAIN) {
                return 5;
            } else if (chainType == .BINANCE_MAIN || chainType == .OKEX_MAIN) {
                return 3;
            }
            return 4;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return onSetAddressItems(tableView, indexPath);
            
        } else {
            if (chainType == .IRIS_MAIN) {
                return onSetIrisItem(tableView, indexPath);
            } else if (chainType == .KAVA_MAIN) {
                return onSetKavaItem(tableView, indexPath);
            } else if (chainType == .BINANCE_MAIN) {
                return onSetBnbItem(tableView, indexPath);
            } else if (chainType == .OKEX_MAIN) {
                return onSetOKexItems(tableView, indexPath);
            } else if (chainType == .IOV_MAIN) {
                return onSetIovItems(tableView, indexPath);
            } else if (chainType == .CRYPTO_MAIN) {
                return onSetCrytoItems(tableView, indexPath);
            } else if (chainType == .SIF_MAIN) {
                return onSetSifItems(tableView, indexPath);
            } else if (chainType == .OSMOSIS_MAIN) {
                return onSetOsmoItems(tableView, indexPath);
            } else if (chainType == .DESMOS_MAIN) {
                return onSetDesmosItems(tableView, indexPath);
            } else if (chainType == .MEDI_MAIN) {
                return onSetMediblocItems(tableView, indexPath);
            } else if (chainType == .CRESCENT_MAIN) {
                return onSetCrescentItems(tableView, indexPath);
            } else if (chainType == .STATION_TEST) {
                return onSetStationItems(tableView, indexPath);
            }
            
            else {
                return onSetBaseChainItems(tableView, indexPath);
            }
        }
    }
    
    func onSetAddressItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
        cell?.updateView(account, chainConfig)
        cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
        return cell!
    }
    
    func onSetBaseChainItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletBaseChainCell") as? WalletBaseChainCell
            cell?.updateView(account, chainConfig)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionWC = { self.onClickWalletConect() }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetIrisItem(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletIrisCell") as? WalletIrisCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionNFT = { self.onClickNFT() }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetBnbItem(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletBnbCell") as? WalletBnbCell
            cell?.updateView(account, chainType)
            cell?.actionWC = { self.onClickWalletConect() }
            cell?.actionBep3 = { self.onClickBep3Send(BNB_MAIN_DENOM) }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetKavaItem(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletKavaCell") as? WalletKavaCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionCdp = { self.onClickCdp() }
            cell?.actionWC = { self.onClickWalletConect() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletKavaIncentiveCell") as? WalletKavaIncentiveCell
            cell?.updateView()
            cell?.actionGetIncentive = { self.onClickKavaIncentive() }
            return cell!
            
        } else if (indexPath.row == 2) {
            return onBindPriceCell(tableView)
            
        } else if (indexPath.row == 3) {
            return onBindMintingCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetIovItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletIovCell") as? WalletIovCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionNameService = { self.onClickStarName() }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetOKexItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletOkCell") as? WalletOkCell
            cell?.updateView(account, chainType)
            cell?.actionDeposit = { self.onClickOkDeposit() }
            cell?.actionWithdraw = { self.onClickOkWithdraw() }
            cell?.actionVoteforVal = { self.onClickOkVoteVal() }
            cell?.actionVote = { self.onShowToast(NSLocalizedString("error_not_yet", comment: "")) }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetCrytoItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCrytoCell") as? WalletCrytoCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionNFT = { self.onClickNFT() }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetSifItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletSifCell") as? WalletSifCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionDex = { self.onClickSifDex() }
            return cell!
            
        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)
            
        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetOsmoItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletOsmoCell") as? WalletOsmoCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionLab = { self.onClickOsmosisLab() }
            cell?.actionWc = { self.onClickWalletConect() }
            return cell!

        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)

        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)

        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetDesmosItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletDesmosCell") as? WalletDesmosCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionProfile = { self.onClickProfile() }
            return cell!

        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)

        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)

        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletDesmosEventCell") as? WalletDesmosEventCell
            cell?.actionDownload = { self.onClickDesmosEvent() }
            return cell!
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetMediblocItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletBaseChainCell") as? WalletBaseChainCell
            cell?.updateView(account, chainConfig)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionWC = { self.onClickWalletConect() }
            return cell!

        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)

        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)

        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletMediblocEventCell") as? WalletMediblocEventCell
            cell?.actionDownload = { self.onClickMediblocEvent() }
            return cell!
            
        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetCrescentItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCrescentCell") as? WalletCrescentCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionWC = { self.onClickWalletConect() }
            cell?.actionDapp = { self.onClickCrescentApp() }
            return cell!

        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)

        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)

        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onSetStationItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletStationCell") as? WalletStationCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionWC = { self.onClickWalletConect() }
            return cell!

        } else if (indexPath.row == 1) {
            return onBindPriceCell(tableView)

        } else if (indexPath.row == 2) {
            return onBindMintingCell(tableView)

        } else {
            return onBindGuideCell(tableView)
        }
    }
    
    func onBindPriceCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
        cell?.onBindCell(account, chainConfig)
        cell?.actionTapPricel = { self.onClickMarketInfo() }
        cell?.actionBuy = { self.onClickBuyCoin() }
        return cell!
    }
    
    func onBindMintingCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
        cell?.onBindCell(account, chainConfig)
        cell?.actionTapApr = { self.onClickAprHelp() }
        return cell!
    }
    
    func onBindGuideCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
        cell?.onBindCell(account, chainConfig)
        cell?.actionGuide1 = { self.onClickGuide1() }
        cell?.actionGuide2 = { self.onClickGuide2() }
        return cell!
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
    
    @IBAction func onClickAlaram(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(named: "btnAlramOff")) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.showWaittingAlert()
                        self.onToggleAlarm(self.account!) { (success) in
                            self.mainTabVC.onUpdateAccountDB()
                            self.updateTitle()
                            self.dismissAlertController()
                        }
                    }
                    
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("permission_push_title", comment: ""), message: NSLocalizedString("permission_push_msg", comment: ""), preferredStyle: .alert)
                    if #available(iOS 13.0, *) { alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
                    let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
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
                self.onToggleAlarm(self.account!) { (success) in
                    self.mainTabVC.onUpdateAccountDB()
                    self.updateTitle()
                    self.dismissAlertController()
                }
            }
        }
    }
    
    func onClickValidatorList() {
        let validatorListVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ValidatorListViewController") as! ValidatorListViewController
        validatorListVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(validatorListVC, animated: true)
    }
    
    func onClickVoteList() {
        let voteListVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "VoteListViewController") as! VoteListViewController
        voteListVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(voteListVC, animated: true)
    }
    
    func onClickWalletConect() {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        self.onStartQrCode()
    }
    
    func onClickBep3Send(_ denom: String) {
        if (!SUPPORT_BEP3_SWAP) {
            self.onShowToast(NSLocalizedString("error_bep3_swap_temporary_disable", comment: ""))
            return
        }
        
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }

        let balances = BaseData.instance.selectBalanceById(accountId: self.account!.account_id)
        if (chainType! == ChainType.BINANCE_MAIN) {
            if (WUtils.getTokenAmount(balances, BNB_MAIN_DENOM).compare(NSDecimalNumber.init(string: FEE_BINANCE_BASE)).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
                return
            }
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_HTLC_SWAP
        txVC.mHtlcDenom = denom
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickStarName() {
        let starnameListVC = UIStoryboard(name: "StarName", bundle: nil).instantiateViewController(withIdentifier: "StarNameListViewController") as! StarNameListViewController
        starnameListVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(starnameListVC, animated: true)
    }
    
    func onClickCdp() {
        let dAppVC = UIStoryboard(name: "Kava", bundle: nil).instantiateViewController(withIdentifier: "DAppsListViewController") as! DAppsListViewController
        dAppVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(dAppVC, animated: true)
    }
    
    func onClickKavaIncentive() {
        print("onClickKavaIncentive")
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        if (BaseData.instance.mIncentiveRewards?.getAllIncentives().count ?? 0 <= 0) {
            self.onShowToast(NSLocalizedString("error_no_incentive_to_claim", comment: ""))
            return
        }
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_INCENTIVE_ALL
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickOkDeposit() {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
                    self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                    return
                }
        if (WUtils.getTokenAmount(mainTabVC.mBalances, OKEX_MAIN_DENOM).compare(NSDecimalNumber(string: "0.01")).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_to_deposit", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_OK_DEPOSIT
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickOkWithdraw() {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (BaseData.instance.okDepositAmount().compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_to_withdraw", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_OK_WITHDRAW
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
        
    }
    
    //no need yet
    func onClickOkVoteValMode() {
        let okVoteTypeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if #available(iOS 13.0, *) { okVoteTypeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        okVoteTypeAlert.addAction(UIAlertAction(title: NSLocalizedString("str_vote_direct", comment: ""), style: .default, handler: { _ in
            self.onClickOkVoteVal()
        }))
        okVoteTypeAlert.addAction(UIAlertAction(title: NSLocalizedString("str_vote_agent", comment: ""), style: .default, handler: { _ in
            self.onShowToast(NSLocalizedString("prepare", comment: ""))
        }))
        self.present(okVoteTypeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            okVoteTypeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onClickOkVoteVal() {
        let okValidatorListVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "OkValidatorListViewController") as! OkValidatorListViewController
        okValidatorListVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(okValidatorListVC, animated: true)
    }
    
    func onClickOsmosisLab() {
        let osmosisDappVC = UIStoryboard(name: "Osmosis", bundle: nil).instantiateViewController(withIdentifier: "OsmosisDAppViewController") as! OsmosisDAppViewController
        osmosisDappVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(osmosisDappVC, animated: true)
    }
    
    func onClickCrescentApp() {
        let commonWcVC = CommonWCViewController(nibName: "CommonWCViewController", bundle: nil)
        commonWcVC.dappURL = "https://wc.dev.cosmostation.io"
        commonWcVC.isDapp = true
        commonWcVC.isDeepLink = false
        commonWcVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(commonWcVC, animated: true)
    }
    
    func onClickSifDex() {
        let sifDexDappVC = UIStoryboard(name: "SifChainDex", bundle: nil).instantiateViewController(withIdentifier: "SifDexDAppViewController") as! SifDexDAppViewController
        sifDexDappVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(sifDexDappVC, animated: true)
    }
    
    func onClickNFT() {
        let nftDappVC = UIStoryboard(name: "Nft", bundle: nil).instantiateViewController(withIdentifier: "NFTsDAppViewController") as! NFTsDAppViewController
        nftDappVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(nftDappVC, animated: true)
    }
    
    func onClickProfile() {
        if (BaseData.instance.mAccount_gRPC?.typeURL.contains(Desmos_Profiles_V1beta1_Profile.protoMessageName) == true) {
            let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(profileVC, animated: true)

        } else {
            if (account?.account_has_private == false) {
                self.onShowAddMenomicDialog()
                return
            }
            if (!BaseData.instance.isTxFeePayable(chainConfig)) {
                self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
            let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            txVC.mType = TASK_TYPE_DESMOS_GEN_PROFILE
            txVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(txVC, animated: true)
        }
    }
    
    func onClickDesmosEvent() {
        guard let url = URL(string: "https://dpm.desmos.network/") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onClickMediblocEvent() {
        guard let url = URL(string: "https://web.medipass.me/") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onClickAprHelp() {
        guard let param = BaseData.instance.mParam else { return }
        let msg1 = NSLocalizedString("str_apr_help_onchain_msg", comment: "") + "\n"
        let msg2 = param.getDpApr(chainType).stringValue + "%\n\n"
        let msg3 = NSLocalizedString("str_apr_help_real_msg", comment: "") + "\n"
        var msg4 = ""
        if (param.getDpRealApr(chainType) == NSDecimalNumber.zero) {
            msg4 = "N/A"
        } else {
            msg4 = param.getDpRealApr(chainType).stringValue + "%"
        }
        
        let helpAlert = UIAlertController(title: "", message: msg1 + msg2 + msg3 + msg4, preferredStyle: .alert)
        if #available(iOS 13.0, *) { helpAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        helpAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(helpAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            helpAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onClickGuide1() {
        guard let url = URL(string: self.chainConfig?.getInfoLink1() ?? "") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onClickGuide2() {
        guard let url = URL(string: self.chainConfig?.getInfoLink2() ?? "") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onClickMarketInfo() {
        guard let url = URL(string: self.chainConfig?.priceUrl ?? "") else { return }
        self.onShowSafariWeb(url)
    }
    
    func onClickBuyCoin() {
        if (self.account?.account_has_private == true) {
            self.onShowBuySelectFiat()
        } else {
            self.onShowBuyWarnNoKey()
        }
    }
    
    func onShowBuyWarnNoKey() {
        let noKeyAlert = UIAlertController(title: NSLocalizedString("buy_without_key_title", comment: ""),
                                           message: NSLocalizedString("buy_without_key_msg", comment: ""),
                                           preferredStyle: .alert)
        if #available(iOS 13.0, *) { noKeyAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        noKeyAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        }))
        noKeyAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .destructive, handler: {_ in
            self.onShowBuySelectFiat()
        }))
        self.present(noKeyAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noKeyAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onShowBuySelectFiat() {
        let selectFiatAlert = UIAlertController(title: NSLocalizedString("buy_select_fiat_title", comment: ""),
                                                message: NSLocalizedString("buy_select_fiat_msg", comment: ""),
                                                preferredStyle: .alert)
        if #available(iOS 13.0, *) { selectFiatAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        let usdAction = UIAlertAction(title: "USD", style: .default, handler: { _ in
            self.onStartMoonpaySignature("usd")
        })
        let eurAction = UIAlertAction(title: "EUR", style: .default, handler: { _ in
            self.onStartMoonpaySignature("eur")
        })
        let gbpAction = UIAlertAction(title: "GBP", style: .default, handler: { _ in
            self.onStartMoonpaySignature("gbp")
        })
        selectFiatAlert.addAction(usdAction)
        selectFiatAlert.addAction(eurAction)
        selectFiatAlert.addAction(gbpAction)
        self.present(selectFiatAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            selectFiatAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onStartMoonpaySignature(_ fiat:String) {
        var query = "?apiKey=" + MOON_PAY_PUBLICK
        if (chainType! == ChainType.COSMOS_MAIN) {
            query = query + "&currencyCode=atom"
        } else if (chainType! == ChainType.BINANCE_MAIN) {
            query = query + "&currencyCode=bnb"
        } else if (chainType! == ChainType.KAVA_MAIN) {
            query = query + "&currencyCode=kava"
        } else if (chainType! == ChainType.BAND_MAIN) {
            query = query + "&currencyCode=band"
        }
        query = query + "&walletAddress=" + self.account!.account_address + "&baseCurrencyCode=" + fiat;
        let param = ["api_key" : query] as [String : Any]
        let request = Alamofire.request(CSS_MOON_PAY, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary else {
                    self.onShowToast(NSLocalizedString("error_network_msg", comment: ""))
                    return
                }
                let result = responseData.object(forKey: "signature") as? String ?? ""
                let signauture = result.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                self.onStartMoonPay(MOON_PAY_URL + query + "&signature=" + signauture!)
                
            case .failure(let error):
                print("onStartMoonpaySignature ", error)
                self.onShowToast(NSLocalizedString("error_network_msg", comment: ""))
            }
        }
    }
    
    func onStartMoonPay(_ url: String) {
        let urlMoonpay = URL(string: url)
        if(UIApplication.shared.canOpenURL(urlMoonpay!)) {
            UIApplication.shared.open(urlMoonpay!, options: [:], completionHandler: nil)
        }
    }
    
    func onClickMainSend() {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        let mainDenom = chainConfig!.stakeDenom
        if (chainConfig?.isGrpc == true) {
            if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_available", comment: ""))
                return
            }
            if (!BaseData.instance.isTxFeePayable(chainConfig)) {
                self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
            
        } else {
            if (BaseData.instance.availableAmount(mainDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_available", comment: ""))
                return
            }
            if (!BaseData.instance.isTxFeePayable(chainConfig)) {
                self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mToSendDenom = WUtils.getMainDenom(chainConfig)
        txVC.mType = TASK_TYPE_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onStartQrCode() {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
    }
    
    func scannedAddress(result: String) {
        print("scannedAddress ", result)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
            if (self.chainType == .BINANCE_MAIN) {
                if (result.contains("wallet-bridge.binance.org")) {
                    self.wcURL = result
                    let wcAlert = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: NSLocalizedString("wc_alert_msg", comment: ""), preferredStyle: .alert)
                    if #available(iOS 13.0, *) { wcAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
                    wcAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: nil))
                    wcAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
                        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                        self.navigationItem.title = ""
                        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                        passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
                        passwordVC.resultDelegate = self
                        passwordVC.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(passwordVC, animated: false)
                    }))
                    self.present(wcAlert, animated: true) {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                        wcAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                    }
                }
                
            } else if (self.chainType == .OSMOSIS_MAIN || self.chainType == .KAVA_MAIN || self.chainType == .CRESCENT_MAIN ||
                       self.chainType == .EVMOS_MAIN || self.chainType == .STATION_TEST) {
                self.wcURL = result
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
                passwordVC.resultDelegate = self
                passwordVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(passwordVC, animated: false)
                
            }
        })
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
                if (self.chainType == .BINANCE_MAIN) {
                    let wcVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "WalletConnectViewController") as! WalletConnectViewController
                    wcVC.wcURL = self.wcURL!
                    wcVC.hidesBottomBarWhenPushed = true
                    self.navigationItem.title = ""
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
                    self.navigationController?.pushViewController(wcVC, animated: true)
                    
                } else if (self.chainType == .OSMOSIS_MAIN || self.chainType == .KAVA_MAIN || self.chainType == .CRESCENT_MAIN ||
                           self.chainType == .EVMOS_MAIN || self.chainType == .STATION_TEST) {
                    let commonWcVC = CommonWCViewController(nibName: "CommonWCViewController", bundle: nil)
                    commonWcVC.wcURL = self.wcURL!
                    commonWcVC.hidesBottomBarWhenPushed = true
                    self.navigationItem.title = ""
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
                    self.navigationController?.pushViewController(commonWcVC, animated: true)
                }
            })
        }
    }
}
