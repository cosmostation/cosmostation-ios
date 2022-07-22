//
//  ContractTokenGrpcViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class ContractTokenGrpcViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tokenImg: UIImageView!
    @IBOutlet weak var tokenSymbol: UILabel!
    @IBOutlet weak var perPrice: UILabel!
    @IBOutlet weak var updownPercent: UILabel!
    @IBOutlet weak var updownImg: UIImageView!
    
    @IBOutlet weak var tokenTableView: UITableView!
    @IBOutlet weak var btnIbcSend: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    var mCw20Token: Cw20Token?
    var mTotalAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.onInitView()
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.tokenTableView.register(UINib(nibName: "TokenDetailCommonCell", bundle: nil), forCellReuseIdentifier: "TokenDetailCommonCell")
        self.tokenTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
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
        if (mCw20Token != nil) {
            tokenImg.af_setImage(withURL: mCw20Token!.getImgUrl())
            tokenSymbol.text = mCw20Token!.denom.uppercased()
            
            self.mTotalAmount = mCw20Token!.getAmount()
            
            self.perPrice.attributedText = WUtils.dpPerUserCurrencyValue(mCw20Token!.denom, perPrice.font)
            self.updownPercent.attributedText = WUtils.dpValueChange(mCw20Token!.denom, font: updownPercent.font)
            let changeValue = WUtils.valueChange(mCw20Token!.denom)
            if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { updownImg.image = UIImage(named: "priceUp") }
            else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { updownImg.image = UIImage(named: "priceDown") }
            else { updownImg.image = nil }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
            if (mCw20Token != nil) {
                cell?.onBindValue(mCw20Token!.denom, mTotalAmount, mCw20Token!.decimal)
            }
            cell?.onBindTokenDetail(account, chainConfig)
            cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
            return cell!
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailCommonCell") as? TokenDetailCommonCell
            if (mCw20Token != nil) {
                cell?.onBindCw20Token(chainType, mCw20Token!)
            }
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
            return cell!
        }
    }
    
    @objc func onClickActionShare() {
        self.shareAddress(account!.account_address, account?.getDpName())
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickIbcSend(_ sender: UIButton) {
        self.onShowToast(NSLocalizedString("prepare", comment: ""))
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
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mCw20SendContract = mCw20Token!.contract_address
        txVC.mType = TASK_TYPE_IBC_CW20_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
