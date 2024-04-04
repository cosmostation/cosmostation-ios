//
//  BepTxResult.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import GRPC
import NIO
import SwiftProtobuf
import Alamofire

class BepTxResult: BaseVC {

    @IBOutlet weak var loadingLayer: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var loadingMsgLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var successLayer: UIView!
    @IBOutlet weak var sendChainimg: UIImageView!
    @IBOutlet weak var sendTxBtn: UIButton!
    @IBOutlet weak var claimChainImg: UIImageView!
    @IBOutlet weak var claimTxBtn: UIButton!
    
    var fromChain: CosmosClass!
    var toChain: CosmosClass!
    var toSendDenom: String!
    var toSendAmount = NSDecimalNumber.zero
    
    var timeStamp: Int64!
    var randomNumber: String!
    var randomNumberHash: String!
    var swapId: String!
    var sendTxHash: String?
    var claimTxHash: String?
    var swapIdFetchCnt = 15
    var claimTxFetchCnt = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        loadingMsgLabel.text = NSLocalizedString("msg_htlc_swap_progress_0", comment: "")
        
        if (fromChain is ChainBinanceBeacon) {
            btoK_FetchBnbAuth()
        } else {
            ktob_FetchKavaAuth()
        }
    }
    
    func onUpdateProgress(_ step: Int) {
        if (step == 1) {
            loadingMsgLabel.text = NSLocalizedString("msg_htlc_swap_progress_1", comment: "")
        } else if (step == 2) {
            loadingMsgLabel.text = NSLocalizedString("msg_htlc_swap_progress_2", comment: "")
        } else if (step == 3) {
            loadingMsgLabel.text = NSLocalizedString("msg_htlc_swap_progress_3", comment: "")
        }
    }
    
    func onUpdateview() {
        loadingView.stop()
        loadingLayer.isHidden = true
        
        successLayer.isHidden = false
        sendChainimg.image =  UIImage.init(named: fromChain.logo1)
        claimChainImg.image =  UIImage.init(named: toChain.logo1)
        confirmBtn.isEnabled = true
    }
    
    @IBAction func onClickSendTx(_ sender: UIButton) {
        guard let url = fromChain.getExplorerTx(sendTxHash) else { return }
        self.onShowSafariWeb(url)
    }
    
    @IBAction func onClickClaimTx(_ sender: UIButton) {
        guard let url = toChain.getExplorerTx(claimTxHash) else { return }
        self.onShowSafariWeb(url)
    }
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        onStartMainTab()
    }
}

