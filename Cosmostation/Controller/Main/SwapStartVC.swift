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

class SwapStartVC: BaseVC {
    
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
    var inputAssetList = Array<JSON>()
    var inputAssetSelected: JSON!
    var inputBalance: Cosmos_Base_V1beta1_Coin!
    
    var outputChain: JSON!
    var outputAssetList = Array<JSON>()
    var outputAssetSelected: JSON!
    var outputBalance: Cosmos_Base_V1beta1_Coin!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
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
            self.inputAssetList = self.skipAssets?["chain_to_assets_map"][self.inputChain["chain_id"].stringValue]["assets"].arrayValue ?? []
            self.inputAssetSelected = self.inputAssetList.filter { $0["denom"].stringValue == "uatom" }.first!
            
            self.outputChain = self.skipChains.filter({ $0["chain_name"].stringValue == "akash" }).first!
            self.outputAssetList = self.skipAssets?["chain_to_assets_map"][self.outputChain["chain_id"].stringValue]["assets"].arrayValue ?? []
            self.outputAssetSelected = self.outputAssetList.filter { $0["denom"].stringValue == "uakt" }.first!
            
            
            DispatchQueue.main.async {
                self.onInitView()
            }
        }
        
        inputChainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onInputChain)))
        inputAssetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onInputAsset)))
        outputChainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOutputChain)))
        outputAssetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOutputAsset)))
        
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
        let inputBaseChain = allCosmosChains.filter { $0.chainId == inputChain["chain_id"].stringValue }.first
        fromAddressLabel.text = inputBaseChain?.address
        
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
        
        
        
        let outputBaseChain = allCosmosChains.filter { $0.chainId == outputChain["chain_id"].stringValue && $0.isDefault == true }.first
        toAddressLabel.text = outputBaseChain?.address
        
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
        
        
        
        Task {
            let inputDenom = inputAssetSelected["denom"].stringValue
            let inputChannel = getConnection(inputBaseChain!)
            if let inputAuth = try? await self.fetchAuth(inputChannel, inputBaseChain!.address!),
                let inputBal = try? await self.fetchBalance(inputChannel, inputBaseChain!.address!, inputDenom) {
                    self.inputBalance = WUtils.onParseAvailableCoin(inputAuth, inputBal)
            }
            
            let outputDenom = outputAssetSelected["denom"].stringValue
            let outputChannel = getConnection(outputBaseChain!)
            if let outputAuth = try? await self.fetchAuth(outputChannel, outputBaseChain!.address!),
                let outputBal = try? await self.fetchBalance(outputChannel, outputBaseChain!.address!, outputDenom) {
                    self.outputBalance = WUtils.onParseAvailableCoin(outputAuth, outputBal)
            }
            
//            if let inputBlance = self.inputBalance,
//               let inputMsAsset = BaseData.instance.getAsset(inputBaseChain!.apiName, inputBlance.denom) {
//                let inputMsPrice = BaseData.instance.getPrice(inputMsAsset.coinGeckoId)
//                let amount = NSDecimalNumber(string: inputBlance.amount)
//                let value = inputMsPrice.multiplying(by: amount).multiplying(byPowerOf10: -inputMsAsset.decimals!, withBehavior: getDivideHandler(6))
//                WDP.dpCoin(inputMsAsset, inputBlance, nil, nil, self.inputAvailableLabel, inputMsAsset.decimals)
//                WDP.dpValue(value, valueCurrencyLabel, valueLabel)
//            }
            
            if let inputBlance = self.inputBalance,
               let inputMsAsset = BaseData.instance.getAsset(inputBaseChain!.apiName, inputBlance.denom) {
                WDP.dpCoin(inputMsAsset, inputBlance, nil, nil, self.inputAvailableLabel, inputMsAsset.decimals)
            }
            
            if let outputBalance = self.outputBalance,
               let outputMsAsset = BaseData.instance.getAsset(outputBaseChain!.apiName, outputBalance.denom) {
                WDP.dpCoin(outputMsAsset, outputBalance, nil, nil, self.outputBalanceLabel, outputMsAsset.decimals)
            }
            
            print("inputBalance ", self.inputBalance)
            print("outputBalance ", self.outputBalance)
            
        }
        
    }
    
    @objc func onInputChain() {
        print("onInputChain Click")
    }
    
    @objc func onInputAsset() {
        print("onInputAsset Click")
    }
    
    
    @objc func onOutputChain() {
        print("onOutputChain Click")
    }
    
    @objc func onOutputAsset() {
        print("onOutputAsset Click")
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
    
    func fetchBalance(_ channel: ClientConnection, _ address: String, _ denom: String) async throws -> Cosmos_Base_V1beta1_Coin? {
        let req = Cosmos_Bank_V1beta1_QueryBalanceRequest.with { $0.address = address; $0.denom = denom }
        return try? await Cosmos_Bank_V1beta1_QueryNIOClient(channel: channel).balance(req).response.get().balance
    }
    
    func getConnection(_ chain: CosmosClass) -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: chain.grpcHost, port: chain.grpcPort)
    }
}
