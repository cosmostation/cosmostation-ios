//
//  Transfer1ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO

class Transfer1ViewController: BaseViewController, QrScannerDelegate, SBCardPopupDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var informationLayer: UIView!
    @IBOutlet weak var recipientChainCard: CardView!
    @IBOutlet weak var recipientChainImg: UIImageView!
    @IBOutlet weak var recipientChainLebel: UILabel!
    @IBOutlet weak var recipientAddressinput: AddressInputTextField!
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet weak var btnQrScan: UIButton!
    @IBOutlet weak var btnPaste: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var toSendDenom: String!
    var toSendableChains = Array<ChainConfig>()
    var toSendChain: ChainConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.toSendDenom = pageHolderVC.mToSendDenom
        self.toSendableChains.append(chainConfig!)
        
        let allChainConfig = ChainFactory.SUPPRT_CONFIG()
        BaseData.instance.mMintscanAssets.forEach { msAsset in
            if (msAsset.chain != chainConfig?.chainAPIName && msAsset.base_denom == toSendDenom) {
                if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.chain }).first {
                    self.toSendableChains.append(sendable)
                }
            }
        }
        print("toSendableChains ", toSendableChains.count)
        self.onSortToChain()
        self.toSendChain = toSendableChains[0]
        self.onUpdateToChainView()
        self.recipientChainCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToChain (_:))))
        
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btnWallet.borderColor = UIColor.init(named: "_font05")
        btnQrScan.borderColor = UIColor.init(named: "_font05")
        btnPaste.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btnWallet.borderColor = UIColor.init(named: "_font05")
        btnQrScan.borderColor = UIColor.init(named: "_font05")
        btnPaste.borderColor = UIColor.init(named: "_font05")
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func onUpdateToChainView() {
        recipientChainImg.image = toSendChain?.chainImg
        recipientChainLebel.text = toSendChain?.chainTitle2
        recipientChainLebel.textColor = toSendChain?.chainColor
        recipientAddressinput.text = ""
    }
    
    
    
    @objc func onClickToChain (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_IBC_CHAIN
        popupVC.ibcToChain = toSendableChains
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @IBAction func onClickWallet(_ sender: UIButton) {
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
        if let copyString = UIPasteboard.general.string {
            recipientAddressinput.text = copyString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
    }
    
    func scannedAddress(result: String) {
        recipientAddressinput.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        informationLayer.isHidden = false
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        informationLayer.isHidden = true
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_IBC_CHAIN) {
            toSendChain = toSendableChains[result]
            onUpdateToChainView()
        }
    }
    
    func onSortToChain() {
        toSendableChains.sort {
            if ($0.chainType == self.chainType) { return true }
            if ($1.chainType == self.chainType) { return false }
            if ($0.chainType == ChainType.COSMOS_MAIN) { return true }
            if ($1.chainType == ChainType.COSMOS_MAIN) { return false }
            if ($0.chainType == ChainType.OSMOSIS_MAIN) { return true }
            if ($1.chainType == ChainType.OSMOSIS_MAIN) { return false }
            return false
        }
    }
    
    /*
    @IBOutlet weak var mTargetAddressTextField: AddressInputTextField!
    @IBOutlet weak var startNameLayer: UIView!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var ScanBtn: UIButton!
    @IBOutlet weak var PasteBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        mTargetAddressTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("recipient_address", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(named: "_font04")])
        
        CancelBtn.borderColor = UIColor.init(named: "_font05")
        NextBtn.borderColor = UIColor.init(named: "photon")
        ScanBtn.borderColor = UIColor.init(named: "_font05")
        PasteBtn.borderColor = UIColor.init(named: "_font05")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        CancelBtn.borderColor = UIColor.init(named: "_font05")
        NextBtn.borderColor = UIColor.init(named: "photon")
        ScanBtn.borderColor = UIColor.init(named: "_font05")
        PasteBtn.borderColor = UIColor.init(named: "_font05")
    }
    
    @IBAction func onClickQrCode(_ sender: Any) {
        let qrScanVC = QRScanViewController(nibName: "QRScanViewController", bundle: nil)
        qrScanVC.hidesBottomBarWhenPushed = true
        qrScanVC.resultDelegate = self
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        self.navigationController?.pushViewController(qrScanVC, animated: false)
        
    }
    
    @IBAction func onClickPaste(_ sender: Any) {
        if let myString = UIPasteboard.general.string {
            self.mTargetAddressTextField.text = myString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            self.onShowToast(NSLocalizedString("error_no_clipboard", comment: ""))
        }
    }
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.CancelBtn.isUserInteractionEnabled = false
        self.NextBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        startNameLayer.isHidden = false
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        startNameLayer.isHidden = true
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        let userInput = mTargetAddressTextField.text?.trimmingCharacters(in: .whitespaces)
        if (WUtils.isStarnameValidStarName(userInput!.lowercased())) {
            self.onCheckNameservice(userInput!.lowercased())
            return;
        }
        
        if (pageHolderVC.mAccount?.account_address == userInput) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (!WUtils.isValidChainAddress(chainConfig, userInput)) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        
        self.CancelBtn.isUserInteractionEnabled = false
        self.NextBtn.isUserInteractionEnabled = false
        pageHolderVC.mToSendRecipientAddress = userInput
        pageHolderVC.onNextPage()
        
    }
    
    override func enableUserInteraction() {
        self.CancelBtn.isUserInteractionEnabled = true
        self.NextBtn.isUserInteractionEnabled = true
    }
    
    func scannedAddress(result: String) {
        mTargetAddressTextField.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func onCheckNameservice(_ userInput: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(ChainType.IOV_MAIN, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Starname_V1beta1_QueryStarnameRequest.with { $0.starname = userInput }
                let response = try Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).starname(req, callOptions:BaseNetWork.getCallOptions()).response.wait()
                try channel.close().wait()
                DispatchQueue.main.async(execute: {
                    guard let matchedAddress = WUtils.checkStarnameWithResource(self.pageHolderVC.chainType!, response) else {
                        self.onShowToast(NSLocalizedString("error_no_mattched_starname", comment: ""))
                        return
                    }
                    if (self.pageHolderVC.mAccount?.account_address == matchedAddress) {
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
        if #available(iOS 13.0, *) { alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        let settingsAction = UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default) { (_) -> Void in
            self.CancelBtn.isUserInteractionEnabled = false
            self.NextBtn.isUserInteractionEnabled = false
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
     */

}
