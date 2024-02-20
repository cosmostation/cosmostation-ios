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
import GRPC
import NIO
import SwiftProtobuf

class TxSendAddressSheet: BaseVC, UITextViewDelegate, UITextFieldDelegate, QrScanDelegate, SelectAddressListDelegate, BaseSheetDelegate {
    
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var fromChain: BaseChain!
    var toChain: BaseChain!
    var sendType: SendAssetType!
    var senderBechAddress: String!
    var senderEvmAddress: String!
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
        addressListSheet.senderBechAddress = senderBechAddress
        addressListSheet.senderEvmAddress = senderEvmAddress
        addressListSheet.addressListSheetDelegate = self
        self.onStartSheet(addressListSheet)
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
        let userInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (userInput?.isEmpty == true || userInput?.count ?? 0 < 5) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return
        }
        if (userInput == senderBechAddress || userInput == senderEvmAddress) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return
        }
        
        if (sendType == .Only_EVM_Coin || sendType == .Only_EVM_ERC20) {
            //only support EVM address style
            if (!WUtils.isValidEvmAddress(userInput)) {
                self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
                return;
            }
            self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
            self.dismiss(animated: true)
            
        } else if (sendType == .Only_Cosmos_Coin || sendType == .Only_Cosmos_CW20) {
            //only support cosmos address style
            if (WUtils.isValidBechAddress((toChain as! CosmosClass), userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            }
            onCheckNameServices(userInput!)
            
        } else if (sendType == .CosmosEVM_Coin) {
            //support both style
            if (WUtils.isValidEvmAddress(userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            }
            if (WUtils.isValidBechAddress((toChain as! CosmosClass), userInput)) {
                self.sendAddressDelegate?.onInputedAddress(userInput!, nil)
                self.dismiss(animated: true)
                return
            }
            onCheckNameServices(userInput!)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func onCheckNameServices(_ userInput: String)  {
        view.isUserInteractionEnabled = false
        loadingView.isHidden = false
        nameservices.removeAll()
        let prefix = (toChain as! CosmosClass).bechAccountPrefix!
        
        Task {
            if let icns = try await checkOsmoname(userInput, prefix) {
                if let result = try? JSONDecoder().decode(JSON.self, from: icns.data) {
                    if (result["bech32_address"].stringValue.starts(with: prefix + "1")) {
                        nameservices.append(NameService.init("osmosis", userInput, result["bech32_address"].stringValue))
                    }
                }
            }
            
            if let stargaze = try await checkStargazename(userInput) {
                if let result = try? JSONDecoder().decode(JSON.self, from: stargaze.data) {
                    if (result.stringValue.starts(with: prefix + "1")) {
                        nameservices.append(NameService.init("stargaze", userInput, result.stringValue))
                    }
                }
            }
            
            if let archway = try await checkArchwayname(userInput) {
                if let result = try? JSONDecoder().decode(JSON.self, from: archway.data) {
                    if (result["address"].stringValue.starts(with: prefix + "1")) {
                        nameservices.append(NameService.init("archway", userInput, result["address"].stringValue))
                    }
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
                    self.onStartSheet(baseSheet)
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
    
    func checkOsmoname(_ inputName: String, _ prefix: String) async throws -> Cosmwasm_Wasm_V1_QuerySmartContractStateResponse? {
        let channel = getConnection(ChainOsmosis())
        let name = String(inputName.split(separator: ".")[0]) + "." + prefix
        let query: JSON = ["address_by_icns" : ["icns" : name]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = OSMO_NAME_SERVICE
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get()
    }
    
    func checkStargazename (_ inputName: String) async throws -> Cosmwasm_Wasm_V1_QuerySmartContractStateResponse? {
        let channel = getConnection(ChainStargaze())
        let name = String(inputName.split(separator: ".")[0])
        let query: JSON = ["associated_address" : ["name" : name]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = STARGAZE_NAME_SERVICE
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get()
    }
    
    func checkArchwayname (_ inputName: String) async throws -> Cosmwasm_Wasm_V1_QuerySmartContractStateResponse? {
        let channel = getConnection(ChainArchway())
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
        return try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get()
    }
    
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.getGrpc().0, port: chain.getGrpc().1)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}

protocol SendAddressDelegate {
    func onInputedAddress(_ address: String, _ memo: String?)
}
