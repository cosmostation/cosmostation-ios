//
//  WalletDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 03/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import QRCode
import Alamofire
import UserNotifications
import GRPC
import NIO

class WalletDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, PasswordViewDelegate {
    
    @IBOutlet weak var walletDetailListTableView: UITableView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnImportPKey: UIButton!
    @IBOutlet weak var btnImportMnemonic: UIButton!
    @IBOutlet weak var btnCheckPkey: UIButton!
    @IBOutlet weak var btnCheckMnemonic: UIButton!
    
    var selectedAccount: Account!
    var selectedChainType: ChainType!
    var selectedChainConfig: ChainConfig!
    var chainId = ""
    var rewardAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedChainType = ChainFactory.getChainType(selectedAccount.account_base_chain)
        self.selectedChainConfig = ChainFactory.getChainConfig(selectedChainType)
        
        self.walletDetailListTableView.delegate = self
        self.walletDetailListTableView.dataSource = self
        self.walletDetailListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.walletDetailListTableView.register(UINib(nibName: "WalletDetailAddressCell", bundle: nil), forCellReuseIdentifier: "WalletDetailAddressCell")
        self.walletDetailListTableView.register(UINib(nibName: "WalletDetailInfoCell", bundle: nil), forCellReuseIdentifier: "WalletDetailInfoCell")
        self.walletDetailListTableView.register(UINib(nibName: "WalletDetailRewardCell", bundle: nil), forCellReuseIdentifier: "WalletDetailRewardCell")
        self.walletDetailListTableView.rowHeight = UITableView.automaticDimension
        self.walletDetailListTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if (selectedChainConfig.isGrpc) {
            self.onFetchRewardAddress_gRPC(selectedAccount!.account_address)
            self.onFetchgRPCNodeInfo()
        } else {
            self.onFetchNodeInfo()
        }
        
        if (selectedAccount.account_has_private) {
            self.btnImportPKey.isHidden = true
            self.btnImportMnemonic.isHidden = true
            self.btnCheckPkey.isHidden = false
            self.btnCheckMnemonic.isHidden = false
            
        } else {
            self.btnImportPKey.isHidden = false
            self.btnImportMnemonic.isHidden = false
            self.btnCheckPkey.isHidden = true
            self.btnCheckMnemonic.isHidden = true
            
        }
        
        btnDelete.setTitle(NSLocalizedString("str_delete_wallet", comment: ""), for: .normal)
        btnImportPKey.setTitle(NSLocalizedString("str_import_privatekey", comment: ""), for: .normal)
        btnImportMnemonic.setTitle(NSLocalizedString("str_import_mnemonic", comment: ""), for: .normal)
        btnCheckPkey.setTitle(NSLocalizedString("str_check_privatekey", comment: ""), for: .normal)
        btnCheckMnemonic.setTitle(NSLocalizedString("str_check_mnemonic", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_wallet_detail", comment: "")
        self.navigationItem.title = NSLocalizedString("title_wallet_detail", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.stopAvoidingKeyboard()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 2) {
            if (rewardAddress == nil) { return 0 }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletDetailAddressCell") as! WalletDetailAddressCell
            cell.onBindView(selectedChainConfig, selectedAccount)
            cell.actionNickname = { self.onNicknameChange() }
            return cell
            
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletDetailInfoCell") as! WalletDetailInfoCell
            cell.onBindView(selectedChainConfig, selectedAccount, chainId)
            cell.actionAddress = { self.shareAddressType(self.selectedChainConfig, self.selectedAccount) }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"WalletDetailRewardCell") as! WalletDetailRewardCell
            cell.onBindView(selectedChainConfig, selectedAccount, rewardAddress)
            cell.actionReward = { self.onRewardAddressChange() }
            return cell
        }
    }
    