//BNB to KAVA
extension BepTxResult {
    func btoK_FetchBnbAuth() {
        AF.request(BaseNetWork.lcdAccountInfoUrl(fromChain, fromChain.bechAddress), method: .get).responseDecodable(of: JSON.self) { response in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async(execute: {
                    self.btoK_CreatBepSend(value)
                });
                
            case .failure:
                print("fetchBnbAuth error")
            }
        }
    }
    
    func btoK_CreatBepSend(_ bnbAuth: JSON) {
        timeStamp = Date().millisecondsSince1970 / 1000
        randomNumber = KeyFac.generateRandomBytes()
        randomNumberHash = KeyFac.getRandomNumnerHash(randomNumber, timeStamp)
        
        let bnbMsg = BinanceMessage.createHtlc(toAddress: fromBnbDuputyAdddress(toSendDenom)!.0,
                                               otherFrom: fromBnbDuputyAdddress(toSendDenom)!.1,
                                               otherTo: toChain.bechAddress,
                                               timestamp: timeStamp,
                                               randomNumberHash: randomNumberHash,
                                               sendAmount: toSendAmount.multiplying(byPowerOf10: 8).int64Value,
                                               sendDenom: toSendDenom!,
                                               expectedIncom: toSendAmount.multiplying(byPowerOf10: 8).stringValue + ":" + toSendDenom!,
                                               heightSpan: 407547,
                                               crossChain: true,
                                               memo: SWAP_MEMO_CREATE,
                                               privateKey: fromChain.privateKey!,
                                               signerAddress: fromChain.bechAddress,
                                               sequence: bnbAuth["sequence"].intValue,
                                               accountNumber: bnbAuth["account_number"].intValue,
                                               chainId: fromChain.chainIdCosmos!)
        
        var encoding: ParameterEncoding = URLEncoding.default
        encoding = HexEncoding(data: try! bnbMsg.encode())
        let param: Parameters = ["address": fromChain.bechAddress]
        
        AF.request(BaseNetWork.broadcastUrl(fromChain), method: .post, parameters: param, encoding: encoding).responseDecodable(of: JSON.self)  { response in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async(execute: {
                    self.sendTxHash = value.arrayValue[0]["hash"].stringValue
                    self.swapId = KeyFac.getSwapId(self.toChain, self.toSendDenom, self.randomNumberHash, self.fromChain.bechAddress)
                    self.btoK_FetchBtoKSwapId()
                });

            case .failure(let error):
                print("creatBepSend error ", error)
            }
        }
    }
    
    func btoK_FetchBtoKSwapId() {
        onUpdateProgress(1)
        let url = BaseNetWork.swapIdBep3Url(toChain, swapId)
        AF.request(url, method: .get).responseDecodable(of: JSON.self) { response in
            self.swapIdFetchCnt = self.swapIdFetchCnt - 1
            switch response.result {
            case .success(let value):
                if (value["code"].intValue != 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        if (self.swapIdFetchCnt > 0) {
                            self.btoK_FetchBtoKSwapId()
                        } else {
                            self.onShowMoreSwapWait()
                        }
                    })
                    
                } else {
                    self.btoK_FetchKavaAuth()
                }
                
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                    if (self.swapIdFetchCnt > 0) {
                        self.btoK_FetchBtoKSwapId()
                    } else {
                        self.onShowMoreSwapWait()
                    }
                })
            }
        }
    }
    
    func btoK_FetchKavaAuth() {
        onUpdateProgress(2)
        let channel = getConnection()
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = toChain.bechAddress }
        if let response = try? Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.wait() {
            self.btoK_CreateBepClaim(response)
        }
    }
    
    func btoK_CreateBepClaim(_ auth :Cosmos_Auth_V1beta1_QueryAccountResponse) {
        let claimAtomicSwap = Kava_Bep3_V1beta1_MsgClaimAtomicSwap.with {
            $0.from = toChain.bechAddress
            $0.swapID = swapId
            $0.randomNumber = randomNumber
        }
        let feeCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = "ukava"
            $0.amount = KAVA_BASE_FEE
        }
        let txFee = Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = UInt64(BASE_GAS_AMOUNT)!
            $0.amount = [feeCoin]
        }
        let reqTx = Signer.genKavaClaimHTLCSwapTx(auth, claimAtomicSwap, txFee, SWAP_MEMO_CLAIM, toChain)
        if let response = try? Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getConnection()).broadcastTx(reqTx, callOptions: getCallOptions()).response.wait() {
            self.claimTxHash = response.txResponse.txhash
            self.btoK_FetchClaimTx()
        }
    }
    
    func btoK_FetchClaimTx() {
        onUpdateProgress(3)
        claimTxFetchCnt = claimTxFetchCnt - 1
        let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = claimTxHash! }
        if let response = try? Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getConnection()).getTx(req, callOptions: getCallOptions()).response.wait() {
            DispatchQueue.main.async {
                self.onUpdateview()
            }
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                if (self.claimTxFetchCnt > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.btoK_FetchClaimTx()
                    })
                } else {
                    self.onShowMoreClaimWait()
                }
            })
        }
    }
    
}

//KAVA to BNB
extension BepTxResult {
    func ktob_FetchKavaAuth() {
        let channel = getConnection()
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = fromChain.bechAddress }
        if let response = try? Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.wait() {
            self.ktob_CreatBepSend(response)
        }
    }
    
    func ktob_CreatBepSend(_ auth :Cosmos_Auth_V1beta1_QueryAccountResponse) {
        timeStamp = Date().millisecondsSince1970 / 1000
        randomNumber = KeyFac.generateRandomBytes()
        randomNumberHash = KeyFac.getRandomNumnerHash(randomNumber, timeStamp)
        
        let createAtomicSwap = Kava_Bep3_V1beta1_MsgCreateAtomicSwap.with {
            $0.from = fromChain.bechAddress
            $0.to = fromKavaDuputyAdddress(toSendDenom)!.0
            $0.senderOtherChain = fromKavaDuputyAdddress(toSendDenom)!.1
            $0.recipientOtherChain = toChain.bechAddress
            $0.randomNumberHash = randomNumberHash
            $0.timestamp = timeStamp
            $0.amount = [Cosmos_Base_V1beta1_Coin.with { $0.denom = toSendDenom; $0.amount = toSendAmount.stringValue }]
            $0.heightSpan = 24686
        }
        let feeCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = "ukava"
            $0.amount = KAVA_BASE_FEE
        }
        let txFee = Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = UInt64(BASE_GAS_AMOUNT)!
            $0.amount = [feeCoin]
        }
        let reqTx = Signer.genKavaCreateHTLCSwap(auth, createAtomicSwap, txFee, SWAP_MEMO_CLAIM, fromChain)
        if let response = try? Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getConnection()).broadcastTx(reqTx, callOptions: getCallOptions()).response.wait() {
            self.sendTxHash = response.txResponse.txhash
            
            self.swapId = KeyFac.getSwapId(self.toChain, self.toSendDenom, self.randomNumberHash, self.fromChain.bechAddress)
            self.ktob_FetchBtoKSwapId()
        }
    }
    
    func ktob_FetchBtoKSwapId() {
        onUpdateProgress(1)
        let url = BaseNetWork.swapIdBep3Url(toChain, swapId)
        AF.request(url, method: .get).responseDecodable(of: JSON.self) { response in
            self.swapIdFetchCnt = self.swapIdFetchCnt - 1
            switch response.result {
            case .success(let value):
                if (value["code"].intValue != 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        if (self.swapIdFetchCnt > 0) {
                            self.ktob_FetchBtoKSwapId()
                        } else {
                            self.onShowMoreSwapWait()
                        }
                    })
                    
                } else {
                    self.ktob_FetchBnbAuth()
                }
                
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                    if (self.swapIdFetchCnt > 0) {
                        self.ktob_FetchBtoKSwapId()
                    } else {
                        self.onShowMoreSwapWait()
                    }
                })
            }
        }
    }
    
    func ktob_FetchBnbAuth() {
        onUpdateProgress(2)
        AF.request(BaseNetWork.lcdAccountInfoUrl(toChain, toChain.bechAddress), method: .get).responseDecodable(of: JSON.self) { response in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async(execute: {
                    self.ktob_CreateBepClaim(value)
                });
                
            case .failure:
                print("ktob_FetchBnbAuth error")
            }
        }
    }
    
    func ktob_CreateBepClaim(_ bnbAuth: JSON) {
        onUpdateProgress(3)
        let bnbMsg = BinanceMessage.claimHtlc(randomNumber: randomNumber,
                                              swapId: swapId,
                                              memo: SWAP_MEMO_CLAIM,
                                              privateKey: toChain.privateKey!,
                                              signerAddress: toChain.bechAddress,
                                              sequence: bnbAuth["sequence"].intValue,
                                              accountNumber: bnbAuth["account_number"].intValue,
                                              chainId: toChain.chainIdCosmos)
        
        var encoding: ParameterEncoding = URLEncoding.default
        encoding = HexEncoding(data: try! bnbMsg.encode())
        let param: Parameters = ["address": toChain.bechAddress]
        
        AF.request(BaseNetWork.broadcastUrl(toChain), method: .post, parameters: param, encoding: encoding).responseDecodable(of: JSON.self)  { response in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async(execute: {
                    self.claimTxHash = value.arrayValue[0]["hash"].stringValue
                    self.onUpdateview()
                });

            case .failure(let error):
                print("ktob_createBepClaim error ", error)
            }
        }
    }
}


