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
import SDWebImage
import SwiftyJSON
import SwiftProtobuf

class SwapStartVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slippageBtn: UIButton!
    @IBOutlet weak var midGapConstraint1: NSLayoutConstraint!
    @IBOutlet weak var midGapConstraint2: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var toggleBtn: UIButton!
    
    @IBOutlet weak var errorCardView: RedFixCardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    @IBOutlet weak var descriptionCardView: FixCardView!
    @IBOutlet weak var slippageLabel: UILabel!
    @IBOutlet weak var rateInputAmountLanel: UILabel!
    @IBOutlet weak var rateInputDenomLabel: UILabel!
    @IBOutlet weak var rateOutputAmountLanel: UILabel!
    @IBOutlet weak var rateOutputDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLanel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var swapBtn: BaseButton!
    
    var allChains = Array<BaseChain>()
    var skipChains = Array<BaseChain>()               //inapp support chain for skip
    var skipInputAssets = [JSON]()
    var skipOutputAssets = [JSON]()
    
    var squidChains = Array<BaseChain>()               //inapp support chain for squid
    var squidInputAssets = [JSON]()
    var squidOutputAssets = [JSON]()
    
    var targetChains = Array<BaseChain>()
    var targetInputAssets = [TargetAsset]()
    var targetOutputAssets = [TargetAsset]()
    
    var inputChain: BaseChain!
    var inputAsset: TargetAsset!
    
    var outputChain: BaseChain!
    var outputAsset: TargetAsset!
    
    
    
    
    
    
    var skipAssets: JSON?
    var skipSlippage = "1"
    
//    var inputAssetList = Array<JSON>()
//    var inputAssetSelected: JSON!
    var inputMsAsset: MintscanAsset!
    
    
