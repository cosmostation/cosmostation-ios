//
//  SwapStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import Alamofire
import AlamofireImage
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf

class SwapStartVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slippageBtn: UIButton!
    
    @IBOutlet weak var rootScrollView: UIScrollView!
    @IBOutlet weak var inputCardView: FixCardView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var inputChainView: DropDownView!
    @IBOutlet weak var inputChainImg: UIImageView!
    @IBOutlet weak var inputChainLabel: UILabel!
    @IBOutlet weak var inputAssetView: DropDownView!
    @IBOutlet weak var inputAssetImg: UIImageView!
    @IBOutlet weak var inputAssetLabel: UILabel!
    @IBOutlet weak var inputAmountTextField: UITextField!
    @IBOutlet weak var inputInvalidLabel: UILabel!
    @IBOutlet weak var inputValueCurrency: UILabel!
    @IBOutlet weak var inputValueLabel: UILabel!
    @IBOutlet weak var inputAvailableLabel: UILabel!
    
    @IBOutlet weak var outputCardView: FixCardView!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var outputChainView: DropDownView!
    @IBOutlet weak var outputChainImg: UIImageView!
    @IBOutlet weak var outputChainLabel: UILabel!
    @IBOutlet weak var outputAssetView: DropDownView!
    @IBOutlet weak var outputAssetImg: UIImageView!
    @IBOutlet weak var outputAssetLabel: UILabel!
    @IBOutlet weak var outputAmountLabel: UILabel!
    @IBOutlet weak var outputValueCurrency: UILabel!
    @IBOutlet weak var outputValueLabel: UILabel!
    @IBOutlet weak var outputBalanceLabel: UILabel!
    
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var descriptionCardView: FixCardView!
    @IBOutlet weak var descriptionTitleLabel: UILabel!
    @IBOutlet weak var guaranteeAmountLabel: UILabel!
    @IBOutlet weak var guaranteeDenomLabel: UILabel!
    @IBOutlet weak var rateInputAmountLanel: UILabel!
    @IBOutlet weak var rateInputDenomLabel: UILabel!
    @IBOutlet weak var rateOutputAmountLanel: UILabel!
    @IBOutlet weak var rateOutputDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLanel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    @IBOutlet weak var swapBtn: BaseButton!
    
    var allCosmosChains = Array<CosmosClass>()
    var skipChains = Array<CosmosClass>()       //inapp support chain for skip
    var skipAssets: JSON?
    
    var inputCosmosChain: CosmosClass!
    var inputAssetList = Array<JSON>()
    var inputAssetSelected: JSON!
    var inputMsAsset: MintscanAsset!
    
    var outputCosmosChain: CosmosClass!
    var outputAssetList = Array<JSON>()
    var outputAssetSelected: JSON!
    var outputMsAsset: MintscanAsset!
    
    var availableAmount = NSDecimalNumber.zero
    var toActionAmount = NSDecimalNumber.zero
    
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txMemo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        titleLabel.isHidden = true
        slippageBtn.isHidden = true
        rootScrollView.isHidden = true
        swapBtn.isHidden = true
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        inputValueCurrency?.text = BaseData.instance.getCurrencySymbol()
        inputValueLabel?.text = ""
        outputValueCurrency?.text = BaseData.instance.getCurrencySymbol()
        outputValueLabel?.text = ""
        
        Task {
            allCosmosChains = await baseAccount.initOnyKeyData()
            
            var sChains: JSON!
            if (BaseData.instance.skipChains == nil) {
                sChains = try? await fetchSkipChains()
                BaseData.instance.skipChains = sChains
            } else {
                sChains = BaseData.instance.skipChains
            }
//            print("sChains ", sChains)
            sChains?["chains"].arrayValue.forEach({ sChain in
                if let skipChain = allCosmosChains.filter({ $0.chainId == sChain["chain_id"].stringValue && $0.isDefault == true }).first {
                    skipChains.append(skipChain)
                }
            })
            
            if (BaseData.instance.skipAssets == nil) {
                skipAssets = try? await fetchSkipAssets()
                BaseData.instance.skipAssets = skipAssets
            } else {
                skipAssets = BaseData.instance.skipAssets
            }
//            print("skipChains ", skipChains.count)
//            print("skipAssets ", skipAssets?["chain_to_assets_map"].count)
            
            // $0.isDefault 예외처리 확인 카바
            inputCosmosChain = skipChains.filter({ $0.tag == "cosmos118" }).first!
            skipAssets?["chain_to_assets_map"][inputCosmosChain.chainId]["assets"].arrayValue.forEach({ json in
                if BaseData.instance.getAsset(inputCosmosChain.apiName, json["denom"].stringValue) != nil {
                    inputAssetList.append(json)
                }
            })
            inputAssetSelected = inputAssetList.filter { $0["denom"].stringValue == inputCosmosChain.stakeDenom }.first!
            
            outputCosmosChain = skipChains.filter({ $0.tag == "akash118" }).first!
            skipAssets?["chain_to_assets_map"][outputCosmosChain.chainId]["assets"].arrayValue.forEach({ json in
                if BaseData.instance.getAsset(outputCosmosChain.apiName, json["denom"].stringValue) != nil {
                    outputAssetList.append(json)
                }
            })
            outputAssetSelected = outputAssetList.filter { $0["denom"].stringValue == outputCosmosChain.stakeDenom }.first!
            
            let inputChannel = getConnection(inputCosmosChain)
            if let inputAuth = try? await fetchAuth(inputChannel, inputCosmosChain.address!),
               let inputBal = try? await fetchBalances(inputChannel, inputCosmosChain.address!),
               let inputParam = try? await inputCosmosChain.fetchChainParam() {
                inputCosmosChain.mintscanChainParam = inputParam
                inputCosmosChain.cosmosAuth = inputAuth!
                inputCosmosChain.cosmosBalances = inputBal!
                WUtils.onParseVestingAccount(inputCosmosChain)
            }
            
            let outputChannel = getConnection(outputCosmosChain)
            if let outputAuth = try? await fetchAuth(outputChannel, outputCosmosChain.address!),
               let outputBal = try? await fetchBalances(outputChannel, outputCosmosChain.address!),
               let outputParam = try? await outputCosmosChain.fetchChainParam() {
                outputCosmosChain.mintscanChainParam = outputParam
                outputCosmosChain.cosmosAuth = outputAuth!
                outputCosmosChain.cosmosBalances = outputBal!
                WUtils.onParseVestingAccount(outputCosmosChain)
            }
            
            DispatchQueue.main.async {
                self.onInitView()
            }
        }
        
        inputChainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onInputChain)))
        inputAssetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onInputAsset)))
        outputChainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOutputChain)))
        outputAssetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOutputAsset)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        inputAmountTextField.delegate = self
        inputAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: inputAssetSelected["decimals"].int16Value)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = inputAmountTextField.text?.trimmingCharacters(in: .whitespaces)  {
            print("text ", text)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func onInitView() {
        titleLabel.isHidden = false
        slippageBtn.isHidden = false
        rootScrollView.isHidden = false
        swapBtn.isHidden = false
        onReadyToUserInsert()
    }
    
    func onReadyToUserInsert() {
        loadingView.isHidden = true
        txFee = inputCosmosChain.getInitFee()
        
        //From UI update
        fromAddressLabel.text = inputCosmosChain.address
        inputChainImg.image = UIImage(named: inputCosmosChain.logo1)
        inputChainLabel.text = inputCosmosChain.name.uppercased()
        print("fromAddress ", inputCosmosChain.address)
        
        let inputDenom = inputAssetSelected["denom"].stringValue
        print("inputDenom ", inputDenom)
        inputMsAsset = BaseData.instance.getAsset(inputCosmosChain.apiName, inputDenom)!
        inputAssetImg.af.setImage(withURL: inputMsAsset.assetImg())
        inputAssetLabel.text = inputMsAsset.symbol
        
        let inputBlance = inputCosmosChain.balanceAmount(inputDenom)
        if (txFee.amount[0].denom == inputDenom) {
            let feeAmount = NSDecimalNumber.init(string: txFee.amount[0].amount)
            if (feeAmount.compare(inputBlance).rawValue >= 0) {
                availableAmount = NSDecimalNumber.zero
            } else {
                availableAmount = inputBlance.subtracting(feeAmount)
            }
        } else {
            availableAmount = inputBlance
        }
        WDP.dpCoin(inputMsAsset, availableAmount, nil, nil, inputAvailableLabel, inputMsAsset.decimals)
        
        
        //To UI update
        toAddressLabel.text = outputCosmosChain.address
        outputChainImg.image = UIImage(named: outputCosmosChain.logo1)
        outputChainLabel.text = outputCosmosChain.name.uppercased()
        print("toAddress ", outputCosmosChain.address)
        
        let outputDenom = outputAssetSelected["denom"].stringValue
        print("outputDenom ", outputDenom)
        outputMsAsset = BaseData.instance.getAsset(outputCosmosChain.apiName, outputDenom)!
        outputAssetImg.af.setImage(withURL: outputMsAsset.assetImg())
        outputAssetLabel.text = outputMsAsset.symbol
        
        let outputBalance = outputCosmosChain.balanceAmount(outputDenom)
        WDP.dpCoin(outputMsAsset, outputBalance, nil, nil, outputBalanceLabel, outputMsAsset.decimals)
        
        inputAmountTextField.text = ""
        inputValueCurrency.text = ""
        inputValueLabel.text = ""
        outputAmountLabel.text = "0"
        outputValueCurrency.text = ""
        outputValueLabel.text = ""
        errorCardView.isHidden = true
        descriptionCardView.isHidden = true
    }
    
    @objc func onInputChain() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = skipChains.filter({ $0.tag != outputCosmosChain.tag })
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputChain
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onInputAsset() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = inputAssetList
        baseSheet.swapBalance = inputCosmosChain.cosmosBalances
        baseSheet.targetChain = inputCosmosChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputAsset
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onOutputChain() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = skipChains.filter({ $0.tag != inputCosmosChain.tag })
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputChain
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onOutputAsset() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = outputAssetList
        baseSheet.swapBalance = outputCosmosChain.cosmosBalances
        baseSheet.targetChain = outputCosmosChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputAsset
        onStartSheet(baseSheet, 680)
    }
    
    
    @IBAction func onClickSlippage(_ sender: UIButton) {
        dismissKeyboard()
        print("onClickSlippage")
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
    }
    
    @IBAction func onSwapToggle(_ sender: UIButton) {
        print("onSwapToggle")
    }
    
    @IBAction func onClickSwap(_ sender: UIButton) {
        print("onClickSwap")
    }
    
    
    func onBindSkipRouteReq() -> JSON {
        return JSON()
    }
    
    func onBindSkipMsgReq() -> JSON {
        return JSON()
    }
    
}

