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
    
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var sendDenomLabel: UILabel!
    @IBOutlet weak var sendValueLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!
    @IBOutlet weak var availableValueLabel: UILabel!
    @IBOutlet weak var remainAmountLabel: UILabel!
    @IBOutlet weak var remainDenomLabel: UILabel!
    @IBOutlet weak var remainValueLabel: UILabel!
    @IBOutlet weak var recipientChainLayer: UIView!
    @IBOutlet weak var recipientChainLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    @IBOutlet weak var mMemoLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var feeTitle: UILabel!
    @IBOutlet weak var sendAmountTitle: UILabel!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var remainingTitle: UILabel!
    @IBOutlet weak var recipientChainTitle: UILabel!
    @IBOutlet weak var recipientTitle: UILabel!
    @IBOutlet weak var memoTitle: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    var divideDecimal:Int16 = 6
    var displayDecimal:Int16 = 6
    var feeDivideDecimal:Int16 = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        backBtn.borderColor = UIColor.font05
        confirmBtn.borderColor = UIColor.init(named: "photon")
        
        feeTitle.text = NSLocalizedString("str_tx_fee", comment: "")
        sendAmountTitle.text = NSLocalizedString("str_send_amount", comment: "")
        currentTitle.text = NSLocalizedString("str_current_availabe", comment: "")
        remainingTitle.text = NSLocalizedString("str_remaining_availabe", comment: "")
        recipientTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        recipientChainTitle.text = NSLocalizedString("str_recipient_chain", comment: "")
        memoTitle.text = NSLocalizedString("str_memo", comment: "")
        backBtn.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        backBtn.borderColor = UIColor.font05
        confirmBtn.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if (BaseData.instance.isAutoPass()) {
            if (chainConfig?.isGrpc == true) {
                self.onFetchAuth(account!.account_address)
            } else {
                self.onFetchAccountInfo(account!)
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
        let toSendDenom = pageHolderVC.mToSendAmount[0].denom
        let toSendAmount = NSDecimalNumber.init(string: pageHolderVC.mToSendAmount[0].amount)
        let feeDenom = pageHolderVC.mFee!.amount[0].denom
        let feeAmount = NSDecimalNumber.init(string: pageHolderVC.mFee!.amount[0].amount)
        var currentAvailable = NSDecimalNumber.zero
        var remainAvailable = NSDecimalNumber.zero

        if (chainConfig?.isGrpc == true) {
            var sendPriceDenom = toSendDenom
            var feePriceDenom = feeDenom
            if let sendMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == toSendDenom.lowercased() }).first {
                divideDecimal = sendMsAsset.decimal
                displayDecimal = sendMsAsset.decimal
                currentAvailable = BaseData.instance.getAvailableAmount_gRPC(toSendDenom)
                if (toSendDenom == feeDenom) {
                    remainAvailable = currentAvailable.subtracting(toSendAmount).subtracting(feeAmount)
                } else {
                    remainAvailable = currentAvailable.subtracting(toSendAmount)
                }
                sendPriceDenom = sendMsAsset.priceDenom()
                
            } else if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.denom.lowercased() == toSendDenom.lowercased() }).first {
                divideDecimal = msToken.decimal
                displayDecimal = msToken.decimal
                currentAvailable = NSDecimalNumber.init(string: msToken.amount)
                remainAvailable = currentAvailable.subtracting(toSendAmount)
                sendPriceDenom = msToken.denom
            }
            
            feeDivideDecimal = WUtils.getDenomDecimal(chainConfig, feeDenom)
            if let feeMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == feeDenom.lowercased() }).first {
                feePriceDenom = feeMsAsset.priceDenom()
                feeDivideDecimal = feeMsAsset.decimal
            }
            
            WDP.dpCoin(chainConfig, pageHolderVC.mToSendAmount[0], sendDenomLabel, sendAmountLabel)
            WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
            WDP.dpCoin(chainConfig, toSendDenom, currentAvailable.stringValue, availableDenomLabel, availableAmountLabel)
            WDP.dpCoin(chainConfig, toSendDenom, remainAvailable.stringValue, remainDenomLabel, remainAmountLabel)
            
            
            feeValueLabel.attributedText = WUtils.dpAssetValue(feePriceDenom, feeAmount, feeDivideDecimal, feeValueLabel.font)
            sendValueLabel.attributedText = WUtils.dpAssetValue(sendPriceDenom, toSendAmount, divideDecimal, sendValueLabel.font)
            availableValueLabel.attributedText = WUtils.dpAssetValue(sendPriceDenom, currentAvailable, divideDecimal, availableValueLabel.font)
            remainValueLabel.attributedText = WUtils.dpAssetValue(sendPriceDenom, remainAvailable, divideDecimal, remainValueLabel.font)
            
        } else {
            divideDecimal = chainConfig!.divideDecimal
            displayDecimal = chainConfig!.displayDecimal
            currentAvailable = BaseData.instance.availableAmount(toSendDenom)
            if (pageHolderVC.mToSendDenom == chainConfig!.stakeDenom) {
                remainAvailable = currentAvailable.subtracting(toSendAmount).subtracting(feeAmount)
            } else {
                remainAvailable = currentAvailable.subtracting(toSendAmount)
            }
            
            WDP.dpCoin(chainConfig, pageHolderVC.mToSendAmount[0], sendDenomLabel, sendAmountLabel)
            WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
            WDP.dpCoin(chainConfig, toSendDenom, currentAvailable.stringValue, availableDenomLabel, availableAmountLabel)
            WDP.dpCoin(chainConfig, toSendDenom, remainAvailable.stringValue, remainDenomLabel, remainAmountLabel)
            
            feeValueLabel.isHidden = true
            sendValueLabel.isHidden = true
            availableValueLabel.isHidden = true
            remainValueLabel.isHidden = true
        }
        
        print("fee              ", feeDenom, "  ", feeAmount)
        print("toSend           ", toSendDenom, "  ", toSendAmount)
        print("currentAvailable ", toSendDenom, "  ", currentAvailable)
        print("remainAvailable  ", toSendDenom, "  ", remainAvailable)
        
        if (self.pageHolderVC.mTransferType == TRANSFER_IBC_SIMPLE || self.pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
            recipientChainLayer.isHidden = false
            recipientChainLabel.text = pageHolderVC.mRecipinetChainConfig?.chainTitle2
            recipientChainLabel.textColor = pageHolderVC.mRecipinetChainConfig?.chainColor
        } else {
            recipientChainLayer.isHidden = true
        }
        
        recipientAddressLabel.text = pageHolderVC.mRecipinetAddress
        recipientAddressLabel.adjustsFontSizeToFitWidth = true
        mMemoLabel.text = pageHolderVC.mMemo
        
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            if (chainConfig?.isGrpc == true) {
                self.onFetchAuth(account!.account_address)
            } else {
                self.onFetchAccountInfo(account!)
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
                    self.onGenOkcSendTx()
                    
                }
                
            case .failure(let error):
                self.hideWaittingAlert()
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
                print("onFetchAccountInfo ", error)
            }
        }
    }
    
    func onGenOkcSendTx() {
        DispatchQueue.global().async {
            var stdTx:StdTx!
            do {
                let msg = MsgGenerator.genGetSendMsg(self.pageHolderVC.mAccount!.account_address,
                                                     self.pageHolderVC.mRecipinetAddress!,
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
                
                if (self.pageHolderVC.mAccount!.account_pubkey_type == 0) {
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
                    let request = Alamofire.request(BaseNetWork.broadcastUrl(self.chainType), method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:])
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
                                                 toAddress: self.pageHolderVC.mRecipinetAddress!,
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
    func onFetchAuth(_ address: String) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if (self.pageHolderVC.mTransferType == TRANSFER_IBC_SIMPLE || self.pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
                        self.onFetchIbcClientState(response)
                    } else {
                        self.onBroadcastTx(response, nil)
                    }
                }
                try channel.close().wait()
            } catch {
                print("onFetchAuth failed: \(error)")
            }
        }
    }
    
    func onFetchIbcClientState(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
                    $0.channelID = self.pageHolderVC.mMintscanPath!.channel!
                    $0.portID = self.pageHolderVC.mMintscanPath!.port!
                }
                if let response = try? Ibc_Core_Channel_V1_QueryClient(channel: channel).channelClientState(req).response.wait() {
                    let clientState = try! Ibc_Lightclients_Tendermint_V1_ClientState.init(serializedData: response.identifiedClientState.clientState.value)
                    self.onBroadcastTx(auth, clientState.latestHeight)
                }
                try channel.close().wait()
            } catch {
                print("onFetchIbcClientState failed: \(error)")
            }
        }
    }
    
    func onBroadcastTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?, _ height: Ibc_Core_Client_V1_Height?) {
        DispatchQueue.global().async {
            var reqTx: Cosmos_Tx_V1beta1_BroadcastTxRequest?
            if (self.pageHolderVC.mTransferType == TRANSFER_SIMPLE) {
                reqTx = Signer.genSimpleSend(auth!, self.account!.account_pubkey_type,
                                             self.pageHolderVC.mRecipinetAddress!, self.pageHolderVC.mToSendAmount,
                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                             self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
                
            } else if (self.pageHolderVC.mTransferType == TRANSFER_IBC_SIMPLE) {
                reqTx = Signer.genIbcSend(auth!, self.account!.account_pubkey_type,
                                          self.pageHolderVC.mRecipinetAddress!, self.pageHolderVC.mToSendAmount,
                                          self.pageHolderVC.mMintscanPath!, height!,
                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
                
            } else if (self.pageHolderVC.mTransferType == TRANSFER_WASM) {
                reqTx = Signer.genWasmSend(auth!, self.account!.account_pubkey_type,
                                           self.pageHolderVC.mRecipinetAddress!, self.pageHolderVC.mMintscanTokens!.contract_address,
                                           self.pageHolderVC.mToSendAmount,
                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
                
            } else if (self.pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
                reqTx = Signer.genWasmIbcSend(auth!, self.account!.account_pubkey_type,
                                              self.pageHolderVC.mRecipinetAddress!, self.pageHolderVC.mMintscanTokens!.contract_address,
                                              self.pageHolderVC.mToSendAmount, self.pageHolderVC.mMintscanPath!,
                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                              self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
            }
            
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                if let response = try? Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx!, callOptions: BaseNetWork.getCallOptions()).response.wait() {
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
                print("onBroadcastTx failed: \(error)")
            }
        }
    }

}