//    var outputAssetList = Array<JSON>()
//    var outputAssetSelected: JSON!
    var outputMsAsset: MintscanAsset!
    
    var availableAmount = NSDecimalNumber.zero
    var toActionAmount = NSDecimalNumber.zero
    
    var txFee: Cosmos_Tx_V1beta1_Fee!
    var txTip: Cosmos_Tx_V1beta1_Tip?
    var toMsg: JSON?

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
        
        Task {
            allChains = await baseAccount.initAllKeys().filter({ $0.isTestnet == false && $0.isDefault })
            
            
            let skipChainList = try? await self.fetchSkipChains()
//            print("skipChainList ", skipChainList?["chains"].count)
            
            let squidChainList = try? await self.fetchSquidChains()
//            print("squidChainList ", squidChainList?["chains"].count)
            
            
            skipChainList?["chains"].arrayValue.forEach({ skipChain in
                if let skipCosmosChain = allChains.filter({ $0.chainIdCosmos == skipChain["chain_id"].stringValue }).first {
                    skipChains.append(skipCosmosChain)
                }
                if let skipEvmChain = allChains.filter({ $0.chainIdEvmDecimal == skipChain["chain_id"].stringValue }).first {
                    skipChains.append(skipEvmChain)
                }
            })
//            print("skipChains ", skipChains.count)
            
            
            squidChainList?["chains"].arrayValue.forEach({ squidChain in
                if let squidCosmosChain = allChains.filter({ $0.chainIdCosmos == squidChain["chainId"].stringValue }).first {
                    squidChains.append(squidCosmosChain)
                }
                if let squidEvmChain = allChains.filter({ $0.chainIdEvmDecimal == squidChain["chainId"].stringValue }).first {
                    squidChains.append(squidEvmChain)
                }
            })
//            print("squidChains ", squidChains.count)
            
            targetChains.append(contentsOf: skipChains)
            squidChains.forEach { squidChain in
                if !targetChains.contains(where: { $0.tag == squidChain.tag }) {
                    targetChains.append(squidChain)
                }
            }
            targetChains.sort {
                if ($0.tag == "cosmos118") { return true }
                if ($1.tag == "cosmos118") { return false }
                if ($0.tag == "ethereum60") { return true }
                if ($1.tag == "ethereum60") { return false }
                if ($0.tag == "osmosis118") { return true }
                if ($1.tag == "osmosis118") { return false }
                return $0.name < $1.name
            }
            print("targetChains ", targetChains.count)
            
//            print("skipChains ", skipChains)
//            print("squidChains ", squidChains)
//            print("targetChains ", targetChains)
            
            inputChain = targetChains[0]
            outputChain = targetChains[1]
            
            try await fetchInputAssetBalances()             // fetching coins balance and vesting
            try await fetchOutputAssetBalances()            // fetching coins balance and vesting
            
            try await fetchInputAssets()
            try await fetchOutputAssets()
            
            inputAsset = targetInputAssets[0]
            outputAsset = targetOutputAssets[0]
            
            try await fetchInputAssetBalance()
            try await fetchOutputAssetBalance()
            
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let gap = UIScreen.main.bounds.size.height - 740
        if (gap > 0) {
            midGapConstraint1.constant = gap
            midGapConstraint2.constant = gap + 40
        } else {
            midGapConstraint1.constant = 60
            midGapConstraint2.constant = 70
        }
    }
    
    func onInitView() {
        titleLabel.isHidden = false
        slippageBtn.isHidden = false
        rootScrollView.isHidden = false
        swapBtn.isHidden = false
        
        onReadyToUserInsert()
        
        if (BaseData.instance.getSwapWarn()) {
            let warnSheet = NoticeSheet(nibName: "NoticeSheet", bundle: nil)
            warnSheet.noticeType = .SwapInitWarn
            onStartSheet(warnSheet, 320, 0.6)
        }
    }
    
    func onReadyToUserInsert() {
        
        swapBtn.isEnabled = false
        toggleBtn.isEnabled = true
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        
        //From UI update
        fromAddressLabel.text = inputChain.bechAddress ?? inputChain.evmAddress
        inputChainImg.image = UIImage(named: inputChain.logo1)
        inputChainLabel.text = inputChain.name.uppercased()
        if let inputMsAsset = BaseData.instance.getAsset(inputChain.apiName, inputAsset.denom) {
            inputAssetImg.sd_setImage(with: inputMsAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            inputAssetLabel.text = inputMsAsset.symbol
        } else {
            inputAssetImg.sd_setImage(with: inputAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            inputAssetLabel.text = inputAsset.symbol
        }
        
        //TODO Check Fee!!
        print("inputAsset balance", inputAsset.balance)
        let dpInputBalance = inputAsset.balance.multiplying(byPowerOf10: -inputAsset.decimals!)
        inputAvailableLabel?.attributedText = WDP.dpAmount(dpInputBalance.stringValue, inputAvailableLabel!.font, inputAsset.decimals)
        
        
        //To UI update
        toAddressLabel.text = outputChain.bechAddress ?? outputChain.evmAddress
        outputChainImg.image = UIImage(named: outputChain.logo1)
        outputChainLabel.text = outputChain.name.uppercased()
        if let outputMsAsset = BaseData.instance.getAsset(outputChain.apiName, outputAsset!.denom) {
            outputAssetImg.sd_setImage(with: outputMsAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            outputAssetLabel.text = outputMsAsset.symbol
        } else {
            outputAssetImg.sd_setImage(with: outputAsset.assetImg(), placeholderImage: UIImage(named: "tokenDefault"))
            outputAssetLabel.text = outputAsset.symbol
        }
        
        print("outputAsset balance", outputAsset.balance)
        let dpOutputBalance = outputAsset.balance.multiplying(byPowerOf10: -outputAsset.decimals!)
        outputBalanceLabel?.attributedText = WDP.dpAmount(dpOutputBalance.stringValue, outputBalanceLabel!.font, outputAsset.decimals)
        
        inputAmountTextField.text = ""
        inputValueCurrency.text = ""
        inputValueLabel.text = ""
        outputAmountLabel.text = ""
        outputValueCurrency.text = ""
        outputValueLabel.text = ""
        errorCardView.isHidden = true
        descriptionCardView.isHidden = true
        
        /*
        toMsg = nil
        swapBtn.isEnabled = false
        toggleBtn.isEnabled = true
        
        view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        txFee = getBaseFee()
//        print("txFee ", txFee)
        
        //From UI update
        fromAddressLabel.text = inputChain.bechAddress
        inputChainImg.image = UIImage(named: inputChain.logo1)
        inputChainLabel.text = inputChain.name.uppercased()
//        print("fromAddress ", inputChain.address)
        
        let inputDenom = inputAssetSelected["denom"].stringValue
//        print("inputDenom ", inputDenom)
        inputMsAsset = BaseData.instance.getAsset(inputChain.apiName, inputDenom)!
        inputAssetImg.af.setImage(withURL: inputMsAsset.assetImg())
        inputAssetLabel.text = inputMsAsset.symbol
        
        let inputBlance = inputChain.getCosmosfetcher()!.balanceAmount(inputDenom)
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
        toAddressLabel.text = outputChain.bechAddress
        outputChainImg.image = UIImage(named: outputChain.logo1)
        outputChainLabel.text = outputChain.name.uppercased()
//        print("toAddress ", outputChain.address)
        
        let outputDenom = outputAssetSelected["denom"].stringValue
//        print("outputDenom ", outputDenom)
        outputMsAsset = BaseData.instance.getAsset(outputChain.apiName, outputDenom)!
        outputAssetImg.af.setImage(withURL: outputMsAsset.assetImg())
        outputAssetLabel.text = outputMsAsset.symbol
        
        let outputBalance = outputChain.getCosmosfetcher()!.balanceAmount(outputDenom)
        WDP.dpCoin(outputMsAsset, outputBalance, nil, nil, outputBalanceLabel, outputMsAsset.decimals)
        
        inputAmountTextField.text = ""
        inputValueCurrency.text = ""
        inputValueLabel.text = ""
        outputAmountLabel.text = ""
        outputValueCurrency.text = ""
        outputValueLabel.text = ""
        errorCardView.isHidden = true
        descriptionCardView.isHidden = true
        
        //save last user ui
        BaseData.instance.setLastSwapSet([inputChain.tag, inputAssetSelected["denom"].stringValue, outputChain.tag, outputAssetSelected["denom"].stringValue])
        */
    }
    
    @objc func onInputChain() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = targetChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputChain
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    @objc func onInputAsset() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = targetInputAssets
        baseSheet.targetChain = inputChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapInputAsset
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    @objc func onOutputChain() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapChains = targetChains
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputChain
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    @objc func onOutputAsset() {
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.swapAssets = targetOutputAssets
        baseSheet.targetChain = outputChain
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapOutputAsset
        onStartSheet(baseSheet, 680, 0.8)
    }
    
    
    @IBAction func onClickSlippage(_ sender: UIButton) {
        toMsg = nil
        dismissKeyboard()
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SelectSwapSlippage
        onStartSheet(baseSheet, 320, 0.6)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldChange(charactersIn: range, replacementString: string, displayDecimal: inputMsAsset.decimals!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onUpdateAmountView()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onClickHalf(_ sender: UIButton) {
        let halfAmount = availableAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -inputMsAsset.decimals!, withBehavior: getDivideHandler(inputMsAsset.decimals!))
        inputAmountTextField.text = halfAmount.stringValue
        onUpdateAmountView()
    }
    
    @IBAction func onClickMax(_ sender: UIButton) {
        let maxAmount = availableAmount.multiplying(byPowerOf10: -inputMsAsset.decimals!, withBehavior: getDivideHandler(inputMsAsset.decimals!))
        inputAmountTextField.text = maxAmount.stringValue
        onUpdateAmountView()
    }
    
    func onUpdateAmountView() {
        toMsg = nil
        if let text = inputAmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")  {
            swapBtn.isEnabled = false
            toggleBtn.isEnabled = false
            if (text.isEmpty) {
                outputAmountLabel.text = ""
                inputInvalidLabel.isHidden = false
                descriptionCardView.isHidden = true
                return
            }
            let userInput = NSDecimalNumber(string: text)
            if (NSDecimalNumber.notANumber == userInput) {
                outputAmountLabel.text = ""
                inputInvalidLabel.isHidden = false
                descriptionCardView.isHidden = true
                return
            }
            let inputAmount = userInput.multiplying(byPowerOf10: inputMsAsset.decimals!)
            if (inputAmount == NSDecimalNumber.zero || (availableAmount.compare(inputAmount).rawValue < 0)) {
                outputAmountLabel.text = ""
                inputInvalidLabel.isHidden = false
                descriptionCardView.isHidden = true
                return
            }
            inputInvalidLabel.isHidden = true
            Task {
                let route = try await fetchSkipRoute(inputAmount.stringValue)
//                print("route ", route)
                if (route["code"].int != nil) {
                    descriptionCardView.isHidden = true
                    errorCardView.isHidden = false
                    errorMsgLabel.text = route["message"].stringValue
                    return
                    
                } else if (route["amount_in"].stringValue == inputAmount.stringValue) {
                    let msg = try await fetchSkipMsg(route)
//                    print("msg ", msg)
                    if (msg["msgs"].arrayValue.count == 1) {
                        let slippage = NSDecimalNumber(string: "100").subtracting(NSDecimalNumber(string: skipSlippage))
                        let outputAmount = NSDecimalNumber(string: route["amount_out"].stringValue).multiplying(by: slippage).multiplying(byPowerOf10: -2, withBehavior: handler0Down)
                        WDP.dpCoin(outputMsAsset, outputAmount, nil, nil, outputAmountLabel, outputMsAsset.decimals)
                        
                        slippageLabel.text = skipSlippage + "%"
                        
                        let swapRate = outputAmount.dividing(by: inputAmount, withBehavior: handler6).multiplying(byPowerOf10: (inputMsAsset.decimals! - outputMsAsset.decimals!))
                        rateInputDenomLabel.text = inputMsAsset.symbol
                        rateInputAmountLanel.attributedText = WDP.dpAmount(NSDecimalNumber.one.stringValue, rateInputAmountLanel.font, 6)
                        rateOutputDenomLabel.text = outputMsAsset.symbol
                        rateOutputAmountLanel.attributedText = WDP.dpAmount(swapRate.stringValue, rateOutputAmountLanel.font, 6)
                        
                        if let feeMsAsset = BaseData.instance.getAsset(inputChain.apiName, txFee.amount[0].denom) {
                            WDP.dpCoin(feeMsAsset, txFee.amount[0], nil, feeDenomLabel, feeAmountLanel, feeMsAsset.decimals)
                        }
                        
                        venueLabel.text = route["swap_venue"]["name"].stringValue
                        
                        let inputMsPrice = BaseData.instance.getPrice(inputMsAsset.coinGeckoId)
                        let inputValue = inputMsPrice.multiplying(by: inputAmount).multiplying(byPowerOf10: -inputMsAsset.decimals!, withBehavior: handler6)
                        WDP.dpValue(inputValue, inputValueCurrency, inputValueLabel)
                        
                        let outputMsPrice = BaseData.instance.getPrice(outputMsAsset.coinGeckoId)
                        let outputValue = outputMsPrice.multiplying(by: outputAmount).multiplying(byPowerOf10: -outputMsAsset.decimals!, withBehavior: handler6)
                        WDP.dpValue(outputValue, outputValueCurrency, outputValueLabel)
                        
                        descriptionCardView.isHidden = false
                        errorCardView.isHidden = true
                        onSimul(route, msg)
                        
                        let inValue = NSDecimalNumber(string: route["usd_amount_in"].string ?? "0")
                        let outValue = NSDecimalNumber(string: route["usd_amount_out"].string ?? "0")
                        if (inValue.multiplying(by: NSDecimalNumber(string: "0.9")).compare(outValue).rawValue > 0) {
                            onShowbiglossPopup()
                        }
                        
                    } else {
                        //TODO msgs2개 이상일때 에러처리??
                        descriptionCardView.isHidden = true
                        errorCardView.isHidden = false
                        errorMsgLabel.text = "No Route"
                    }
                    
                }
            }
            
        }
    }
    
    @IBAction func onSwapToggle(_ sender: UIButton) {
        let tempChain = inputChain
        let tempAssetList = targetInputAssets
        let tempAssetSelected = inputAsset
        
        inputChain = outputChain
        targetInputAssets = targetOutputAssets
        inputAsset = outputAsset
        
        outputChain = tempChain
        targetOutputAssets = tempAssetList
        outputAsset = tempAssetSelected
        
        onReadyToUserInsert()
    }
    
    @IBAction func onClickSwap(_ sender: UIButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
    
    func onBindSkipRouteReq(_ amount: String) -> JSON {
        var routeReq = JSON()
        routeReq["amount_in"].stringValue = amount
        routeReq["source_asset_chain_id"].stringValue = inputChain.chainIdCosmos!
        routeReq["source_asset_denom"].stringValue = inputMsAsset.denom!
        routeReq["dest_asset_chain_id"].stringValue = outputChain.chainIdCosmos!
        routeReq["dest_asset_denom"].stringValue = outputMsAsset.denom!
        routeReq["cumulative_affiliate_fee_bps"] = "100"
        routeReq["client_id"] = "cosmostation_ios"
        return routeReq
    }
    
    func onBindSkipMsgReq(_ route: JSON) -> JSON {
        var msgReq = JSON()
        var address_list = [String]()
        route["chain_ids"].array?.forEach({ chain_Id in
            if let address = allChains.filter({ $0.chainIdCosmos == chain_Id.stringValue }).first?.bechAddress {
                address_list.append(address)
            }
        })
        msgReq["address_list"].arrayObject = address_list
        msgReq["slippage_tolerance_percent"].stringValue = skipSlippage
        msgReq["amount_in"] = route["amount_in"]
        msgReq["source_asset_chain_id"] = route["source_asset_chain_id"]
        msgReq["source_asset_denom"] = route["source_asset_denom"]
        msgReq["amount_out"] = route["amount_out"]
        msgReq["dest_asset_chain_id"] = route["dest_asset_chain_id"]
        msgReq["dest_asset_denom"] = route["dest_asset_denom"]
        msgReq["operations"] = route["operations"]
        msgReq["client_id"] = "cosmostation_ios"
        if let affiliate = getAffiliate(route["swap_venue"])  {
            msgReq["affiliates"].arrayObject = affiliate
        }
        return msgReq
    }
    
    func getBaseFee() -> Cosmos_Tx_V1beta1_Fee {
        let minFee = inputChain.getDefaultFeeCoins()[0]
        let feeCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = minFee.denom; $0.amount = minFee.amount }
        return Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = UInt64(BASE_GAS_AMOUNT)!
            $0.amount = [feeCoin]
        }
    }
    
    func getAffiliate(_ venue: JSON) -> [JSON]? {
        if (venue["chain_id"].stringValue.contains("osmosis")) {
            var affiliate = JSON()
            affiliate["address"].stringValue = "osmo1clpqr4nrk4khgkxj78fcwwh6dl3uw4epasmvnj"
            affiliate["basis_points_fee"].stringValue = "100"
            return [affiliate]
        } else if (venue["chain_id"].stringValue.contains("neutron")) {
            var affiliate = JSON()
            affiliate["address"].stringValue = "neutron1clpqr4nrk4khgkxj78fcwwh6dl3uw4ep35p7l8"
            affiliate["basis_points_fee"].stringValue = "100"
            return [affiliate]
        } else if (venue["chain_id"].stringValue.contains("phoenix")) {
            var affiliate = JSON()
            affiliate["address"].stringValue = "terra1564j3fq8p8np4yhh4lytnftz33japc03wuejxm"
            affiliate["basis_points_fee"].stringValue = "100"
            return [affiliate]
        } else if (venue["chain_id"].stringValue.contains("injective")) {
            var affiliate = JSON()
            affiliate["address"].stringValue = "inj1rvqzf9u2uxttmshn302anlknfgsatrh5mcu6la"
            affiliate["basis_points_fee"].stringValue = "100"
            return [affiliate]
        } else if (venue["chain_id"].stringValue.contains("pacific")) {
            var affiliate = JSON()
            affiliate["address"].stringValue = "sei1hnkkqnzwmyw652muh6wfea7xlfgplnyj3edm09"
            affiliate["basis_points_fee"].stringValue = "100"
            return [affiliate]
        } else if (venue["chain_id"].stringValue.contains("chihuahua")) {
            var affiliate = JSON()
            affiliate["address"].stringValue = "chihuahua1tgcypttehx3afugys6eq28h0kpmswfkgcuewfw"
            affiliate["basis_points_fee"].stringValue = "100"
            return [affiliate]
        }
        return nil
    }
    
    func onUpdateWithSimul(_ gasUsed: UInt64?, _ msg: JSON) {
        if let toGas = gasUsed {
            txFee.gasLimit = UInt64(Double(toGas) * inputChain.gasMultiply())
            let baseFeePosition = inputChain.getFeeBasePosition()
            if let gasRate = inputChain.getFeeInfos()[baseFeePosition].FeeDatas.filter({ $0.denom == txFee.amount[0].denom }).first {
                let gasLimit = NSDecimalNumber.init(value: txFee.gasLimit)
                let feeCoinAmount = gasRate.gasRate?.multiplying(by: gasLimit, withBehavior: handler0Up)
                txFee.amount[0].amount = feeCoinAmount!.stringValue
            }
        }
        if let feeMsAsset = BaseData.instance.getAsset(inputChain.apiName, txFee.amount[0].denom) {
            WDP.dpCoin(feeMsAsset, txFee.amount[0], nil, feeDenomLabel, feeAmountLanel, feeMsAsset.decimals)
        }
        toMsg = msg
        swapBtn.isEnabled = true
        toggleBtn.isEnabled = true
    }
    
    
    var bigLossAlert: UIAlertController?
    func onShowbiglossPopup() {
        if (bigLossAlert != nil) {
            bigLossAlert?.dismiss(animated: true, completion: nil)
        }
        
        bigLossAlert = UIAlertController(title: NSLocalizedString("str_big_loss", comment: ""), message: NSLocalizedString("str_big_loss_msg", comment: ""), preferredStyle: .alert)
        bigLossAlert!.addAction(UIAlertAction(title: NSLocalizedString("str_confirm", comment: ""), style: .default, handler: nil))
        present(bigLossAlert!, animated: true, completion: nil)
    }
    
    func onSimul(_ route: JSON, _ msg: JSON) {
        swapBtn.isEnabled = false
        toggleBtn.isEnabled = false
        let msgs = msg["msgs"].arrayValue[0]
        if (msgs["msg_type_url"].stringValue == "/ibc.applications.transfer.v1.MsgTransfer") {
            let inner_mag = try? JSON(data: Data(msgs["msg"].stringValue.utf8))
//            print("inner_mag ", inner_mag)
            Task {
                do {
                    if let inputCosmosfetcher = inputChain.getCosmosfetcher(),
                       let simulReq = try await Signer.genSimul(inputChain, onBindIbcSend(inner_mag!), "", txFee, txTip),
                       let simulRes = try await inputCosmosfetcher.simulateTx(simulReq) {
                        DispatchQueue.main.async {
                            self.onUpdateWithSimul(simulRes, msg)
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.loadingView.isHidden = true
                        self.onShowToast("Error : " + "\n" + "\(error)")
                        self.toMsg = nil
                        self.swapBtn.isEnabled = false
                        self.toggleBtn.isEnabled = true
                        return
                    }
                }
            }
            
        } else if (msgs["msg_type_url"].stringValue == "/cosmwasm.wasm.v1.MsgExecuteContract") {
            let inner_mag = try? JSON(data: Data(msgs["msg"].stringValue.utf8))
//            print("inner_mag ", inner_mag)
            Task {
                do {
                    if let inputCosmosfetcher = inputChain.getCosmosfetcher(),
                       let simulReq = try await Signer.genSimul(inputChain, onBindWasm(inner_mag!), "", txFee, txTip),
                       let simulRes = try await inputCosmosfetcher.simulateTx(simulReq) {
                        DispatchQueue.main.async {
                            self.onUpdateWithSimul(simulRes, msg)
                        }
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        self.loadingView.isHidden = true
                        self.onShowToast("Error : " + "\n" + "\(error)")
                        self.toMsg = nil
                        self.swapBtn.isEnabled = false
                        self.toggleBtn.isEnabled = true
                        return
                    }
                }
            }
        }
    }
    
    func onBindIbcSend(_ innerMsg: JSON) -> [Google_Protobuf_Any] {
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = innerMsg["token"]["denom"].stringValue
            $0.amount = innerMsg["token"]["amount"].stringValue
        }
        let ibcSendMsg = Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = innerMsg["sender"].stringValue
            $0.receiver = innerMsg["receiver"].stringValue
            $0.sourceChannel = innerMsg["source_channel"].stringValue
            $0.sourcePort = innerMsg["source_port"].stringValue
            $0.timeoutTimestamp = innerMsg["timeout_timestamp"].uInt64Value
            $0.token = sendCoin
            $0.memo = innerMsg["memo"].stringValue
        }
        return Signer.genIbcSendMsg(ibcSendMsg)
    }
    
    func onBindWasm(_ innerMsg: JSON) -> [Google_Protobuf_Any] {
        var wasmMsgs = [Cosmwasm_Wasm_V1_MsgExecuteContract]()
        let jsonMsgBase64 = try! innerMsg["msg"].rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let fundCoin = Cosmos_Base_V1beta1_Coin.init(innerMsg["funds"].arrayValue[0]["denom"].stringValue, innerMsg["funds"].arrayValue[0]["amount"].stringValue)
        
        let msg =  Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = innerMsg["sender"].stringValue
            $0.contract = innerMsg["contract"].stringValue
            $0.msg = Data(base64Encoded: jsonMsgBase64)!
            $0.funds = [fundCoin]
        }
        wasmMsgs.append(msg)
        return Signer.genWasmMsg(wasmMsgs)
    }
    
}

