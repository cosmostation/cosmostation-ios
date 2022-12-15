//
//  SwapViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class SwapViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var inputCoinLayer: CardView!
    @IBOutlet weak var inputCoinImg: UIImageView!
    @IBOutlet weak var inputCoinName: UILabel!
    @IBOutlet weak var inputCoinAvailableAmountLabel: UILabel!
    
    @IBOutlet weak var toggleBtn: UIButton!
    @IBOutlet weak var swapFeeLabel: UILabel!
    @IBOutlet weak var slippageLabel: UILabel!
    
    @IBOutlet weak var outputCoinLayer: CardView!
    @IBOutlet weak var outputCoinImg: UIImageView!
    @IBOutlet weak var outputCoinName: UILabel!
    
    @IBOutlet weak var inputCoinRateAmount: UILabel!
    @IBOutlet weak var inputCoinRateDenom: UILabel!
    @IBOutlet weak var outputCoinRateAmount: UILabel!
    @IBOutlet weak var outputCoinRateDenom: UILabel!
    @IBOutlet weak var inputCoinExRateAmount: UILabel!
    @IBOutlet weak var inputCoinExRateDenom: UILabel!
    @IBOutlet weak var outputCoinExRateAmount: UILabel!
    @IBOutlet weak var outputCoinExRateDenom: UILabel!
    
    var mAllDenoms: Array<String> = Array<String>()
    var mSwapableDenoms: Array<String> = Array<String>()
    var mSelectedPoolId: UInt64 = 1
    var mSelectedPool: Osmosis_Gamm_V1beta1_Pool?
    var mSelectedStablePool: Osmosis_Gamm_Poolmodels_Stableswap_V1beta1_Pool?
    var mInputDenom: String?
    var mOutputDenom: String?
    var mInputDecimal:Int16 = 6
    var mOutputDecimal:Int16 = 6
    var mAvailableMaxAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)

        BaseData.instance.mSupportPools.forEach { supportPool in
            if (!self.mAllDenoms.contains(supportPool.adenom)) {
                self.mAllDenoms.append(supportPool.adenom)
            }
            if (!self.mAllDenoms.contains(supportPool.bdenom)) {
                self.mAllDenoms.append(supportPool.bdenom)
            }
        }
//        print("mAllDenoms ", mAllDenoms.count)
        
        self.inputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickInput (_:))))
        self.outputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickOutput (_:))))
        
        self.mSelectedPoolId = 1
        self.mInputDenom = "ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2"
        self.mOutputDenom = "uosmo"
        self.onFetchSelectedPool(mSelectedPoolId)
    }
    
    func updateView() {
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        guard let inputMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == mInputDenom }).first,
              let outputMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == mOutputDenom }).first else {
            return
        }
        
        mInputDecimal = inputMsAsset.decimals
        mOutputDecimal = outputMsAsset.decimals
        mAvailableMaxAmount = BaseData.instance.getAvailableAmount_gRPC(mInputDenom!)
        WDP.dpCoin(chainConfig, mInputDenom, mAvailableMaxAmount.stringValue, nil, inputCoinAvailableAmountLabel)
        
        WDP.dpSymbolImg(chainConfig, mInputDenom!, inputCoinImg)
        WDP.dpSymbolImg(chainConfig, mOutputDenom!, outputCoinImg)
        WDP.dpSymbol(chainConfig, mInputDenom, inputCoinName)
        WDP.dpSymbol(chainConfig, mOutputDenom, outputCoinName)
        WDP.dpSymbol(chainConfig, mInputDenom, inputCoinRateDenom)
        WDP.dpSymbol(chainConfig, mOutputDenom, outputCoinRateDenom)
        WDP.dpSymbol(chainConfig, mInputDenom, inputCoinExRateDenom)
        WDP.dpSymbol(chainConfig, mOutputDenom, outputCoinExRateDenom)
        