extension BepTxResult {
    func onShowMoreSwapWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_swap_title", comment: ""), message: NSLocalizedString("more_wait_swap_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.swapIdFetchCnt = 15
            if (self.fromChain is ChainBinanceBeacon) {
                self.btoK_FetchBtoKSwapId()
            } else {
                self.ktob_FetchBtoKSwapId()
            }
        }))
        self.present(noticeAlert, animated: true, completion: nil)
    }
    
    func onShowMoreClaimWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_swap_title", comment: ""), message: NSLocalizedString("more_wait_swap_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.claimTxFetchCnt = 15
            if (self.fromChain is ChainBinanceBeacon) {
                self.btoK_FetchClaimTx()
            } else {
                
            }
        }))
        self.present(noticeAlert, animated: true, completion: nil)
    }
    
    func fromBnbDuputyAdddress(_ denom: String) -> (String, String)? {
        if (denom == TOKEN_HTLC_BINANCE_BNB) {
            return (BINANCE_MAIN_BNB_DEPUTY, KAVA_MAIN_BNB_DEPUTY)
        } else if (denom == TOKEN_HTLC_BINANCE_BTCB) {
            return (BINANCE_MAIN_BTCB_DEPUTY, KAVA_MAIN_BTCB_DEPUTY)
        } else if (denom == TOKEN_HTLC_BINANCE_XRPB) {
            return (BINANCE_MAIN_XRPB_DEPUTY, KAVA_MAIN_XRPB_DEPUTY)
        } else if (denom == TOKEN_HTLC_BINANCE_BUSD) {
            return (BINANCE_MAIN_BUSD_DEPUTY, KAVA_MAIN_BUSD_DEPUTY)
        }
        return nil
    }
    
    func fromKavaDuputyAdddress(_ denom: String) -> (String, String)? {
        if (denom == TOKEN_HTLC_KAVA_BNB) {
            return (KAVA_MAIN_BNB_DEPUTY, BINANCE_MAIN_BNB_DEPUTY)
        } else if (denom == TOKEN_HTLC_KAVA_BTCB) {
            return (KAVA_MAIN_BTCB_DEPUTY, BINANCE_MAIN_BTCB_DEPUTY)
        } else if (denom == TOKEN_HTLC_KAVA_XRPB) {
            return (KAVA_MAIN_XRPB_DEPUTY, BINANCE_MAIN_XRPB_DEPUTY)
        } else if (denom == TOKEN_HTLC_KAVA_BUSD) {
            return (KAVA_MAIN_BUSD_DEPUTY, BINANCE_MAIN_BUSD_DEPUTY)
        }
        return nil
    }
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let KavaChain = ChainKava459()
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: KavaChain.getGrpc().host, port: KavaChain.getGrpc().port)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}