extension SwapStartVC: BaseSheetDelegate, PinDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if (sheetType == .SelectSwapInputChain) {
            if let chainName = result["chainName"] as? String {
                if (inputChain.name != chainName) {
                    view.isUserInteractionEnabled = false
                    loadingView.isHidden = false
                    Task {
                        inputChain = targetChains.filter({ $0.name == chainName }).first!
                        try await fetchInputAssetBalances()
                        try await fetchInputAssets()
                        inputAsset = targetInputAssets[0]
                        try await fetchInputAssetBalance()
                        DispatchQueue.main.async {
                            self.onReadyToUserInsert()
                        }
                    }
                }
            }
            
        } else if (sheetType == .SelectSwapOutputChain) {
            if let chainName = result["chainName"] as? String {
                if (outputChain.name != chainName) {
                    loadingView.isHidden = false
                    view.isUserInteractionEnabled = false
                    Task {
                        outputChain = targetChains.filter({ $0.name == chainName }).first!
                        try await fetchOutputAssetBalances()
                        try await fetchOutputAssets()
                        outputAsset = targetOutputAssets[0]
                        try await fetchOutputAssetBalance()
                        DispatchQueue.main.async {
                            self.onReadyToUserInsert()
                        }
                    }
                }
            }
            
        } else if (sheetType == .SelectSwapInputAsset) {
            if let denom = result["denom"] as? String {
                if (inputAsset.denom != denom) {
                    loadingView.isHidden = false
                    view.isUserInteractionEnabled = false
                    Task {
                        inputAsset = targetInputAssets.filter({ $0.denom == denom }).first
                        try await fetchInputAssetBalance()
                        DispatchQueue.main.async {
                            self.onReadyToUserInsert()
                        }
                    }
                }
            }
            
            
        } else if (sheetType == .SelectSwapOutputAsset) {
            if let denom = result["denom"] as? String {
                if (outputAsset.denom != denom) {
                    loadingView.isHidden = false
                    view.isUserInteractionEnabled = false
                    Task {
                        outputAsset = targetOutputAssets.filter({ $0.denom == denom }).first
                        try await fetchOutputAssetBalance()
                        DispatchQueue.main.async {
                            self.onReadyToUserInsert()
                        }
                    }
                }
            }
            
        } else if (sheetType == .SelectSwapSlippage) {
            if let index = result["index"] as? Int {
                if (index == 0) {
                    skipSlippage = "1"
                } else if (index == 1) {
                    skipSlippage = "3"
                } else if (index == 2) {
                    skipSlippage = "5"
                }
                onUpdateAmountView()
            }
        }
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            swapBtn.isEnabled = false
            view.isUserInteractionEnabled = false
            loadingView.isHidden = false
            let msgs = toMsg!["msgs"].arrayValue[0]
            if (msgs["msg_type_url"].stringValue == "/ibc.applications.transfer.v1.MsgTransfer") {
                let inner_mag = try? JSON(data: Data(msgs["msg"].stringValue.utf8))
                
                Task {
                    do {
                        if let inputGrpcfetcher = inputChain.getCosmosfetcher(),
                           let broadReq = try await Signer.genTx(inputChain, onBindIbcSend(inner_mag!), "", txFee, txTip),
                           let broadRes = try await inputGrpcfetcher.broadcastTx(broadReq) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                                self.loadingView.isHidden = true
                                let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                                txResult.selectedChain = self.inputChain
                                txResult.broadcastTxResponse = broadRes
                                txResult.modalPresentationStyle = .fullScreen
                                self.present(txResult, animated: true)
                            })
                        }
                           
                        
                    } catch {
                        //TODO handle Error
                    }
                }
                
            } else if (msgs["msg_type_url"].stringValue == "/cosmwasm.wasm.v1.MsgExecuteContract") {
                let inner_mag = try? JSON(data: Data(msgs["msg"].stringValue.utf8))
                
                Task {
                    do {
                        if let inputGrpcfetcher = inputChain.getCosmosfetcher(),
                           let broadReq = try await Signer.genTx(inputChain, onBindWasm(inner_mag!), "", txFee, txTip),
                           let broadRes = try await inputGrpcfetcher.broadcastTx(broadReq) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                                self.loadingView.isHidden = true
                                let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                                txResult.selectedChain = self.inputChain
                                txResult.broadcastTxResponse = broadRes
                                txResult.modalPresentationStyle = .fullScreen
                                self.present(txResult, animated: true)
                            })
                        }
                        
                    } catch {
                        //TODO handle Error
                    }
                }
            }
            
        }
    }
}


