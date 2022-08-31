//
//  MainTabTokenViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 26/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import SafariServices

class MainTabTokenViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, SBCardPopupDelegate {
    
    let SECTION_NATIVE_GRPC             = 1;
    let SECTION_IBC_GRPC                = 2;
    let SECTION_BRIDGE_GRPC             = 3;
    let SECTION_TOKEN_GRPC              = 4;
    
    let SECTION_NATIVE                  = 5;
    let SECTION_ETC                     = 6;

    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleWalletName: UILabel!
    @IBOutlet weak var tokenTableView: UITableView!
    var refresher: UIRefreshControl!
    var mainTabVC: MainTabViewController!
    var mBnbTics = [String : NSMutableDictionary]()
    
    var mBalances = Array<Balance>()
    var mBalances_gRPC = Array<Coin>()
    
    var mNative_gRPC = Array<Coin>()                // section 1
    var mIbc_gRPC = Array<Coin>()                   // section 2
    var mBridged_gRPC = Array<Coin>()               // section 3
    var mToken_gRPC = Array<MintscanToken>()        // section 4
    
    var mNative = Array<Balance>()                  // section 5
    var mEtc = Array<Balance>()                     // section 6
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.tokenTableView.register(UINib(nibName: "AssetCell", bundle: nil), forCellReuseIdentifier: "AssetCell")
        self.tokenTableView.register(UINib(nibName: "AssetAddCell", bundle: nil), forCellReuseIdentifier: "AssetAddCell")
        self.tokenTableView.rowHeight = UITableView.automaticDimension
        self.tokenTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            self.tokenTableView.sectionHeaderTopPadding = 0.0
        }
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = UIColor(named: "_font05")
        tokenTableView.addSubview(refresher)
        
        self.mBalances = BaseData.instance.mBalances
        self.mBalances_gRPC = BaseData.instance.mMyBalances_gRPC
        
        self.updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchPrice(_:)), name: Notification.Name("onFetchPrice"), object: nil)
        self.updateTitle()
        self.updateView()
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
    }
    
    func updateView() {
        self.onClassifyAssets()
        self.tokenTableView.reloadData()
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.mBalances = BaseData.instance.mBalances
        self.mBalances_gRPC = BaseData.instance.mMyBalances_gRPC
        
        self.updateView()
        self.refresher.endRefreshing()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.updateView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) { return 0 }
        else if (section == SECTION_NATIVE_GRPC && mNative_gRPC.count > 0) { return 30 }
        else if (section == SECTION_IBC_GRPC && mIbc_gRPC.count > 0) { return 30 }
        else if (section == SECTION_BRIDGE_GRPC && mBridged_gRPC.count > 0) { return 30 }
        else if (section == SECTION_TOKEN_GRPC && mToken_gRPC.count > 0) { return 30 }
        
        else if (section == SECTION_NATIVE && mNative.count > 0) { return 30 }
        else if (section == SECTION_ETC && mEtc.count > 0) { return 30 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == SECTION_NATIVE_GRPC) { view.headerTitleLabel.text = "Native Coins"; view.headerCntLabel.text = String(self.mNative_gRPC.count) }
        else if (section == SECTION_IBC_GRPC) { view.headerTitleLabel.text = "IBC Coins"; view.headerCntLabel.text = String(self.mIbc_gRPC.count) }
        else if (section == SECTION_BRIDGE_GRPC) { view.headerTitleLabel.text = "Bridged Assets"; view.headerCntLabel.text = String(self.mBridged_gRPC.count) }
        else if (section == SECTION_TOKEN_GRPC) { view.headerTitleLabel.text = "Contract Tokens"; view.headerCntLabel.text = String(self.mToken_gRPC.count) }
        
        else if (section == SECTION_NATIVE) { view.headerTitleLabel.text = "Native Coins"; view.headerCntLabel.text = String(self.mNative.count) }
        else if (section == SECTION_ETC) {
            view.headerTitleLabel.text = (chainType! == ChainType.OKEX_MAIN) ? "KIP10 Coins" : "Tokens"
            view.headerCntLabel.text = String(self.mEtc.count)
        }
        else { view.headerTitleLabel.text = ""; view.headerCntLabel.text = "" }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) { return 1}
        else if (section == SECTION_NATIVE_GRPC) { return mNative_gRPC.count }
        else if (section == SECTION_IBC_GRPC) { return mIbc_gRPC.count }
        else if (section == SECTION_BRIDGE_GRPC) { return mBridged_gRPC.count }
        else if (section == SECTION_TOKEN_GRPC) {
            if (mToken_gRPC.count > 0) { return mToken_gRPC.count + 1 }
            return 0
        }
        
        else if (section == SECTION_NATIVE) { return mNative.count }
        else if (section == SECTION_ETC) { return mEtc.count }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return onSetAddressItems(tableView, indexPath);
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AssetCell") as? AssetCell
            if (indexPath.section == SECTION_NATIVE_GRPC) {
                onBindNativeCoin_gRPC(cell, mNative_gRPC[indexPath.row])
                
            } else if (indexPath.section == SECTION_IBC_GRPC) {
                onBindIbcCoin_gRPC(cell, mIbc_gRPC[indexPath.row])
                
            } else if (indexPath.section == SECTION_BRIDGE_GRPC) {
                onBindBridgedAsset_gRPC(cell, mBridged_gRPC[indexPath.row])
                
            } else if (indexPath.section == SECTION_TOKEN_GRPC) {
                if (indexPath.row == mToken_gRPC.count) {
                    let addCell = tableView.dequeueReusableCell(withIdentifier:"AssetAddCell") as? AssetAddCell
                    return addCell!
                }
                onBindToken_gRPC(cell, mToken_gRPC[indexPath.row])
            }
            
            else if (indexPath.section == SECTION_NATIVE) {
                onBindNativeCoin(cell, mNative[indexPath.row])
                
            } else if (indexPath.section == SECTION_ETC) {
                onBindEtcToken(cell, mEtc[indexPath.row])
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == SECTION_NATIVE_GRPC) {
            if (mNative_gRPC[indexPath.row].denom == WUtils.getMainDenom(chainConfig)) {
                let sTokenDetailVC = StakingTokenGrpcViewController(nibName: "StakingTokenGrpcViewController", bundle: nil)
                sTokenDetailVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(sTokenDetailVC, animated: true)
            } else {
                let nTokenDetailVC = NativeTokenGrpcViewController(nibName: "NativeTokenGrpcViewController", bundle: nil)
                nTokenDetailVC.nativeDenom = mNative_gRPC[indexPath.row].denom
                nTokenDetailVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            }

        } else if (indexPath.section == SECTION_TOKEN_GRPC && indexPath.row == mToken_gRPC.count) {
            let popupVC = MultiSelectPopupViewController(nibName: "MultiSelectPopupViewController", bundle: nil)
            popupVC.type = SELECT_POPUP_CONTRACT_TOKEN_EDIT
            let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
            cardPopup.resultDelegate = self
            cardPopup.show(onViewController: self)
            
        } else {
            //TODO display transfer UI!!!
            
        }
        
        
