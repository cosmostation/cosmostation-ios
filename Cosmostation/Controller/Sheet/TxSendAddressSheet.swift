//
//  TxSendAddressSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/19/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents
import SwiftyJSON

class TxSendAddressSheet: BaseVC, UITextViewDelegate, UITextFieldDelegate, QrScanDelegate, SelectAddressListDelegate, BaseSheetDelegate {
    
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var fromChain: BaseChain!
    var toChain: BaseChain!
    var sendType: SendAssetType!
    var existedAddress: String?
    var sendAddressDelegate: SendAddressDelegate?
    
    var nameservices = [NameService]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = true
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        addressTextField.setup()
        if let existedAddress = existedAddress {
            addressTextField.text = existedAddress
        }
        addressTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func setLocalizedString() {
        addressTextField.label.text = NSLocalizedString("msg_address_nameservice", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickAddressBook(_ sender: UIButton) {
        let addressListSheet = SelectAddressListSheet(nibName: "SelectAddressListSheet", bundle: nil)
        addressListSheet.fromChain = fromChain
        addressListSheet.toChain = toChain
        addressListSheet.sendType = sendType
        addressListSheet.addressListSheetDelegate = self
        onStartSheet(addressListSheet, 320, 0.6)
    }
    
    @IBAction func onClickScan(_ sender: UIButton) {
        let qrScanVC = QrScanVC(nibName: "QrScanVC", bundle: nil)
        qrScanVC.scanDelegate = self
        present(qrScanVC, animated: true)
    }
    
    func onScanned(_ result: String) {
        let address = result.components(separatedBy: "(MEMO)")[0]
        addressTextField.text = address.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton?) {
        print("onClickConfirm ", sendType)
        let userInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (userInput?.isEmpty == true || userInput?.count ?? 0 < 5) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        
        if (fromChain.bechAddress?.isEmpty == false && userInput?.lowercased() == fromChain.bechAddress?.lowercased()) {
            onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return
        }
        
        if (fromChain.evmAddress?.isEmpty == false && userInput?.lowercased() == fromChain.evmAddress?.lowercased()) {
            onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return
        }
        
        if (fromChain.mainAddress.isEmpty == false && userInput?.lowercased() == fromChain.mainAddress.lowercased()) {
            onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return
        }
        
        
        if (toChain is ChainSui) {
            //only support sui address style
            if (WUtils.isValidSuiAdderss(userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            } else {
                self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                return
            }
            
        } else if toChain is ChainIota {
            if (WUtils.isValidSuiAdderss(userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            } else {
                self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                return
            }
            
        } else if (toChain is ChainBitCoin86 || toChain is ChainBitCoin86_T) {
            var network = ""
            if userInput!.starts(with: "1") || userInput!.starts(with: "bc1") || userInput!.starts(with: "3") {
                network = "bitcoin"
            } else {
                network = "testnet"
            }
            if BtcJS.shared.callJSValueToBool(key: "validateAddress", param: [userInput!, network]) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            } else {
                self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                return
            }
            
        } else if (toChain.supportEvm == true && toChain.supportCosmos == false) {
            //only support EVM address style
            if (WUtils.isValidEvmAddress(userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            } else {
                self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                return
            }
            
        } else if (toChain.supportEvm == false && toChain.supportCosmos == true) {
            if (WUtils.isValidBechAddress(toChain, userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            } else {
                onCheckNameServices(userInput!)
            }
            
        } else if (toChain.supportEvm == true && toChain.supportCosmos == true) {
            if (sendType == .COSMOS_COIN) {
                //코스모스만
                if (WUtils.isValidBechAddress(toChain, userInput)) {
                    self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                    self.dismiss(animated: true)
                    return
                } else {
                    onCheckNameServices(userInput!)
                }
                
            } else if (sendType == .EVM_COIN) {
                if (WUtils.isValidEvmAddress(userInput)) {
                    self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                    self.dismiss(animated: true)
                    return
                } else {
                    self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                    return
                }

            } else if (sendType == .EVM_ERC20 && fromChain.tag == toChain.tag) {
                //이더리움만 지원
                if (WUtils.isValidEvmAddress(userInput)) {
                    self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                    self.dismiss(animated: true)
                    return
                } else {
                    self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                    return
                }
                
            } else if (sendType == .EVM_ERC20 && fromChain.tag != toChain.tag) {
                //코스모스만(유레카)
                if (WUtils.isValidBechAddress(toChain, userInput)) {
                    self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                    self.dismiss(animated: true)
                    return
                } else {
                    onCheckNameServices(userInput!)
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func onCheckNameServices(_ userInput: String)  {
        let prefix = toChain.bechAddressPrefix()
        
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        nameservices.removeAll()
        
        Task {
            if let icns = try await checkOsmoname(userInput, prefix) {
                if (icns["bech32_address"].stringValue.starts(with: prefix + "1")) {
                    nameservices.append(NameService.init("osmosis", userInput, icns["bech32_address"].stringValue))
                }
            }
            
            if let stargaze = try await checkStargazename(userInput) {
                if (stargaze.stringValue.starts(with: prefix + "1")) {
                    nameservices.append(NameService.init("stargaze", userInput, stargaze.stringValue))
                }
            }
            
            if let archway = try await checkArchwayname(userInput) {
                if (archway["address"].stringValue.starts(with: prefix + "1")) {
                    nameservices.append(NameService.init("archway", userInput, archway["address"].stringValue))
                }
            }
            
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.loadingView.isHidden = true
                if (self.nameservices.count == 0) {
                    self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                    
                } else {
                    let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
                    baseSheet.nameservices = self.nameservices
                    baseSheet.sheetDelegate = self
                    baseSheet.sheetType = .SelectCosmosNameServiceAddress
                    self.onStartSheet(baseSheet, 320, 0.6)
                }
            }
        }
    }
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectCosmosNameServiceAddress) {
            if let index = result["index"] as? Int {
                let nameservice = nameservices[index]
                addressTextField.text = nameservice.address
            }
        }
    }
    
    func onAddressSelected(_ result: Dictionary<String, Any>) {
        if let address = result["address"] as? String {
            let memo = result["memo"] as? String
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.sendAddressDelegate?.onInputedAddress(address, memo)
                self.dismiss(animated: true)
            });
        }
    }
}

extension TxSendAddressSheet {
    
    func checkOsmoname(_ inputName: String, _ prefix: String) async throws -> JSON? {
        let name = String(inputName.split(separator: ".")[0]) + "." + prefix
        let query: JSON = ["address_by_icns" : ["icns" : name]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = OSMO_NAME_SERVICE
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try await ChainOsmosis().getCosmosfetcher()?.fetchSmartContractState(req)
    }
    
    func checkStargazename (_ inputName: String) async throws -> JSON? {
        let name = String(inputName.split(separator: ".")[0])
        let query: JSON = ["associated_address" : ["name" : name]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = STARGAZE_NAME_SERVICE
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try await ChainStargaze().getCosmosfetcher()?.fetchSmartContractState(req)
    }
    
    func checkArchwayname (_ inputName: String) async throws -> JSON? {
        var name = ""
        if (inputName.contains(".arch")) {
            name = inputName
        } else if (inputName.contains(".")) {
            name = inputName + "arch"
        } else {
            name = inputName + ".arch"
        }
        let query: JSON = ["resolve_record" : ["name" : name]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = ARCH_NAME_SERVICE
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try await ChainArchway().getCosmosfetcher()?.fetchSmartContractState(req)
    }
}

protocol SendAddressDelegate {
    func onInputedAddress(_ address: String, _ memo: String?)
}



public struct NameService {
    var type: String?
    var name: String?
    var address: String?
    
    init(_ type: String, _ name: String, _ address: String) {
        self.type = type
        self.name = name
        self.address = address
    }
}
