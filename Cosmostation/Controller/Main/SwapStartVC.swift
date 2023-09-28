//
//  SwapStartVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SkeletonView
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
    var skipChains = Array<JSON>()              //inapp support chain for skip
    var skipAssets: JSON?
    
    
    var inputChain: JSON!
    var inputCosmosChain: CosmosClass!
    var inputAssetList = Array<JSON>()
    var inputAssetSelected: JSON!
    var inputBalances = Array<Cosmos_Base_V1beta1_Coin>()
    
    var outputChain: JSON!
    var outputCosmosChain: CosmosClass!
    var outputAssetList = Array<JSON>()
    var outputAssetSelected: JSON!
    var outputBalances = Array<Cosmos_Base_V1beta1_Coin>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
//        let skeletonAnimation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
//        inputAvailableLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), 
//                                                         animation: skeletonAnimation, transition: .none)
//        outputBalanceLabel.showAnimatedGradientSkeleton(usingGradient: .init(colors: [.color03, .color02]), 
//                                                        animation: skeletonAnimation, transition: .none)
        
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
            let sChains = try? await fetchSkipChains()
            sChains?["chains"].arrayValue.forEach({ sChain in
                if (allCosmosChains.filter { $0.chainId == sChain["chain_id"].stringValue }.count > 0 ) {
                    skipChains.append(sChain)
                }
            })
            skipAssets = try? await fetchSkipAssets()
            
            inputChain = skipChains.filter({ $0["chain_name"].stringValue == "cosmoshub" }).first!
            inputCosmosChain = self.allCosmosChains.filter({ $0.chainId == inputChain["chain_id"].stringValue && $0.isDefault == true }).first!
            skipAssets?["chain_to_assets_map"][inputChain["chain_id"].stringValue]["assets"].arrayValue.forEach({ json in
                if BaseData.instance.getAsset(inputCosmosChain.apiName, json["denom"].stringValue) != nil {
                    inputAssetList.append(json)
                }
            })
            inputAssetSelected = inputAssetList.filter { $0["denom"].stringValue == inputCosmosChain.stakeDenom }.first!
            
            outputChain = skipChains.filter({ $0["chain_name"].stringValue == "akash" }).first!
            outputCosmosChain = allCosmosChains.filter({ $0.chainId == outputChain["chain_id"].stringValue && $0.isDefault == true }).first!
            skipAssets?["chain_to_assets_map"][outputChain["chain_id"].stringValue]["assets"].arrayValue.forEach({ json in
                if BaseData.instance.getAsset(outputCosmosChain.apiName, json["denom"].stringValue) != nil {
                    outputAssetList.append(json)
                }
            })
            outputAssetSelected = outputAssetList.filter { $0["denom"].stringValue == outputCosmosChain.stakeDenom }.first!
            
            let inputChannel = getConnection(inputCosmosChain)
            if let inputAuth = try? await fetchAuth(inputChannel, inputCosmosChain.address!),
                let inputBal = try? await fetchBalances(inputChannel, inputCosmosChain.address!) {
                    inputBalances = WUtils.onParseAvailableCoins(inputAuth, inputBal)
            }
            
            let outputChannel = getConnection(outputCosmosChain)
            if let outputAuth = try? await fetchAuth(outputChannel, outputCosmosChain.address!),
                let outputBal = try? await fetchBalances(outputChannel, outputCosmosChain.address!) {
                    outputBalances = WUtils.onParseAvailableCoins(outputAuth, outputBal)
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
//        loadingView.stop()
        loadingView.isHidden = true
        
        titleLabel.isHidden = false
        slippageBtn.isHidden = false
        rootScrollView.isHidden = false
        swapBtn.isHidden = false
        
        
//        print("inputChain ", inputChain)
//        print("inputAssetSelected ", inputAssetSelected)
//
//        print("outputChain ", outputChain)
//        print("outputAssetSelected ", outputAssetSelected)
        
        onReadyToUserInsert()
    }
    
    func onReadyToUserInsert() {
        loadingView.isHidden = true
        
        //From UI update
        fromAddressLabel.text = inputCosmosChain.address
        print("address ", inputCosmosChain.address)
        
        if let inputChainLogo = URL(string: inputChain["logo_uri"].stringValue) {
            inputChainImg.af.setImage(withURL: inputChainLogo)
        } else {
            inputChainImg.image = UIImage(named: "chainDefault")
        }
        inputChainLabel.text = inputChain["chain_name"].stringValue.uppercased()
        
        if let inputAssetLogo = URL(string: inputAssetSelected?["logo_uri"].stringValue ?? "") {
            inputAssetImg.af.setImage(withURL: inputAssetLogo)
        } else {
            inputAssetImg.image = UIImage(named: "tokenDefault")
        }
        
        inputAssetLabel.text = inputAssetSelected?["symbol"].stringValue
        
        let inputDenom = inputAssetSelected["denom"].stringValue
        print("inputDenom ", inputDenom)
        if let inputBlance = self.inputBalances.filter({ $0.denom == inputDenom }).first,
            let inputMsAsset = BaseData.instance.getAsset(inputCosmosChain.apiName, inputDenom) {
            WDP.dpCoin(inputMsAsset, inputBlance, nil, nil, self.inputAvailableLabel, inputMsAsset.decimals)
        } else {
            self.inputAvailableLabel.text = "0"
        }
        
        
        //To UI update
        toAddressLabel.text = outputCosmosChain.address
        print("toAddressLabel ", outputCosmosChain.address)
        
        if let outputChainLogo = URL(string: outputChain["logo_uri"].stringValue) {
            outputChainImg.af.setImage(withURL: outputChainLogo)
        } else {
            outputChainImg.image = UIImage(named: "chainDefault")
        }
        outputChainLabel.text = outputChain["chain_name"].stringValue.uppercased()
        
        if let outputAssetLogo = URL(string: outputAssetSelected?["logo_uri"].stringValue ?? "") {
            outputAssetImg.af.setImage(withURL: outputAssetLogo)
        } else {
            outputAssetImg.image = UIImage(named: "tokenDefault")
        }
        
        outputAssetLabel.text = outputAssetSelected?["symbol"].stringValue
        
    
        let outputDenom = outputAssetSelected["denom"].stringValue
        print("outputDenom ", outputDenom)
        if let outputBalance = self.outputBalances.filter({ $0.denom == outputDenom }).first,
           let outputMsAsset = BaseData.instance.getAsset(outputCosmosChain.apiName, outputDenom) {
            WDP.dpCoin(outputMsAsset, outputBalance, nil, nil, self.outputBalanceLabel, outputMsAsset.decimals)
        } else {
            self.outputBalanceLabel.text = "0"
        }
        
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
        baseSheet.swapChains = skipChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputChain
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onInputAsset() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = inputAssetList
        baseSheet.swapBalance = inputBalances
        baseSheet.targetChain = inputCosmosChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputAsset
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onOutputChain() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = skipChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputChain
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onOutputAsset() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = outputAssetList
        baseSheet.swapBalance = outputBalances
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
    
    
}

