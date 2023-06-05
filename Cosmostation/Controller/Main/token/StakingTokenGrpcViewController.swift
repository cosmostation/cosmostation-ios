//
//  StakingTokenGrpcViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class StakingTokenGrpcViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var naviTokenImg: UIImageView!
    @IBOutlet weak var naviTokenSymbol: UILabel!
    @IBOutlet weak var naviPerPrice: UILabel!
    @IBOutlet weak var naviUpdownPercent: UILabel!
    
    @IBOutlet weak var tokenTableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    
    var stakingDenom = ""
    var totalAmount = NSDecimalNumber.zero
    var msAsset: MintscanAsset!
    var hasVesting = false
    var hasUnbonding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.stakingDenom = chainConfig!.stakeDenom
        
        self.onInitView()
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.tokenTableView.register(UINib(nibName: "TokenDetailStakingCell", bundle: nil), forCellReuseIdentifier: "TokenDetailStakingCell")
        self.tokenTableView.register(UINib(nibName: "TokenDetailCustomCell", bundle: nil), forCellReuseIdentifier: "TokenDetailCustomCell")
        self.tokenTableView.register(UINib(nibName: "TokenDetailVestingDetailCell", bundle: nil), forCellReuseIdentifier: "TokenDetailVestingDetailCell")
        self.tokenTableView.register(UINib(nibName: "TokenDetailUnbondingDetailCell", bundle: nil), forCellReuseIdentifier: "TokenDetailUnbondingDetailCell")
        self.tokenTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        
        self.btnSend.setTitle(NSLocalizedString("str_send", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func onInitView() {
        msAsset = BaseData.instance.getMSAsset(chainConfig!, stakingDenom)
        WDP.dpMainSymbol(chainConfig, naviTokenSymbol)
        self.naviTokenImg.image = chainConfig?.stakeDenomImg
        WDP.dpPrice(msAsset.coinGeckoId, naviPerPrice)
        WDP.dpPriceChanged(msAsset.coinGeckoId, naviUpdownPercent)
        let changePrice = WUtils.priceChange(msAsset.coinGeckoId)
        WDP.setPriceColor(naviUpdownPercent, changePrice)
        totalAmount = WUtils.getAllMainAsset(stakingDenom)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
            
        } else if (section == 1) {
            return 1
            
        } else if (section == 2) {
            if (BaseData.instance.onParseRemainVestingsByDenom_gRPC(stakingDenom).count > 0 ||
                BaseData.instance.mNeutronVesting.compare(NSDecimalNumber.zero).rawValue > 0) { return 1 }
            else { return 0 }
            
        } else if (section == 3) {
            if (BaseData.instance.getUnbondingSumAmount_gRPC().compare(NSDecimalNumber.zero).rawValue > 0) { return 1 }
            else { return 0 }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
            cell?.onBindTokenDetail(account, chainConfig)
            cell?.onBindValue(msAsset.coinGeckoId, totalAmount, chainConfig!.divideDecimal)
            cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
            return cell!
            
        } else if (indexPath.section == 1) {
            if (chainType == .NOBLE_MAIN || chainType == .NEUTRON_MAIN || chainType == .NEUTRON_TEST) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailCustomCell") as? TokenDetailCustomCell
                cell?.onBindStakingToken(chainConfig!)
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailStakingCell") as? TokenDetailStakingCell
                cell?.onBindStakingToken(chainConfig!)
                return cell!
            }
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailVestingDetailCell") as? TokenDetailVestingDetailCell
            cell?.onBindVestingToken(chainConfig!, stakingDenom)
            return cell!
            
        } else if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailUnbondingDetailCell") as? TokenDetailUnbondingDetailCell
            cell?.onBindUnbondingToken(chainConfig!)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
            return cell!
        }
    }
    

    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (BaseData.instance.getAvailableAmount_gRPC(stakingDenom).compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mToSendDenom = stakingDenom
        txVC.mType = TASK_TYPE_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
