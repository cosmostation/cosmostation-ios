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

class MainTabTokenViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let SECTION_NATIVE_GRPC             = 0;
    let SECTION_IBC_AUTHED_GRPC         = 1;
    let SECTION_BRIDGE_GRPC             = 2;
    let SECTION_KAVA_BEP2_GRPC          = 3;
    let SECTION_CW20_GRPC               = 4;
    let SECTION_POOL_TOKEN_GRPC         = 5;
    let SECTION_ETC_GRPC                = 6;
    let SECTION_IBC_UNKNOWN_GRPC        = 7;
    let SECTION_UNKNOWN_GRPC            = 8;
    
    let SECTION_NATIVE                  = 9;
    let SECTION_ETC                     = 10;
    let SECTION_UNKNOWN                 = 11;
    

    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleWalletName: UILabel!
    @IBOutlet weak var titleAlarmBtn: UIButton!
    @IBOutlet weak var titleChainName: UILabel!
    
    @IBOutlet weak var totalCard: CardView!
    @IBOutlet weak var totalKeyState: UIImageView!
    @IBOutlet weak var totalDpAddress: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var totalBtcValue: UILabel!
    
    @IBOutlet weak var tokenTableView: UITableView!
    var refresher: UIRefreshControl!
    var mainTabVC: MainTabViewController!
    var mBnbTics = [String : NSMutableDictionary]()
    
    var mBalances = Array<Balance>()
    var mBalances_gRPC = Array<Coin>()
    
    var mNative_gRPC = Array<Coin>()                // section 0
    var mIbcAuthed_gRPC = Array<Coin>()             // section 1
    var mBridged_gRPC = Array<Coin>()               // section 2
    var mKavaBep2_gRPC = Array<Coin>()              // section 3
    var mCW20_gRPC = Array<Cw20Token>()             // section 4
    var mPoolToken_gRPC = Array<Coin>()             // section 5
    var mEtc_gRPC = Array<Coin>()                   // section 6
    var mIbcUnknown_gRPC = Array<Coin>()            // section 7
    var mUnKnown_gRPC = Array<Coin>()               // section 8
    
    var mNative = Array<Balance>()                  // section 9
    var mEtc = Array<Balance>()                     // section 10
    var mUnKnown = Array<Balance>()                 // section 11
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory().getChainConfig(chainType)
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "TokenCell", bundle: nil), forCellReuseIdentifier: "TokenCell")
        self.tokenTableView.rowHeight = UITableView.automaticDimension
        self.tokenTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            self.tokenTableView.sectionHeaderTopPadding = 0.0
        }
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = UIColor.white
        tokenTableView.addSubview(refresher)
        
        self.mBalances = BaseData.instance.mBalances
        self.mBalances_gRPC = BaseData.instance.mMyBalances_gRPC
        self.mCW20_gRPC = BaseData.instance.getCw20s_gRPC()
        
        let tapTotalCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickActionShare))
        self.totalCard.addGestureRecognizer(tapTotalCard)
        
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
    
    func updateView() {
        self.onClassifyTokens()
        self.tokenTableView.reloadData()
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.mBalances = BaseData.instance.mBalances
        self.mBalances_gRPC = BaseData.instance.mMyBalances_gRPC
        self.mCW20_gRPC = BaseData.instance.getCw20s_gRPC()
        
        self.updateView()
        self.refresher.endRefreshing()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.updateView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == SECTION_NATIVE_GRPC && mNative_gRPC.count == 0) { return 0 }
        else if (section == SECTION_IBC_AUTHED_GRPC && mIbcAuthed_gRPC.count == 0) { return 0 }
        else if (section == SECTION_BRIDGE_GRPC && mBridged_gRPC.count == 0) { return 0 }
        else if (section == SECTION_KAVA_BEP2_GRPC && mKavaBep2_gRPC.count == 0) { return 0 }
        else if (section == SECTION_CW20_GRPC && mCW20_gRPC.count == 0) { return 0 }
        else if (section == SECTION_POOL_TOKEN_GRPC && mPoolToken_gRPC.count == 0) { return 0 }
        else if (section == SECTION_ETC_GRPC && mEtc_gRPC.count == 0) { return 0 }
        else if (section == SECTION_IBC_UNKNOWN_GRPC && mIbcUnknown_gRPC.count == 0) { return 0 }
        else if (section == SECTION_UNKNOWN_GRPC && mUnKnown_gRPC.count == 0) { return 0 }
        
        else if (section == SECTION_NATIVE && mNative.count == 0) { return 0 }
        else if (section == SECTION_ETC && mEtc.count == 0) { return 0 }
        else if (section == SECTION_UNKNOWN && mUnKnown.count == 0) { return 0 }
        else { return 30 }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == SECTION_NATIVE_GRPC) { view.headerTitleLabel.text = "Native Coins"; view.headerCntLabel.text = String(self.mNative_gRPC.count) }
        else if (section == SECTION_IBC_AUTHED_GRPC) { view.headerTitleLabel.text = "IBC Coins"; view.headerCntLabel.text = String(self.mIbcAuthed_gRPC.count) }
        else if (section == SECTION_BRIDGE_GRPC) { view.headerTitleLabel.text = "Ether Bridged Assets"; view.headerCntLabel.text = String(self.mBridged_gRPC.count) }
        else if (section == SECTION_KAVA_BEP2_GRPC) { view.headerTitleLabel.text = "BEP2 Coins"; view.headerCntLabel.text = String(self.mKavaBep2_gRPC.count) }
        else if (section == SECTION_CW20_GRPC) { view.headerTitleLabel.text = "CW20 Tokens"; view.headerCntLabel.text = String(self.mCW20_gRPC.count) }
        else if (section == SECTION_POOL_TOKEN_GRPC) { view.headerTitleLabel.text = "Pool Coins"; view.headerCntLabel.text = String(self.mPoolToken_gRPC.count) }
        else if (section == SECTION_ETC_GRPC) { view.headerTitleLabel.text = "Etc Coins"; view.headerCntLabel.text = String(self.mEtc_gRPC.count) }
        else if (section == SECTION_IBC_UNKNOWN_GRPC) { view.headerTitleLabel.text = "Unknown IBC Coins"; view.headerCntLabel.text = String(self.mIbcUnknown_gRPC.count) }
        else if (section == SECTION_UNKNOWN_GRPC) { view.headerTitleLabel.text = "Unknown Coins"; view.headerCntLabel.text = String(self.mUnKnown_gRPC.count) }
        
        else if (section == SECTION_NATIVE) { view.headerTitleLabel.text = "Native Coins"; view.headerCntLabel.text = String(self.mNative.count) }
        else if (section == SECTION_ETC) {
            view.headerTitleLabel.text = (chainType! == ChainType.OKEX_MAIN) ? "KIP10 Coins" : "Etc Coins"
            view.headerCntLabel.text = String(self.mEtc.count)
        }
        else if (section == SECTION_UNKNOWN) { view.headerTitleLabel.text = "Unknown Coins"; view.headerCntLabel.text = String(self.mUnKnown.count) }
        else { view.headerTitleLabel.text = ""; view.headerCntLabel.text = "0" }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == SECTION_NATIVE_GRPC) { return mNative_gRPC.count }
        else if (section == SECTION_IBC_AUTHED_GRPC) { return mIbcAuthed_gRPC.count }
        else if (section == SECTION_BRIDGE_GRPC) { return mBridged_gRPC.count }
        else if (section == SECTION_KAVA_BEP2_GRPC) { return mKavaBep2_gRPC.count }
        else if (section == SECTION_CW20_GRPC) { return mCW20_gRPC.count }
        else if (section == SECTION_POOL_TOKEN_GRPC) { return mPoolToken_gRPC.count }
        else if (section == SECTION_ETC_GRPC) { return mEtc_gRPC.count }
        else if (section == SECTION_IBC_UNKNOWN_GRPC) { return mIbcUnknown_gRPC.count }
        else if (section == SECTION_UNKNOWN_GRPC) { return mUnKnown_gRPC.count }
        
        else if (section == SECTION_NATIVE) { return mNative.count }
        else if (section == SECTION_ETC) { return mEtc.count }
        else if (section == SECTION_UNKNOWN) { return mUnKnown.count }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"TokenCell") as? TokenCell
        if (indexPath.section == SECTION_NATIVE_GRPC) {
            onBindNativeToken_gRPC(cell, mNative_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_IBC_AUTHED_GRPC) {
            onBindIbcToken_gRPC(cell, mIbcAuthed_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_BRIDGE_GRPC) {
            onBindEthBridgeToken_gRPC(cell, mBridged_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_KAVA_BEP2_GRPC) {
            onBindKavaBep2Token_gRPC(cell, mKavaBep2_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_CW20_GRPC) {
            onBindCw20Token_gRPC(cell, mCW20_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_POOL_TOKEN_GRPC) {
            onBindPoolToken_gRPC(cell, mPoolToken_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_ETC_GRPC) {
            onBindEtcToken_gRPC(cell, mEtc_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_IBC_UNKNOWN_GRPC) {
            onBindIbcToken_gRPC(cell, mIbcUnknown_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_UNKNOWN_GRPC) {
            cell?.tokenSymbol.text = mUnKnown_gRPC[indexPath.row].denom.uppercased()
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(mUnKnown_gRPC[indexPath.row].amount, cell!.tokenAmount.font, 6, 6)
        }
        
        
        
        else if (indexPath.section == SECTION_NATIVE) {
            onBindNativeToken(cell, mNative[indexPath.row])
            
        } else if (indexPath.section == SECTION_ETC) {
            onBindEtcToken(cell, mEtc[indexPath.row])
            
        } else if (indexPath.section == SECTION_UNKNOWN) {
            cell?.tokenSymbol.text = mUnKnown[indexPath.row].balance_denom.uppercased()
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == SECTION_NATIVE_GRPC) {
            if (mNative_gRPC[indexPath.row].denom == WUtils.getMainDenom(chainType)) {
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

        } else if (indexPath.section == SECTION_IBC_AUTHED_GRPC) {
            let iTokenDetailVC = IBCTokenGrpcViewController(nibName: "IBCTokenGrpcViewController", bundle: nil)
            iTokenDetailVC.ibcDenom = mIbcAuthed_gRPC[indexPath.row].denom
            iTokenDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(iTokenDetailVC, animated: true)

        } else if (indexPath.section == SECTION_IBC_UNKNOWN_GRPC) {
            let iTokenDetailVC = IBCTokenGrpcViewController(nibName: "IBCTokenGrpcViewController", bundle: nil)
            iTokenDetailVC.ibcDenom = mIbcUnknown_gRPC[indexPath.row].denom
            iTokenDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(iTokenDetailVC, animated: true)

        } else if (indexPath.section == SECTION_POOL_TOKEN_GRPC) {
            let pTokenDetailVC = PoolTokenGrpcViewController(nibName: "PoolTokenGrpcViewController", bundle: nil)
            pTokenDetailVC.poolDenom = mPoolToken_gRPC[indexPath.row].denom
            pTokenDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(pTokenDetailVC, animated: true)

        } else if (indexPath.section == SECTION_BRIDGE_GRPC) {
            let bTokenDetailVC = BridgeTokenGrpcViewController(nibName: "BridgeTokenGrpcViewController", bundle: nil)
            bTokenDetailVC.hidesBottomBarWhenPushed = true
            bTokenDetailVC.bridgeDenom = mBridged_gRPC[indexPath.row].denom
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(bTokenDetailVC, animated: true)

        } else if (indexPath.section == SECTION_KAVA_BEP2_GRPC) {
            let nTokenDetailVC = NativeTokenGrpcViewController(nibName: "NativeTokenGrpcViewController", bundle: nil)
            nTokenDetailVC.nativeDenom = mKavaBep2_gRPC[indexPath.row].denom
            nTokenDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            
        } else if (indexPath.section == SECTION_CW20_GRPC) {
            let cTokenDetailVC = ContractTokenGrpcViewController(nibName: "ContractTokenGrpcViewController", bundle: nil)
            cTokenDetailVC.mCw20Token = mCW20_gRPC[indexPath.row]
            cTokenDetailVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(cTokenDetailVC, animated: true)
            
        } else if (indexPath.section == SECTION_ETC_GRPC) {
            return
            
        } else if (indexPath.section == SECTION_UNKNOWN_GRPC) {
            return
        }

        else if (indexPath.section == SECTION_NATIVE) {
            if (mNative[indexPath.row].balance_denom == WUtils.getMainDenom(chainType)) {
                let sTokenDetailVC = StakingTokenDetailViewController(nibName: "StakingTokenDetailViewController", bundle: nil)
                sTokenDetailVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(sTokenDetailVC, animated: true)

            } else {
                let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
                nTokenDetailVC.hidesBottomBarWhenPushed = true
                nTokenDetailVC.denom = mNative[indexPath.row].balance_denom
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            }

        } else if (indexPath.section == SECTION_ETC) {
            if (chainType == .BINANCE_MAIN || chainType == .OKEX_MAIN) {
                let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
                nTokenDetailVC.hidesBottomBarWhenPushed = true
                nTokenDetailVC.denom = mEtc[indexPath.row].balance_denom
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            }

        } else if (indexPath.section == SECTION_UNKNOWN) {
            return
        }
    }
    
    //bind native tokens with grpc
    func onBindNativeToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        if (coin.denom == OSMOSIS_ION_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenIon")
            cell?.tokenSymbol.text = "ION"
            cell?.tokenSymbol.textColor = UIColor(named: "osmosis_ion")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "Ion Coin"
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OSMOSIS_ION_DENOM, BaseData.instance.getAvailableAmount_gRPC(OSMOSIS_ION_DENOM), 6, cell!.tokenValue.font)

        } else if (coin.denom == EMONEY_EUR_DENOM || coin.denom == EMONEY_CHF_DENOM || coin.denom == EMONEY_DKK_DENOM ||
                    coin.denom == EMONEY_NOK_DENOM || coin.denom == EMONEY_SEK_DENOM) {
            cell?.tokenImg.af_setImage(withURL: URL(string: EMONEY_COIN_IMG_URL + coin.denom + ".png")!)
            cell?.tokenSymbol.text = coin.denom.uppercased()
            cell?.tokenSymbol.textColor = UIColor(named: "_font05")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = coin.denom.substring(from: 1).uppercased() + " on E-Money Network"

            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, BaseData.instance.getAvailableAmount_gRPC(coin.denom), 6, cell!.tokenValue.font)

        } else if (coin.denom == KAVA_HARD_DENOM) {
            cell?.tokenImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(KAVA_HARD_DENOM))!)
            cell?.tokenSymbol.text = "HARD"
            cell?.tokenSymbol.textColor = UIColor(named: "kava_hard")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "HardPool Gov. Coin"

            let totalTokenAmount = WUtils.getKavaTokenAll(coin.denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_HARD_DENOM, totalTokenAmount, 6, cell!.tokenValue.font)

        } else if (coin.denom == KAVA_USDX_DENOM) {
            cell?.tokenImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(KAVA_USDX_DENOM))!)
            cell?.tokenSymbol.text = KAVA_USDX_DENOM.uppercased()
            cell?.tokenSymbol.textColor = UIColor(named: "kava_usdx")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "USDX Stable Asset"

            let totalTokenAmount = WUtils.getKavaTokenAll(coin.denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_USDX_DENOM, totalTokenAmount, 6, cell!.tokenValue.font)

        } else if (coin.denom == KAVA_SWAP_DENOM) {
            cell?.tokenImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(KAVA_SWAP_DENOM))!)
            cell?.tokenSymbol.text = KAVA_SWAP_DENOM.uppercased()
            cell?.tokenSymbol.textColor = UIColor(named: "kava_swp")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "Kava Swap Coin"

            let totalTokenAmount = WUtils.getKavaTokenAll(coin.denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_SWAP_DENOM, totalTokenAmount, 6, cell!.tokenValue.font)

        } else if (coin.denom == CRESCENT_BCRE_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenBcre")
            cell?.tokenSymbol.text = "BCRE"
            cell?.tokenSymbol.textColor = UIColor(named: "crescent_bcre")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "Liquidated CRE"

            let allBCre = NSDecimalNumber.init(string: coin.amount)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allBCre.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(CRESCENT_BCRE_DENOM, allBCre, 6, cell!.tokenValue.font)

        } else if (coin.denom == NYX_NYM_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenNym")
            cell?.tokenSymbol.text = "NYM"
            cell?.tokenSymbol.textColor = UIColor(named: "nyx_nym")
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "Nym Coin"

            let allNym = NSDecimalNumber.init(string: coin.amount)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allNym.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(NYX_NYM_DENOM, allNym, 6, cell!.tokenValue.font)

        } else {
            let divideDecimal = WUtils.mainDivideDecimal(chainType)
            if (coin.denom == chainConfig?.stakeDenom) {
                cell?.tokenImg.image = chainConfig?.stakeDenomImg
                cell?.tokenSymbol.text = chainConfig?.stakeSymbol
                cell?.tokenSymbol.textColor = chainConfig?.chainColor
                cell?.tokenTitle.text = ""
                cell?.tokenDescription.text = (chainConfig?.chainAPIName.capitalizingFirstLetter() ?? "Base") + " Staking Coin"
                
                let allStakingCoin = WUtils.getAllMainAsset(coin.denom)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(allStakingCoin.stringValue, cell!.tokenAmount.font, divideDecimal, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, allStakingCoin, divideDecimal, cell!.tokenValue.font)
            }
        }
    }
    
    //bind ibc tokens with grpc
    func onBindIbcToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.tokenSymbol.textColor = UIColor(named: "_font05")
        guard let ibcToken = BaseData.instance.getIbcToken(coin.getIbcHash()) else {
            cell?.tokenImg.image = UIImage(named: "tokenDefaultIbc")
            cell?.tokenSymbol.text = "UnKnown"
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = ""
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 6, cell!.tokenValue.font)
            return
        }
        if (ibcToken.auth == true) {
            cell?.tokenImg.af_setImage(withURL: URL(string: ibcToken.moniker!)!)
            cell?.tokenSymbol.text = ibcToken.display_denom?.uppercased()
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = ibcToken.channel_id
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, ibcToken.decimal!, 6)
            let basedenom = BaseData.instance.getBaseDenom(coin.denom)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(basedenom, NSDecimalNumber.init(string: coin.amount), ibcToken.decimal!, cell!.tokenValue.font)
            
        } else {
            cell?.tokenImg.image = UIImage(named: "tokenDefaultIbc")
            cell?.tokenSymbol.text = "UnKnown"
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = ibcToken.channel_id
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 6, cell!.tokenValue.font)
        }
    }
    
    //bind Pool tokens with grpc
    func onBindPoolToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.tokenSymbol.textColor = UIColor(named: "_font05")
        if (chainType == .OSMOSIS_MAIN) {
            cell?.tokenImg.image = UIImage(named: "tokenPool")
            cell?.tokenSymbol.text = coin.isOsmosisAmmDpDenom()
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = coin.denom
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 18, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 18, cell!.tokenValue.font)
            
        } else if (chainType == .COSMOS_MAIN) {
            cell?.tokenImg.image = UIImage(named: "tokenGravitydex")
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 6, cell!.tokenValue.font)
            guard let poolInfo = BaseData.instance.getGravityPoolByDenom(coin.denom) else {
                return
            }
            cell?.tokenSymbol.text = "GDEX-" + String(poolInfo.id)
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "pool/" + String(poolInfo.id)
            
        } else if (chainType == .INJECTIVE_MAIN) {
            cell?.tokenImg.image = UIImage(named: "tokenIc")
            cell?.tokenSymbol.text = coin.denom.uppercased()
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "Pool Asset"
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 18, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 18, cell!.tokenValue.font)
            
        } else if (chainType == .CRESCENT_MAIN) {
            cell?.tokenImg.image = UIImage(named: "tokenCrescentpool")
            cell?.tokenSymbol.text = coin.denom.uppercased()
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = "Pool Asset"
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 12, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 12, cell!.tokenValue.font)
            
        }
    }
    
    //bind Eth bridged tokens with grpc (SifChain, G-bridge, Injective)
    func onBindEthBridgeToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.onBindBridgeToken(self.chainType!, coin)
    }
    
    //bind kava bep2 tokens with grpc
    func onBindKavaBep2Token_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.tokenImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(coin.denom))!)
        cell?.tokenSymbol.text = coin.denom.uppercased()
        cell?.tokenSymbol.textColor = UIColor(named: "_font05")
        cell?.tokenTitle.text = ""
        cell?.tokenDescription.text = coin.denom.uppercased() + " on Kava Chain"

        let baseDenom = WUtils.getKavaBaseDenom(coin.denom)
        let decimal = WUtils.getKavaCoinDecimal(coin.denom)
        let totalTokenAmount = WUtils.getKavaTokenAll(coin.denom)
        cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, WUtils.getKavaCoinDecimal(coin.denom), 6)
        cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(baseDenom, totalTokenAmount, decimal, cell!.tokenValue.font)
    }
    
    //bind cw20 tokens
    func onBindCw20Token_gRPC(_ cell: TokenCell?, _ token: Cw20Token) {
        cell?.tokenImg.af_setImage(withURL: token.getImgUrl())
        cell?.tokenSymbol.text = token.denom.uppercased()
        cell?.tokenSymbol.textColor = UIColor(named: "_font05")
        cell?.tokenTitle.text = ""
        cell?.tokenDescription.text = token.contract_address
        
        let decimal = token.decimal
        cell?.tokenAmount.attributedText = WUtils.displayAmount2(token.amount, cell!.tokenAmount.font!, decimal, 6)
        cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(token.denom, token.getAmount(), decimal, cell!.tokenValue.font)
    }
    
    //bind etc tokens with grpc
    func onBindEtcToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        //bind "btch" for kava
        if (chainType == .KAVA_MAIN || coin.denom == "btch") {
            cell?.tokenImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(coin.denom))!)
            cell?.tokenSymbol.text = coin.denom.uppercased()
            cell?.tokenSymbol.textColor = UIColor(named: "_font05")
            cell?.tokenDescription.text = coin.denom.uppercased() + " on Kava Chain"

            let baseDenom = WUtils.getKavaBaseDenom(coin.denom)
            let decimal = WUtils.getKavaCoinDecimal(coin.denom)
            let totalTokenAmount = WUtils.getKavaTokenAll(coin.denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, WUtils.getKavaCoinDecimal(coin.denom), 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(baseDenom, totalTokenAmount, decimal, cell!.tokenValue.font)
        }
        
    }
    
    
    //bind native tokens
    func onBindNativeToken(_ cell: TokenCell?, _ balance: Balance) {
        if (balance.balance_denom == BNB_MAIN_DENOM) {
            if let bnbToken = WUtils.getBnbToken(BNB_MAIN_DENOM) {
                cell?.tokenImg.image = UIImage(named: "tokenBinance")
                cell?.tokenSymbol.text = bnbToken.original_symbol.uppercased()
                cell?.tokenSymbol.textColor = UIColor(named: "binance")
                cell?.tokenTitle.text = "(" + bnbToken.symbol + ")"
                cell?.tokenDescription.text = bnbToken.name
                
                let amount = WUtils.getAllBnbToken(BNB_MAIN_DENOM)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(amount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(BNB_MAIN_DENOM, amount, 0, cell!.tokenValue.font)
            }
            
        } else if (balance.balance_denom == OKEX_MAIN_DENOM) {
            if let okToken = WUtils.getOkToken(OKEX_MAIN_DENOM) {
                cell?.tokenImg.image = UIImage(named: "tokenOkc")
                cell?.tokenSymbol.text = okToken.original_symbol!.uppercased()
                cell?.tokenSymbol.textColor = UIColor(named: "okc")
                cell?.tokenTitle.text = "(" + okToken.symbol! + ")"
                cell?.tokenDescription.text = "OKC Staking Coin"
                
                let tokenAmount = WUtils.getAllExToken(OKEX_MAIN_DENOM)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(tokenAmount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OKEX_MAIN_DENOM, tokenAmount, 0, cell!.tokenValue.font)
            }
            
        }
    }
    
    //bind Etc tokens (binance, okex)
    func onBindEtcToken(_ cell: TokenCell?, _ balance: Balance) {
        if (chainType == .BINANCE_MAIN) {
            if let bnbToken = WUtils.getBnbToken(balance.balance_denom) {
                cell?.tokenImg.af_setImage(withURL: URL(string: BINANCE_TOKEN_IMG_URL + bnbToken.original_symbol + ".png")!)
                cell?.tokenSymbol.text = bnbToken.original_symbol.uppercased()
                cell?.tokenSymbol.textColor = .white
                cell?.tokenTitle.text = "(" + bnbToken.symbol + ")"
                cell?.tokenDescription.text = bnbToken.name
                
                let tokenAmount = WUtils.getAllBnbToken(balance.balance_denom)
                let convertAmount = WUtils.getBnbConvertAmount(balance.balance_denom)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(tokenAmount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(BNB_MAIN_DENOM, convertAmount, 0, cell!.tokenValue.font)
            }
            
        }  else if (chainType == .OKEX_MAIN) {
            if let okToken = WUtils.getOkToken(balance.balance_denom) {
                cell?.tokenImg.af_setImage(withURL: URL(string: OKEX_COIN_IMG_URL + okToken.original_symbol! + ".png")!)
                cell?.tokenSymbol.text = okToken.original_symbol?.uppercased()
                cell?.tokenSymbol.textColor = .white
                cell?.tokenTitle.text = "(" + okToken.symbol! + ")"
                cell?.tokenDescription.text = okToken.description
                
                let tokenAmount = WUtils.getAllExToken(balance.balance_denom)
                let convertedAmount = WUtils.convertTokenToOkt(balance.balance_denom)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(tokenAmount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OKEX_MAIN_DENOM, convertedAmount, 0, cell!.tokenValue.font)
            }
        }
        
    }
    
    
    func onClassifyTokens() {
        mNative_gRPC.removeAll()
        mIbcAuthed_gRPC.removeAll()
        mPoolToken_gRPC.removeAll()
        mBridged_gRPC.removeAll()
        mKavaBep2_gRPC.removeAll()
        mEtc_gRPC.removeAll()
        mIbcUnknown_gRPC.removeAll()
        mUnKnown_gRPC.removeAll()
        
        self.mBalances_gRPC.forEach { balance_gRPC in
            if (WUtils.getMainDenom(chainType) == balance_gRPC.denom) {
                mNative_gRPC.append(balance_gRPC)
                
            } else if (balance_gRPC.isIbc()) {
                guard let ibcToken = BaseData.instance.getIbcToken(balance_gRPC.getIbcHash()) else {
                    mIbcUnknown_gRPC.append(balance_gRPC)
                    return
                }
                if (ibcToken.auth == true) { mIbcAuthed_gRPC.append(balance_gRPC) }
                else { mIbcUnknown_gRPC.append(balance_gRPC) }
                
            } else if (chainType == .OSMOSIS_MAIN) {
                if (balance_gRPC.denom == OSMOSIS_ION_DENOM) {
                    mNative_gRPC.append(balance_gRPC)
                } else if (balance_gRPC.isOsmosisAmm()) {
                    mPoolToken_gRPC.append(balance_gRPC)
                }
                
            } else if (chainType == .EMONEY_MAIN) {
                if (balance_gRPC.denom == EMONEY_EUR_DENOM || balance_gRPC.denom == EMONEY_CHF_DENOM || balance_gRPC.denom == EMONEY_DKK_DENOM ||
                        balance_gRPC.denom == EMONEY_NOK_DENOM || balance_gRPC.denom == EMONEY_SEK_DENOM) {
                    mNative_gRPC.append(balance_gRPC)
                }
            
            } else if (chainType == .COSMOS_MAIN && balance_gRPC.isPoolToken()) {
                mPoolToken_gRPC.append(balance_gRPC)
                
            } else if (chainType == .SIF_MAIN && balance_gRPC.denom.starts(with: "c")) {
                mBridged_gRPC.append(balance_gRPC)
                
            } else if (chainType == .GRAVITY_BRIDGE_MAIN && balance_gRPC.denom.starts(with: "gravity0x")) {
                mBridged_gRPC.append(balance_gRPC)
                
            } else if (chainType == .KAVA_MAIN) {
                if (balance_gRPC.denom == KAVA_HARD_DENOM || balance_gRPC.denom == KAVA_USDX_DENOM || balance_gRPC.denom == KAVA_SWAP_DENOM) {
                    mNative_gRPC.append(balance_gRPC)

                } else if (balance_gRPC.denom == TOKEN_HTLC_KAVA_BNB || balance_gRPC.denom == TOKEN_HTLC_KAVA_BTCB ||
                           balance_gRPC.denom == TOKEN_HTLC_KAVA_XRPB || balance_gRPC.denom == TOKEN_HTLC_KAVA_BUSD) {
                    mKavaBep2_gRPC.append(balance_gRPC)

                } else if (balance_gRPC.denom == "btch") {
                    mUnKnown_gRPC.append(balance_gRPC)
                }

            } else if (chainType == .INJECTIVE_MAIN) {
                if (balance_gRPC.denom.starts(with: "peggy0x")) {
                    mBridged_gRPC.append(balance_gRPC)
                } else if (balance_gRPC.denom.starts(with: "share")) {
                    mPoolToken_gRPC.append(balance_gRPC)
                }
                
            } else if (chainType == .CRESCENT_MAIN || chainType == .CRESCENT_TEST) {
                if (balance_gRPC.denom == CRESCENT_BCRE_DENOM) {
                    mNative_gRPC.append(balance_gRPC)
                } else if (balance_gRPC.isPoolToken()) {
                    mPoolToken_gRPC.append(balance_gRPC)
                }
                
            } else if (chainType == .NYX_MAIN) {
                if (balance_gRPC.denom == NYX_NYM_DENOM) {
                    mNative_gRPC.append(balance_gRPC)
                }
                
            } else {
                mUnKnown_gRPC.append(balance_gRPC)
            }
        }
        
        mNative.removeAll()
        mEtc.removeAll()
        mUnKnown.removeAll()
        self.mBalances.forEach { balance in
            if (WUtils.getMainDenom(chainType) == balance.balance_denom) {
                mNative.append(balance)
                
            } else if (chainType == .BINANCE_MAIN) {
                mEtc.append(balance)
                
            } else if (chainType == .OKEX_MAIN) {
                mEtc.append(balance)
                
            } else {
                mUnKnown.append(balance)
                
            }
        }
        
        
        mNative_gRPC.sort {
            if ($0.denom == WUtils.getMainDenom(chainType)) { return true }
            if ($1.denom == WUtils.getMainDenom(chainType)) { return false }
            if (chainType == .KAVA_MAIN) {
                if ($0.denom == KAVA_HARD_DENOM) { return true }
                if ($1.denom == KAVA_HARD_DENOM) { return false }
                if ($0.denom == KAVA_SWAP_DENOM) { return true }
                if ($1.denom == KAVA_SWAP_DENOM) { return false }
            }
            return false
        }
        mPoolToken_gRPC.sort {
            if (chainType == ChainType.OSMOSIS_MAIN) {
                return $0.osmosisAmmPoolId() < $1.osmosisAmmPoolId()
            } else if (chainType == .COSMOS_MAIN) {
                let id0 = BaseData.instance.getGravityPoolByDenom($0.denom)?.id ?? 0
                let id1 = BaseData.instance.getGravityPoolByDenom($1.denom)?.id ?? 0
                return id0 < id1
            }
            return false
        }
        mNative.sort {
            if ($0.balance_denom == WUtils.getMainDenom(chainType)) { return true }
            if ($1.balance_denom == WUtils.getMainDenom(chainType)) { return false }
            
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
                        self.onToggleAlarm(self.account!) { (success) in
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
                self.onToggleAlarm(self.account!) { (success) in
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
