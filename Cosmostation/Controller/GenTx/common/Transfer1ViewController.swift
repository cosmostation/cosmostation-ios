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
        self.mintscanTokens = BaseData.instance.mMintscanTokens.filter({ $0.address == toSendDenom }).first
        self.recipientableChains.append(chainConfig!)
        
        let allChainConfig = ChainFactory.SUPPRT_CONFIG()
        BaseData.instance.mMintscanAssets.forEach { msAsset in
            if (mintscanAsset != nil) {
                if (msAsset.chain == chainConfig?.chainAPIName && msAsset.denom.lowercased() == toSendDenom.lowercased()) {
                    //add backward path
                    if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.beforeChain(chainConfig!)}).first {
                        if !self.recipientableChains.contains(where: { $0.chainAPIName == sendable.chainAPIName }) {
                            self.recipientableChains.append(sendable)
                        }
                    }
                } else if (msAsset.counter_party?.denom?.lowercased() == toSendDenom.lowercased()) {
                    //add forward path
                    if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.chain &&
                        msAsset.beforeChain($0) == chainConfig?.chainAPIName }).first {
                        if !self.recipientableChains.contains(where: { $0.chainAPIName == sendable.chainAPIName }) {
                            self.recipientableChains.append(sendable)
                        }
                    }
                }
                
            } else if (mintscanTokens != nil) {
                //add only forward path
                if (msAsset.counter_party?.denom == mintscanTokens?.address) {
                    if let sendable = allChainConfig.filter({ $0.chainAPIName == msAsset.chain }).first {
                        if !self.recipientableChains.contains(where: { $0.chainAPIName == sendable.chainAPIName }) {
                        self.recipientableChains.append(sendable)
                        }
                    }
                }
            }
        }
        
        self.onSortToChain()
        self.recipientChainConfig = recipientableChains[0]
        self.onUpdateToChainView()
        self.recipientChainCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToChain (_:))))
        self.recipientAddressinput.placeholder = NSLocalizedString("msg_address_nameservice", comment: "")
        
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnWallet.borderColor = UIColor.font05
        btnQrScan.borderColor = UIColor.font05
        btnPaste.borderColor = UIColor.font05
        
        recipientChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        recipientAddressTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        ibcMsg1.text = NSLocalizedString("msg_warn_ibc_send1", comment: "")
        ibcMsg2.text = NSLocalizedString("msg_warn_ibc_send2", comment: "")
        ibcMsg3.text = NSLocalizedString("msg_warn_ibc_send3", comment: "")
        btnWallet.setTitle(NSLocalizedString("str_wallet", comment: ""), for: .normal)
        btnQrScan.setTitle(NSLocalizedString("str_qr_scan", comment: ""), for: .normal)
        btnPaste.setTitle(NSLocalizedString("str_paste", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("str_cancel", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnCancel.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.photon
        btnWallet.borderColor = UIColor.font05
        btnQrScan.borderColor = UIColor.font05
        btnPaste.borderColor = UIColor.font05
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
        if (userInput?.isEmpty == true) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        if (account?.account_address == userInput) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (WUtils.isValidChainAddress(recipientChainConfig, userInput)) {
            btnCancel.isUserInteractionEnabled = false
            btnNext.isUserInteractionEnabled = false
            pageHolderVC.mRecipinetChainConfig = recipientChainConfig
            pageHolderVC.mRecipinetAddress = userInput
            onSetTranfserType()
            pageHolderVC.onNextPage()
            
        } else {
            nameservices.removeAll()
            if (WUtils.isStarnameValidStarName(userInput!.lowercased())) {
                fetchCnt = 1
                onCheckStarNameService(recipientChainConfig, userInput!)
                return;
                
            } else {
                fetchCnt = 3
                onCheckIcnsNameService(recipientChainConfig, userInput!)
                onCheckStargazeNameService(recipientChainConfig, userInput!)
                onCheckArchwayNameService(recipientChainConfig, userInput!)
            }
        }
    }
    
    func onSetTranfserType() {
        if (chainType == recipientChainConfig.chainType) {
            if (mintscanAsset != nil) { pageHolderVC.mTransferType = TRANSFER_SIMPLE }
            else if (mintscanTokens != nil) {
                if (mintscanTokens?.address.starts(with: "0x") == true) {
                    pageHolderVC.mTransferType = TRANSFER_EVM
                } else {
                    pageHolderVC.mTransferType = TRANSFER_WASM
                }
            }

        } else {
            if (mintscanAsset != nil) {
                pageHolderVC.mTransferType = TRANSFER_IBC_SIMPLE
                pageHolderVC.mMintscanPath = WUtils.getMintscanPath(chainConfig!, recipientChainConfig!, toSendDenom!)
                
            } else if (mintscanTokens != nil) {
                pageHolderVC.mTransferType = TRANSFER_IBC_WASM
                pageHolderVC.mMintscanPath = WUtils.getMintscanPath(chainConfig!, recipientChainConfig!, toSendDenom!)
            }
        }
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
            
        } else if (type == SELECT_POPUP_NAME_SERVICE) {
            let matchedAddress = nameservices[result].address
            if (account?.account_address == matchedAddress) {
                self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
                return;
            }
            
            if (!WUtils.isValidChainAddress(recipientChainConfig, matchedAddress)) {
                self.onShowToast(NSLocalizedString("error_invalid_nameservice_address", comment: ""))
                return;
            }
            
            self.btnCancel.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            self.pageHolderVC.mRecipinetChainConfig = recipientChainConfig
            self.pageHolderVC.mRecipinetAddress = matchedAddress
            self.onSetTranfserType()
            self.pageHolderVC.onNextPage()
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
    
    func onCheckStarNameService(_ recipientChainConfig: ChainConfig, _ userInput: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(ChainStarname(.IOV_MAIN))!
                let req = Starnamed_X_Starname_V1beta1_QueryStarnameRequest.with { $0.starname = userInput }
                if let response = try? Starnamed_X_Starname_V1beta1_QueryClient(channel: channel).starname(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    if let matchedAddress = WUtils.checkStarnameWithResource(recipientChainConfig.chainType, response) {
                        self.nameservices = [NameService.init(.starname, userInput, matchedAddress)]
                    }
                }
                try channel.close().wait()
                
            } catch { print("onFetchgRPCResolve failed: \(error)") }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onCheckIcnsNameService(_ recipientChainConfig: ChainConfig, _ userInput: String) {
        DispatchQueue.global().async {
            do {
                let nameReq = Cw20IcnsByNameReq.init(recipientChainConfig.addressPrefix, userInput)
                let channel = BaseNetWork.getConnection(ChainOsmosis(.OSMOSIS_MAIN))!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = ICNS_CONTRACT_ADDRESS
                    $0.queryData = nameReq.getEncode()
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if let matchedAddress = try? JSONDecoder().decode(Cw20IcnsByNameRes.self, from: response.data).bech32_address {
                        if (matchedAddress.isEmpty == false) {
                            self.nameservices = [NameService.init(.icns, nameReq.address_by_icns!.icns, matchedAddress)]
                        }
                    }
                }
                try channel.close().wait()

            } catch { print("onCheckIcnsNameService failed: \(error)") }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onCheckStargazeNameService(_ recipientChainConfig: ChainConfig, _ userInput: String) {
        DispatchQueue.global().async {
            do {
                let nameReq = Cw20IcnsByNameReq.init(userInput)
                let channel = BaseNetWork.getConnection(recipientChainConfig)!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = STARGAZE_NS_CONTRACT_ADDRESS
                    $0.queryData = nameReq.getEncode()
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    let matchedAddress = String(decoding: response.data, as: UTF8.self)
                    if (matchedAddress.isEmpty == false) {
                        self.nameservices = [NameService.init(.stargaze, nameReq.associated_address!.name! + "." + recipientChainConfig.addressPrefix, matchedAddress.replacingOccurrences(of: "\"", with: ""))]
                    }
                }
                try channel.close().wait()

            } catch { print("onCheckStargazeNameService failed: \(error)") }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onCheckArchwayNameService(_ recipientChainConfig: ChainConfig, _ userInput: String) {
        DispatchQueue.global().async {
            do {
                let nameReq = ArchwayIcnsByNameReq.init(userInput)
                let channel = BaseNetWork.getConnection(recipientChainConfig)!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = ARCHWAY_NS_CONTRACT_ADDRESS
                    $0.queryData = nameReq.getEncode()
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if let matchedAddress = try? JSONDecoder().decode(ArchwayIcnsByNameRes.self, from: response.data).address {
                        if (matchedAddress.isEmpty == false) {
                            self.nameservices = [NameService.init(.archway, nameReq.resolve_record?.name, matchedAddress)]
                        }
                    }
                }
                try channel.close().wait()

            } catch { print("onCheckArchwayNameService failed: \(error)") }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    var fetchCnt = 0
    var nameservices = Array<NameService>()
    func onFetchFinished() {
        fetchCnt = fetchCnt - 1
        if (fetchCnt > 0) { return }
        
        if (nameservices.count == 0) {
            self.onShowToast(NSLocalizedString("error_invalide_nameservice", comment: ""))
            return;
        }
        if (nameservices.count == 2 && (nameservices[0].address == nameservices[1].address)) {
            if (recipientChainConfig.chainType == .ARCHWAY_MAIN) {
                nameservices[0].type = .icns_archway
            } else {
                nameservices[0].type = .icns_stargaze
            }
            nameservices.removeLast()
        }
        
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_NAME_SERVICE
        popupVC.nameservices = nameservices
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
}


enum NameServiceType: Int {
    case starname = 0
    case icns = 1
    case stargaze = 2
    case icns_stargaze = 3
    case archway = 4
    case icns_archway = 5
}

public struct NameService {
    var type: NameServiceType?
    var name: String?
    var address: String?
    
    init(_ type: NameServiceType?, _ name: String?, _ address: String?) {
        self.type = type
        self.name = name
        self.address = address
    }
}
