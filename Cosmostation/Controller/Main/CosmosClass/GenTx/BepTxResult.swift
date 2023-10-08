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
    
    var fromChain: CosmosClass!
    var toChain: CosmosClass!
    var toSendDenom: String!
    var toSendAmount = NSDecimalNumber.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        print("fromChain ", fromChain.address)
        print("toChain ", toChain.address)
        print("toSendDenom ", toSendDenom)
        print("toSendAmount ", toSendAmount)
        
        loadingMsgLabel.text = NSLocalizedString("msg_htlc_swap_progress_0", comment: "")
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
    
    
    @IBAction func onClickConfirm(_ sender: BaseButton) {
        
    }
    
    
    var timeStamp: Int64!
    var randomNumber: String!
    var randomNumberHash: String!
    
//    var bnbAuth = JSON()
}

//BNB to KAVA
extension BepTxResult {
    
    
    func fetchBnbAuth() {
        AF.request(BaseNetWork.lcdAccountInfoUrl(fromChain, fromChain.address!), method: .get).responseDecodable(of: JSON.self) { response in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async(execute: {
                    self.creatBepSend(value)
                });
                
            case .failure:
                print("fetchBnbAuth error")
            }
        }
    }
    
    func creatBepSend(_ bnbAuth: JSON) {
        timeStamp = Date().millisecondsSince1970 / 1000
        randomNumber = KeyFac.generateRandomBytes()
        randomNumberHash = KeyFac.getRandomNumnerHash(randomNumber, timeStamp)
        
        let bnbMsg = BinanceMessage.createHtlc(toAddress: fromBnbDuputyAdddress(toSendDenom)!.0,
                                               otherFrom: fromBnbDuputyAdddress(toSendDenom)!.1,
                                               otherTo: toChain.address!,
                                               timestamp: timeStamp,
                                               randomNumberHash: randomNumberHash,
                                               sendAmount: toSendAmount.multiplying(byPowerOf10: 8).int64Value,
                                               sendDenom: toSendDenom!,
                                               expectedIncom: toSendAmount.multiplying(byPowerOf10: 8).stringValue + ":" + toSendDenom!,
                                               heightSpan: 407547,
                                               crossChain: true,
                                               memo: SWAP_MEMO_CREATE,
                                               privateKey: fromChain.privateKey!,
                                               signerAddress: fromChain.address!,
                                               sequence: bnbAuth["sequence"].intValue,
                                               accountNumber: bnbAuth["account_number"].intValue,
                                               chainId: toChain.chainId!)
        
        var encoding: ParameterEncoding = URLEncoding.default
        encoding = HexEncoding(data: try! bnbMsg.encode())
        let param: Parameters = ["address": fromChain.address!]
        
        AF.request(BaseNetWork.broadcastUrl(fromChain), method: .post, parameters: param, encoding: encoding).responseDecodable(of: JSON.self)  { response in
            print("response ", response)
            switch response.result {
            case .success(let res):
                let sendTxHash = res.arrayValue[0]["hash"].stringValue
                print("sendTxHash ", sendTxHash)
                
                DispatchQueue.main.async(execute: {
//                    self.onFetchSwapId()
                });

            case .failure(let error):
                print("creatBepSend error ", error)
            }
        }
    }
    
    
    func fetchBtoKSwapId() {
        onUpdateProgress(1)
        let swapId = KeyFac.getSwapId(toChain, toSendDenom, randomNumberHash, fromChain.address!)
        let url = BaseNetWork.swapIdBep3Url(toChain, swapId!)
        print("swapId ", swapId)
        print("url ", swapId)
        
        AF.request(url, method: .get).responseDecodable(of: JSON.self) { response in
            switch response.result {
            case .success(let value):
                print("fetchBtoKSwapId ", value)
//                DispatchQueue.main.async(execute: {
//                    self.creatBepSend(value)
//                });
                
            case .failure:
                print("fetchBtoKSwapId error")
            }
        }
    }
    
}

//KAVA to BNB
extension BepTxResult {
    
    
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
}
