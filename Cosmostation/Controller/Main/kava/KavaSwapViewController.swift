//
//  KavaSwapViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/27.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class KavaSwapViewController: BaseViewController, SBCardPopupDelegate{
    
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
    
    var pageHolderVC: DAppsListViewController!
    var mKavaSwapPoolParam: Kava_Swap_V1beta1_Params?
    var mKavaSwapPools: Array<Kava_Swap_V1beta1_PoolResponse> = Array<Kava_Swap_V1beta1_PoolResponse>()
    var mAllDenoms: Array<String> = Array<String>()
    var mKavaSwapablePools: Array<Kava_Swap_V1beta1_PoolResponse> = Array<Kava_Swap_V1beta1_PoolResponse>()
    var mKavaSwapableDenoms: Array<String> = Array<String>()
    var mKavaSelectedPool: Kava_Swap_V1beta1_PoolResponse!
    var mInputCoinDenom: String!
    var mOutputCoinDenom: String!
    var mAvailableMaxAmount = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.loadingImg.onStartAnimation()
        
        self.inputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickInput (_:))))
        self.outputCoinLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickOutput (_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKavaSwapPoolDone(_:)), name: Notification.Name("KavaSwapPoolDone"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("KavaSwapPoolDone"), object: nil)
    }
    
    @objc func onKavaSwapPoolDone(_ notification: NSNotification) {
        self.mKavaSwapPoolParam = BaseData.instance.mKavaSwapPoolParam
        self.pageHolderVC = self.parent as? DAppsListViewController
        self.mKavaSwapPools = pageHolderVC.mKavaSwapPools
        
        self.mKavaSwapPools.forEach { pool in
            if (!self.mAllDenoms.contains(pool.coins[0].denom)) {
                self.mAllDenoms.append(pool.coins[0].denom)
            }
            if (!self.mAllDenoms.contains(pool.coins[1].denom)) {
                self.mAllDenoms.append(pool.coins[1].denom)
            }
        }
        
        self.mKavaSwapPools.forEach { pool in
            if (pool.name.contains("ukava") == true && pool.name.contains("usdx") == true) {
                self.mKavaSelectedPool = pool
                self.mInputCoinDenom = "ukava"
                self.mOutputCoinDenom = "usdx"
            }
        }
        
        self.loadingImg.stopAnimating()
        self.loadingImg.isHidden = true
        self.updateView()
    }
    
    func updateView() {
        let inputCoinDecimal = WUtils.getKavaCoinDecimal(mInputCoinDenom)
        let outputCoinDecimal = WUtils.getKavaCoinDecimal(mOutputCoinDenom)
        mAvailableMaxAmount = BaseData.instance.getAvailableAmount_gRPC(mInputCoinDenom!)

        let swapFee = NSDecimalNumber.init(string: mKavaSwapPoolParam?.swapFee).multiplying(byPowerOf10: -16)
        swapFeeLabel.attributedText = WUtils.displayPercent(swapFee, swapFeeLabel.font)
        slippageLabel.attributedText = WUtils.displayPercent(NSDecimalNumber.init(string: "3"), swapFeeLabel.font)
        inputCoinAvailableAmountLabel.attributedText = WUtils.displayAmount2(mAvailableMaxAmount.stringValue, inputCoinAvailableAmountLabel.font!, inputCoinDecimal, inputCoinDecimal)

        WDP.dpSymbol(chainConfig, mInputCoinDenom, inputCoinName)
        WDP.dpSymbol(chainConfig, mOutputCoinDenom, outputCoinName)
        WDP.dpSymbol(chainConfig, mInputCoinDenom, inputCoinRateDenom)
        WDP.dpSymbol(chainConfig, mOutputCoinDenom, outputCoinRateDenom)
        WDP.dpSymbol(chainConfig, mInputCoinDenom, inputCoinExRateDenom)
        WDP.dpSymbol(chainConfig, mOutputCoinDenom, outputCoinExRateDenom)
        
        WDP.dpSymbolImg(chainConfig, mInputCoinDenom, inputCoinImg)
        WDP.dpSymbolImg(chainConfig, mOutputCoinDenom, outputCoinImg)

        var lpInputAmount = NSDecimalNumber.zero
        var lpOutputAmount = NSDecimalNumber.zero
        if (mKavaSelectedPool.coins[0].denom == self.mInputCoinDenom) {
            lpInputAmount = NSDecimalNumber.init(string: self.mKavaSelectedPool.coins[0].amount)
            lpOutputAmount = NSDecimalNumber.init(string: self.mKavaSelectedPool.coins[1].amount)
        } else {
            lpInputAmount = NSDecimalNumber.init(string: self.mKavaSelectedPool.coins[1].amount)
            lpOutputAmount = NSDecimalNumber.init(string: self.mKavaSelectedPool.coins[0].amount)
        }
        let poolSwapRate = lpOutputAmount.dividing(by: lpInputAmount, withBehavior: WUtils.handler6).multiplying(byPowerOf10: (inputCoinDecimal - outputCoinDecimal))
        print("poolSwapRate ", poolSwapRate)

        //display swap rate with this pool
        inputCoinRateAmount.attributedText = WUtils.displayAmount2(NSDecimalNumber.one.stringValue, inputCoinRateAmount.font, 0, inputCoinDecimal)
        outputCoinRateAmount.attributedText = WUtils.displayAmount2(poolSwapRate.stringValue, outputCoinRateAmount.font, 0, outputCoinDecimal)


        //display swap rate with market price
        inputCoinExRateAmount.attributedText = WUtils.displayAmount2(NSDecimalNumber.one.stringValue, inputCoinExRateAmount.font, 0, inputCoinDecimal)
        let priceInput = WUtils.perUsdValue(BaseData.instance.getBaseDenom(chainConfig, mInputCoinDenom)) ?? NSDecimalNumber.zero
        let priceOutput = WUtils.perUsdValue(BaseData.instance.getBaseDenom(chainConfig, mOutputCoinDenom)) ?? NSDecimalNumber.zero
        
        if (priceInput == NSDecimalNumber.zero || priceOutput == NSDecimalNumber.zero) {
            self.outputCoinExRateAmount.text = "?.??????"
        } else {
            let priceRate = priceInput.dividing(by: priceOutput, withBehavior: WUtils.handler6)
            self.outputCoinExRateAmount.attributedText = WUtils.displayAmount2(priceRate.stringValue, outputCoinExRateAmount.font, 0, outputCoinDecimal)
        }
    }

    
    @objc func onClickInput (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_KAVA_SWAP_IN
        popupVC.toCoinList = mAllDenoms
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @objc func onClickOutput (_ sender: UITapGestureRecognizer) {
        self.mKavaSwapablePools.removeAll()
        self.mKavaSwapableDenoms.removeAll()
        for pool in self.mKavaSwapPools {
            if (pool.name.contains(self.mInputCoinDenom) == true) {
                mKavaSwapablePools.append(pool)
            }
        }
        self.mKavaSwapablePools.forEach { swapablePool in
            if (swapablePool.coins[0].denom == self.mInputCoinDenom) {
                mKavaSwapableDenoms.append(swapablePool.coins[1].denom)
            } else {
                mKavaSwapableDenoms.append(swapablePool.coins[0].denom)
            }
        }

        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_KAVA_SWAP_OUT
        popupVC.toCoinList = mKavaSwapableDenoms
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    @IBAction func onClickToggle(_ sender: UIButton) {
        let temp = mInputCoinDenom
        mInputCoinDenom = mOutputCoinDenom
        mOutputCoinDenom = temp
        self.updateView()
    }
    
    @IBAction func onClickSwap(_ sender: UIButton) {
        if (!account!.account_has_private) {
            self.onShowAddMenomicDialog()
            return
        }

        let txVC = UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        txVC.mType = TASK_TYPE_KAVA_SWAP_TOKEN
        txVC.mKavaSwapPool = mKavaSelectedPool
        txVC.mSwapInDenom = mInputCoinDenom
        txVC.mSwapOutDenom = mOutputCoinDenom
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(txVC, animated: true)
    }
    
    
    func SBCardPopupResponse(type: Int, result: Int) {
        if (type == SELECT_POPUP_KAVA_SWAP_IN) {
            self.mInputCoinDenom = self.mAllDenoms[result]
            for pool in self.mKavaSwapPools {
                if (pool.name.contains(self.mInputCoinDenom) == true) {
                    self.mKavaSelectedPool = pool
                    break
                }
            }
            if (self.mKavaSelectedPool.coins[0].denom == self.mInputCoinDenom) {
                self.mOutputCoinDenom = self.mKavaSelectedPool.coins[1].denom
            } else {
                self.mOutputCoinDenom = self.mKavaSelectedPool.coins[0].denom
            }
            self.updateView()

        } else if (type == SELECT_POPUP_KAVA_SWAP_OUT) {
            self.mOutputCoinDenom = self.mKavaSwapableDenoms[result]
            for pool in self.mKavaSwapPools {
                if (pool.name.contains(self.mInputCoinDenom) == true && pool.name.contains(self.mOutputCoinDenom) == true) {
                    self.mKavaSelectedPool = pool
                    break
                }
            }
            self.updateView()
        }
    }
    
}
