//
//  TxAddressSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class TxAddressSheet: BaseVC, UITextViewDelegate, QrScanDelegate, UITextFieldDelegate, BaseSheetDelegate {
    
    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var addressTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var existedAddress: String?
    var selectedChain: CosmosClass!
    var recipientChain: CosmosClass!
    var addressDelegate: AddressDelegate?
    
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
        addressTitle.text = NSLocalizedString("recipient_address", comment: "")
        addressTextField.label.text = NSLocalizedString("msg_address_nameservice", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onClickAddressBook(_ sender: UIButton) {
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
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        let userInput = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (userInput?.isEmpty == true || userInput?.count ?? 0 < 5) {
            self.onShowToast(NSLocalizedString("error_invalid_address", comment: ""))
            return;
        }
        
        if (userInput == selectedChain.address) {
            self.onShowToast(NSLocalizedString("error_self_send", comment: ""))
            return;
        }
        
        if (WUtils.isValidChainAddress(recipientChain, userInput)) {
            addressDelegate?.onInputedAddress(userInput!)
            dismiss(animated: true)
            
        } else {
            //check name service!!
            view.isUserInteractionEnabled = false
            loadingView.isHidden = false
            nameservices.removeAll()
            let prefix = recipientChain.accountPrefix!
            
            Task {
                if let starname = try await checkStarname(userInput!) {
                    starname.account.resources.forEach { resource in
                        if (resource.resource.starts(with: prefix)) {
                            nameservices.append(NameService.init("starname", userInput!, resource.resource))
                        }
                    }
                }
                
                if let icns = try await checkOsmoname(userInput!, prefix) {
                    if let result = try? JSONDecoder().decode(JSON.self, from: icns.data) {
                        if (result["bech32_address"].stringValue.starts(with: prefix)) {
                            nameservices.append(NameService.init("osmosis", userInput!, result["bech32_address"].stringValue))
                        }
                    }
                }
                
                if let stargaze = try await checkStargazename(userInput!) {
                    if let result = try? JSONDecoder().decode(JSON.self, from: stargaze.data) {
                        if (result.stringValue.starts(with: prefix)) {
                            nameservices.append(NameService.init("stargaze", userInput!, result.stringValue))
                        }
                    }
                }
                
                if let archway = try await checkArchwayname(userInput!) {
                    if let result = try? JSONDecoder().decode(JSON.self, from: archway.data) {
                        if (result["address"].stringValue.starts(with: prefix)) {
                            nameservices.append(NameService.init("archway", userInput!, result["address"].stringValue))
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
                        baseSheet.sheetType = .SelectNameServiceAddress
                        self.onStartSheet(baseSheet)
                    }
                }
            }
            
        }
    }
    
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        let nameservice = nameservices[result.position!]
        addressTextField.text = nameservice.address
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

protocol AddressDelegate {
    func onInputedAddress(_ address: String)
}


extension TxAddressSheet {
    
    func checkStarname(_ inputName: String) async throws -> Starnamed_X_Starname_V1beta1_QueryStarnameResponse? {
        let channel = getConnection(ChainStarname())
        let req = Starnamed_X_Starname_V1beta1_QueryStarnameRequest.with { $0.starname = inputName }
        return try? await Starnamed_X_Starname_V1beta1_QueryNIOClient(channel: channel).starname(req, callOptions: getCallOptions()).response.get()
    }
    
    func checkOsmoname(_ inputName: String, _ prefix: String) async throws -> Cosmwasm_Wasm_V1_QuerySmartContractStateResponse? {
        let channel = getConnection(ChainOsmosis())
        let name = String(inputName.split(separator: ".")[0]) + "." + prefix
        let query: JSON = ["address_by_icns" : ["icns" : name]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = "osmo1xk0s8xgktn9x5vwcgtjdxqzadg88fgn33p8u9cnpdxwemvxscvast52cdd"
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
            $0.address = "stars1fx74nkqkw2748av8j7ew7r3xt9cgjqduwn8m0ur5lhe49uhlsasszc5fhr"
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
            $0.address = "archway1275jwjpktae4y4y0cdq274a2m0jnpekhttnfuljm6n59wnpyd62qppqxq0"
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        return try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get()
    }
    
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.grpcHost, port: chain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
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