    func onReloadTableView(_ position: Int) {
        DispatchQueue.main.async(execute: {
            self.walletDetailListTableView.beginUpdates()
            self.walletDetailListTableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .none)
            self.walletDetailListTableView.endUpdates()
        });
    }
    
    func onNicknameChange() {
        let nameAlert = UIAlertController(title: NSLocalizedString("change_wallet_name", comment: ""), message: nil, preferredStyle: .alert)
        nameAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        nameAlert.addTextField { (textField) in textField.placeholder = NSLocalizedString("wallet_name", comment: "") }
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        nameAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { [weak nameAlert] (_) in
            let textField = nameAlert?.textFields![0]
            let trimmedString = textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmedString?.count ?? 0 > 0) {
                self.selectedAccount.account_nick_name = trimmedString!
                _ = BaseData.instance.updateAccount(self.selectedAccount)
                BaseData.instance.setNeedRefresh(true)
                self.onReloadTableView(0)
            }
        }))
        self.present(nameAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            nameAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onRewardAddressChange() {
        if (!selectedAccount.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }
        if (selectedChainConfig.chainType == .FETCH_MAIN || selectedChainConfig.chainType == .ONOMY_MAIN) {
            self.onShowToast("Disabled")
            return
        }
        
        let title = NSLocalizedString("reward_address_notice_title", comment: "")
        let msg1 = NSLocalizedString("reward_address_notice_msg", comment: "")
        let msg2 = NSLocalizedString("reward_address_notice_msg2", comment: "")
        let msg = msg1 + msg2
        let range = (msg as NSString).range(of: msg2)
        let noticeAlert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString(
            string: msg,
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)
            ]
        )
        attributedMessage.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14.0), range: range)
        attributedMessage.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
        
        noticeAlert.setValue(attributedMessage, forKey: "attributedMessage")
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default, handler: { _ in
            BaseData.instance.setRecentAccountId(self.selectedAccount.account_id)
            let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            txVC.mType = TASK_TYPE_MODIFY_REWARD_ADDRESS
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(txVC, animated: true)
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    var option: Int?
    @IBAction func onClickCheckMenmonic(_ sender: UIButton) {
        if (!selectedAccount.account_from_mnemonic) {
            self.onShowToast(NSLocalizedString("error_no_mnemonic", comment: ""))
            return
        }
        
        self.option = 1
        if (BaseData.instance.isAutoPass()) {
            self.onStartCheckVc()
        } else {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_SIMPLE_CHECK), animated: false)
        }
    }
    
    @IBAction func onClickCheckPrivateKey(_ sender: UIButton) {
        self.option = 2
        if (BaseData.instance.isAutoPass()) {
            self.onStartCheckVc()
        } else {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_SIMPLE_CHECK), animated: false)
        }
    }
    
    @IBAction func onClickImportMenmonic(_ sender: UIButton) {
        let restoreMnemonicVC = MnemonicRestoreViewController(nibName: "MnemonicRestoreViewController", bundle: nil)
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(restoreMnemonicVC, animated: true)
    }
    
    @IBAction func onClickImportPrivateKey(_ sender: UIButton) {
        let restorePKeyVC = PrivateKeyRestoreViewController(nibName: "PrivateKeyRestoreViewController", bundle: nil)
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(restorePKeyVC, animated: true)
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: NSLocalizedString("delete_wallet", comment: ""), message: NSLocalizedString("delete_wallet_msg", comment: ""), preferredStyle: .alert)
        deleteAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive, handler: { _ in
            if (self.selectedAccount.account_has_private) {
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_DELETE_ACCOUNT), animated: false)
                
            } else {
                self.showWaittingAlert()
                self.onDeleteWallet(self.selectedAccount) {
                    DispatchQueue.main.async(execute: {
                        self.onSelectNextAccount()
                        self.hideWaittingAlert()
                        self.onShowToast(NSLocalizedString("wallet_delete_complete", comment: ""))
                        self.onStartIntro()
                    });
                }
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(deleteAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            deleteAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(310), execute: {
                self.onStartCheckVc()
            })
            
        } else if (result == PASSWORD_RESUKT_OK_FOR_DELETE) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(310), execute: {
                self.showWaittingAlert()
                self.onDeleteWallet(self.selectedAccount) {
                    DispatchQueue.main.async(execute: {
                        self.onSelectNextAccount()
                        self.hideWaittingAlert()
                        self.onShowToast(NSLocalizedString("wallet_delete_complete", comment: ""))
                        self.onStartIntro()
                    });
                }
            })
        }
    }
    
    func onStartCheckVc() {
        if (self.option == 1) {
            let mnemonicDetailVC = MnemonicDetailViewController(nibName: "MnemonicDetailViewController", bundle: nil)
            mnemonicDetailVC.mnemonicId = self.selectedAccount.account_mnemonic_id
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(mnemonicDetailVC, animated: true)
            
        } else if (self.option == 2) {
            let walletCheckPkeyVC = WalletCheckPKeyViewController(nibName: "WalletCheckPKeyViewController", bundle: nil)
            walletCheckPkeyVC.hidesBottomBarWhenPushed = true
            walletCheckPkeyVC.selectedAccount = self.selectedAccount
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(walletCheckPkeyVC, animated: true)
        }
    }
    
    func onFetchRewardAddress_gRPC(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.selectedChainConfig)!
                let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = address }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegatorWithdrawAddress(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.rewardAddress = response.withdrawAddress.replacingOccurrences(of: "\"", with: "")
                }
                try channel.close().wait()
            } catch { print("onFetchRewardAddress_gRPC failed: \(error)") }
            self.onReloadTableView(2)
        }
    }
    
    func onFetchNodeInfo() {
        let request = Alamofire.request(BaseNetWork.nodeInfoUrl(selectedChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let nodeInfo = responseData.object(forKey: "node_info") as? NSDictionary else {
                    return
                }
                self.chainId = NodeInfo.init(nodeInfo).network ?? ""
                self.onReloadTableView(1)
                
            case .failure(let error):
                print("onFetchNodeInfo ", error)
            }
        }
    }
    
    func onFetchgRPCNodeInfo() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.selectedChainConfig)!
                let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest()
                if let response = try? Cosmos_Base_Tendermint_V1beta1_ServiceClient(channel: channel).getNodeInfo(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.chainId = response.defaultNodeInfo.network
                }
                try channel.close().wait()
            } catch { print("onFetchgRPCNodeInfo failed: \(error)") }
            self.onReloadTableView(1)
        }
    }
}
