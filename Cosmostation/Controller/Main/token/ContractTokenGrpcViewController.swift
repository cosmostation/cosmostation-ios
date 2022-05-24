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
    
    @IBOutlet weak var topCard: CardView!
    @IBOutlet weak var topKeyState: UIImageView!
    @IBOutlet weak var topDpAddress: UILabel!
    @IBOutlet weak var topValue: UILabel!
    
    @IBOutlet weak var tokenTableView: UITableView!
    @IBOutlet weak var btnIbcSend: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    var mCw20Token: Cw20Token?
    var mTotalAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "TokenDetailCommonCell", bundle: nil), forCellReuseIdentifier: "TokenDetailCommonCell")
        self.tokenTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        
        let tapTotalCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickActionShare))
        self.topCard.addGestureRecognizer(tapTotalCard)
        
        self.onInitView()
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
            self.topValue.attributedText = WUtils.dpUserCurrencyValue(mCw20Token!.denom, mTotalAmount, mCw20Token!.decimal, topValue.font)
            
            self.perPrice.attributedText = WUtils.dpPerUserCurrencyValue(mCw20Token!.denom, perPrice.font)
            self.updownPercent.attributedText = WUtils.dpValueChange(mCw20Token!.denom, font: updownPercent.font)
            let changeValue = WUtils.valueChange(mCw20Token!.denom)
            if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { updownImg.image = UIImage(named: "priceUp") }
            else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { updownImg.image = UIImage(named: "priceDown") }
            else { updownImg.image = nil }
        }
        
        self.topCard.backgroundColor = WUtils.getChainBg(chainType)
        if (account?.account_has_private == true) {
            self.topKeyState.image = topKeyState.image?.withRenderingMode(.alwaysTemplate)
            self.topKeyState.tintColor = WUtils.getChainColor(chainType)
        }
        self.topDpAddress.text = account?.account_address
        self.topDpAddress.adjustsFontSizeToFitWidth = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailCommonCell") as? TokenDetailCommonCell
        if (mCw20Token != nil) {
            cell?.onBindCw20Token(chainType, mCw20Token!)
        }
        return cell!
    }
    
    @objc func onClickActionShare() {
        self.shareAddress(account!.account_address, WUtils.getWalletName(account))
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
        
        let gasDenom = WUtils.getGasDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_CW20_TRANSFER, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(gasDenom).compare(feeAmount).rawValue < 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mCw20SendContract = mCw20Token!.contract_address
        txVC.mType = TASK_CW20_TRANSFER
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