extension SwapStartVC: BaseSheetDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectSwapInputChain) {
            if (inputCosmosChain.chainId != result.param) {
                loadingView.isHidden = false
                Task {
                    inputCosmosChain = skipChains.filter({ $0.chainId == result.param }).first!
                    inputAssetList.removeAll()
                    skipAssets?["chain_to_assets_map"][inputCosmosChain.chainId]["assets"].arrayValue.forEach({ json in
                        if BaseData.instance.getAsset(inputCosmosChain.apiName, json["denom"].stringValue) != nil {
                            inputAssetList.append(json)
                        }
                    })
                    inputAssetSelected = inputAssetList.filter { $0["denom"].stringValue == inputCosmosChain.stakeDenom }.first ?? inputAssetList[0]
                    
                    let inputChannel = getConnection(inputCosmosChain)
                    if let inputAuth = try? await fetchAuth(inputChannel, inputCosmosChain.address!),
                       let inputBal = try? await fetchBalances(inputChannel, inputCosmosChain.address!),
                       let inputParam = try? await inputCosmosChain.fetchChainParam() {
                        inputCosmosChain.mintscanChainParam = inputParam
                        inputCosmosChain.cosmosAuth = inputAuth!
                        inputCosmosChain.cosmosBalances = inputBal!
                        WUtils.onParseVestingAccount(inputCosmosChain)
                    }
                    
                    DispatchQueue.main.async {
                        self.onReadyToUserInsert()
                    }
                }
            }
            
        } else if (sheetType == .SelectSwapOutputChain) {
            if (outputCosmosChain.chainId != result.param) {
                loadingView.isHidden = false
                Task {
                    outputCosmosChain = skipChains.filter({ $0.chainId == result.param}).first!
                    outputAssetList.removeAll()
                    skipAssets?["chain_to_assets_map"][outputCosmosChain.chainId]["assets"].arrayValue.forEach({ json in
                        if BaseData.instance.getAsset(outputCosmosChain.apiName, json["denom"].stringValue) != nil {
                            outputAssetList.append(json)
                        }
                    })
                    outputAssetSelected = outputAssetList.filter { $0["denom"].stringValue == outputCosmosChain.stakeDenom }.first ?? outputAssetList[0]
                    
                    let outputChannel = getConnection(outputCosmosChain)
                    if let outputAuth = try? await fetchAuth(outputChannel, outputCosmosChain.address!),
                       let outputBal = try? await fetchBalances(outputChannel, outputCosmosChain.address!),
                       let outputParam = try? await outputCosmosChain.fetchChainParam() {
                        outputCosmosChain.mintscanChainParam = outputParam
                        outputCosmosChain.cosmosAuth = outputAuth!
                        outputCosmosChain.cosmosBalances = outputBal!
                        WUtils.onParseVestingAccount(outputCosmosChain)
                    }
                    
                    DispatchQueue.main.async {
                        self.onReadyToUserInsert()
                    }
                }
            }
            
        } else if (sheetType == .SelectSwapInputAsset) {
            if (inputAssetSelected["denom"].stringValue != result.param) {
                inputAssetSelected = inputAssetList.filter { $0["denom"].stringValue == result.param }.first!
                onReadyToUserInsert()
            }
            
            
        } else if (sheetType == .SelectSwapOutputAsset) {
            if (outputAssetSelected["denom"].stringValue != result.param) {
                outputAssetSelected = outputAssetList.filter { $0["denom"].stringValue == result.param}.first!
                onReadyToUserInsert()
            }
            
        }
    }
}


