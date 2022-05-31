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

class MainTabWalletViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate, QrScannerDelegate, PasswordViewDelegate {

    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleAlarmBtn: UIButton!
    @IBOutlet weak var titleWalletName: UILabel!
    @IBOutlet weak var titleChainName: UILabel!
    
    @IBOutlet weak var totalCard: CardView!
    @IBOutlet weak var totalKeyState: UIImageView!
    @IBOutlet weak var totalDpAddress: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var noticeCard: CardView!
    @IBOutlet weak var noticeTextLabel: UILabel!
    @IBOutlet weak var noticeBadgeLabel: UILabel!
    @IBOutlet weak var noticeBadgeView: UIView!
    @IBOutlet weak var totalCardTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var walletTableView: UITableView!
    var refresher: UIRefreshControl!
    
    var mainTabVC: MainTabViewController!
    var wcURL:String?
    var board: Board!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)

        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        self.walletTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.walletTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.walletTableView.register(UINib(nibName: "WalletCosmosCell", bundle: nil), forCellReuseIdentifier: "WalletCosmosCell")
        self.walletTableView.register(UINib(nibName: "WalletIrisCell", bundle: nil), forCellReuseIdentifier: "WalletIrisCell")
        self.walletTableView.register(UINib(nibName: "WalletBnbCell", bundle: nil), forCellReuseIdentifier: "WalletBnbCell")
        self.walletTableView.register(UINib(nibName: "WalletKavaCell", bundle: nil), forCellReuseIdentifier: "WalletKavaCell")
        self.walletTableView.register(UINib(nibName: "WalletKavaIncentiveCell", bundle: nil), forCellReuseIdentifier: "WalletKavaIncentiveCell")
        self.walletTableView.register(UINib(nibName: "WalletIovCell", bundle: nil), forCellReuseIdentifier: "WalletIovCell")
        self.walletTableView.register(UINib(nibName: "WalletBandCell", bundle: nil), forCellReuseIdentifier: "WalletBandCell")
        self.walletTableView.register(UINib(nibName: "WalletSecretCell", bundle: nil), forCellReuseIdentifier: "WalletSecretCell")
        self.walletTableView.register(UINib(nibName: "WalletOkCell", bundle: nil), forCellReuseIdentifier: "WalletOkCell")
        self.walletTableView.register(UINib(nibName: "WalletCertikCell", bundle: nil), forCellReuseIdentifier: "WalletCertikCell")
        self.walletTableView.register(UINib(nibName: "WalletAkashCell", bundle: nil), forCellReuseIdentifier: "WalletAkashCell")
        self.walletTableView.register(UINib(nibName: "WalletPersisCell", bundle: nil), forCellReuseIdentifier: "WalletPersisCell")
        self.walletTableView.register(UINib(nibName: "WalletSentinelCell", bundle: nil), forCellReuseIdentifier: "WalletSentinelCell")
        self.walletTableView.register(UINib(nibName: "WalletFetchCell", bundle: nil), forCellReuseIdentifier: "WalletFetchCell")
        self.walletTableView.register(UINib(nibName: "WalletCrytoCell", bundle: nil), forCellReuseIdentifier: "WalletCrytoCell")
        self.walletTableView.register(UINib(nibName: "WalletSifCell", bundle: nil), forCellReuseIdentifier: "WalletSifCell")
