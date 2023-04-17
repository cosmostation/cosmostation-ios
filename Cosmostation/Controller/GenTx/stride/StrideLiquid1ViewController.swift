//
//  StrideLiquidity1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/11/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class StrideLiquid1ViewController: BaseViewController, QrScannerDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var recipientAddressTitle: UILabel!
    @IBOutlet weak var recipientAddressinput: AddressInputTextField!
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet weak var btnQrScan: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var recipientChain: ChainConfig!
    var recipientableAccounts = Array<Account>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        recipientAddressinput.placeholder = NSLocalizedString("tx_send_nft_0", comment: "")
        recipientChain = ChainFactory.SUPPRT_CONFIG().filter { pageHolderVC.mChainId!.starts(with: $0.chainIdPrefix) == true }.first
        
        recipientAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        btnWallet.setTitle(NSLocalizedString("str_wallet", comment: ""), for: .normal)
        btnQrScan.setTitle(NSLocalizedString("str_qr_scan", comment: ""), for: .normal)
        btnPaste.setTitle(NSLocalizedString("str_paste", comment: ""), for: .normal)
        btnBack.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnBack.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnWallet.borderColor = UIColor.font05
        btnQrScan.borderColor = UIColor.font05
        btnPaste.borderColor = UIColor.font05
    }
    
    override func enableUserInteraction() {
        self.btnBack.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickWallet(_ sender: UIButton) {
        recipientableAccounts = BaseData.instance.selectAllAccountsByChain2(recipientChain.chainType, account!.account_address)
        if (recipientableAccounts.count <= 0) {
            self.onShowToast(NSLocalizedString("error_no_wallet_this_chain", comment: ""))
            return

        } else {
            let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
            popupVC.type = SELECT_POPUP_RECIPIENT_ADDRESS
            popupVC.toChain = recipientChain.chainType
            popupVC.toAccountList = recipientableAccounts
            let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
            cardPopup.resultDelegate = self
            cardPopup.show(onViewController: self)
        }
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        recipientAddressinput.text = recipientableAccounts[result].account_address
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
        recipientAddressinput.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    @IBAction func onClickPaste(_ sender: UIButton) {
        if let copyString = UIPasteboard.general.string {
            recipientAddressinput.text = copyString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBack.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = recipientAddressinput.text?.trimmingCharacters(in: .whitespaces)
        if (!WUtils.isValidChainAddress(recipientChain, userInput)) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        btnBack.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.mRecipinetAddress = userInput
        pageHolderVC.onNextPage()
    }

}
