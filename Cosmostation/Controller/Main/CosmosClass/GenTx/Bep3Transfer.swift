//
//  Bep3Transfer.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/08.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf
import web3swift
import BigInt

class Bep3Transfer: BaseVC {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var fromChainImg: UIImageView!
    @IBOutlet weak var fromChainLabel: UILabel!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainLabel: UILabel!
    
    @IBOutlet weak var toSendAssetCard: FixCardView!
    @IBOutlet weak var toSendAssetTitle: UILabel!
    @IBOutlet weak var toSendAssetImg: UIImageView!
    @IBOutlet weak var toSendSymbolLabel: UILabel!
    @IBOutlet weak var toSendAssetHint: UILabel!
    @IBOutlet weak var toAssetAmountLabel: UILabel!
    @IBOutlet weak var toAssetDenomLabel: UILabel!
    @IBOutlet weak var toAssetCurrencyLabel: UILabel!
    @IBOutlet weak var toAssetValueLabel: UILabel!
    
    @IBOutlet weak var toAddressCardView: FixCardView!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressHint: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var sendBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var swapParmas: [Kava_Bep3_V1beta1_AssetParam]?
    var swapSupplies: [Kava_Bep3_V1beta1_AssetSupplyResponse]?
    
    var fromChain: CosmosClass!
    var toChains: [CosmosClass]!
    var toSendDenom: String!
    var toSendAmount = NSDecimalNumber.zero
    var recipientAddress: String?
    
    var availableAmount = NSDecimalNumber.zero

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
        
        
        if (fromChain is ChainBinanceBeacon) {
            let bnbChain = fromChain as! ChainBinanceBeacon
            toChains = baseAccount.allCosmosClassChains.filter { $0.name == "Kava" }
            fromChainImg.image = UIImage.init(named: "chainBnbBeacon")
            fromChainLabel.text = "BNB Beacon"
            
            toChainImg.image = UIImage.init(named: "chainKava")
            toChainLabel.text = "Kava"
            if let tokenInfo = bnbChain.lcdBeaconTokens.filter({ $0["symbol"].string == toSendDenom }).first {
                let original_symbol = tokenInfo["original_symbol"].stringValue
                toSendAssetImg.af.setImage(withURL: ChainBinanceBeacon.assetImg(original_symbol))
                toSendSymbolLabel.text = original_symbol.uppercased()
            }
            
            let available = bnbChain.lcdBalanceAmount(toSendDenom)
            if (toSendDenom == fromChain.stakeDenom) {
                availableAmount = available.subtracting(NSDecimalNumber(string: BNB_BEACON_BASE_FEE))
            } else {
                availableAmount = available
            }
            print("availableAmount ", toSendDenom, " ", availableAmount)
            
        } else {
            toChains = baseAccount.allCosmosClassChains.filter { $0.name == "BNB Beacon" }
            fromChainImg.image = UIImage.init(named: "chainKava")
            fromChainLabel.text = "Kava"
            
            toChainImg.image = UIImage.init(named: "chainBnbBeacon")
            toChainLabel.text = "BNB Beacon"
            
            if let msAsset = BaseData.instance.getAsset(fromChain.apiName, toSendDenom) {
                toSendSymbolLabel.text = msAsset.symbol
                toSendAssetImg.af.setImage(withURL: msAsset.assetImg())
            }
            
            availableAmount = fromChain.balanceAmount(toSendDenom)
            print("availableAmount ", toSendDenom, " ", availableAmount)
        }
        
        toAddressCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickToAddress)))
        toSendAssetCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAmount)))
        
        fetchData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        print("onFetchDone ", tag)
    }
    
    func fetchData() {
        Task {
            self.baseAccount.fetchTargetCosmosChains(toChains)
            
            let channel = getConnection()
            if let swapParam = try? await fetchSwapParam(channel),
               let swapSupply = try? await fetchSwapSupply(channel) {
//                print("swapParam ", swapParam)
//                print("swapSupply ", swapSupply)
                self.swapParmas = swapParam?.params.assetParams
                self.swapSupplies = swapSupply?.assetSupplies
                
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                }
            }
        }
    }
    
    @objc func onClickToAddress() {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.cosmosChainList = toChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectBepRecipientAddress
        onStartSheet(baseSheet)
    }
    
    func onUpdateToAddressView() {
        if (recipientAddress == nil ||
            recipientAddress?.isEmpty == true) {
            toAddressHint.isHidden = false
            toAddressLabel.isHidden = true
            
        } else {
            toAddressHint.isHidden = true
            toAddressLabel.isHidden = false
            toAddressLabel.text = recipientAddress
            toAddressLabel.adjustsFontSizeToFitWidth = true
        }
        onValidate()
    }
    
    @objc func onClickAmount() {
        let amountSheet = TxAmountBepSheet(nibName: "TxAmountBepSheet", bundle: nil)
        amountSheet.fromChain = fromChain
        amountSheet.toSendDenom = toSendDenom
        amountSheet.availableAmount = availableAmount
        if (toSendAmount != NSDecimalNumber.zero) {
            amountSheet.existedAmount = toSendAmount
        }
        amountSheet.sheetDelegate = self
        self.onStartSheet(amountSheet)
    }
    
    func onUpdateAmountView(_ amount: String?) {
        toSendAssetHint.isHidden = false
        toAssetAmountLabel.isHidden = true
        toAssetDenomLabel.isHidden = true
        toAssetCurrencyLabel.isHidden = true
        toAssetValueLabel.isHidden = true
        
        if (amount?.isEmpty == true) {
            toSendAmount = NSDecimalNumber.zero
        } else {
            toSendAmount = NSDecimalNumber(string: amount)
            
            if (fromChain is ChainBinanceBeacon) {
                let bnbChain = fromChain as! ChainBinanceBeacon
                if let tokenInfo = bnbChain.lcdBeaconTokens.filter({ $0["symbol"].string == toSendDenom }).first {
                    toAssetDenomLabel.text = tokenInfo["original_symbol"].stringValue.uppercased()
                    toAssetAmountLabel?.attributedText = WDP.dpAmount(toSendAmount.stringValue, toAssetAmountLabel!.font, 8)
                    
                    if (toSendDenom == bnbChain.stakeDenom) {
                        let msPrice = BaseData.instance.getPrice(BNB_GECKO_ID)
                        let toSendValue = msPrice.multiplying(by: toSendAmount, withBehavior: handler6)
                        WDP.dpValue(toSendValue, toAssetCurrencyLabel, toAssetValueLabel)
                        toAssetCurrencyLabel.isHidden = false
                        toAssetValueLabel.isHidden = false
                    }
                }
                
            } else {
                if let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom?.lowercased() == toSendDenom.lowercased() }).first {
                    let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
                    let value = msPrice.multiplying(by: toSendAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                    
                    WDP.dpCoin(msAsset, toSendAmount, nil, toAssetDenomLabel, toAssetAmountLabel, msAsset.decimals)
                    WDP.dpValue(value, toAssetCurrencyLabel, toAssetValueLabel)
                    toAssetCurrencyLabel.isHidden = false
                    toAssetValueLabel.isHidden = false
                }
            }
            toSendAssetHint.isHidden = true
            toAssetAmountLabel.isHidden = false
            toAssetDenomLabel.isHidden = false
        }
        onValidate()
    }

    @IBAction func onClickSend(_ sender: BaseButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    func onValidate() {
        sendBtn.isEnabled = false
        if (toSendAmount == NSDecimalNumber.zero ) { return }
        if (recipientAddress == nil || recipientAddress?.isEmpty == true) { return }
        sendBtn.isEnabled = true
    }
}

extension Bep3Transfer: BaseSheetDelegate, BepAmountSheetDelegate, PinDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SelectBepRecipientAddress) {
            recipientAddress = result.param
            onUpdateToAddressView()
        }
    }
    
    func onInputedAmount(_ amount: String) {
        onUpdateAmountView(amount)
    }
    
    func pinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                let bepResult = BepTxResult(nibName: "BepTxResult", bundle: nil)
                bepResult.fromChain = self.fromChain
                bepResult.toChain = self.toChains.filter { $0.address == self.recipientAddress }.first!
                bepResult.toSendDenom = self.toSendDenom
                bepResult.toSendAmount = self.toSendAmount
                bepResult.modalPresentationStyle = .fullScreen
                self.present(bepResult, animated: true)
            });
        }
    }
}


extension Bep3Transfer {
    
    func fetchSwapParam(_ channel: ClientConnection) async throws -> Kava_Bep3_V1beta1_QueryParamsResponse? {
        let req = Kava_Bep3_V1beta1_QueryParamsRequest()
        return try? await Kava_Bep3_V1beta1_QueryNIOClient(channel: channel).params(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchSwapSupply(_ channel: ClientConnection) async throws -> Kava_Bep3_V1beta1_QueryAssetSuppliesResponse? {
        let req = Kava_Bep3_V1beta1_QueryAssetSuppliesRequest()
        return try? await Kava_Bep3_V1beta1_QueryNIOClient(channel: channel).assetSupplies(req, callOptions: getCallOptions()).response.get()
    }
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: "grpc-kava.cosmostation.io", port: 443)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}
