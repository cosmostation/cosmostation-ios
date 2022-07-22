//
//  NativeTokenDetailViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class NativeTokenDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var naviTokenImg: UIImageView!
    @IBOutlet weak var naviTokenSymbol: UILabel!
    @IBOutlet weak var naviPerPrice: UILabel!
    @IBOutlet weak var naviUpdownPercent: UILabel!
    @IBOutlet weak var naviUpdownImg: UIImageView!
    
    @IBOutlet weak var tokenDetailTableView: UITableView!
    @IBOutlet weak var bntBep3Send: UIButton!
    
    var denom: String!
    var divideDecimal: Int16 = 6
    var displayDecimal: Int16 = 6
    var totalAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.onInitView()
        
        self.tokenDetailTableView.delegate = self
        self.tokenDetailTableView.dataSource = self
        self.tokenDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenDetailTableView.register(UINib(nibName: "WalletAddressCell", bundle: nil), forCellReuseIdentifier: "WalletAddressCell")
        self.tokenDetailTableView.register(UINib(nibName: "TokenDetailNativeCell", bundle: nil), forCellReuseIdentifier: "TokenDetailNativeCell")
        self.tokenDetailTableView.register(UINib(nibName: "TokenDetailVestingDetailCell", bundle: nil), forCellReuseIdentifier: "TokenDetailVestingDetailCell")
        self.tokenDetailTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        
        if (WUtils.isHtlcSwappableCoin(chainType, denom)) {
            self.bntBep3Send.isHidden = false
        }
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
        if (chainType == .BINANCE_MAIN) {
            guard let bnbToken = WUtils.getBnbToken(denom) else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            naviTokenImg.af_setImage(withURL: URL(string: BinanceTokenImgUrl + bnbToken.original_symbol + ".png")!)
            naviTokenSymbol.text = bnbToken.original_symbol.uppercased()
            
            totalAmount = WUtils.getBnbConvertAmount(denom!)
            
            self.naviPerPrice.attributedText = WUtils.dpBnbTokenUserCurrencyPrice(denom, naviPerPrice.font)
            self.naviUpdownPercent.text = ""
            self.naviUpdownImg.image = nil

        } else if (chainType == .OKEX_MAIN) {
            guard let okToken = WUtils.getOkToken(denom) else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            naviTokenImg.af_setImage(withURL: URL(string: OKTokenImgUrl + okToken.original_symbol! + ".png")!)
            naviTokenSymbol.text = okToken.original_symbol!.uppercased()
            
            totalAmount = WUtils.convertTokenToOkt(denom!)
            
            if (okToken.original_symbol == "okb") {
                self.naviPerPrice.attributedText = WUtils.dpPerUserCurrencyValue("okb", naviPerPrice.font)
                self.naviUpdownPercent.attributedText = WUtils.dpValueChange("okb", font: naviUpdownPercent.font)
                let changeValue = WUtils.valueChange("okb")
                if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { naviUpdownImg.image = UIImage(named: "priceUp") }
                else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { naviUpdownImg.image = UIImage(named: "priceDown") }
                else { naviUpdownImg.image = nil }
                
            } else {
                self.naviPerPrice.text = ""
                self.naviUpdownPercent.text = ""
                self.naviUpdownImg.image = nil
            }
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            return 1
        } else if (section == 2) {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletAddressCell") as? WalletAddressCell
            cell?.onBindTokenDetail(account, chainConfig)
            cell?.onBindValue(chainConfig!.stakeDenom, totalAmount, 0)
            cell?.actionTapAddress = { self.shareAddressType(self.chainConfig, self.account) }
            return cell!
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailNativeCell") as? TokenDetailNativeCell
            cell?.onBindNativeToken(chainType, denom)
            return cell!
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailVestingDetailCell") as? TokenDetailVestingDetailCell
            cell?.onBindVestingToken(chainType!, denom!)
            return cell!
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
        return cell!
    }
    
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        txVC.mHtlcDenom = denom!
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
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mToSendDenom = denom
        txVC.mType = TASK_TYPE_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
