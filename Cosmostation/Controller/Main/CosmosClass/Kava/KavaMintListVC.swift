//
//  KavaMintListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class KavaMintListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainKavaEVM!
    var kavaFetcher: KavaFetcher!
    var priceFeed: Kava_Pricefeed_V1beta1_QueryPricesResponse?
    var cdpParam: Kava_Cdp_V1beta1_Params?
    var myCollateralParamList = [Kava_Cdp_V1beta1_CollateralParam]()
    var otherCollateralParamList = [Kava_Cdp_V1beta1_CollateralParam]()
    var myCdp: [Kava_Cdp_V1beta1_CDPResponse]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        kavaFetcher = selectedChain.getKavaFetcher()
        
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "KavaMintListMyCell", bundle: nil), forCellReuseIdentifier: "KavaMintListMyCell")
        tableView.register(UINib(nibName: "KavaMintListCell", bundle: nil), forCellReuseIdentifier: "KavaMintListCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        onFetchData()
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_mint_list", comment: "")
    }
    
    func onFetchData() {
        Task {
            if let cdpParam = try? await kavaFetcher.fetchMintParam(),
               let myCdps = try? await kavaFetcher.fetchMyCdps() {
                
                cdpParam?.collateralParams.forEach({ collateralParam in
                    if (myCdps?.filter({ $0.type == collateralParam.type }).count ?? 0 > 0) {
                        myCollateralParamList.append(collateralParam)
                    } else {
                        otherCollateralParamList.append(collateralParam)
                    }
                })
                self.cdpParam = cdpParam
                self.myCdp = myCdps
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.loadingView.isHidden = true
                    self.tableView.reloadData()
                }
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    
    func onCreateCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintCreate = KavaMintCreateAction(nibName: "KavaMintCreateAction", bundle: nil)
        mintCreate.selectedChain = selectedChain
        mintCreate.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintCreate.priceFeed = priceFeed
        mintCreate.modalTransitionStyle = .coverVertical
        self.present(mintCreate, animated: true)
    }
    
    func onDepositCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .Deposit
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
    
    func onWithdrawCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .Withdraw
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
    
    func onDrawDebtCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .DrawDebt
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
    
    func onRepayCdpTx(_ type: String) {
        if (selectedChain.isTxFeePayable() == false) {
            onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        let mintAction = KavaMintAction(nibName: "KavaMintAction", bundle: nil)
        mintAction.selectedChain = selectedChain
        mintAction.mintActionType = .Repay
        mintAction.collateralParam = cdpParam!.collateralParams.filter({ $0.type == type }).first!
        mintAction.myCdp = myCdp?.filter({ $0.type == type }).first!
        mintAction.priceFeed = priceFeed
        mintAction.modalTransitionStyle = .coverVertical
        self.present(mintAction, animated: true)
    }
}

extension KavaMintListVC: UITableViewDelegate, UITableViewDataSource, BaseSheetDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return myCollateralParamList.count
        } else {
            return otherCollateralParamList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaMintListMyCell") as? KavaMintListMyCell
            let collateralParam = myCollateralParamList[indexPath.row]
            let myCdp = myCdp?.filter({ $0.type == collateralParam.type }).first!
            cell?.onBindCdp(collateralParam, priceFeed, myCdp)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"KavaMintListCell") as? KavaMintListCell
            let collateralParam = otherCollateralParamList[indexPath.row]
            cell?.onBindCdp(collateralParam)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.cdpType = myCollateralParamList[indexPath.row].type
            baseSheet.sheetDelegate = self
            baseSheet.sheetType = .SelectMintAction
            onStartSheet(baseSheet, 320, 0.6)
            
        } else {
            onCreateCdpTx(otherCollateralParamList[indexPath.row].type)
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectMintAction) {
            if let cdpType = result["cdpType"] as? String,
               let index = result["index"] as? Int {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                    if (index == 0) {
                        self.onDepositCdpTx(cdpType)
                    } else if (index == 1) {
                        self.onWithdrawCdpTx(cdpType)
                    } else if (index == 2) {
                        self.onDrawDebtCdpTx(cdpType)
                    } else if (index == 3) {
                        self.onRepayCdpTx(cdpType)
                    }
                });
            }
        }
    }
    
}
