//
//  StakingTokenDetailViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/30.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class StakingTokenDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var naviTokenImg: UIImageView!
    @IBOutlet weak var naviTokenSymbol: UILabel!
    @IBOutlet weak var naviPerPrice: UILabel!
    @IBOutlet weak var naviUpdownPercent: UILabel!
    @IBOutlet weak var naviUpdownImg: UIImageView!
    
    @IBOutlet weak var tokenDetailTableView: UITableView!
    @IBOutlet weak var btnBep3Send: UIButton!
    
    var stakingDenom = ""
    var stakingDivideDecimal: Int16 = 6
    var stakingDisplayDecimal: Int16 = 6
    var totalAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.stakingDenom = WUtils.getMainDenom(chainConfig)
        self.stakingDivideDecimal = WUtils.mainDivideDecimal(chainType)
        self.stakingDisplayDecimal = WUtils.mainDisplayDecimal(chainType)
        
        self.onInitView()
        
        self.tokenDetailTableView.delegate = self
        self.tokenDetailTableView.dataSource = self
        self.tokenDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenDetailTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.tokenDetailTableView.register(UINib(nibName: "TokenStakingOldCell", bundle: nil), forCellReuseIdentifier: "TokenStakingOldCell")
        self.tokenDetailTableView.register(UINib(nibName: "TokenDetailVestingDetailCell", bundle: nil), forCellReuseIdentifier: "TokenDetailVestingDetailCell")
        self.tokenDetailTableView.register(UINib(nibName: "TokenDetailUnbondingDetailCell", bundle: nil), forCellReuseIdentifier: "TokenDetailUnbondingDetailCell")
        self.tokenDetailTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
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
        WUtils.setDenomTitle(chainType, naviTokenSymbol)
        self.naviTokenImg.image = chainConfig?.stakeDenomImg
        self.naviPerPrice.attributedText = WUtils.dpPerUserCurrencyValue(WUtils.getMainDenom(chainConfig), naviPerPrice.font)
        self.naviUpdownPercent.attributedText = WUtils.dpValueChange(WUtils.getMainDenom(chainConfig), font: naviUpdownPercent.font)
        let changeValue = WUtils.valueChange(WUtils.getMainDenom(chainConfig))
        if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { naviUpdownImg.image = UIImage(named: "priceUp") }
        else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { naviUpdownImg.image = UIImage(named: "priceDown") }
        else { naviUpdownImg.image = nil }
        
        if (chainType == ChainType.BINANCE_MAIN) {
            totalAmount = WUtils.getAllBnbToken(stakingDenom)
            btnBep3Send.isHidden = false
        } else if (chainType == ChainType.OKEX_MAIN) {
            totalAmount = WUtils.getAllExToken(stakingDenom)
        }
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
            return 0
        } else if (section == 3) {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
            cell?.onBindTokenDetail(account, chainConfig)
            cell?.onBindValue(stakingDenom, totalAmount, stakingDivideDecimal)
            cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
            return cell!
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenStakingOldCell") as? TokenStakingOldCell
            cell?.onBindStakingToken(chainType!)
            return cell!
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailVestingDetailCell") as? TokenDetailVestingDetailCell
            cell?.onBindVestingToken(chainType!, stakingDenom)
            return cell!
            
        } else if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailUnbondingDetailCell") as? TokenDetailUnbondingDetailCell
            cell?.onBindUnbondingToken(chainType!)
            return cell!
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
        return cell!
    }
    
    
    @objc func onClickActionShare() {
        self.shareAddress(account!.account_address, account?.getDpName())
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if (account?.account_has_private == false) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
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
    
    @IBAction func onClickBep3Send(_ sender: UIButton) {
        if (!SUPPORT_BEP3_SWAP) {
            self.onShowToast(NSLocalizedString("error_bep3_swap_temporary_disable", comment: ""))
            return
        }
        
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_HTLC_SWAP
        txVC.mHtlcDenom = stakingDenom
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
