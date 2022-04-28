//
//  NativeTokenGrpcViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/20.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class NativeTokenGrpcViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var naviTokenImg: UIImageView!
    @IBOutlet weak var naviTokenSymbol: UILabel!
    @IBOutlet weak var naviPerPrice: UILabel!
    @IBOutlet weak var naviUpdownPercent: UILabel!
    @IBOutlet weak var naviUpdownImg: UIImageView!
    
    @IBOutlet weak var topCard: CardView!
    @IBOutlet weak var topKeyState: UIImageView!
    @IBOutlet weak var topDpAddress: UILabel!
    @IBOutlet weak var topValue: UILabel!
    
    @IBOutlet weak var tokenTableView: UITableView!
    @IBOutlet weak var btnBepSend: UIButton!
    @IBOutlet weak var btnIbcSend: UIButton!
    @IBOutlet weak var btnSend: UIButton!

    var nativeDenom = ""
    var nativeDivideDecimal: Int16 = 6
    var nativeDisplayDecimal: Int16 = 6
    var totalAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "TokenDetailNativeCell", bundle: nil), forCellReuseIdentifier: "TokenDetailNativeCell")
        self.tokenTableView.register(UINib(nibName: "TokenDetailVestingDetailCell", bundle: nil), forCellReuseIdentifier: "TokenDetailVestingDetailCell")
        self.tokenTableView.register(UINib(nibName: "NewHistoryCell", bundle: nil), forCellReuseIdentifier: "NewHistoryCell")
        
        let tapTotalCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickActionShare))
        self.topCard.addGestureRecognizer(tapTotalCard)
        
        if (ChainType.isHtlcSwappableCoin(chainType, nativeDenom)) {
            self.btnBepSend.isHidden = false
        } else {
            self.btnIbcSend.isHidden = false
        }
        
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
        if (chainType == ChainType.OSMOSIS_MAIN) {
            WUtils.DpOsmosisTokenName(naviTokenSymbol, nativeDenom)
            WUtils.DpOsmosisTokenImg(naviTokenImg, nativeDenom)
            if (nativeDenom == OSMOSIS_ION_DENOM) {
                nativeDivideDecimal = 6
                nativeDisplayDecimal = 6
                totalAmount = BaseData.instance.getAvailableAmount_gRPC(nativeDenom)
            }
            
        } else if (chainType == ChainType.EMONEY_MAIN) {
            naviTokenSymbol.text = nativeDenom.uppercased()
            naviTokenImg.af_setImage(withURL: URL(string: EMONEY_COIN_IMG_URL + nativeDenom + ".png")!)
            nativeDivideDecimal = 6
            nativeDisplayDecimal = 6
            totalAmount = BaseData.instance.getAvailableAmount_gRPC(nativeDenom)
            
        } else if (chainType == ChainType.KAVA_MAIN) {
            WUtils.DpKavaTokenName(naviTokenSymbol, nativeDenom)
            naviTokenImg.af_setImage(withURL: URL(string: WUtils.getKavaCoinImg(nativeDenom))!)
            nativeDivideDecimal = WUtils.getKavaCoinDecimal(nativeDenom)
            nativeDisplayDecimal = WUtils.getKavaCoinDecimal(nativeDenom)
            totalAmount = WUtils.getKavaTokenAll(nativeDenom)
            
        } else if (chainType == ChainType.CRESCENT_MAIN || chainType == ChainType.CRESCENT_TEST) {
            if (nativeDenom == CRESCENT_BCRE_DENOM) {
                naviTokenSymbol.text = nativeDenom.uppercased()
                naviTokenImg.image = UIImage(named: "tokenBcre")
                nativeDivideDecimal = 6
                nativeDisplayDecimal = 6
                totalAmount = BaseData.instance.getAvailableAmount_gRPC(nativeDenom)
            }
            
        }
        
        self.naviPerPrice.attributedText = WUtils.dpPerUserCurrencyValue(nativeDenom, naviPerPrice.font)
        self.naviUpdownPercent.attributedText = WUtils.dpValueChange(nativeDenom, font: naviUpdownPercent.font)
        let changeValue = WUtils.valueChange(nativeDenom)
        if (changeValue.compare(NSDecimalNumber.zero).rawValue > 0) { naviUpdownImg.image = UIImage(named: "priceUp") }
        else if (changeValue.compare(NSDecimalNumber.zero).rawValue < 0) { naviUpdownImg.image = UIImage(named: "priceDown") }
        else { naviUpdownImg.image = nil }
        
        self.topCard.backgroundColor = WUtils.getChainBg(chainType)
        if (account?.account_has_private == true) {
            self.topKeyState.image = topKeyState.image?.withRenderingMode(.alwaysTemplate)
            self.topKeyState.tintColor = WUtils.getChainColor(chainType)
        }
        
        self.topDpAddress.text = account?.account_address
        self.topDpAddress.adjustsFontSizeToFitWidth = true
        self.topValue.attributedText = WUtils.dpUserCurrencyValue(nativeDenom, totalAmount, nativeDivideDecimal, topValue.font)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (section == 1) {
            if (BaseData.instance.onParseRemainVestingsByDenom_gRPC(nativeDenom).count > 0) { return 1 }
            else { return 0 }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailNativeCell") as? TokenDetailNativeCell
            cell?.onBindNativeToken(chainType, nativeDenom)
            return cell!
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TokenDetailVestingDetailCell") as? TokenDetailVestingDetailCell
            cell?.onBindVestingToken(chainType!, nativeDenom)
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewHistoryCell") as? NewHistoryCell
            return cell!
        }
    }
    
    @objc func onClickActionShare() {
        self.shareAddress(account!.account_address, WUtils.getWalletName(account))
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickIbcSend(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        let stakingDenom = WUtils.getMainDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_IBC_TRANSFER, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(stakingDenom).compare(feeAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        self.onAlertIbcTransfer()
    }
    
    func onAlertIbcTransfer() {
        let unAuthTitle = NSLocalizedString("str_warning", comment: "")
        let unAuthMsg = NSLocalizedString("str_msg_ibc", comment: "")
        let noticeAlert = UIAlertController(title: unAuthTitle, message: unAuthMsg, preferredStyle: .alert)
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
        txVC.mIBCSendDenom = nativeDenom
        txVC.mType = TASK_IBC_TRANSFER
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
        
        let stakingDenom = WUtils.getMainDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, COSMOS_MSG_TYPE_TRANSFER2, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(stakingDenom).compare(feeAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mToSendDenom = nativeDenom
        txVC.mType = COSMOS_MSG_TYPE_TRANSFER2
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    @IBAction func onClickBepSend(_ sender: Any) {
        if (!SUPPORT_BEP3_SWAP) {
            self.onShowToast(NSLocalizedString("error_bep3_swap_temporary_disable", comment: ""))
            return
        }
        
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        
        let stakingDenom = WUtils.getMainDenom(chainType)
        let feeAmount = WUtils.getEstimateGasFeeAmount(chainType!, TASK_TYPE_HTLC_SWAP, 0)
        if (BaseData.instance.getAvailableAmount_gRPC(stakingDenom).compare(feeAmount).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_not_enough_balance_to_send", comment: ""))
            return
        }
        
        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_HTLC_SWAP
        txVC.mHtlcDenom = nativeDenom
        txVC.hidesBottomBarWhenPushed = true
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.navigationController?.pushViewController(txVC, animated: true)
    }
}