extension SwapStartVC: BaseSheetDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectSwapInputChain) {
            if (inputChain["chain_id"].stringValue != result.param) {
                loadingView.isHidden = false
                Task {
                    inputChain = skipChains.filter({ $0["chain_id"].stringValue == result.param }).first!
                    inputCosmosChain = self.allCosmosChains.filter({ $0.chainId == inputChain["chain_id"].stringValue && $0.isDefault == true }).first!
                    skipAssets?["chain_to_assets_map"][inputChain["chain_id"].stringValue]["assets"].arrayValue.forEach({ json in
                        if BaseData.instance.getAsset(inputCosmosChain.apiName, json["denom"].stringValue) != nil {
                            inputAssetList.append(json)
                        }
                    })
                    inputAssetSelected = inputAssetList.filter { $0["denom"].stringValue == inputCosmosChain.stakeDenom }.first!
                    
                    let inputChannel = getConnection(inputCosmosChain)
                    if let inputAuth = try? await fetchAuth(inputChannel, inputCosmosChain.address!),
                        let inputBal = try? await fetchBalances(inputChannel, inputCosmosChain.address!) {
                            inputBalances = WUtils.onParseAvailableCoins(inputAuth, inputBal)
                    }
                    
                    DispatchQueue.main.async {
                        self.onReadyToUserInsert()
                    }
                }
            }
            
        } else if (sheetType == .SelectSwapOutputChain) {
            if (outputChain["chain_id"].stringValue != result.param) {
                loadingView.isHidden = false
                Task {
                    outputChain = skipChains.filter({ $0["chain_id"].stringValue == result.param }).first!
                    outputCosmosChain = allCosmosChains.filter({ $0.chainId == outputChain["chain_id"].stringValue && $0.isDefault == true }).first!
                    skipAssets?["chain_to_assets_map"][outputChain["chain_id"].stringValue]["assets"].arrayValue.forEach({ json in
                        if BaseData.instance.getAsset(outputCosmosChain.apiName, json["denom"].stringValue) != nil {
                            outputAssetList.append(json)
                        }
                    })
                    outputAssetSelected = outputAssetList.filter { $0["denom"].stringValue == outputCosmosChain.stakeDenom }.first!
                    
                    let outputChannel = getConnection(outputCosmosChain)
                    if let outputAuth = try? await fetchAuth(outputChannel, outputCosmosChain.address!),
                        let outputBal = try? await fetchBalances(outputChannel, outputCosmosChain.address!) {
                            outputBalances = WUtils.onParseAvailableCoins(outputAuth, outputBal)
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
        return try await AF.request(BaseNetWork.SkipChains(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipAssets() async throws -> JSON {
        return try await AF.request(BaseNetWork.SkipAssets(), method: .get).serializingDecodable(JSON.self).value
    }
    
    
    func fetchAuth(_ channel: ClientConnection, _ address: String) async throws -> Google_Protobuf_Any? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req).response.get().account
    }
    
    func fetchBalances(_ channel: ClientConnection, _ address: String) async throws -> [Cosmos_Base_V1beta1_Coin]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address; $0.pagination = page }
        return try? await Cosmos_Bank_V1beta1_QueryNIOClient(channel: channel).allBalances(req).response.get().balances
    }
    
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.grpcHost, port: chain.grpcPort)
    }
}
