//
//  IBCTokenGrpcViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/20.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class IBCTokenGrpcViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var naviTokenImg: UIImageView!
    @IBOutlet weak var naviTokenSymbol: UILabel!
    @IBOutlet weak var naviTokenChannel: UILabel!
    @IBOutlet weak var naviPerPrice: UILabel!
    @IBOutlet weak var naviUpdownPercent: UILabel!
    @IBOutlet weak var naviUpdownImg: UIImageView!
    
    @IBOutlet weak var tokenTableView: UITableView!
    @IBOutlet weak var btnIbcSend: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    var ibcDenom = ""
    var baseDenom = ""
    var ibcDivideDecimal: Int16 = 6
    var ibcDisplayDecimal: Int16 = 6
    var totalAmount = NSDecimalNumber.zero

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
        self.tokenTableView.register(UINib(nibName: "TokenDetailIBCInfoCell", bundle: nil), forCellReuseIdentifier: "TokenDetailIBCInfoCell")
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
        let ibcHash = ibcDenom.replacingOccurrences(of: "ibc/", with: "")
        baseDenom = BaseData.instance.getBaseDenom(chainConfig, ibcDenom)
        guard let ibcToken = BaseData.instance.getIbcToken(ibcHash) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        ibcDivideDecimal = ibcToken.decimal ?? 6
        ibcDisplayDecimal = ibcToken.decimal ?? 6
        totalAmount = BaseData.instance.getAvailableAmount_gRPC(ibcDenom)
        print("ibcToken ", ibcToken)
        
        if (ibcToken.auth == true) {
            WDP.dpSymbolImg(chainConfig, ibcDenom, naviTokenImg)
            naviTokenSymbol.text = ibcToken.display_denom?.uppercased()
            naviTokenChannel.text = "(" + ibcToken.channel_id! + ")"
            
            self.naviPerPrice.attributedText = WUtils.dpPerUserCurrencyValue(baseDenom, naviPerPrice.font)
            self.naviUpdownPercent.attributedText = WUtils.dpValueChange(baseDenom, font: naviUpdownPercent.font)
            let changeValue = WUtils.valueChange(baseDenom)
            if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { naviUpdownImg.image = UIImage(named: "priceUp") }
            else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { naviUpdownImg.image = UIImage(named: "priceDown") }
            else { self.naviUpdownImg.image = nil }
            
        } else {
            naviTokenImg.image = UIImage(named: "tokenDefaultIbc")
            naviTokenSymbol.text = "UnKnown"
            naviTokenChannel.text = "(" + ibcToken.channel_id! + ")"
            
            self.naviPerPrice.text = ""
            self.naviUpdownPercent.text = ""
            self.naviUpdownImg.image = nil
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
            cell?.onBindTokenDetail(account, chainConfig)
            cell?.onBindValue(baseDenom, totalAmount, ibcDivideDecimal)
            cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
            return cell!
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailIBCInfoCell") as? TokenDetailIBCInfoCell
            cell?.onBindIBCTokenInfo(chainType!, ibcDenom)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
            return cell!
        }
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickIbcSend(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        if (BaseData.instance.getAvailableAmount_gRPC(ibcDenom).compare(NSDecimalNumber.zero).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        self.onAlertIbcTransfer()
    }
    
    func onAlertIbcTransfer() {
        let unAuthTitle = NSLocalizedString("str_notice", comment: "")
        let unAuthMsg = NSLocalizedString("str_msg_ibc", comment: "")
        let noticeAlert = UIAlertController(title: unAuthTitle, message: unAuthMsg, preferredStyle: .alert)
        if #available(iOS 13.0, *) { noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default, handler: { _ in
            self.onStartIbc()
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onStartIbc() {
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mIBCSendDenom = ibcDenom
        txVC.mType = TASK_TYPE_IBC_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
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
        if (BaseData.instance.getAvailableAmount_gRPC(ibcDenom).compare(NSDecimalNumber.zero).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mToSendDenom = ibcDenom
        txVC.mType = TASK_TYPE_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