extension SwapStartVC {
    
    func fetchSkipChains() async throws -> JSON {
        print("fetchSkipChains ", BaseNetWork.SkipChains())
        return try await AF.request(BaseNetWork.SkipChains(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipAssets() async throws -> JSON {
        print("fetchSkipAssets ", BaseNetWork.SkipAssets())
        return try await AF.request(BaseNetWork.SkipAssets(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipRoute() async throws -> JSON {
        let json = onBindSkipRouteReq()
        return try await AF.request(BaseNetWork.SkipRoutes(), method: .post, parameters: json.dictionaryObject!, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipMsg() async throws -> JSON {
        let json = onBindSkipMsgReq()
        return try await AF.request(BaseNetWork.SkipMsg(), method: .post, parameters: json.dictionaryObject!, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
    
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Google_Protobuf_Any? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.get().account
    }
    
    func fetchIbcClient(_ channel: ClientConnection, _ msPath: MintscanPath) async throws -> Ibc_Core_Channel_V1_QueryChannelClientStateResponse? {
        let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
            $0.channelID = msPath.channel!
            $0.portID = msPath.port!
        }
        return try? await Ibc_Core_Channel_V1_QueryNIOClient(channel: channel).channelClientState(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLastBlock(_ channel: ClientConnection) async throws -> Cosmos_Base_Tendermint_V1beta1_GetLatestBlockResponse? {
        let req = Cosmos_Base_Tendermint_V1beta1_GetLatestBlockRequest()
        return try? await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: channel).getLatestBlock(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchBalances(_ channel: ClientConnection, _ address: String) async throws -> [Cosmos_Base_V1beta1_Coin]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address; $0.pagination = page }
        return try? await Cosmos_Bank_V1beta1_QueryNIOClient(channel: channel).allBalances(req, callOptions: getCallOptions()).response.get().balances
    }
    
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.grpcHost, port: chain.grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}
