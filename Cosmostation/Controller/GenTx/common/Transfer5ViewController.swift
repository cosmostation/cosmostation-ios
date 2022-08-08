//
//  Transfer5ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/06/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import HDWalletKit
import GRPC
import NIO

class Transfer5ViewController: BaseViewController, PasswordViewDelegate{
    
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var sendDenomLabel: UILabel!
    @IBOutlet weak var sendValueLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!
    @IBOutlet weak var availableValueLabel: UILabel!
    @IBOutlet weak var remainAmountLabel: UILabel!
    @IBOutlet weak var remainDenomLabel: UILabel!
    @IBOutlet weak var remainValueLabel: UILabel!
    @IBOutlet weak var mToAddressLabel: UILabel!
    @IBOutlet weak var mMemoLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mDivideDecimal:Int16 = 6
    var mDisplayDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        WUtils.setDenomTitle(chainType, sendDenomLabel)
        WUtils.setDenomTitle(chainType, availableDenomLabel)
        WUtils.setDenomTitle(chainType, remainDenomLabel)
        
        backBtn.borderColor = UIColor.init(named: "_font05")
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backBtn.borderColor = UIColor.init(named: "_font05")
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if (BaseData.instance.isAutoPass()) {
            if (WUtils.isGRPC(chainType)) {
                self.onFetchgRPCAuth(pageHolderVC.mAccount!)
            } else {
                self.onFetchAccountInfo(pageHolderVC.mAccount!)
            }
        } else {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
            passwordVC.resultDelegate = self
            self.navigationController?.pushViewController(passwordVC, animated: false)
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.backBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.backBtn.isUserInteractionEnabled = true
        self.confirmBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        let mainDenom = WUtils.getMainDenom(chainConfig)
        let toSendDenom = pageHolderVC.mToSendAmount[0].denom
        let toSendAmount = WUtils.plainStringToDecimal(pageHolderVC.mToSendAmount[0].amount)
        let feeAmount = WUtils.plainStringToDecimal((pageHolderVC.mFee?.amount[0].amount)!)
        var currentAvailable = NSDecimalNumber.zero
        var remainAvailable = NSDecimalNumber.zero
        
        if (WUtils.isGRPC(chainType)) {
            mDivideDecimal = WUtils.getDenomDecimal(chainConfig, pageHolderVC.mToSendDenom)
            mDisplayDecimal = WUtils.getDenomDecimal(chainConfig, pageHolderVC.mToSendDenom)
            currentAvailable = BaseData.instance.getAvailableAmount_gRPC(toSendDenom)
            
        } else {
            if (chainType == ChainType.BINANCE_MAIN) {
                mDivideDecimal = WUtils.mainDivideDecimal(chainType)
                mDisplayDecimal = WUtils.mainDisplayDecimal(chainType)
                
            } else if (chainType == ChainType.OKEX_MAIN) {
                mDivideDecimal = WUtils.mainDivideDecimal(chainType)
                mDisplayDecimal = WUtils.mainDisplayDecimal(chainType)
                
            } else {
                mDivideDecimal = WUtils.mainDivideDecimal(chainType)
                mDisplayDecimal = WUtils.mainDisplayDecimal(chainType)
            }
            currentAvailable = BaseData.instance.availableAmount(toSendDenom)
            
        }
        
        if (toSendDenom == mainDenom) {
            remainAvailable = currentAvailable.subtracting(toSendAmount).subtracting(feeAmount)
            sendValueLabel.attributedText = WUtils.dpValueUserCurrency(mainDenom, toSendAmount, mDivideDecimal, sendValueLabel.font)
            feeValueLabel.attributedText = WUtils.dpValueUserCurrency(mainDenom, feeAmount, mDivideDecimal, feeValueLabel.font)
            availableValueLabel.attributedText = WUtils.dpValueUserCurrency(mainDenom, currentAvailable, mDivideDecimal, availableValueLabel.font)
            remainValueLabel.attributedText = WUtils.dpValueUserCurrency(mainDenom, remainAvailable, mDivideDecimal, remainValueLabel.font)
            
        } else {
            remainAvailable = currentAvailable.subtracting(toSendAmount)
            sendValueLabel.isHidden = true
            feeValueLabel.isHidden = true
            availableValueLabel.isHidden = true
            remainValueLabel.isHidden = true
            
        }
//        print("currentAvailable ", currentAvailable)
//        print("feeAmount ", feeAmount)
//        print("toSendAmount ", toSendAmount)
//        print("remainAvailable ", remainAvailable)
        
        
        WDP.dpCoin(chainConfig, pageHolderVC.mToSendAmount[0], sendDenomLabel, sendAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
        WDP.dpCoin(chainConfig, toSendDenom, currentAvailable.stringValue, availableDenomLabel, availableAmountLabel)
        WDP.dpCoin(chainConfig, toSendDenom, remainAvailable.stringValue, remainDenomLabel, remainAmountLabel)
        
        mToAddressLabel.text = pageHolderVC.mToSendRecipientAddress
        mToAddressLabel.adjustsFontSizeToFitWidth = true
        mMemoLabel.text = pageHolderVC.mMemo
        
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            if (WUtils.isGRPC(chainType)) {
                self.onFetchgRPCAuth(pageHolderVC.mAccount!)
            } else {
                self.onFetchAccountInfo(pageHolderVC.mAccount!)
            }
        }
    }
    
    
    func onFetchAccountInfo(_ account: Account) {
        self.showWaittingAlert()
        let request = Alamofire.request(BaseNetWork.accountInfoUrl(chainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if (self.chainType == ChainType.BINANCE_MAIN) {
                    guard let info = res as? [String : Any] else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.hideWaittingAlert()
                        self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    let bnbAccountInfo = BnbAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithBnbAccountInfo(account, bnbAccountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithBnbAccountInfo(account, bnbAccountInfo))
                    self.onGenBnbSendTx()
                    
                } else if (self.chainType == ChainType.OKEX_MAIN) {
                    guard let info = res as? NSDictionary else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.hideWaittingAlert()
                        self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    let okAccountInfo = OkAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithOkAccountInfo(account, okAccountInfo))
                    BaseData.instance.mOkAccountInfo = okAccountInfo
                    self.onGenOexSendTx()
                    
                }
                
            case .failure(let error):
                self.hideWaittingAlert()
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
                print("onFetchAccountInfo ", error)
            }
        }
    }
    
    func onGenOexSendTx() {
        DispatchQueue.global().async {
            var stdTx:StdTx!
            do {
                let msg = MsgGenerator.genGetSendMsg(self.pageHolderVC.mAccount!.account_address,
                                                     self.pageHolderVC.mToSendRecipientAddress!,
                                                     self.pageHolderVC.mToSendAmount,
                                                     self.chainType!)
                var msgList = Array<Msg>()
                msgList.append(msg)
                
                let stdMsg = MsgGenerator.getToSignMsg(BaseData.instance.getChainId(self.chainType),
                                                       String(self.pageHolderVC.mAccount!.account_account_numner),
                                                       String(self.pageHolderVC.mAccount!.account_sequence_number),
                                                       msgList, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .sortedKeys
                let data = try? encoder.encode(stdMsg)
                let rawResult = String(data:data!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
                let rawData: Data? = rawResult!.data(using: .utf8)
                
                if (self.pageHolderVC.mAccount!.account_custom_path == 0) {
                    print("Tender Type")
                    let hash = rawData!.sha256()
                    let signedData = try! ECDSA.compactsign(hash, privateKey: self.pageHolderVC.privateKey!)
                    
                    var genedSignature = Signature.init()
                    var genPubkey =  PublicKey.init()
                    genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
                    genPubkey.value = self.pageHolderVC.publicKey!.base64EncodedString()
                    genedSignature.pub_key = genPubkey
                    genedSignature.signature = signedData.base64EncodedString()
                    genedSignature.account_number = String(self.pageHolderVC.mAccount!.account_account_numner)
                    genedSignature.sequence = String(self.pageHolderVC.mAccount!.account_sequence_number)
                    
                    var signatures: Array<Signature> = Array<Signature>()
                    signatures.append(genedSignature)
                    
                    stdTx = MsgGenerator.genSignedTx(msgList, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, signatures)
                    
                } else {
                    print("Ether Type")
                    let hash = HDWalletKit.Crypto.sha3keccak256(data: rawData!)
                    let signedData: Data? = try ECDSA.compactsign(hash, privateKey: self.pageHolderVC.privateKey!)
                    
                    var genedSignature = Signature.init()
                    var genPubkey =  PublicKey.init()
                    genPubkey.type = ETHERMINT_KEY_TYPE_PUBLIC
                    genPubkey.value = self.pageHolderVC.publicKey!.base64EncodedString()
                    genedSignature.pub_key = genPubkey
                    genedSignature.signature = signedData!.base64EncodedString()
                    genedSignature.account_number = String(self.pageHolderVC.mAccount!.account_account_numner)
                    genedSignature.sequence = String(self.pageHolderVC.mAccount!.account_sequence_number)
                    
                    var signatures: Array<Signature> = Array<Signature>()
                    signatures.append(genedSignature)
                    
                    stdTx = MsgGenerator.genSignedTx(msgList, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, signatures)
                }
                
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async(execute: {
                let postTx = PostTx.init("sync", stdTx.value)
                let encoder = JSONEncoder()
                encoder.outputFormatting = .sortedKeys
                let data = try? encoder.encode(postTx)
                do {
                    let params = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    print("params ", params)
                    let request = Alamofire.request(BaseNetWork.broadcastUrl(self.chainType), method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:])
                    print("request ", request.request?.url)
                    request.responseJSON { response in
                        var txResult = [String:Any]()
                        switch response.result {
                        case .success(let res):
                            print("Send ", res)
                            if let result = res as? [String : Any]  {
                                txResult = result
                            }
                        case .failure(let error):
                            print("send error ", error)
                            if (response.response?.statusCode == 500) {
                                txResult["net_error"] = 500
                            }
                        }
                        if (self.waitAlert != nil) {
                            self.waitAlert?.dismiss(animated: true, completion: {
                                self.onStartTxDetail(txResult)
                            })
                        }
                    }

                } catch {
                    print(error)
                }
            });
        }
    }
    
    func onGenBnbSendTx() {
        DispatchQueue.global().async {
            let bnbMsg = BinanceMessage.transfer(symbol: self.pageHolderVC.mToSendAmount[0].denom,
                                                 amount: (self.pageHolderVC.mToSendAmount[0].amount as NSString).doubleValue,
                                                 toAddress: self.pageHolderVC.mToSendRecipientAddress!,
                                                 memo: self.pageHolderVC.mMemo!,
                                                 privateKey: PrivateKey.init(pk: self.pageHolderVC.privateKey!.hexEncodedString(), coin: .bitcoin)!,
                                                 signerAddress: self.pageHolderVC.mAccount!.account_address,
                                                 sequence: Int(self.pageHolderVC.mAccount!.account_sequence_number),
                                                 accountNumber: Int(self.pageHolderVC.mAccount!.account_account_numner),
                                                 chainId: BaseData.instance.getChainId(self.chainType))
            
            DispatchQueue.main.async(execute: {
                do {
                    var encoding: ParameterEncoding = URLEncoding.default
                    encoding = HexEncoding(data: try bnbMsg.encode())
                    let param: Parameters = [ "address": self.pageHolderVC.mAccount!.account_address ]
                    let request = Alamofire.request(BaseNetWork.broadcastUrl(self.chainType), method: .post, parameters: param, encoding: encoding, headers: [:])
                    request.responseJSON { response in
                        var txResult = [String:Any]()
                        switch response.result {
                        case .success(let res):
                            print("res ", res)
                            if let result = res as? Array<NSDictionary> {
                                txResult["hash"] = result[0].object(forKey:"hash")
                            }
                            
                        case .failure(let error):
                            print("send error ", error)
                        }
                        if (self.waitAlert != nil) {
                            self.waitAlert?.dismiss(animated: true, completion: {
                                self.onStartTxDetail(txResult)
                            })
                        }
                    }

                } catch {
                    print(error)
                }
            });
        }
    }
    
    
    //gRPC
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    self.onBroadcastGrpcTx(response)
                }
                try channel.close().wait()
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onBroadcastGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
        DispatchQueue.global().async {
            let reqTx = Signer.genSignedSendTxgRPC(auth!,
                                                   self.pageHolderVC.mToSendRecipientAddress!, self.pageHolderVC.mToSendAmount,
                                                   self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
            
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                if let response = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    DispatchQueue.main.async(execute: {
                        if (self.waitAlert != nil) {
                            self.waitAlert?.dismiss(animated: true, completion: {
                                self.onStartTxDetailgRPC(response)
                            })
                        }
                    });
                }
                try channel.close().wait()
            } catch {
                print("onBroadcastGrpcTx failed: \(error)")
            }
        }
    }

}
