//
//  HtlcSend3ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/23.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class HtlcSend3ViewController: BaseViewController, PasswordViewDelegate, SBCardPopupDelegate {
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var sendImg: UIImageView!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var sendAmountDenom: UILabel!
    @IBOutlet weak var sendFeeLabel: UILabel!
    @IBOutlet weak var sendFeeDenom: UILabel!
    @IBOutlet weak var recipientChainLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    
    @IBOutlet weak var claimImg: UIImageView!
    @IBOutlet weak var receiveAmountLabel: UILabel!
    @IBOutlet weak var receiveAmountDenom: UILabel!
    @IBOutlet weak var relayFeeLabel: UILabel!
    @IBOutlet weak var relayFeeDenom: UILabel!
    @IBOutlet weak var claimFeeLabel: UILabel!
    @IBOutlet weak var claimFeeDenom: UILabel!
    @IBOutlet weak var claimAddress: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var mDpDecimal:Int16 = 8
    
    var relayerFee: NSDecimalNumber = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
    }
    
    override func enableUserInteraction() {
        self.btnBack.isUserInteractionEnabled = true
        self.btnConfirm.isUserInteractionEnabled = true
        self.onUpdateView()
    }
    
    func onUpdateView() {
        onInitSendFee()
        onInitClaimFee()
        
        let toSendAmount = WUtils.plainStringToDecimal(pageHolderVC.mToSendAmount[0].amount)
        let sendFeeAmount = WUtils.plainStringToDecimal((pageHolderVC.mHtlcSendFee?.amount[0].amount)!)
        let claimFeeAmount = WUtils.plainStringToDecimal((pageHolderVC.mHtlcClaimFee?.amount[0].amount)!)
        
        //set Send layer's data
        sendImg.image = sendImg.image?.withRenderingMode(.alwaysTemplate)
        sendImg.tintColor = ChainFactory.getChainConfig(chainType)?.chainColor
        WUtils.setDenomTitle(chainType, sendFeeDenom)
        if (chainType == ChainType.BINANCE_MAIN) {
            mDpDecimal = 8;
            if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_BNB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_TEST_BNB) {
                sendAmountDenom.text = "BNB"
                sendAmountDenom.textColor = UIColor.init(named: "binance")
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_BTCB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_TEST_BTC) {
                sendAmountDenom.text = "BTC"
                sendAmountDenom.textColor = UIColor.font05
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_XRPB) {
                sendAmountDenom.text = "XRP"
                sendAmountDenom.textColor = UIColor.font05
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_BUSD) {
                sendAmountDenom.text = "BUSD"
                sendAmountDenom.textColor = UIColor.font05
            }
            sendAmountLabel.attributedText = WDP.dpAmount(toSendAmount.stringValue, sendAmountLabel.font, 0, 8)
            sendFeeLabel.attributedText = WDP.dpAmount(sendFeeAmount.stringValue, sendFeeLabel.font, 0, 8)
            recipientChainLabel.text = WUtils.dpBepSwapChainName(pageHolderVC.mHtlcToChain!)
            recipientAddressLabel.text = pageHolderVC.mHtlcToAccount?.account_address
            
        } else if (chainType == ChainType.KAVA_MAIN) {
            let chainConfig = ChainKava.init(.KAVA_MAIN)
            mDpDecimal = WUtils.getDenomDecimal(chainConfig, self.pageHolderVC.mHtlcDenom!)
            if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_BNB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_TEST_BNB) {
                sendAmountDenom.text = "BNB"
                sendAmountDenom.textColor = UIColor.init(named: "binance")
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_BTCB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_TEST_BTC) {
                sendAmountDenom.text = "BTC"
                sendAmountDenom.textColor = UIColor.font05
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_XRPB) {
                sendAmountDenom.text = "XRP"
                sendAmountDenom.textColor = UIColor.font05
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_BUSD) {
                sendAmountDenom.text = "BUSD"
                sendAmountDenom.textColor = UIColor.font05
            }
            sendAmountLabel.attributedText = WDP.dpAmount(toSendAmount.stringValue, sendAmountLabel.font, mDpDecimal, mDpDecimal)
            sendFeeLabel.attributedText = WDP.dpAmount(sendFeeAmount.stringValue, sendFeeLabel.font, 6, 6)
            recipientChainLabel.text = WUtils.dpBepSwapChainName(pageHolderVC.mHtlcToChain!)
            claimAddress.text = pageHolderVC.mHtlcToAccount?.account_address
        }
        
        //set Claim layer's data
        claimImg.image = claimImg.image?.withRenderingMode(.alwaysTemplate)
        claimImg.tintColor = ChainFactory.getChainConfig(pageHolderVC.mHtlcToChain)?.chainColor
        if (pageHolderVC.mHtlcToChain == ChainType.BINANCE_MAIN) {
            receiveAmountDenom.text = self.pageHolderVC.mHtlcDenom!.uppercased()
            relayFeeDenom.text = self.pageHolderVC.mHtlcDenom!.uppercased()
            if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_BNB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_TEST_BNB) {
                receiveAmountDenom.textColor = UIColor.init(named: "binance")
                relayFeeDenom.textColor = UIColor.init(named: "binance")
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_BTCB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_TEST_BTC) {
                receiveAmountDenom.text = "BTC"
                relayFeeDenom.text = "BTC"
                
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_XRPB) {
                receiveAmountDenom.text = "XRP"
                relayFeeDenom.text = "XRP"
                
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_KAVA_BUSD) {
                receiveAmountDenom.text = "BUSD"
                relayFeeDenom.text = "BUSD"
                
            }
            WUtils.setDenomTitle(pageHolderVC.mHtlcToChain!, claimFeeDenom)
            
            relayerFee = self.pageHolderVC.mKavaSwapParam2!.getSupportedSwapAssetFee(pageHolderVC.mHtlcDenom!)
            receiveAmountLabel.attributedText = WDP.dpAmount(toSendAmount.subtracting(relayerFee).stringValue , receiveAmountLabel.font, mDpDecimal, mDpDecimal)
            relayFeeLabel.attributedText = WDP.dpAmount(relayerFee.stringValue, relayFeeLabel.font, mDpDecimal, mDpDecimal)
            claimFeeLabel.attributedText = WDP.dpAmount(claimFeeAmount.stringValue, claimFeeLabel.font, 0, mDpDecimal)
            recipientAddressLabel.text = pageHolderVC.mHtlcToAccount?.account_address
            
        } else if (pageHolderVC.mHtlcToChain == ChainType.KAVA_MAIN) {
            if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_BNB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_TEST_BNB) {
                receiveAmountDenom.text = "BNB"
                relayFeeDenom.text = "BNB"
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_BTCB || pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_TEST_BTC) {
                receiveAmountDenom.text = "BTC"
                relayFeeDenom.text = "BTC"
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_XRPB) {
                receiveAmountDenom.text = "XRP"
                relayFeeDenom.text = "XRP"
            } else if (pageHolderVC.mHtlcDenom == TOKEN_HTLC_BINANCE_BUSD) {
                receiveAmountDenom.text = "BUSD"
                relayFeeDenom.text = "BUSD"
            }
            WUtils.setDenomTitle(pageHolderVC.mHtlcToChain!, claimFeeDenom)
            
            relayerFee = self.pageHolderVC.mKavaSwapParam2!.getSupportedSwapAssetFee(pageHolderVC.mHtlcDenom!).multiplying(byPowerOf10: -8)
            receiveAmountLabel.attributedText = WDP.dpAmount(toSendAmount.subtracting(relayerFee).stringValue , receiveAmountLabel.font, 0, 8)
            relayFeeLabel.attributedText = WDP.dpAmount(relayerFee.stringValue, relayFeeLabel.font, 0, 8)
            claimFeeLabel.attributedText = WDP.dpAmount(claimFeeAmount.stringValue, claimFeeLabel.font, 6, 6)
            claimAddress.text = pageHolderVC.mHtlcToAccount?.account_address
        }
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnBack.isUserInteractionEnabled = false
        self.btnConfirm.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
        
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        let popupVC = Bep3WarnPopup(nibName: "Bep3WarnPopup", bundle: nil)
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        if (result == 1) {
            self.btnBack.isUserInteractionEnabled = false
            self.btnConfirm.isUserInteractionEnabled = false
            if (BaseData.instance.isAutoPass()) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
                    let htlcDetailVC = HtlcResultViewController(nibName: "HtlcResultViewController", bundle: nil)
                    self.navigationItem.title = ""
                    htlcDetailVC.mHtlcDenom = self.pageHolderVC.mHtlcDenom
                    htlcDetailVC.mHtlcToSendAmount = self.pageHolderVC.mToSendAmount
                    htlcDetailVC.mHtlcToChain = self.pageHolderVC.mHtlcToChain
                    htlcDetailVC.mHtlcToAccount = self.pageHolderVC.mHtlcToAccount
                    htlcDetailVC.mHtlcSendFee = self.pageHolderVC.mHtlcSendFee
                    htlcDetailVC.mHtlcClaimFee = self.pageHolderVC.mHtlcClaimFee
                    self.navigationController?.pushViewController(htlcDetailVC, animated: true)
                    self.btnBack.isUserInteractionEnabled = true
                    self.btnConfirm.isUserInteractionEnabled = true
                })
                
            } else {
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
                passwordVC.resultDelegate = self
                self.navigationController?.pushViewController(passwordVC, animated: false)
            }
        }
    }
    
    func onInitSendFee() {
        if (chainType == ChainType.BINANCE_MAIN) {
            let feeCoin = Coin.init(BNB_MAIN_DENOM, FEE_BINANCE_BASE)
            var tempList = Array<Coin>()
            tempList.append(feeCoin)
            pageHolderVC.mHtlcSendFee = Fee.init("", tempList)

        } else if (chainType == ChainType.KAVA_MAIN) {
            let feeCoin = Coin.init(KAVA_MAIN_DENOM, "12500")
            var tempList = Array<Coin>()
            tempList.append(feeCoin)
            pageHolderVC.mHtlcSendFee = Fee.init(BASE_GAS_AMOUNT, tempList)

        }
    }
    
    func onInitClaimFee() {
        if (pageHolderVC.mHtlcToChain == ChainType.BINANCE_MAIN) {
            let feeCoin = Coin.init(BNB_MAIN_DENOM, FEE_BINANCE_BASE)
            var tempList = Array<Coin>()
            tempList.append(feeCoin)
            pageHolderVC.mHtlcClaimFee = Fee.init("", tempList)
            
        } else if (pageHolderVC.mHtlcToChain == ChainType.KAVA_MAIN) {
            let feeCoin = Coin.init(KAVA_MAIN_DENOM, "12500")
            var tempList = Array<Coin>()
            tempList.append(feeCoin)
            pageHolderVC.mHtlcClaimFee = Fee.init(BASE_GAS_AMOUNT, tempList)
            
        }
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
                let htlcDetailVC = HtlcResultViewController(nibName: "HtlcResultViewController", bundle: nil)
                self.navigationItem.title = ""
                htlcDetailVC.mHtlcDenom = self.pageHolderVC.mHtlcDenom
                htlcDetailVC.mHtlcToSendAmount = self.pageHolderVC.mToSendAmount
                htlcDetailVC.mHtlcToChain = self.pageHolderVC.mHtlcToChain
                htlcDetailVC.mHtlcToAccount = self.pageHolderVC.mHtlcToAccount
                htlcDetailVC.mHtlcSendFee = self.pageHolderVC.mHtlcSendFee
                htlcDetailVC.mHtlcClaimFee = self.pageHolderVC.mHtlcClaimFee
                self.navigationController?.pushViewController(htlcDetailVC, animated: true)
            })
        } else {
            self.btnBack.isUserInteractionEnabled = true
            self.btnConfirm.isUserInteractionEnabled = true
        }
    }
}
