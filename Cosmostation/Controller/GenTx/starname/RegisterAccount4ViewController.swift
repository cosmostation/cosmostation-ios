//
//  RegisterAccount4ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/10/30.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class RegisterAccount4ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, PasswordViewDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var resigter4Tableview: UITableView!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.resigter4Tableview.delegate = self
        self.resigter4Tableview.dataSource = self
        self.resigter4Tableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.resigter4Tableview.register(UINib(nibName: "RegistAccountCheckCell", bundle: nil), forCellReuseIdentifier: "RegistAccountCheckCell")
    }
    
    override func enableUserInteraction() {
        self.resigter4Tableview.reloadData()
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RegistAccountCheckCell? = tableView.dequeueReusableCell(withIdentifier:"RegistAccountCheckCell") as? RegistAccountCheckCell
        
        let starnameFee = WUtils.getStarNameRegisterAccountFee("open")
        cell?.feeAmountLabel.attributedText = WDP.dpAmount((pageHolderVC.mFee?.amount[0].amount)!, cell!.feeAmountLabel.font, 6, 6)
        cell?.starnameFeeAmount.attributedText = WDP.dpAmount(starnameFee.stringValue, cell!.starnameFeeAmount.font, 6, 6)
        cell?.starnameLabel.text = pageHolderVC.mStarnameAccount! + "*" + pageHolderVC.mStarnameDomain!
        
        let extendTime = WUtils.getStarNameRegisterDomainExpireTime()
        let expireTime = Date().millisecondsSince1970 + extendTime
        cell?.expireDate.text = WDP.dpTime(expireTime)
        cell?.memoLabel.text = pageHolderVC.mMemo
        
        let resources = pageHolderVC.mStarnameResources_gRPC
        if (resources.count == 0) {
            cell?.connectedAddressesLabel.text = ""
        } else {
            var resourceString = ""
            for resource in resources {
                resourceString.append(resource.uri + "\n" + resource.resource + "\n\n")
            }
            cell?.connectedAddressesLabel.text = resourceString
        }
        return cell!
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnConfirm.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        if (BaseData.instance.isAutoPass()) {
            self.onFetchgRPCAuth(pageHolderVC.mAccount!)
        } else {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
            passwordVC.resultDelegate = self
            self.navigationController?.pushViewController(passwordVC, animated: false)
        }
        
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            self.onFetchgRPCAuth(pageHolderVC.mAccount!)
        }
    }
    
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.onBroadcastGrpcTx(response)
                }
                try channel.close().wait()
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onBroadcastGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
        DispatchQueue.global().async {
            let reqTx = Signer.genSignedRegisterAccountMsgTxgRPC(auth!, self.account!.account_pubkey_type,
                                                                 self.pageHolderVC.mStarnameDomain!,
                                                                 self.pageHolderVC.mStarnameAccount!,
                                                                 self.pageHolderVC.mAccount!.account_address,
                                                                 self.pageHolderVC.mAccount!.account_address,
                                                                 self.pageHolderVC.mStarnameResources_gRPC,
                                                                 self.pageHolderVC.mFee!,
                                                                 self.pageHolderVC.mMemo!,
                                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                 self.chainType!)
            
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                if let response = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    DispatchQueue.main.async(execute: {
                        if (self.waitAlert != nil) {
                            self.waitAlert?.dismiss(animated: true, completion: {
                                self.onStartTxDetailgRPC(response)
                            })
                        }
                    });
                }
                try channel.close().wait()
            } catch {
                print("onBroadcastGrpcTx failed: \(error)")
            }
        }
    }
}
