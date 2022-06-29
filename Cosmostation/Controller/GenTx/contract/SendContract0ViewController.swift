//
//  SendContract0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/01/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class SendContract0ViewController: BaseViewController, QrScannerDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var addressInput: AddressInputTextField!
    @IBOutlet weak var btnQrScan: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
    }
    
    override func enableUserInteraction() {
        self.btnBack.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.modalPresentationStyle = .fullScreen
        qrScanVC.resultDelegate = self
        self.present(qrScanVC, animated: true, completion: nil)
    }
    
    func scannedAddress(result: String) {
        self.addressInput.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let myString = UIPasteboard.general.string {
            self.addressInput.text = myString
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBack.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInputRecipient = addressInput.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (WUtils.isStarnameValidStarName(userInputRecipient!.lowercased())) {
            self.onCheckNameservice(userInputRecipient!.lowercased())
            return;
        }
        if (account?.account_address == userInputRecipient) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        if (!WUtils.isValidChainAddress(chainType, userInputRecipient)) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        btnBack.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
        pageHolderVC.mToSendRecipientAddress = userInputRecipient
        pageHolderVC.onNextPage()
    }
    
    func onCheckNameservice(_ userInput: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(ChainType.IOV_MAIN, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Starname_V1beta1_QueryStarnameRequest.with { $0.starname = userInput }
                let response = try Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).starname(req, callOptions:BaseNetWork.getCallOptions()).response.wait()
                try channel.close().wait()
                DispatchQueue.main.async(execute: {
                    guard let matchedAddress = WUtils.checkStarnameWithResource(self.chainType!, response) else {
                        self.onShowToast(NSLocalizedString("error_no_mattched_starname", comment: ""))
                        return
                    }
                    if (self.account?.account_address == matchedAddress) {
                        self.onShowToast(NSLocalizedString("error_starname_self_send", comment: ""))
                        return;
                    }
                    self.onShowMatchedStarName(userInput, matchedAddress)
                });
                
            } catch {
                print("onFetchgRPCResolve failed: \(error)")
                DispatchQueue.main.async(execute: {
                    self.onShowToast(NSLocalizedString("error_invalide_starname", comment: ""))
                    return
                });
            }
        }
    }
    
    func onShowMatchedStarName(_ starname: String, _ matchedAddress: String) {
        let msg = String(format: NSLocalizedString("str_starname_confirm_msg", comment: ""), starname, matchedAddress)
        let alertController = UIAlertController(title: NSLocalizedString("str_starname_confirm_title", comment: ""), message: msg, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default) { (_) -> Void in
            self.btnBack.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            self.pageHolderVC.mToSendRecipientAddress = matchedAddress
            self.pageHolderVC.onNextPage()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
