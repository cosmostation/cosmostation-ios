//
//  HtlcSend0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/23.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class HtlcSend0ViewController: BaseViewController, SBCardPopupDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var fromChainImg: UIImageView!
    @IBOutlet weak var fromChainTxt: UILabel!
    @IBOutlet weak var toChainCard: CardView!
    @IBOutlet weak var toChainImg: UIImageView!
    @IBOutlet weak var toChainText: UILabel!
    
    @IBOutlet weak var sendCoinCard: CardView!
    @IBOutlet weak var sendCoinImg: UIImageView!
    @IBOutlet weak var sendCoinTxt: UILabel!
    @IBOutlet weak var sendCoinDenom: UILabel!
    @IBOutlet weak var sendCoinAvailable: UILabel!
    
    @IBOutlet weak var RelayerMaxLayer: UIView!
    @IBOutlet weak var RelayerReaminLayer: UIView!
    @IBOutlet weak var oneTimeLimitAmount: UILabel!
    @IBOutlet weak var oneTimeLimitDenom: UILabel!
    @IBOutlet weak var systemMaxAmount: UILabel!
    @IBOutlet weak var systemMaxDenom: UILabel!
    @IBOutlet weak var systemReaminAmount: UILabel!
    @IBOutlet weak var systemReaminDenom: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var toChainList = Array<ChainType>()
    var toChain: ChainType?
    var toSwapableCoinList = Array<String>()
    var toSwapDenom: String?
    
    var kavaSwapParam: KavaSwapParam?
    var kavaSwapSupply: KavaSwapSupply?
    
    var supplyLimit = NSDecimalNumber.zero
    var supplyRemain = NSDecimalNumber.zero
    var onetimeMax = NSDecimalNumber.zero
    var availableAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageHolderVC = self.parent as? StepGenTxViewController
        
        self.toChainCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToChain (_:))))
        self.sendCoinCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickToSendCoin (_:))))
        self.toChainList = WUtils.getHtlcSendable(pageHolderVC.chainType!)
        if (self.toChainList.count <= 0) {
            pageHolderVC.onBeforePage()
            return
        }
        self.toChain = self.toChainList[0]
        
        self.toSwapableCoinList = WUtils.getHtlcSwappableCoin(pageHolderVC.chainType!)
        if (self.toSwapableCoinList.count <= 0) { pageHolderVC.onBeforePage() }
        self.toSwapDenom = pageHolderVC.mHtlcDenom;
        
        self.onCheckSwapParam()
        self.updateView()
    }
    
    func updateView() {
        WUtils.dpBepSwapChainInfo(pageHolderVC.chainType!, fromChainImg, fromChainTxt)
        WUtils.dpBepSwapChainInfo(toChain!, toChainImg, toChainText)
        sendCoinDenom.text = "(" + toSwapDenom! + ")"
        if (pageHolderVC.chainType == ChainType.BINANCE_MAIN && kavaSwapParam != nil && kavaSwapSupply != nil) {
            RelayerMaxLayer.isHidden = false
            RelayerReaminLayer.isHidden = false
            if let bnbToken = BaseData.instance.bnbToken(toSwapDenom) {
                sendCoinImg.af_setImage(withURL: bnbToken.assetImg())
                self.onSetDpDenom(bnbToken.original_symbol)
            }
            
            availableAmount = pageHolderVC.mAccount!.getTokenBalance(toSwapDenom!)
            supplyLimit = kavaSwapParam!.getSupportedSwapAssetLimit(toSwapDenom!)
            supplyRemain = kavaSwapSupply!.getRemainCap(toSwapDenom!, supplyLimit)
            onetimeMax = kavaSwapParam!.getSupportedSwapAssetMaxOnce(toSwapDenom!)
            sendCoinAvailable.attributedText = WDP.dpAmount(availableAmount.stringValue, sendCoinAvailable.font, 0, 8)
            
        } else if (pageHolderVC.chainType == ChainType.KAVA_MAIN && kavaSwapParam != nil && kavaSwapSupply != nil) {
            let chainConfig = ChainKava.init(.KAVA_MAIN)
            RelayerMaxLayer.isHidden = true
            RelayerReaminLayer.isHidden = true
            if (toSwapDenom == TOKEN_HTLC_KAVA_BNB) {
                sendCoinImg.image = UIImage(named: "bnbonKavaImg")
                self.onSetDpDenom("BNB")
            } else if (toSwapDenom == TOKEN_HTLC_KAVA_BTCB) {
                WDP.dpSymbolImg(chainConfig, toSwapDenom, sendCoinImg)
                self.onSetDpDenom("BTC")
            } else if (toSwapDenom == TOKEN_HTLC_KAVA_XRPB) {
                WDP.dpSymbolImg(chainConfig, toSwapDenom, sendCoinImg)
                self.onSetDpDenom("XRP")
            } else if (toSwapDenom == TOKEN_HTLC_KAVA_BUSD) {
                WDP.dpSymbolImg(chainConfig, toSwapDenom, sendCoinImg)
                self.onSetDpDenom("BUSD")
            }
            availableAmount = BaseData.instance.getAvailableAmount_gRPC(toSwapDenom!)
            supplyLimit = kavaSwapParam!.getSupportedSwapAssetLimit(toSwapDenom!)
            supplyRemain = kavaSwapSupply!.getRemainCap(toSwapDenom!, supplyLimit)
            onetimeMax = kavaSwapParam!.getSupportedSwapAssetMaxOnce(toSwapDenom!)
            sendCoinAvailable.attributedText = WDP.dpAmount(availableAmount.stringValue, sendCoinAvailable.font, 8, 8)
            
        }
        
        oneTimeLimitAmount.attributedText = WDP.dpAmount(onetimeMax.stringValue, oneTimeLimitAmount.font, 8, 8)
        systemMaxAmount.attributedText = WDP.dpAmount(supplyLimit.stringValue, systemMaxAmount.font, 8, 8)
        systemReaminAmount.attributedText = WDP.dpAmount(supplyRemain.stringValue, systemReaminAmount.font, 8, 8)
    }
    
    func onSetDpDenom(_ denom: String) {
        sendCoinTxt.text = denom
        oneTimeLimitDenom.text = denom
        systemMaxDenom.text = denom
        systemReaminDenom.text = denom
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
        
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (supplyRemain.compare(NSDecimalNumber.zero).rawValue <= 0) {
            self.onShowToast(NSLocalizedString("error_bep3_supply_full", comment: ""))
            
        } else if (!onCheckMinMinBalance()) {
            self.onShowToast(NSLocalizedString("error_bep3_under_min_amount", comment: ""))
            
        } else {
            self.btnCancel.isUserInteractionEnabled = false
            self.btnNext.isUserInteractionEnabled = false
            self.pageHolderVC.mHtlcDenom = self.toSwapDenom
            self.pageHolderVC.mHtlcToChain = self.toChain
            self.pageHolderVC.mSwapRemainCap = self.supplyRemain
            self.pageHolderVC.mSwapMaxOnce = self.onetimeMax
            pageHolderVC.onNextPage()
        }
    }
    
    @objc func onClickToChain (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_HTLC_TO_CHAIN
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
        
    }
    
    @objc func onClickToSendCoin (_ sender: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_HTLC_TO_COIN
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        if (type == SELECT_POPUP_HTLC_TO_CHAIN) {
            self.toChain = self.toChainList[result]
            self.updateView()
            
        } else if (type == SELECT_POPUP_HTLC_TO_COIN) {
            self.toSwapDenom = self.toSwapableCoinList[result]
            self.updateView()
        }
    }
    
    func onCheckSwapParam() {
        let request = Alamofire.request(BaseNetWork.paramBep3Url(pageHolderVC.chainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let info = res as? [String : Any] else {
                        self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    self.kavaSwapParam = KavaSwapParam.init(info)
                    self.pageHolderVC.mKavaSwapParam = self.kavaSwapParam
                    self.onCheckSwapSupply()

                case .failure:
                    self.onShowToast(NSLocalizedString("error_network", comment: ""))
                }
        }
        
    }
    
    func onCheckSwapSupply() {
        let request = Alamofire.request(BaseNetWork.supplyBep3Url(pageHolderVC.chainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let info = res as? [String : Any] else {
                        self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    self.kavaSwapSupply = KavaSwapSupply.init(info)
                    self.pageHolderVC.mKavaSwapSupply = self.kavaSwapSupply
                    self.updateView()
                    
                case .failure:
                    self.onShowToast(NSLocalizedString("error_network", comment: ""))
                }
        }
        
    }
    
    func onCheckMinMinBalance() -> Bool {
        if (pageHolderVC.chainType! == ChainType.BINANCE_MAIN) {
            if (availableAmount.compare(kavaSwapParam!.getSupportedSwapAssetMin(toSwapDenom!).multiplying(byPowerOf10: -8)).rawValue > 0) {
                return true
            }
            
        } else if (pageHolderVC.chainType! == ChainType.KAVA_MAIN) {
            if (availableAmount.compare(kavaSwapParam!.getSupportedSwapAssetMin(toSwapDenom!)).rawValue > 0) {
                return true
            }
        }
        return false
    }
    
}

