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
    
    @IBOutlet weak var recipientChainTitle: UILabel!
    @IBOutlet weak var recipientAddressTitle: UILabel!
    @IBOutlet weak var ibcMsg1: UILabel!
    @IBOutlet weak var ibcMsg2: UILabel!
    @IBOutlet weak var ibcMsg3: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var toSendDenom: String!
    var recipientableChains = Array<ChainConfig>()
    var recipientableAccounts = Array<Account>()
    var recipientChainConfig: ChainConfig!
    var mintscanAsset: MintscanAsset?
    var mintscanTokens: MintscanToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.toSendDenom = pageHolderVC.mToSendDenom
        self.mintscanAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == toSendDenom.lowercased() }).first
        self.mintscanTokens = BaseData.instance.mMintscanTokens.filter({ $0.denom.lowercased() == toSendDenom.lowercased() }).first
//        print("toSendDenom ", toSendDenom)
//        print("mintscanAsset ", mintscanAsset)
//        print("mintscanTokens ", mintscanTokens)
        self.recipientableChains.append(chainConfig!)
        
        let allChainConfig = ChainFactory.SUPPRT_CONFIG()
        BaseData.instance.mMintscanAssets.forEach { msAsset in
            if (mintscanAsset != nil) {
                if (msAsset.chain == chainConfig?.chainAPIName && msAsset.denom.lowercased() == toSendDenom.lowercased()) {
                    //add backward path
                    if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.beforeChain(chainConfig!)}).first {
                        self.recipientableChains.append(sendable)
                    }
                } else if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add forward path
                    if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.chain }).first {
                        self.recipientableChains.append(sendable)
                    }
                }
                
                
            } else if (mintscanTokens != nil) {
                //add only forward path
                if (msAsset.counter_party?.denom == mintscanTokens?.contract_address) {
                    if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.chain }).first {
                        self.recipientableChains.append(sendable)
                    }
                }
            }
        }
        print("recipientableChains ", recipientableChains.count)
        
        self.onSortToChain()
        self.recipientChainConfig = recipientableChains[0]
        self.onUpdateToChainView()
        self.recipientChainCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToChain (_:))))
        
        btnCancel.borderColor = UIColor.init(named: "_font05")
        btnNext.borderColor = UIColor.init(named: "photon")
        btnWallet.borderColor = UIColor.init(named: "_font05")
        btnQrScan.borderColor = UIColor.init(named: "_font05")
        btnPaste.borderColor = UIColor.init(named: "_font05")
        
        recipientChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        recipientAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        ibcMsg1.text = NSLocalizedString("msg_warn_ibc_send1", comment: "")
        ibcMsg2.text = NSLocalizedString("msg_warn_ibc_send2", comment: "")
        ibcMsg3.text = NSLocalizedString("msg_warn_ibc_send3", comment: "")
        btnWallet.setTitle(NSLocalizedString("str_wallet2", comment: ""), for: .normal)
        btnQrScan.setTitle(NSLocalizedString("str_qr_scan", comment: ""), for: .normal)
        btnPaste.setTitle(NSLocalizedString("str_paste", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
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
        recipientChainImg.image = recipientChainConfig?.chainImg
        recipientChainLebel.text = recipientChainConfig?.chainTitle2
        recipientChainLebel.textColor = recipientChainConfig?.chainColor
        recipientAddressinput.text = ""
        informationLayer.isHidden = (recipientChainConfig.chainType == chainType)
    }

    
    @objc func onClickToChain (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_RECIPIENT_CHAIN
        popupVC.ibcToChain = recipientableChains
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @IBAction func onClickWallet(_ sender: UIButton) {
        recipientableAccounts = BaseData.instance.selectAllAccountsByChain2(recipientChainConfig.chainType, account!.account_address)
        if (recipientableAccounts.count <= 0) {
            self.onShowToast(NSLocalizedString("error_no_wallet_this_chain", comment: ""))
            return
            
        } else {
            let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
            popupVC.type = SELECT_POPUP_RECIPIENT_ADDRESS
            popupVC.toChain = recipientChainConfig.chainType
            popupVC.toAccountList = recipientableAccounts
            let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
            cardPopup.resultDelegate = self
            cardPopup.show(onViewController: self)
        }
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
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let userInput = recipientAddressinput.text?.trimmingCharacters(in: .whitespaces)
        if (WUtils.isStarnameValidStarName(userInput!.lowercased())) {
            self.onCheckNameservice(userInput!.lowercased())
            return;
        }
        if (account?.account_address == userInput) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        if (!WUtils.isValidChainAddress(recipientChainConfig, userInput)) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.mRecipinetChainConfig = recipientChainConfig
        pageHolderVC.mRecipinetAddress = userInput
        onSetTranfserType()
        pageHolderVC.onNextPage()
    }
    
    func onSetTranfserType() {
        if (chainType == recipientChainConfig.chainType) {
            if (mintscanAsset != nil) { pageHolderVC.mTransferType = TRANSFER_SIMPLE }
            else if (mintscanTokens != nil) { pageHolderVC.mTransferType = TRANSFER_WASM }

        } else {
            if (mintscanAsset != nil) {
                pageHolderVC.mTransferType = TRANSFER_IBC_SIMPLE
                pageHolderVC.mMintscanPath = WUtils.getMintscanPath(chainConfig!, recipientChainConfig!, toSendDenom!)
                
            } else if (mintscanTokens != nil) {
                pageHolderVC.mTransferType = TRANSFER_IBC_WASM
                pageHolderVC.mMintscanPath = WUtils.getMintscanPath(chainConfig!, recipientChainConfig!, toSendDenom!)
            }
        }
        print("channel ", pageHolderVC.mMintscanPath?.channel)
        print("port ", pageHolderVC.mMintscanPath?.port)
        pageHolderVC.mMintscanAsset = mintscanAsset
        pageHolderVC.mMintscanTokens = mintscanTokens
    }
    
    func scannedAddress(result: String) {
        recipientAddressinput.text = result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        informationLayer.isHidden = (recipientChainConfig.chainType == chainType)
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        informationLayer.isHidden = true
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_RECIPIENT_CHAIN) {
            recipientChainConfig = recipientableChains[result]
            onUpdateToChainView()
        } else if (type == SELECT_POPUP_RECIPIENT_ADDRESS) {
            recipientAddressinput.text = recipientableAccounts[result].account_address
        }
    }
    
    func onSortToChain() {
        recipientableChains.sort {
            if ($0.chainType == self.chainType) { return true }
            if ($1.chainType == self.chainType) { return false }
            if ($0.chainType == ChainType.COSMOS_MAIN) { return true }
            if ($1.chainType == ChainType.COSMOS_MAIN) { return false }
            if ($0.chainType == ChainType.OSMOSIS_MAIN) { return true }
            if ($1.chainType == ChainType.OSMOSIS_MAIN) { return false }
            return false
        }
    }
    
    func onCheckNameservice(_ userInput: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(.IOV_MAIN, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Starname_V1beta1_QueryStarnameRequest.with { $0.starname = userInput }
                let response = try Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).starname(req, callOptions:BaseNetWork.getCallOptions()).response.wait()
                try channel.close().wait()
                DispatchQueue.main.async(execute: {
                    guard let matchedAddress = WUtils.checkStarnameWithResource(self.recipientChainConfig.chainType, response) else {
                        self.onShowToast(NSLocalizedString("error_no_mattched_starname", comment: ""))
                        return
                    }
                    if (self.account?.account_address == userInput) {
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
        alertController.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let settingsAction = UIAlertAction(title: NSLocalizedString("continue", comment: ""), style: .default) { (_) -> Void in
            self.btnCancel.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            self.pageHolderVC.mRecipinetChainConfig = self.recipientChainConfig
            self.pageHolderVC.mRecipinetAddress = matchedAddress
            self.onSetTranfserType()
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
