//
//  RewardAddress1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class RewardAddress1ViewController: BaseViewController, QrScannerDelegate {
    
    @IBOutlet weak var newRewardAddressInput: AddressInputTextField!
    @IBOutlet weak var currentRewardAddressLabel: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    @IBOutlet weak var currentRecipientTitle: UILabel!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.onFetchRewardAddress_gRPC(pageHolderVC.mAccount!.account_address)
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.init(named: "photon")
        btnScan.borderColor = UIColor.font05
        btnPaste.borderColor = UIColor.font05
        
        currentRecipientTitle.text = NSLocalizedString("str_current_reward_recipient_address", comment: "")
        btnScan.setTitle(NSLocalizedString("str_qr_scan", comment: ""), for: .normal)
        btnPaste.setTitle(NSLocalizedString("str_paste", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.init(named: "photon")
        btnScan.borderColor = UIColor.font05
        btnPaste.borderColor = UIColor.font05
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let myString = UIPasteboard.general.string {
            self.newRewardAddressInput.text = myString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickQrScan(_ sender: UIButton) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (currentRewardAddressLabel.text == "-") {
            self.onShowToast(NSLocalizedString("error_network", comment: ""))
            return;
        }
        
        let userInput = newRewardAddressInput.text?.trimmingCharacters(in: .whitespaces)
        if (currentRewardAddressLabel.text == userInput) {
            self.onShowToast(NSLocalizedString("error_same_reward_address", comment: ""))
            return;
        }
        
        if (!WUtils.isValidChainAddress(chainConfig, userInput)) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.mToChangeRewardAddress = userInput
        pageHolderVC.onNextPage()
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func onFetchRewardAddress_gRPC(_ address: String) {
        DispatchQueue.global().async {
            var responseAddress = ""
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.pageHolderVC.chainType!, group)!
            defer { try! channel.close().wait() }
            
            let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with {
                $0.delegatorAddress = address
            }
            do {
                let response = try Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegatorWithdrawAddress(req).response.wait()
                responseAddress = response.withdrawAddress.replacingOccurrences(of: "\"", with: "")
            } catch {
                print("onFetchRedelegation_gRPC failed: \(error)")
            }
            DispatchQueue.main.async(execute: {
                self.currentRewardAddressLabel.text = responseAddress
                if (responseAddress != address) {
                    self.currentRewardAddressLabel.textColor = UIColor.warnRed
                }
                self.currentRewardAddressLabel.adjustsFontSizeToFitWidth = true
                self.pageHolderVC.mCurrentRewardAddress = responseAddress
            });
        }
    }
    
    func scannedAddress(result: String) {
        newRewardAddressInput.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}
