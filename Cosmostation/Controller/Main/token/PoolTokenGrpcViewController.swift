//
//  PoolTokenGrpcViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/20.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class PoolTokenGrpcViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var naviTokenImg: UIImageView!
    @IBOutlet weak var naviTokenSymbol: UILabel!
    @IBOutlet weak var naviPerPrice: UILabel!
    @IBOutlet weak var naviUpdownPercent: UILabel!
    @IBOutlet weak var naviUpdownImg: UIImageView!
    
    @IBOutlet weak var tokenTableView: UITableView!
    @IBOutlet weak var btnIbcSend: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    var poolDenom = ""
    var poolDivideDecimal: Int16 = 18
    var poolDisplayDecimal: Int16 = 18
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
        self.tokenTableView.register(UINib(nibName: "TokenDetailNativeCell", bundle: nil), forCellReuseIdentifier: "TokenDetailNativeCell")
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
        if (chainType == ChainType.OSMOSIS_MAIN) {
            WDP.dpSymbol(chainConfig, poolDenom, naviTokenSymbol)
            WDP.dpSymbolImg(chainConfig, poolDenom, naviTokenImg)
            
            poolDivideDecimal = 18
            poolDisplayDecimal = 18
            totalAmount = BaseData.instance.getAvailableAmount_gRPC(poolDenom)
            
        } else if (chainType == ChainType.INJECTIVE_MAIN) {
            naviTokenImg.image = UIImage(named: "tokenInjectivePool")
            naviTokenSymbol.text = poolDenom.uppercased()
            
            poolDivideDecimal = 18
            poolDisplayDecimal = 18
            totalAmount = BaseData.instance.getAvailableAmount_gRPC(poolDenom)
            
        } else if (chainType == ChainType.CRESCENT_MAIN) {
            naviTokenImg.image = UIImage(named: "tokenCrescentpool")
            naviTokenSymbol.text = poolDenom.uppercased()
            
            poolDivideDecimal = 12
            poolDisplayDecimal = 12
            totalAmount = BaseData.instance.getAvailableAmount_gRPC(poolDenom)
        }
        
        self.naviPerPrice.attributedText = WUtils.dpPerUserCurrencyValue(poolDenom, naviPerPrice.font)
        self.naviUpdownPercent.attributedText = WUtils.dpValueChange(poolDenom, font: naviUpdownPercent.font)
        let changeValue = WUtils.valueChange(poolDenom)
        if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { naviUpdownImg.image = UIImage(named: "priceUp") }
        else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { naviUpdownImg.image = UIImage(named: "priceDown") }
        else { naviUpdownImg.image = nil }
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
            cell?.onBindValue(poolDenom, totalAmount, poolDivideDecimal)
            cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
            return cell!
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailNativeCell") as? TokenDetailNativeCell
            cell?.onBindPoolToken(chainType, poolDenom)
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
        self.onShowToast(NSLocalizedString("prepare", comment: ""))
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        self.onShowToast(NSLocalizedString("prepare", comment: ""))
//        if (!account!.account_has_private) {
//            self.onShowAddMenomicDialog()
//            return
//        }
//
        
//        if (!BaseData.instance.isTxFeePayable(chainConfig)) {
//            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
//            return
//        }
//
//        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
//        txVC.mToSendDenom = poolDenom
//        txVC.mType = TASK_TYPE_TRANSFER
//        txVC.hidesBottomBarWhenPushed = true
//        self.navigationItem.title = ""
//        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