extension SwapStartVC {
    
    func fetchSkipChains() async throws -> JSON {
//        print("fetchSkipChains ", BaseNetWork.SkipChains())
        return try await AF.request(BaseNetWork.SkipChains(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipAssets() async throws -> JSON {
//        print("fetchSkipAssets ", BaseNetWork.SkipAssets())
        return try await AF.request(BaseNetWork.SkipAssets(), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipRoute(_ amount: String) async throws -> JSON {
        let json = onBindSkipRouteReq(amount)
        return try await AF.request(BaseNetWork.SkipRoutes(), method: .post, parameters: json.dictionaryObject!, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
    
    func fetchSkipMsg(_ route: JSON) async throws -> JSON {
        let json = onBindSkipMsgReq(route)
        return try await AF.request(BaseNetWork.SkipMsg(), method: .post, parameters: json.dictionaryObject!, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
    
    
    
    func fetchSquidChains() async throws -> JSON {
//        print("fetchSquidChains ", BaseNetWork.SkipChains())
        return try await AF.request(BaseNetWork.SquidChains(), method: .get).serializingDecodable(JSON.self).value
    }
    
    
    func fetchInputAssetBalances() async throws {
        if (inputChain.supportCosmos && inputChain.supportEvm) {
            _ = await inputChain.getCosmosfetcher()?.fetchCosmosBalances()
            _ = await inputChain.getEvmfetcher()?.fetchEvmBalances()
        } else if (inputChain.supportCosmos) {
            _ = await inputChain.getCosmosfetcher()?.fetchCosmosBalances()
        } else if (inputChain.supportEvm) {
            _ = await inputChain.getEvmfetcher()?.fetchEvmBalances()
        }
        inputChain.getCosmosfetcher()?.onCheckVesting()
    }
    
    func fetchOutputAssetBalances() async throws {
        if (outputChain.supportCosmos && outputChain.supportEvm) {
            _ = await outputChain.getCosmosfetcher()?.fetchCosmosBalances()
            _ = await outputChain.getEvmfetcher()?.fetchEvmBalances()
        } else if (outputChain.supportCosmos) {
            _ = await outputChain.getCosmosfetcher()?.fetchCosmosBalances()
        } else if (outputChain.supportEvm) {
            _ = await outputChain.getEvmfetcher()?.fetchEvmBalances()
        }
        outputChain.getCosmosfetcher()?.onCheckVesting()
    }
    
    
    func fetchInputAssets() async throws {

        squidInputAssets.removeAll()
        if (squidChains.contains(where: { $0.tag == inputChain.tag }))  {
            if (inputChain.supportCosmos) {
                let squidCosmosAssets = try? await AF.request(BaseNetWork.SquidAsset(inputChain.chainIdCosmos!), method: .get).serializingDecodable(JSON.self).value
                squidInputAssets.append(contentsOf: squidCosmosAssets?["tokens"].arrayValue ?? [])
            }
            if (inputChain.supportEvm) {
                let squidEvmAssets = try? await AF.request(BaseNetWork.SquidAsset(inputChain.chainIdEvmDecimal!), method: .get).serializingDecodable(JSON.self).value
                squidInputAssets.append(contentsOf: squidEvmAssets?["tokens"].arrayValue ?? [])
            }
        }
        
        skipInputAssets.removeAll()
        if (skipChains.contains(where: { $0.tag == inputChain.tag }))  {
            let skipAssets = try? await AF.request(BaseNetWork.SkipAsset(inputChain), method: .get).serializingDecodable(JSON.self).value
            skipInputAssets = skipAssets?["chain_to_assets_map"][inputChain.chainIdForSwap]["assets"].arrayValue ?? []
        }
        
        var tempInputAssets = [TargetAsset]()
        squidInputAssets.forEach { squidInput in
            let tempTarget = TargetAsset.init(squidInput["address"].stringValue,
                                              squidInput["symbol"].stringValue,
                                              squidInput["decimals"].int16Value,
                                              squidInput["logoURI"].stringValue,
                                              squidInput["coingeckoId"].string,
                                              squidInput["name"].string)
            tempInputAssets.append(tempTarget)
        }
        skipInputAssets.forEach { skipInput in
            let tempTarget = TargetAsset.init(skipInput["denom"].stringValue,
                                              skipInput["recommended_symbol"].stringValue,
                                              skipInput["decimals"].int16Value,
                                              skipInput["logo_uri"].stringValue,
                                              skipInput["coingecko_id"].string,
                                              skipInput["description"].string)
            if !tempInputAssets.contains(where: { $0.denom.lowercased() == tempTarget.denom.lowercased() }) {
                tempInputAssets.append(tempTarget)
            }
        }
        
        targetInputAssets.removeAll()
        let msAssets = BaseData.instance.mintscanAssets?.filter({ $0.chain == inputChain.apiName })
        if let mainCoin = msAssets?.first, (!inputChain.supportCosmos && inputChain.supportEvm) {
            targetInputAssets.append(TargetAsset.init("evmMain", mainCoin.symbol!,  18, mainCoin.assetImg().absoluteString, mainCoin.coinGeckoId, mainCoin.description))
        }
        for index in tempInputAssets.indices {
            if (tempInputAssets[index].denom == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE") { continue }
            if (tempInputAssets[index].denom.starts(with: "0x") ||
                tempInputAssets[index].denom.starts(with: "cw20:") ||
                msAssets?.filter({ $0.denom == tempInputAssets[index].denom }).first != nil) {
                let msAsset = msAssets?.filter({ $0.denom == tempInputAssets[index].denom }).first
                if let msGeckoId = msAsset?.coinGeckoId {
                    tempInputAssets[index].geckoId = msGeckoId
                }
                if let msDescription = msAsset?.description {
                    tempInputAssets[index].description = msDescription
                }
                if let msImg = msAsset?.assetImg().absoluteString {
                    tempInputAssets[index].image = msImg
                }
                targetInputAssets.append(tempInputAssets[index])
            }
        }
        
        targetInputAssets.sort {
            if ($0.denom == inputChain.stakeDenom) { return true }
            if ($1.denom == inputChain.stakeDenom) { return false }
            if ($0.symbol == inputChain.coinSymbol) { return true }
            if ($1.symbol == inputChain.coinSymbol) { return false }
            if ($0.type.rawValue < $1.type.rawValue ) { return true }
            if ($0.type.rawValue > $1.type.rawValue ) { return false }
            return $0.symbol < $1.symbol
        }
        print("targetInputAssets ", targetInputAssets.count)
//        targetInputAssets.forEach { target in
//            print("target input ", target.symbol,  "  ", target.denom, "  ", target.assetImg())
//        }
    }
    
    func fetchOutputAssets() async throws  {
        
        squidOutputAssets.removeAll()
        if (squidChains.contains(where: { $0.tag == outputChain.tag }))  {
            if (outputChain.supportCosmos) {
                let squidCosmosAssets = try? await AF.request(BaseNetWork.SquidAsset(outputChain.chainIdCosmos!), method: .get).serializingDecodable(JSON.self).value
                squidOutputAssets.append(contentsOf: squidCosmosAssets?["tokens"].arrayValue ?? [])
            }
            if (outputChain.supportEvm) {
                let squidEvmAssets = try? await AF.request(BaseNetWork.SquidAsset(outputChain.chainIdEvmDecimal!), method: .get).serializingDecodable(JSON.self).value
                squidOutputAssets.append(contentsOf: squidEvmAssets?["tokens"].arrayValue ?? [])
            }
        }
        
        skipOutputAssets.removeAll()
        if (skipChains.contains(where: { $0.tag == outputChain.tag }))  {
            let skipAssets = try? await AF.request(BaseNetWork.SkipAsset(outputChain), method: .get).serializingDecodable(JSON.self).value
            skipOutputAssets = skipAssets?["chain_to_assets_map"][outputChain.chainIdForSwap]["assets"].arrayValue ?? []
        }
        
        var tempOutputAssets = [TargetAsset]()
        squidOutputAssets.forEach { squidOutput in
            let tempTarget = TargetAsset.init(squidOutput["address"].stringValue,
                                              squidOutput["symbol"].stringValue,
                                              squidOutput["decimals"].int16Value,
                                              squidOutput["logoURI"].stringValue,
                                              squidOutput["coingeckoId"].string,
                                              squidOutput["name"].string)
            tempOutputAssets.append(tempTarget)
        }
        
        skipOutputAssets.forEach { skipOutput in
            let tempTarget = TargetAsset.init(skipOutput["denom"].stringValue,
                                              skipOutput["recommended_symbol"].stringValue,
                                              skipOutput["decimals"].int16Value,
                                              skipOutput["logo_uri"].stringValue,
                                              skipOutput["coingecko_id"].string,
                                              skipOutput["description"].string)
            if !tempOutputAssets.contains(where: { $0.denom.lowercased() == tempTarget.denom.lowercased() }) {
                tempOutputAssets.append(tempTarget)
            }
        }
        
        targetOutputAssets.removeAll()
        let msAssets = BaseData.instance.mintscanAssets?.filter({ $0.chain == outputChain.apiName })
        if let mainCoin = msAssets?.first, (!outputChain.supportCosmos && outputChain.supportEvm) {
            targetOutputAssets.append(TargetAsset.init("evmMain", mainCoin.symbol!,  18, mainCoin.assetImg().absoluteString, mainCoin.coinGeckoId, mainCoin.description))
        }
        for index in tempOutputAssets.indices {
            if (tempOutputAssets[index].denom == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE") { continue }
            if (tempOutputAssets[index].denom.starts(with: "0x") ||
                tempOutputAssets[index].denom.starts(with: "cw20:") ||
                msAssets?.filter({ $0.denom == tempOutputAssets[index].denom }).first != nil) {
                let msAsset = msAssets?.filter({ $0.denom == tempOutputAssets[index].denom }).first
                if let msGeckoId = msAsset?.coinGeckoId {
                    tempOutputAssets[index].geckoId = msGeckoId
                }
                if let msDescription = msAsset?.description {
                    tempOutputAssets[index].description = msDescription
                }
                if let msImg = msAsset?.assetImg().absoluteString {
                    tempOutputAssets[index].image = msImg
                }
                targetOutputAssets.append(tempOutputAssets[index])
            }
        }
        
        targetOutputAssets.sort {
            if ($0.denom == outputChain.stakeDenom) { return true }
            if ($1.denom == outputChain.stakeDenom) { return false }
            if ($0.symbol == outputChain.coinSymbol) { return true }
            if ($1.symbol == outputChain.coinSymbol) { return false }
            if ($0.type.rawValue < $1.type.rawValue ) { return true }
            if ($0.type.rawValue > $1.type.rawValue ) { return false }
            return $0.symbol < $1.symbol
        }
        print("targetOutputAssets ", targetOutputAssets.count)
//        targetOutputAssets.forEach { target in
//            print("target input ", target.symbol,  "  ", target.denom, "  ", target.assetImg())
//        }
    }
    
    func fetchInputAssetBalance() async throws {
        if inputAsset.type == .CW20 {
            inputAsset.balance = try await inputChain.getCosmosfetcher()?.fetchCw20BalanceAmount(inputAsset.denom!) ?? NSDecimalNumber.zero
            
        } else if inputAsset.type == .ERC20 {
            inputAsset.balance = try await inputChain.getEvmfetcher()?.fetchErc20BalanceAmount(inputAsset.denom!) ?? NSDecimalNumber.zero
            
        } else {
            if (!inputChain.supportCosmos && inputChain.supportEvm) {
                inputAsset.balance = inputChain.getEvmfetcher()?.evmBalances ?? NSDecimalNumber.zero
            } else {
                inputAsset.balance = inputChain.getCosmosfetcher()?.balanceAmount(inputAsset.denom) ?? NSDecimalNumber.zero
            }
        }
    }
    
    func fetchOutputAssetBalance() async throws {
        if outputAsset.type == .CW20 {
            outputAsset.balance = try await outputChain.getCosmosfetcher()?.fetchCw20BalanceAmount(outputAsset.denom!) ?? NSDecimalNumber.zero
            
        } else if outputAsset.type == .ERC20 {
            outputAsset.balance = try await outputChain.getEvmfetcher()?.fetchErc20BalanceAmount(outputAsset.denom!) ?? NSDecimalNumber.zero
            
        } else {
            if (!outputChain.supportCosmos && outputChain.supportEvm) {
                outputAsset.balance = outputChain.getEvmfetcher()?.evmBalances ?? NSDecimalNumber.zero
            } else {
                outputAsset.balance = outputChain.getCosmosfetcher()?.balanceAmount(outputAsset.denom) ?? NSDecimalNumber.zero
            }
        }
    }
    
}


public struct TargetAsset {
    var denom: String!                      // skip - "denom"                       squid - "address"
    var symbol: String!                     // skip - "recommended_symbol"          squid - "symbol"
    var decimals: Int16!                    // skip - "decimals"                    squid - "decimals"
    var image: String?                      // skip - "logo_uri"                    squid - "logoURI"
    var geckoId: String?                    // skip - "coingecko_id"                squid - "coingeckoId"
    var description: String?                // skip - "description"                 squid - "name"
    var balance = NSDecimalNumber.zero      // fetched balacne
    var type = TargetAssetType.Native
    
    init(_ denom: String, _ symbol: String, _ decimals: Int16, _ image: String?, _ geckoId: String?, _ description: String?) {
        self.denom = denom
        self.symbol = symbol
        self.decimals = decimals
        self.image = image
        self.geckoId = geckoId
        self.description = description
        
        if (denom.lowercased().starts(with: "0x")) {
            self.type = .ERC20
        } else if (denom.lowercased().starts(with: "cw20:")) {
            self.type = .CW20
        } else if (denom.lowercased().starts(with: "ibc/")) {
            self.type = .IBC
        }
    }
    
    func assetImg() -> URL? {
        guard let path = image else {
            return nil
        }
        return URL(string: path)
    }
}

enum TargetAssetType: Int {
    case Native = 0
    case IBC = 1
    case CW20 = 2
    case ERC20 = 3
}