//        print("Input ", mInputDenom, " ", mInputDecimal, "  ", mAvailableMaxAmount)
//        print("Output ", mOutputDenom, " ", mOutputDecimal)
        
        if (mSelectedPool != nil) {
            self.swapFeeLabel.attributedText = WUtils.displayPercent(NSDecimalNumber.init(string: mSelectedPool!.poolParams.swapFee).multiplying(byPowerOf10: -16), swapFeeLabel.font)

        } else if (mSelectedStablePool != nil) {
            self.swapFeeLabel.attributedText = WUtils.displayPercent(NSDecimalNumber.init(string: mSelectedStablePool!.poolParams.swapFee).multiplying(byPowerOf10: -16), swapFeeLabel.font)
        }
        self.slippageLabel.attributedText = WUtils.displayPercent(NSDecimalNumber.init(string: "3"), swapFeeLabel.font)
        
        //display swap rate
        inputCoinRateAmount.attributedText = WDP.dpAmount(NSDecimalNumber.one.stringValue, inputCoinRateAmount.font, 0, 6)
        inputCoinExRateAmount.attributedText = WDP.dpAmount(NSDecimalNumber.one.stringValue, inputCoinExRateAmount.font, 0, 6)
        
        //display swap rate with this pool
        if (mSelectedPool != nil) {
            var inputAssetAmount = NSDecimalNumber.zero
            var inputAssetWeight = NSDecimalNumber.zero
            var outputAssetAmount = NSDecimalNumber.zero
            var outputAssetWeight = NSDecimalNumber.zero
            mSelectedPool!.poolAssets.forEach { poolAsset in
                if (poolAsset.token.denom == mInputDenom) {
                    inputAssetAmount = NSDecimalNumber.init(string: poolAsset.token.amount)
                    inputAssetWeight = NSDecimalNumber.init(string: poolAsset.weight)
                }
                if (poolAsset.token.denom == mOutputDenom) {
                    outputAssetAmount = NSDecimalNumber.init(string: poolAsset.token.amount)
                    outputAssetWeight = NSDecimalNumber.init(string: poolAsset.weight)
                }
            }
            inputAssetAmount = inputAssetAmount.multiplying(byPowerOf10: -mInputDecimal)
            outputAssetAmount = outputAssetAmount.multiplying(byPowerOf10: -mOutputDecimal)
            let poolSwapRate = outputAssetAmount.multiplying(by: inputAssetWeight).dividing(by: inputAssetAmount, withBehavior: WUtils.handler18).dividing(by: outputAssetWeight, withBehavior: WUtils.handler6)
//            print("inputAssetAmount ", inputAssetAmount)
//            print("inputAssetWeight ", inputAssetWeight)
//            print("outputAssetAmount ", outputAssetAmount)
//            print("outputAssetWeight ", outputAssetWeight)
            print("poolSwapRate ", poolSwapRate)
            outputCoinRateAmount.attributedText = WDP.dpAmount(poolSwapRate.stringValue, outputCoinRateAmount.font, 0, 6)
            
        } else if (mSelectedStablePool != nil) {
            
        }
        
        //display swap rate with market price
        inputCoinExRateAmount.attributedText = WDP.dpAmount(NSDecimalNumber.one.stringValue, inputCoinExRateAmount.font, 0, 6)
        let priceInput = WUtils.price(inputMsAsset.coinGeckoId)
        let priceOutput = WUtils.price(outputMsAsset.coinGeckoId)
        
        if (priceInput == NSDecimalNumber.zero || priceOutput == NSDecimalNumber.zero) {
            self.outputCoinExRateAmount.text = "?.??????"
        } else {
            let priceRate = priceInput.dividing(by: priceOutput, withBehavior: WUtils.handler6)
            self.outputCoinExRateAmount.attributedText = WDP.dpAmount(priceRate.stringValue, outputCoinExRateAmount.font, 0, 6)
        }
    }
    
    @IBAction func onClickToggle(_ sender: UIButton) {
        let temp = mInputDenom
        mInputDenom = mOutputDenom
        mOutputDenom = temp
        self.updateView()
    }
    
    func onSetSwapableDenoms(_ include: String) {
        mSwapableDenoms.removeAll()
        BaseData.instance.mSupportPools.forEach { pool in
            if (pool.adenom == include) {
                if (!mSwapableDenoms.contains(where: { $0 == pool.bdenom })) {
                    mSwapableDenoms.append(pool.bdenom)
                }
            }
            if (pool.bdenom == include) {
                if (!mSwapableDenoms.contains(where: { $0 == pool.adenom })) {
                    mSwapableDenoms.append(pool.adenom)
                }
            }
        }
        print("mSwapableDenoms ", mSwapableDenoms)
    }
    
    @objc func onClickInput (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_OSMOSIS_COIN_IN
        popupVC.toCoinList = mAllDenoms
        
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @objc func onClickOutput (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_OSMOSIS_COIN_OUT
        onSetSwapableDenoms(mInputDenom!)
        popupVC.toCoinList = mSwapableDenoms
        
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    
    @IBAction func onClickSwap(_ sender: UIButton) {
        print("onClickSwap")
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_OSMOSIS_SWAP
        txVC.mPoolId = String(mSelectedPool!.id)
        txVC.mSwapInDenom = mInputDenom
        txVC.mSwapOutDenom = mOutputDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_OSMOSIS_COIN_IN) {
            mInputDenom = self.mAllDenoms[result]
            mSelectedPoolId = 0
            if let pool = BaseData.instance.mSupportPools.filter({ $0.adenom == mInputDenom }).first {
                mOutputDenom = pool.bdenom
                mSelectedPoolId = UInt64(pool.id)!
                onFetchSelectedPool(mSelectedPoolId)
                return
                
            }
            if let pool = BaseData.instance.mSupportPools.filter({ $0.bdenom == mInputDenom }).first {
                mOutputDenom = pool.adenom
                mSelectedPoolId = UInt64(pool.id)!
                onFetchSelectedPool(mSelectedPoolId)
                return
            }
            print("Error")
            self.dismiss(animated: true)

        } else if (type == SELECT_POPUP_OSMOSIS_COIN_OUT) {
            self.mOutputDenom = self.mSwapableDenoms[result]
            mSelectedPoolId = 0
            if let pool = BaseData.instance.mSupportPools.filter({ $0.adenom == mOutputDenom }).first {
                mInputDenom = pool.bdenom
                mSelectedPoolId = UInt64(pool.id)!
                onFetchSelectedPool(mSelectedPoolId)
            }
            if let pool = BaseData.instance.mSupportPools.filter({ $0.bdenom == mOutputDenom }).first {
                mInputDenom = pool.adenom
                mSelectedPoolId = UInt64(pool.id)!
                onFetchSelectedPool(mSelectedPoolId)
            }
            print("Error")
            self.dismiss(animated: true)
        }
    }
    
    func onFetchSelectedPool(_ id: UInt64) {
        self.loadingImg.startAnimating()
        self.loadingImg.isHidden = false
        self.mSelectedPool = nil
        self.mSelectedStablePool = nil
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Osmosis_Gamm_V1beta1_QueryPoolRequest.with { $0.poolID = id}
                if let response = try? Osmosis_Gamm_V1beta1_QueryClient(channel: channel).pool(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if (response.pool.typeURL.contains(Osmosis_Gamm_V1beta1_Pool.protoMessageName) == true) {
                        self.mSelectedPool = try! Osmosis_Gamm_V1beta1_Pool.init(serializedData: response.pool.value)                        
                    } else if (response.pool.typeURL.contains(Osmosis_Gamm_Poolmodels_Stableswap_V1beta1_Pool.protoMessageName) == true) {
                        self.mSelectedStablePool = try! Osmosis_Gamm_Poolmodels_Stableswap_V1beta1_Pool.init(serializedData: response.pool.value)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchSelectedPool failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.updateView() });
        }
    }
}
