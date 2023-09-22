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
        loadingView.animation = LottieAnimation.named("loading2")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        inputValueCurrency?.text = BaseData.instance.getCurrencySymbol()
        inputValueLabel?.text = ""
        outputValueCurrency?.text = BaseData.instance.getCurrencySymbol()
        outputValueLabel?.text = ""
        
        Task {
            self.allCosmosChains = await baseAccount.initOnyKeyData(true)
            let sChains = try? await self.fetchSkipChains()
            sChains?["chains"].arrayValue.forEach({ sChain in
                if (self.allCosmosChains.filter { $0.chainId == sChain["chain_id"].stringValue }.count > 0 ) {
                    self.skipChains.append(sChain)
                }
            })
            self.skipAssets = try? await self.fetchSkipAssets()
            
            self.inputChain = self.skipChains.filter({ $0["chain_name"].stringValue == "cosmoshub" }).first!
            self.inputCosmosChain = self.allCosmosChains.filter({ $0.chainId == self.inputChain["chain_id"].stringValue }).first!
            self.skipAssets?["chain_to_assets_map"][self.inputChain["chain_id"].stringValue]["assets"].arrayValue.forEach({ json in
                if BaseData.instance.getAsset(self.inputCosmosChain.apiName, json["denom"].stringValue) != nil {
                    self.inputAssetList.append(json)
                }
            })
            self.inputAssetSelected = self.inputAssetList.filter { $0["denom"].stringValue == "uatom" }.first!
            
            self.outputChain = self.skipChains.filter({ $0["chain_name"].stringValue == "akash" }).first!
            self.outputCosmosChain = self.allCosmosChains.filter({ $0.chainId == self.outputChain["chain_id"].stringValue && $0.isDefault == true }).first!
            self.skipAssets?["chain_to_assets_map"][self.outputChain["chain_id"].stringValue]["assets"].arrayValue.forEach({ json in
                if BaseData.instance.getAsset(self.outputCosmosChain.apiName, json["denom"].stringValue) != nil {
                    self.outputAssetList.append(json)
                }
            })
            self.outputAssetSelected = self.outputAssetList.filter { $0["denom"].stringValue == "uakt" }.first!
            
            let inputChannel = getConnection(self.inputCosmosChain)
            if let inputAuth = try? await self.fetchAuth(inputChannel, inputCosmosChain.address!),
                let inputBal = try? await self.fetchBalances(inputChannel, inputCosmosChain.address!) {
                    self.inputBalances = WUtils.onParseAvailableCoins(inputAuth, inputBal)
            }
            
            let outputChannel = getConnection(self.outputCosmosChain)
            if let outputAuth = try? await self.fetchAuth(outputChannel, outputCosmosChain.address!),
                let outputBal = try? await self.fetchBalances(outputChannel, outputCosmosChain.address!) {
                    self.outputBalances = WUtils.onParseAvailableCoins(outputAuth, outputBal)
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
        loadingView.stop()
        loadingView.isHidden = true
        
        titleLabel.isHidden = false
        slippageBtn.isHidden = false
        rootScrollView.isHidden = false
        swapBtn.isHidden = false
        
        
        print("inputChain ", inputChain)
        print("inputAssetSelected ", inputAssetSelected)

        print("outputChain ", outputChain)
        print("outputAssetSelected ", outputAssetSelected)
        
        onUpdateView()
    }
    
    func onUpdateView() {
        //From UI update
        fromAddressLabel.text = inputCosmosChain.address
        
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
        if let inputBlance = self.inputBalances.filter({ $0.denom == inputDenom }).first,
            let inputMsAsset = BaseData.instance.getAsset(inputCosmosChain.apiName, inputDenom) {
            WDP.dpCoin(inputMsAsset, inputBlance, nil, nil, self.inputAvailableLabel, inputMsAsset.decimals)
        } else {
            self.inputAvailableLabel.text = "0"
        }
        
        
        //To UI update
        toAddressLabel.text = outputCosmosChain.address
        
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
        if let outputBalance = self.outputBalances.filter({ $0.denom == outputDenom }).first,
           let outputMsAsset = BaseData.instance.getAsset(outputCosmosChain.apiName, outputDenom) {
            WDP.dpCoin(outputMsAsset, outputBalance, nil, nil, self.outputBalanceLabel, outputMsAsset.decimals)
        } else {
            self.outputBalanceLabel.text = "0"
        }
        
    }
    
    @objc func onInputChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = skipChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputChain
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onInputAsset() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = inputAssetList
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputAsset
        onStartSheet(baseSheet, 680)
    }
    
    
    @objc func onOutputChain() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = skipChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputChain
        onStartSheet(baseSheet, 680)
    }
    
    @objc func onOutputAsset() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = outputAssetList
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputAsset
        onStartSheet(baseSheet, 680)
    }
    
    
    @IBAction func onClickSlippage(_ sender: UIButton) {
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
            if (inputChain["chain_id"].stringValue != skipChains[result.position!]["chain_id"].stringValue) {
            }
            
        } else if (sheetType == .SelectSwapOutputChain) {
            if (outputChain["chain_id"].stringValue != skipChains[result.position!]["chain_id"].stringValue) {
            }
            
        } else if (sheetType == .SelectSwapInputAsset) {
            if (inputAssetSelected["denom"].stringValue != inputAssetList[result.position!]["denom"].stringValue) {
            }
            
            
        } else if (sheetType == .SelectSwapOutputAsset) {
            if (outputAssetSelected["denom"].stringValue != outputAssetList[result.position!]["denom"].stringValue) {
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