//        self.walletTableView.register(UINib(nibName: "WalletSifIncentiveCell", bundle: nil), forCellReuseIdentifier: "WalletSifIncentiveCell")
        self.walletTableView.register(UINib(nibName: "WalletKiCell", bundle: nil), forCellReuseIdentifier: "WalletKiCell")
        self.walletTableView.register(UINib(nibName: "WalletRizonCell", bundle: nil), forCellReuseIdentifier: "WalletRizonCell")
        self.walletTableView.register(UINib(nibName: "WalletMediCell", bundle: nil), forCellReuseIdentifier: "WalletMediCell")
        self.walletTableView.register(UINib(nibName: "WalletAltheaCell", bundle: nil), forCellReuseIdentifier: "WalletAltheaCell")
        self.walletTableView.register(UINib(nibName: "WalletOsmoCell", bundle: nil), forCellReuseIdentifier: "WalletOsmoCell")
        self.walletTableView.register(UINib(nibName: "WalletUmeeCell", bundle: nil), forCellReuseIdentifier: "WalletUmeeCell")
        self.walletTableView.register(UINib(nibName: "WalletAxelarCell", bundle: nil), forCellReuseIdentifier: "WalletAxelarCell")
        self.walletTableView.register(UINib(nibName: "WalletEmoneyCell", bundle: nil), forCellReuseIdentifier: "WalletEmoneyCell")
        self.walletTableView.register(UINib(nibName: "WalletJunoCell", bundle: nil), forCellReuseIdentifier: "WalletJunoCell")
        self.walletTableView.register(UINib(nibName: "WalletRegenCell", bundle: nil), forCellReuseIdentifier: "WalletRegenCell")
        self.walletTableView.register(UINib(nibName: "WalletBitcannaCell", bundle: nil), forCellReuseIdentifier: "WalletBitcannaCell")
        self.walletTableView.register(UINib(nibName: "WalletGBridgeCell", bundle: nil), forCellReuseIdentifier: "WalletGBridgeCell")
        self.walletTableView.register(UINib(nibName: "WalletStargazeCell", bundle: nil), forCellReuseIdentifier: "WalletStargazeCell")
        self.walletTableView.register(UINib(nibName: "WalletComdexCell", bundle: nil), forCellReuseIdentifier: "WalletComdexCell")
        self.walletTableView.register(UINib(nibName: "WalletInjectiveCell", bundle: nil), forCellReuseIdentifier: "WalletInjectiveCell")
        self.walletTableView.register(UINib(nibName: "WalletBitsongCell", bundle: nil), forCellReuseIdentifier: "WalletBitsongCell")
        self.walletTableView.register(UINib(nibName: "WalletDesmosCell", bundle: nil), forCellReuseIdentifier: "WalletDesmosCell")
        self.walletTableView.register(UINib(nibName: "WalletLumCell", bundle: nil), forCellReuseIdentifier: "WalletLumCell")
        self.walletTableView.register(UINib(nibName: "WalletChihuahuaCell", bundle: nil), forCellReuseIdentifier: "WalletChihuahuaCell")
        self.walletTableView.register(UINib(nibName: "WalletKonstellationCell", bundle: nil), forCellReuseIdentifier: "WalletKonstellationCell")
        self.walletTableView.register(UINib(nibName: "WalletEvmosCell", bundle: nil), forCellReuseIdentifier: "WalletEvmosCell")
        self.walletTableView.register(UINib(nibName: "WalletProvenanceCell", bundle: nil), forCellReuseIdentifier: "WalletProvenanceCell")
        self.walletTableView.register(UINib(nibName: "WalletCudosCell", bundle: nil), forCellReuseIdentifier: "WalletCudosCell")
        self.walletTableView.register(UINib(nibName: "WalletCerberusCell", bundle: nil), forCellReuseIdentifier: "WalletCerberusCell")
        self.walletTableView.register(UINib(nibName: "WalletOmniCell", bundle: nil), forCellReuseIdentifier: "WalletOmniCell")
        self.walletTableView.register(UINib(nibName: "WalletCrescentCell", bundle: nil), forCellReuseIdentifier: "WalletCrescentCell")
        self.walletTableView.register(UINib(nibName: "WalletMantleCell", bundle: nil), forCellReuseIdentifier: "WalletMantleCell")
        self.walletTableView.register(UINib(nibName: "WalletStationCell", bundle: nil), forCellReuseIdentifier: "WalletStationCell")
        self.walletTableView.register(UINib(nibName: "WalletNyxCell", bundle: nil), forCellReuseIdentifier: "WalletNyxCell")
        self.walletTableView.register(UINib(nibName: "WalletUnbondingInfoCellTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletUnbondingInfoCellTableViewCell")
        self.walletTableView.register(UINib(nibName: "WalletPriceCell", bundle: nil), forCellReuseIdentifier: "WalletPriceCell")
        self.walletTableView.register(UINib(nibName: "WalletInflationCell", bundle: nil), forCellReuseIdentifier: "WalletInflationCell")
        self.walletTableView.register(UINib(nibName: "WalletGuideCell", bundle: nil), forCellReuseIdentifier: "WalletGuideCell")
        self.walletTableView.register(UINib(nibName: "WalletDesmosEventCell", bundle: nil), forCellReuseIdentifier: "WalletDesmosEventCell")
        
        self.walletTableView.rowHeight = UITableView.automaticDimension
        self.walletTableView.estimatedRowHeight = UITableView.automaticDimension
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = UIColor.white
        walletTableView.addSubview(refresher)
        noticeBadgeView.layer.masksToBounds = false
        noticeBadgeView.layer.cornerRadius = 6
        noticeBadgeView.clipsToBounds = true
        
        let tapNoticeCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickNoticeBoard))
        self.noticeCard.addGestureRecognizer(tapNoticeCard)
        
        let tapTotalCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickActionShare))
        self.totalCard.addGestureRecognizer(tapTotalCard)
        
        self.updateFloaty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchPrice(_:)), name: Notification.Name("onFetchPrice"), object: nil)
        self.onFetchNoticeInfo()
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
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.titleChainImg.image = WUtils.getChainImg(chainType)
        self.titleChainName.text = WUtils.getChainTitle(chainType)
        self.titleChainName.textColor = WUtils.getChainColor(chainType!)
        self.titleWalletName.text = WUtils.getWalletName(account)
        self.titleAlarmBtn.isHidden = (chainType! == ChainType.COSMOS_MAIN) ? false : true
        
        self.totalCard.backgroundColor = WUtils.getChainBg(chainType)
        if (account?.account_has_private == true) {
            self.totalKeyState.image = totalKeyState.image?.withRenderingMode(.alwaysTemplate)
            self.totalKeyState.tintColor = WUtils.getChainColor(chainType)
        }
        self.totalDpAddress.text = account?.account_address
        self.totalDpAddress.adjustsFontSizeToFitWidth = true
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    if (self.account!.account_push_alarm) {
                        self.titleAlarmBtn.setImage(UIImage(named: "notificationsIc"), for: .normal)
                    } else {
                        self.titleAlarmBtn.setImage(UIImage(named: "notificationsIcOff"), for: .normal)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.titleAlarmBtn.setImage(UIImage(named: "notificationsIcOff"), for: .normal)
                }
            }
        }
        
    }
    
    func updateFloaty() {
        let floaty = Floaty()
        if (chainType! == ChainType.PERSIS_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendPersistence")
            floaty.buttonColor = .black
        } else if (chainType! == ChainType.SENTINEL_MAIN) {
            floaty.buttonImage = UIImage.init(named: "sendImg")
            floaty.buttonColor = COLOR_SENTINEL_DARK2
        } else if (chainType! == ChainType.CRYPTO_MAIN) {
            floaty.buttonImage = UIImage.init(named: "sendImg")
            floaty.buttonColor = COLOR_CRYPTO_DARK
        } else if (chainType! == ChainType.ALTHEA_MAIN || chainType! == ChainType.ALTHEA_TEST) {
            floaty.buttonImage = UIImage.init(named: "btnSendAlthea")
            floaty.buttonColor = COLOR_ALTHEA
        } else if (chainType == ChainType.MEDI_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendMedi")
            floaty.buttonColor = .white
        } else if (chainType! == ChainType.AXELAR_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendAlthea")
            floaty.buttonColor = .white
        } else if (chainType! == ChainType.COMDEX_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendComdex")
            floaty.buttonColor = UIColor.init(hexString: "03264a")
        } else if (chainType! == ChainType.SECRET_MAIN) {
            floaty.buttonImage = UIImage.init(named: "sendImg")
            floaty.buttonColor = COLOR_SECRET_DARK
        } else if (chainType! == ChainType.INJECTIVE_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendAlthea")
            floaty.buttonColor = COLOR_INJECTIVE
        } else if (chainType! == ChainType.KONSTELLATION_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendKonstellation")
            floaty.buttonColor = UIColor.init(hexString: "122951")
        } else if (chainType! == ChainType.EVMOS_MAIN) {
            floaty.buttonImage = UIImage.init(named: "btnSendEvmos")
            floaty.buttonColor = UIColor.init(hexString: "000000")
        } else if (chainType! == ChainType.CRESCENT_MAIN || chainType! == ChainType.CRESCENT_TEST) {
            floaty.buttonImage = UIImage.init(named: "btnSendCrescent")
            floaty.buttonColor = UIColor.init(hexString: "452318")
        } else {
            floaty.buttonImage = UIImage.init(named: "sendImg")
            floaty.buttonColor = WUtils.getChainColor(chainType)
        }
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }

    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
        self.walletTableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
        self.walletTableView.reloadData()
    }
    
    func emptyFloatySelected(_ floaty: Floaty) {
        self.onClickMainSend()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (chainType == ChainType.KAVA_MAIN || chainType == ChainType.DESMOS_MAIN) {
            return 5;
        } else if (chainType == ChainType.BINANCE_MAIN) {
            return 3;
        } else if (chainType == ChainType.OKEX_MAIN) {
            return 3;
        }
        return 4;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (chainType == ChainType.COSMOS_MAIN) {
            return onSetCosmosItems(tableView, indexPath);
        } else if (chainType == ChainType.IRIS_MAIN) {
            return onSetIrisItem(tableView, indexPath);
        } else if (chainType == ChainType.BINANCE_MAIN) {
            return onSetBnbItem(tableView, indexPath);
        } else if (chainType == ChainType.KAVA_MAIN) {
            return onSetKavaItem(tableView, indexPath);
        } else if (chainType == ChainType.BAND_MAIN) {
            return onSetBandItem(tableView, indexPath);
        } else if (chainType == ChainType.SECRET_MAIN) {
            return onSetSecretItem(tableView, indexPath);
        } else if (chainType == ChainType.IOV_MAIN) {
            return onSetIovItems(tableView, indexPath);
        } else if (chainType == ChainType.OKEX_MAIN) {
            return onSetOKexItems(tableView, indexPath);
        } else if (chainType == ChainType.CERTIK_MAIN) {
            return onSetCertikItems(tableView, indexPath);
        } else if (chainType == ChainType.AKASH_MAIN) {
            return onSetAkashItems(tableView, indexPath);
        } else if (chainType == ChainType.PERSIS_MAIN) {
            return onSetPersisItems(tableView, indexPath);
        } else if (chainType == ChainType.SENTINEL_MAIN) {
            return onSetSentinelItems(tableView, indexPath);
        } else if (chainType == ChainType.FETCH_MAIN) {
            return onSetFetchItems(tableView, indexPath);
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            return onSetCrytoItems(tableView, indexPath);
        } else if (chainType == ChainType.SIF_MAIN) {
            return onSetSifItems(tableView, indexPath);
        } else if (chainType == ChainType.KI_MAIN) {
            return onSetkiItems(tableView, indexPath);
        } else if (chainType == ChainType.OSMOSIS_MAIN) {
            return onSetOsmoItems(tableView, indexPath);
        } else if (chainType == ChainType.MEDI_MAIN) {
            return onSetMediItems(tableView, indexPath);
        } else if (chainType == ChainType.EMONEY_MAIN) {
            return onSetEmoneyItems(tableView, indexPath);
        } else if (chainType == ChainType.RIZON_MAIN) {
            return onSetRizonItems(tableView, indexPath);
        } else if (chainType == ChainType.JUNO_MAIN) {
            return onSetJunoItems(tableView, indexPath);
        } else if (chainType == ChainType.REGEN_MAIN) {
            return onSetRegenItems(tableView, indexPath);
        } else if (chainType == ChainType.BITCANA_MAIN) {
            return onSetBitcanaItems(tableView, indexPath);
        } else if (chainType == ChainType.ALTHEA_MAIN || chainType == ChainType.ALTHEA_TEST) {
            return onSetAltheaItems(tableView, indexPath);
        } else if (chainType == ChainType.GRAVITY_BRIDGE_MAIN) {
            return onSetGBridgeItems(tableView, indexPath);
        } else if (chainType == ChainType.STARGAZE_MAIN) {
            return onSetStargazeItems(tableView, indexPath);
        } else if (chainType == ChainType.COMDEX_MAIN) {
            return onSetComdexItems(tableView, indexPath);
        } else if (chainType == ChainType.INJECTIVE_MAIN) {
            return onSetInjectiveItems(tableView, indexPath);
        } else if (chainType == ChainType.BITSONG_MAIN) {
            return onSetBitsongItems(tableView, indexPath);
        } else if (chainType == ChainType.DESMOS_MAIN) {
            return onSetDesmosItems(tableView, indexPath);
        } else if (chainType == ChainType.LUM_MAIN) {
            return onSetLumItems(tableView, indexPath);
        } else if (chainType == ChainType.CHIHUAHUA_MAIN) {
            return onSetChihuahuaItems(tableView, indexPath);
        } else if (chainType == ChainType.AXELAR_MAIN) {
            return onSetAxelarItems(tableView, indexPath);
        } else if (chainType == ChainType.KONSTELLATION_MAIN) {
            return onSetKonstellationItems(tableView, indexPath);
        } else if (chainType == ChainType.UMEE_MAIN) {
            return onSetUmeeItems(tableView, indexPath);
        } else if (chainType == ChainType.EVMOS_MAIN) {
            return onSetEvmosItems(tableView, indexPath);
        } else if (chainType == ChainType.PROVENANCE_MAIN) {
            return onSetProvenanceItems(tableView, indexPath);
        } else if (chainType == ChainType.CUDOS_MAIN) {
            return onSetCudosItems(tableView, indexPath);
        } else if (chainType == ChainType.CERBERUS_MAIN) {
            return onSetCerberusItems(tableView, indexPath);
        } else if (chainType == ChainType.OMNIFLIX_MAIN) {
            return onSetOmniItems(tableView, indexPath);
        } else if (chainType == ChainType.CRESCENT_MAIN) {
            return onSetCrescentItems(tableView, indexPath);
        } else if (chainType == ChainType.MANTLE_MAIN) {
            return onSetMantleItems(tableView, indexPath);
        } else if (chainType == ChainType.NYX_MAIN) {
            return onSetNyxItems(tableView, indexPath);
        }
        
        else if (chainType == ChainType.COSMOS_TEST) {
            return onSetCosmosTestItems(tableView, indexPath);
        } else if (chainType == ChainType.IRIS_TEST) {
            return onSetIrisTestItems(tableView, indexPath);
        } else if (chainType == ChainType.CRESCENT_TEST) {
            return onSetCrescentItems(tableView, indexPath);
        } else if (chainType == ChainType.STATION_TEST) {
            return onSetStationItems(tableView, indexPath);
        } else {
            let cell:WalletAddressCell? = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func onSetCosmosItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCosmosCell") as? WalletCosmosCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionGravity = {
                self.onClickGravityDex()
                
            }
            cell?.actionWalletConnect = {
                self.onShowToast(NSLocalizedString("prepare", comment: ""))
//                self.onClickWalletConect()
                
            }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetBandItem(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletBandCell") as? WalletBandCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetSecretItem(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletSecretCell") as? WalletSecretCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetCertikItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCertikCell") as? WalletCertikCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetAkashItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAkashCell") as? WalletAkashCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetPersisItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPersisCell") as? WalletPersisCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetSentinelItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletSentinelCell") as? WalletSentinelCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetFetchItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletFetchCell") as? WalletFetchCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            cell?.actionBuy = { self.onClickBuyCoin() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetkiItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletKiCell") as? WalletKiCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetRizonItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletRizonCell") as? WalletRizonCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
        
    }
    
    func onSetMediItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletMediCell") as? WalletMediCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetEmoneyItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletEmoneyCell") as? WalletEmoneyCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetJunoItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletJunoCell") as? WalletJunoCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetAltheaItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAltheaCell") as? WalletAltheaCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
        
    }
    
    func onSetUmeeItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletUmeeCell") as? WalletUmeeCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetEvmosItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletEvmosCell") as? WalletEvmosCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionWc = { self.onClickWalletConect() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetAxelarItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAxelarCell") as? WalletAxelarCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetKonstellationItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletKonstellationCell") as? WalletKonstellationCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetRegenItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletRegenCell") as? WalletRegenCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetBitcanaItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletBitcannaCell") as? WalletBitcannaCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetGBridgeItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGBridgeCell") as? WalletGBridgeCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
        
    }
    
    func onSetStargazeItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletStargazeCell") as? WalletStargazeCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
        
    }
    
    func onSetComdexItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletComdexCell") as? WalletComdexCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetInjectiveItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInjectiveCell") as? WalletInjectiveCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetBitsongItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletBitsongCell") as? WalletBitsongCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletDesmosEventCell") as? WalletDesmosEventCell
            cell?.actionDownload = { self.onClickDesmosEvent() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetLumItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletLumCell") as? WalletLumCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetChihuahuaItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletChihuahuaCell") as? WalletChihuahuaCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetProvenanceItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletProvenanceCell") as? WalletProvenanceCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetCudosItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCudosCell") as? WalletCudosCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetCerberusItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCerberusCell") as? WalletCerberusCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetOmniItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletOmniCell") as? WalletOmniCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetStationItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletStationCell") as? WalletStationCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            cell?.actionWC = { self.onClickWalletConect() }
            cell?.actionDapp = { self.onClickStationApp() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetMantleItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletMantleCell") as? WalletMantleCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetNyxItems(_ tableView: UITableView, _ indexPath: IndexPath)  -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletNyxCell") as? WalletNyxCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!

        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!

        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    
    func onSetCosmosTestItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletCosmosCell") as? WalletCosmosCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
        }
    }
    
    func onSetIrisTestItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletIrisCell") as? WalletIrisCell
            cell?.updateView(account, chainType)
            cell?.actionDelegate = { self.onClickValidatorList() }
            cell?.actionVote = { self.onClickVoteList() }
            return cell!
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletPriceCell") as? WalletPriceCell
            cell?.updateView(account, chainType)
            cell?.actionTapPricel = { self.onClickMarketInfo() }
            return cell!
            
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletInflationCell") as? WalletInflationCell
            cell?.updateView(account, chainType)
            cell?.actionTapApr = { self.onClickAprHelp() }
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletGuideCell") as? WalletGuideCell
            cell?.updateView(account, chainType)
            cell?.actionGuide1 = { self.onClickGuide1() }
            cell?.actionGuide2 = { self.onClickGuide2() }
            return cell!
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
        if (sender.imageView?.image == UIImage(named: "notificationsIcOff")) {
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
    
    @objc func onClickNoticeBoard() {
        if let url = URL(string: "https://notice.mintscan.io/\(WUtils.getChainNameByBaseChain(chainType))/\(self.noticeCard.tag)") {
            self.onShowSafariWeb(url)
        }
    }
    
    @objc func onClickActionShare() {
        self.shareAddress(account!.account_address, WUtils.getWalletName(account))
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
            if (WUtils.getTokenAmount(balances, BNB_MAIN_DENOM).compare(NSDecimalNumber.init(string: FEE_BNB_TRANSFER)).rawValue <= 0) {
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
        txVC.mType = KAVA_MSG_TYPE_INCENTIVE_ALL
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickOkDeposit() {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, OK_MSG_TYPE_DEPOSIT, BaseData.instance.mMyValidator.count)
        if (BaseData.instance.availableAmount(OKEX_MAIN_DENOM).compare(feeAmount).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (WUtils.getTokenAmount(mainTabVC.mBalances, OKEX_MAIN_DENOM).compare(NSDecimalNumber(string: "0.01")).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_to_deposit", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = OK_MSG_TYPE_DEPOSIT
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    func onClickOkWithdraw() {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, OK_MSG_TYPE_WITHDRAW, BaseData.instance.mMyValidator.count)
        if (BaseData.instance.availableAmount(OKEX_MAIN_DENOM).compare(feeAmount).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (WUtils.okDepositAmount(BaseData.instance.mOkStaking).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_to_withdraw", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = OK_MSG_TYPE_WITHDRAW
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
        
    }
    
    //no need yet
    func onClickOkVoteValMode() {
        let okVoteTypeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
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
    
    func onClickStationApp() {
        let commonWcVC = CommonWCViewController(nibName: "CommonWCViewController", bundle: nil)
        commonWcVC.dappURL = "https://dapps.cosmostation.io"
        commonWcVC.isDapp = true
        commonWcVC.isDeepLink = false
        commonWcVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(commonWcVC, animated: true)
    }
    
    func onClickGravityDex() {
        let gravityDappVC = UIStoryboard(name: "Gravity", bundle: nil).instantiateViewController(withIdentifier: "GravityDAppViewController") as! GravityDAppViewController
        gravityDappVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(gravityDappVC, animated: true)
    }
    
    func onClickSifIncentive() {
        print("onClickSifIncentive")
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        if let lmCurrentAmount = BaseData.instance.mSifLmIncentive?.user?.totalClaimableCommissionsAndClaimableRewards {
            if (lmCurrentAmount <= 0) {
                self.onShowToast(NSLocalizedString("error_no_incentive_to_claim", comment: ""))
                return
            }
            let mainDenom = WUtils.getMainDenom(chainType)
            let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, SIF_MSG_TYPE_CLAIM_INCENTIVE, 0)
            if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(feeAmount).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
            
            let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            txVC.mType = SIF_MSG_TYPE_CLAIM_INCENTIVE
            txVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(txVC, animated: true)
            
        } else {
            self.onShowToast(NSLocalizedString("error_no_incentive_to_claim", comment: ""))
        }
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
            let mainDenom = WUtils.getMainDenom(chainType)
            let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_GEN_PROFILE, 0)
            if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(feeAmount).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                return
            }
            let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            txVC.mType = TASK_GEN_PROFILE
            txVC.hidesBottomBarWhenPushed = true
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(txVC, animated: true)
        }
    }
    
    func onClickDesmosEvent() {
        guard let url = URL(string: "https://dpm.desmos.network/") else { return }
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
        helpAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(helpAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            helpAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onClickGuide1() {
        if (chainType! == ChainType.COSMOS_MAIN || chainType! == ChainType.COSMOS_TEST) {
            if (Locale.current.languageCode == "ko") {
                guard let url = URL(string: "https://medium.com/@cosmostation/d7dd26fc88fd") else { return }
                self.onShowSafariWeb(url)
            } else {
                guard let url = URL(string: "https://medium.com/@cosmostation/5fd64aa0a56b") else { return }
                self.onShowSafariWeb(url)
            }
            
        } else if (chainType! == ChainType.IRIS_MAIN || chainType! == ChainType.IRIS_TEST) {
            guard let url = URL(string: "https://www.irisnet.org") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BINANCE_MAIN) {
            guard let url = URL(string: "https://www.binance.org") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KAVA_MAIN) {
            guard let url = URL(string: "https://www.kava.io/registration/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BAND_MAIN) {
            guard let url = URL(string: "https://bandprotocol.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SECRET_MAIN) {
            guard let url = URL(string: "https://scrt.network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.IOV_MAIN) {
            guard let url = URL(string: "https://iov.one/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OKEX_MAIN) {
            guard let url = URL(string: "https://www.okex.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CERTIK_MAIN) {
            guard let url = URL(string: "https://www.certik.foundation/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.AKASH_MAIN) {
            guard let url = URL(string: "https://akash.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.PERSIS_MAIN) {
            guard let url = URL(string: "https://persistence.one/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SENTINEL_MAIN) {
            guard let url = URL(string: "https://sentinel.co/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.FETCH_MAIN) {
            guard let url = URL(string: "https://fetch.ai/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CRYPTO_MAIN) {
            guard let url = URL(string: "https://crypto.org/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SIF_MAIN) {
            guard let url = URL(string: "https://sifchain.finance/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KI_MAIN) {
            guard let url = URL(string: "https://foundation.ki/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OSMOSIS_MAIN) {
            guard let url = URL(string: "https://osmosis.zone/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.MEDI_MAIN) {
            if (Locale.current.languageCode == "ko") {
                guard let url = URL(string: "https://medibloc.com") else { return }
                self.onShowSafariWeb(url)
            } else {
                guard let url = URL(string: "https://medibloc.com/en/") else { return }
                self.onShowSafariWeb(url)
            }
            
        } else if (chainType! == ChainType.UMEE_MAIN) {
            guard let url = URL(string: "https://umee.cc/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.AXELAR_MAIN) {
            guard let url = URL(string: "https://axelar.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.EMONEY_MAIN) {
            guard let url = URL(string: "https://e-money.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.JUNO_MAIN) {
            guard let url = URL(string: "https://junochain.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.REGEN_MAIN) {
            guard let url = URL(string: "https://www.regen.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BITCANA_MAIN) {
            guard let url = URL(string: "https://www.bitcanna.io/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.ALTHEA_MAIN || chainType! == ChainType.ALTHEA_TEST) {
            guard let url = URL(string: "https://www.althea.net/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.GRAVITY_BRIDGE_MAIN) {
            guard let url = URL(string: "https://www.gravitybridge.net/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.STARGAZE_MAIN) {
            guard let url = URL(string: "https://stargaze.zone/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.COMDEX_MAIN) {
            guard let url = URL(string: "https://comdex.one/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.INJECTIVE_MAIN) {
            guard let url = URL(string: "https://injectiveprotocol.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BITSONG_MAIN) {
            guard let url = URL(string: "http://bitsong.io/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.DESMOS_MAIN) {
            guard let url = URL(string: "https://www.desmos.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.LUM_MAIN) {
            guard let url = URL(string: "https://lum.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CHIHUAHUA_MAIN) {
            guard let url = URL(string: "https://chi.huahua.wtf/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KONSTELLATION_MAIN) {
            guard let url = URL(string: "https://konstellation.tech/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.EVMOS_MAIN) {
            guard let url = URL(string: "https://evmos.org/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CERBERUS_MAIN) {
            guard let url = URL(string: "https://cerberus.zone/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OMNIFLIX_MAIN) {
            guard let url = URL(string: "https://www.omniflix.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.PROVENANCE_MAIN) {
            guard let url = URL(string: "https://www.provenance.io/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CRESCENT_MAIN || chainType! == ChainType.CRESCENT_TEST) {
            guard let url = URL(string: "https://crescent.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.MANTLE_MAIN) {
            guard let url = URL(string: "https://assetmantle.one/") else { return }
            self.onShowSafariWeb(url)
            
        }
        
    }
    
    func onClickGuide2() {
        if (chainType! == ChainType.COSMOS_MAIN || chainType! == ChainType.COSMOS_TEST) {
            if (Locale.current.languageCode == "ko") {
                guard let url = URL(string: "https://guide.cosmostation.io/app_wallet_ko.html") else { return }
                self.onShowSafariWeb(url)
            } else {
                guard let url = URL(string: "https://guide.cosmostation.io/app_wallet_en.html") else { return }
                self.onShowSafariWeb(url)
            }

        } else if (chainType! == ChainType.IRIS_MAIN || chainType! == ChainType.IRIS_TEST) {
            guard let url = URL(string: "https://medium.com/irisnet-blog") else { return }
            self.onShowSafariWeb(url)

        } else if (chainType! == ChainType.BINANCE_MAIN) {
            guard let url = URL(string: "https://medium.com/@binance") else { return }
            self.onShowSafariWeb(url)

        } else if (chainType! == ChainType.KAVA_MAIN) {
            guard let url = URL(string: "https://medium.com/kava-labs") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BAND_MAIN) {
            guard let url = URL(string: "https://medium.com/bandprotocol") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SECRET_MAIN) {
            guard let url = URL(string: "https://blog.scrt.network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.IOV_MAIN) {
            guard let url = URL(string: "https://medium.com/iov-internet-of-values") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OKEX_MAIN) {
            guard let url = URL(string: "https://www.okex.com/community") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CERTIK_MAIN) {
            guard let url = URL(string: "https://www.certik.foundation/blog") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.AKASH_MAIN) {
            guard let url = URL(string: "https://akash.network/blog/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.PERSIS_MAIN) {
            guard let url = URL(string: "https://medium.com/persistence-blog") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SENTINEL_MAIN) {
            guard let url = URL(string: "https://medium.com/sentinel") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.FETCH_MAIN) {
            guard let url = URL(string: "https://fetch.ai/blog/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CRYPTO_MAIN) {
            guard let url = URL(string: "https://crypto.org/community") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SIF_MAIN) {
            guard let url = URL(string: "https://medium.com/sifchain-finance") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KI_MAIN) {
            guard let url = URL(string: "https://medium.com/ki-foundation") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OSMOSIS_MAIN) {
            guard let url = URL(string: "https://medium.com/osmosis") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.MEDI_MAIN) {
            if (Locale.current.languageCode == "ko") {
                guard let url = URL(string: "https://blog.medibloc.org/") else { return }
                self.onShowSafariWeb(url)
            } else {
                guard let url = URL(string: "https://medium.com/medibloc/") else { return }
                self.onShowSafariWeb(url)
            }
        } else if (chainType! == ChainType.UMEE_MAIN) {
            guard let url = URL(string: "https://medium.com/umeeblog") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.AXELAR_MAIN) {
            guard let url = URL(string: "https://axelar.network/blog") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.EMONEY_MAIN) {
            guard let url = URL(string: "https://medium.com/e-money-com") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.JUNO_MAIN) {
            guard let url = URL(string: "https://medium.com/@JunoNetwork/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.REGEN_MAIN) {
            guard let url = URL(string: "https://medium.com/regen-network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BITCANA_MAIN) {
            guard let url = URL(string: "https://medium.com/@BitCannaGlobal") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.ALTHEA_MAIN || chainType! == ChainType.ALTHEA_TEST) {
            guard let url = URL(string: "https://blog.althea.net/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.GRAVITY_BRIDGE_MAIN) {
            guard let url = URL(string: "https://www.gravitybridge.net/blog") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.STARGAZE_MAIN) {
            guard let url = URL(string: "https://mirror.xyz/stargazezone.eth") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.COMDEX_MAIN) {
            guard let url = URL(string: "https://blog.comdex.one/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.INJECTIVE_MAIN) {
            guard let url = URL(string: "https://blog.injectiveprotocol.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BITSONG_MAIN) {
            guard let url = URL(string: "https://bitsongofficial.medium.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.DESMOS_MAIN) {
            guard let url = URL(string: "https://medium.com/desmosnetwork") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.LUM_MAIN) {
            guard let url = URL(string: "https://medium.com/lum-network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CHIHUAHUA_MAIN) {
            guard let url = URL(string: "https://chi.huahua.wtf/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KONSTELLATION_MAIN) {
            guard let url = URL(string: "https://konstellation.medium.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.EVMOS_MAIN) {
            guard let url = URL(string: "https://evmos.blog/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CERBERUS_MAIN) {
            guard let url = URL(string: "https://medium.com/@cerberus_zone") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OMNIFLIX_MAIN) {
            guard let url = URL(string: "https://blog.omniflix.network/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.PROVENANCE_MAIN) {
            guard let url = URL(string: "https://www.provenance.io/blog") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CRESCENT_MAIN || chainType! == ChainType.CRESCENT_TEST) {
            guard let url = URL(string: "https://crescentnetwork.medium.com/") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.MANTLE_MAIN) {
            guard let url = URL(string: "https://blog.assetmantle.one/") else { return }
            self.onShowSafariWeb(url)
            
        }
    }
    
    func onClickMarketInfo() {
        if (chainType! == ChainType.COSMOS_MAIN || chainType! == ChainType.COSMOS_TEST) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/cosmos") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.IRIS_MAIN || chainType! == ChainType.IRIS_TEST) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/irisnet") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BINANCE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/binancecoin") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KAVA_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/kava") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BAND_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/band-protocol") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SECRET_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/secret") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.IOV_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/starname") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CERTIK_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/certik") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.AKASH_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/akash-network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SENTINEL_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/sentinel") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.PERSIS_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/persistence") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.FETCH_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/fetch-ai") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CRYPTO_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/crypto-com-chain") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.SIF_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/sifchain") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KI_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/ki") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.OSMOSIS_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/osmosis") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType == ChainType.MEDI_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/medibloc") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType == ChainType.MEDI_MAIN || chainType == ChainType.EMONEY_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/e-money") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.REGEN_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/regen") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BITCANA_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/bitcanna") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.INJECTIVE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/injective-protocol") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.BITSONG_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/bitsong") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.RIZON_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/rizon") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.JUNO_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/juno-network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.COMDEX_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/comdex") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.STARGAZE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/stargaze") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.LUM_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/lum-network") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CHIHUAHUA_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/chihuahua-chain") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.DESMOS_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/desmos") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.UMEE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/umee") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.GRAVITY_BRIDGE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/graviton") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.MANTLE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/assetmantle") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.CERBERUS_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/cerberus") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.EVMOS_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/evmos") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.KONSTELLATION_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/konstellation") else { return }
            self.onShowSafariWeb(url)
            
        } else if (chainType! == ChainType.PROVENANCE_MAIN) {
            guard let url = URL(string: "https://www.coingecko.com/en/coins/provenance-blockchain") else { return }
            self.onShowSafariWeb(url)
            
        }
        
    }
    
    func onClickBuyCoin() {
        if (self.account?.account_has_private == true) {
            self.onShowBuySelectFiat()
        } else {
            self.onShowBuyWarnNoKey()
        }
    }
    
    func onShowBuyWarnNoKey() {
        let noKeyAlert = UIAlertController(title: NSLocalizedString("buy_without_key_title", comment: ""), message: NSLocalizedString("buy_without_key_msg", comment: ""), preferredStyle: .alert)
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
        let selectFiatAlert = UIAlertController(title: NSLocalizedString("buy_select_fiat_title", comment: ""), message: NSLocalizedString("buy_select_fiat_msg", comment: ""), preferredStyle: .alert)
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
        let param = ["api_key":query] as [String : Any]
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
        
        let gasDenom = WUtils.getGasDenom(chainType)
        let mainDenom = WUtils.getMainDenom(chainType)
        if (WUtils.isGRPC(chainType!)) {
            let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, COSMOS_MSG_TYPE_TRANSFER2, 0)
            if (BaseData.instance.getAvailableAmount_gRPC(gasDenom).compare(feeAmount).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
                return
            }
            if (BaseData.instance.getAvailableAmount_gRPC(mainDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_available", comment: ""))
                return
            }
            
        } else {
            let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, COSMOS_MSG_TYPE_TRANSFER2, 0)
            if (BaseData.instance.availableAmount(gasDenom).compare(feeAmount).rawValue < 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
                return
            }
            if (BaseData.instance.availableAmount(mainDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
                self.onShowToast(NSLocalizedString("error_not_enough_available", comment: ""))
                return
            }
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mToSendDenom = WUtils.getMainDenom(chainType)
        txVC.mType = COSMOS_MSG_TYPE_TRANSFER2
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
            if (self.chainType == ChainType.BINANCE_MAIN) {
                if (result.contains("wallet-bridge.binance.org")) {
                    self.wcURL = result
                    let wcAlert = UIAlertController(title: NSLocalizedString("wc_alert_title", comment: ""), message: NSLocalizedString("wc_alert_msg", comment: ""), preferredStyle: .alert)
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
            } else if (self.chainType == ChainType.OSMOSIS_MAIN || self.chainType == ChainType.KAVA_MAIN || self.chainType == ChainType.CRESCENT_MAIN || self.chainType == ChainType.EVMOS_MAIN || self.chainType == ChainType.STATION_TEST) {
                self.wcURL = result
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
                passwordVC.resultDelegate = self
                passwordVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(passwordVC, animated: false)
                
            } else {
                print("chainType ", self.chainType, "  url ",  result)
                
            }
        })
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
                if (self.chainType == ChainType.BINANCE_MAIN) {
                    let wcVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "WalletConnectViewController") as! WalletConnectViewController
                    wcVC.wcURL = self.wcURL!
                    wcVC.hidesBottomBarWhenPushed = true
                    self.navigationItem.title = ""
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
                    self.navigationController?.pushViewController(wcVC, animated: true)
                } else if (self.chainType == ChainType.OSMOSIS_MAIN || self.chainType == ChainType.KAVA_MAIN || self.chainType == ChainType.CRESCENT_MAIN || self.chainType == ChainType.EVMOS_MAIN || self.chainType == ChainType.STATION_TEST) {
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
    
    func onFetchNoticeInfo() {
        self.noticeCard.backgroundColor = WUtils.getChainBg(chainType)
        let request = Alamofire.request(BaseNetWork.mintscanNoticeInfo(chainType), method: .get, parameters: ["dashboard": "true", "chain": WUtils.getChainNameByBaseChain(chainType)], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let resData = res as? NSDictionary, let boards = resData.object(forKey: "boards") as? Array<NSDictionary> {
                    if let firstBoard = boards.first {
                        let board = Board.init(firstBoard)
                        self.noticeTextLabel.text = board.title
                        self.noticeBadgeLabel.text = board.type?.capitalized
                        self.noticeCard.isHidden = false
                        if let boardId = board.id {
                            self.noticeCard.tag = boardId
                        }
                        self.totalCardTopConstraint.isActive = true
                    } else {
                        self.noticeCard.isHidden = true
                        self.totalCardTopConstraint.isActive = false
                    }
                }
            case .failure(let error):
                print("onFetchNoticeInfo ", error)
                self.noticeCard.isHidden = true
                self.totalCardTopConstraint.isActive = false
            }
        }
    }
}
