//
//  AuthzSend1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzSend1ViewController: BaseViewController, QrScannerDelegate {
    
    @IBOutlet weak var targetAddressTextField: AddressInputTextField!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var pasteBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var grant: Cosmos_Authz_V1beta1_Grant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        targetAddressTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("recipient_address", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "_font04")])
        
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
        scanBtn.borderColor = UIColor.init(named: "_font05")
        pasteBtn.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        cancelBtn.borderColor = UIColor.init(named: "_font05")
        nextBtn.borderColor = UIColor.init(named: "photon")
        scanBtn.borderColor = UIColor.init(named: "_font05")
        pasteBtn.borderColor = UIColor.init(named: "_font05")
    }
    
    override func enableUserInteraction() {
        cancelBtn.isUserInteractionEnabled = true
        nextBtn.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
        
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let myString = UIPasteboard.general.string {
            self.targetAddressTextField.text = myString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        cancelBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = targetAddressTextField.text?.trimmingCharacters(in: .whitespaces)
        
        if (pageHolderVC.mGranterAddress == userInput) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (!WUtils.isValidChainAddress(chainConfig, userInput)) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        
        cancelBtn.isUserInteractionEnabled = false
        nextBtn.isUserInteractionEnabled = false
        pageHolderVC.mRecipinetAddress = userInput
        pageHolderVC.onNextPage()
    }
    
    func scannedAddress(result: String) {
        targetAddressTextField.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}
