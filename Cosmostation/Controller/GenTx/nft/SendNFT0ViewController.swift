//
//  SendNFT0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/26.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class SendNFT0ViewController: BaseViewController, QrScannerDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var addressInput: AddressInputTextField!
    @IBOutlet weak var btnQrScan: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.addressInput.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("recipient_address", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "_font03")])
        
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btnQrScan.borderColor = UIColor.init(named: "_font05")
        btnPaste.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btnQrScan.borderColor = UIColor.init(named: "_font05")
        btnPaste.borderColor = UIColor.init(named: "_font05")
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
    }
    
    func scannedAddress(result: String) {
        self.addressInput.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let myString = UIPasteboard.general.string {
            self.addressInput.text = myString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        self.pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInputRecipient = addressInput.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (WUtils.isValidChainAddress(chainConfig, userInputRecipient)) {
            btnCancel.isUserInteractionEnabled = true
            btnNext.isUserInteractionEnabled = true
            pageHolderVC.mRecipinetAddress = userInputRecipient
            pageHolderVC.onNextPage()
            
        } else {
            self.onShowToast(NSLocalizedString("error_invalid_address_or_pubkey", comment: ""))
            return;
        }
    }
}