//        else if (indexPath.section == SECTION_IBC_GRPC) {
//            let iTokenDetailVC = IBCTokenGrpcViewController(nibName: "IBCTokenGrpcViewController", bundle: nil)
//            iTokenDetailVC.ibcDenom = mIbc_gRPC[indexPath.row].denom
//            iTokenDetailVC.hidesBottomBarWhenPushed = true
//            self.navigationItem.title = ""
//            self.navigationController?.pushViewController(iTokenDetailVC, animated: true)
//
//        } else if (indexPath.section == SECTION_BRIDGE_GRPC) {
////            let bTokenDetailVC = BridgeTokenGrpcViewController(nibName: "BridgeTokenGrpcViewController", bundle: nil)
////            bTokenDetailVC.hidesBottomBarWhenPushed = true
////            bTokenDetailVC.bridgeDenom = mBridged_gRPC[indexPath.row].denom
////            self.navigationItem.title = ""
////            self.navigationController?.pushViewController(bTokenDetailVC, animated: true)
//
//        }
////        else if (indexPath.section == SECTION_KAVA_BEP2_GRPC) {
////            let nTokenDetailVC = NativeTokenGrpcViewController(nibName: "NativeTokenGrpcViewController", bundle: nil)
////            nTokenDetailVC.nativeDenom = mKavaBep2_gRPC[indexPath.row].denom
////            nTokenDetailVC.hidesBottomBarWhenPushed = true
////            self.navigationItem.title = ""
////            self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
////
////        }
//        else if (indexPath.section == SECTION_TOKEN_GRPC) {
////            let cTokenDetailVC = ContractTokenGrpcViewController(nibName: "ContractTokenGrpcViewController", bundle: nil)
////            cTokenDetailVC.mCw20Token = mToken_gRPC[indexPath.row]
////            cTokenDetailVC.hidesBottomBarWhenPushed = true
////            self.navigationItem.title = ""
////            self.navigationController?.pushViewController(cTokenDetailVC, animated: true)
//            if (indexPath.row == mToken_gRPC.count) {
//                let popupVC = MultiSelectPopupViewController(nibName: "MultiSelectPopupViewController", bundle: nil)
//                popupVC.type = SELECT_POPUP_CONTRACT_TOKEN_EDIT
//                let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
//                cardPopup.resultDelegate = self
//                cardPopup.show(onViewController: self)
//                return
//            }
//
//        }
//
//        else if (indexPath.section == SECTION_NATIVE) {
//            let sTokenDetailVC = StakingTokenDetailViewController(nibName: "StakingTokenDetailViewController", bundle: nil)
//            sTokenDetailVC.hidesBottomBarWhenPushed = true
//            self.navigationItem.title = ""
//            self.navigationController?.pushViewController(sTokenDetailVC, animated: true)
//
//        } else if (indexPath.section == SECTION_ETC) {
//            if (chainType == .BINANCE_MAIN || chainType == .OKEX_MAIN) {
//                let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
//                nTokenDetailVC.hidesBottomBarWhenPushed = true
//                nTokenDetailVC.denom = mEtc[indexPath.row].balance_denom
//                self.navigationItem.title = ""
//                self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
//            }
//
//        }
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_CONTRACT_TOKEN_EDIT && result == 1) {
            onRequestFetch()
        }
    }
    
    func onSetAddressItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
        cell?.updateView(account, chainConfig)
        cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
        return cell!
    }
    
    //bind native coins with grpc
    func onBindNativeCoin_gRPC(_ cell: AssetCell?, _ coin: Coin) {
        if let msAsset = BaseData.instance.getMSAsset(chainConfig!, coin.denom) {
            cell?.onBindNativeAsset(chainConfig, msAsset, coin)
        }
    }
    
    //bind ibc coins with grpc
    func onBindIbcCoin_gRPC(_ cell: AssetCell?, _ coin: Coin) {
        if let msAsset = BaseData.instance.getMSAsset(chainConfig!, coin.denom) {
            cell?.onBindIbcAsset(chainConfig, msAsset, coin)
        }
    }
    
    //bind bridged tokens with grpc (Bep2, SifChain, G-bridge, Injective)
    func onBindBridgedAsset_gRPC(_ cell: AssetCell?, _ coin: Coin) {
        if let msAsset = BaseData.instance.getMSAsset(chainConfig!, coin.denom) {
            cell?.onBindBridgeAsset(chainConfig, msAsset, coin)
        }
    }
    
    //bind contract tokens
    func onBindToken_gRPC(_ cell: AssetCell?, _ token: MintscanToken) {
        cell?.onBindContractToken(chainConfig, token)
    }
    
    
    //bind native tokens
    func onBindNativeCoin(_ cell: AssetCell?, _ balance: Balance) {
        cell?.onBindStakingCoin(chainConfig, balance)
    }
    
    //bind Etc tokens (binance, okex)
    func onBindEtcToken(_ cell: AssetCell?, _ balance: Balance) {
        cell?.onBindEtcCoin(chainConfig, balance)
    }
    
    func onClassifyAssets() {
        mNative_gRPC.removeAll()
        mIbc_gRPC.removeAll()
        mBridged_gRPC.removeAll()
        
        self.mBalances_gRPC.forEach { balance_gRPC in
            let coinType = BaseData.instance.getMSAsset(chainConfig!, balance_gRPC.denom)?.type
            if (coinType == "staking" || coinType == "native") {
                mNative_gRPC.append(balance_gRPC)
            } else if (coinType == "bep" || coinType == "bridge") {
                mBridged_gRPC.append(balance_gRPC)
            } else if (coinType == "ibc") {
                mIbc_gRPC.append(balance_gRPC)
            }
        }
        mToken_gRPC = BaseData.instance.mMyTokens
        
        
        mNative.removeAll()
        mEtc.removeAll()
        self.mBalances.forEach { balance in
            if (WUtils.getMainDenom(chainConfig) == balance.balance_denom) {
                mNative.append(balance)
            } else {
                mEtc.append(balance)
            }
        }
        
        mNative_gRPC.sort {
            if ($0.denom == WUtils.getMainDenom(chainConfig)) { return true }
            if ($1.denom == WUtils.getMainDenom(chainConfig)) { return false }
            if (chainType == .KAVA_MAIN) {
                if ($0.denom == KAVA_HARD_DENOM) { return true }
                if ($1.denom == KAVA_HARD_DENOM) { return false }
                if ($0.denom == KAVA_SWAP_DENOM) { return true }
                if ($1.denom == KAVA_SWAP_DENOM) { return false }
            }
            return false
        }
        mNative.sort {
            if ($0.balance_denom == WUtils.getMainDenom(chainConfig)) { return true }
            if ($1.balance_denom == WUtils.getMainDenom(chainConfig)) { return false }
            
            return false
        }
        mEtc.sort {
            if (chainType == ChainType.OKEX_MAIN) {
                if ($0.balance_denom == "okb-c4d") { return true }
                if ($1.balance_denom == "okb-c4d") { return false }
            }
            return false
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
