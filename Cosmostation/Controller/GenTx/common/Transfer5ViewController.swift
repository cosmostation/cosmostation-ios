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
import web3swift

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
        confirmBtn.borderColor = UIColor.photon
        
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
        confirmBtn.borderColor = UIColor.photon
    }
    
    @IBAction func onClickConfirm(_ sender: Any) {
        if (BaseData.instance.isAutoPass()) {
            if (chainConfig?.isGrpc == true) {
                if (self.pageHolderVC.mTransferType == TRANSFER_EVM) {
                    self.onBroadcastEvmTx()
                } else {
                    self.onFetchAuth(account!.account_address)
                }
            } else {
                self.onFetchAccountInfo(account!)
            }
        } else {
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            self.navigationController?.pushViewController(UIStoryboard.passwordViewController(delegate: self, target: PASSWORD_ACTION_CHECK_TX), animated: false)
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
        
        var sendGeckocId = ""
        var feeGeckocId = feeDenom
        if let msToken = BaseData.instance.mMintscanTokens.filter({ $0.address == toSendDenom }).first {
            divideDecimal = msToken.decimals
            displayDecimal = msToken.decimals
            currentAvailable = NSDecimalNumber.init(string: msToken.amount)
            remainAvailable = currentAvailable.subtracting(toSendAmount)
            sendGeckocId = msToken.coinGeckoId
            
            WDP.dpAssetValue(feeGeckocId, feeAmount, feeDivideDecimal, feeValueLabel)
            WDP.dpAssetValue(sendGeckocId, toSendAmount, divideDecimal, sendValueLabel)
            WDP.dpAssetValue(sendGeckocId, currentAvailable, divideDecimal, availableValueLabel)
            WDP.dpAssetValue(sendGeckocId, remainAvailable, divideDecimal, remainValueLabel)
            
        } else {
            if (chainConfig!.isGrpc == true) {
                if let sendMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == toSendDenom.lowercased() }).first {
                    divideDecimal = sendMsAsset.decimals
                    displayDecimal = sendMsAsset.decimals
                    currentAvailable = BaseData.instance.getAvailableAmount_gRPC(toSendDenom)
                    if (toSendDenom == feeDenom) {
                        remainAvailable = currentAvailable.subtracting(toSendAmount).subtracting(feeAmount)
                    } else {
                        remainAvailable = currentAvailable.subtracting(toSendAmount)
                    }
                    sendGeckocId = sendMsAsset.coinGeckoId
                }
                
                if let feeMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom == feeDenom }).first {
                    feeGeckocId = feeMsAsset.coinGeckoId
                    feeDivideDecimal = feeMsAsset.decimals
                }
                
                WDP.dpAssetValue(feeGeckocId, feeAmount, feeDivideDecimal, feeValueLabel)
                WDP.dpAssetValue(sendGeckocId, toSendAmount, divideDecimal, sendValueLabel)
                WDP.dpAssetValue(sendGeckocId, currentAvailable, divideDecimal, availableValueLabel)
                WDP.dpAssetValue(sendGeckocId, remainAvailable, divideDecimal, remainValueLabel)
                
            } else {
                divideDecimal = chainConfig!.divideDecimal
                displayDecimal = chainConfig!.displayDecimal
                currentAvailable = BaseData.instance.availableAmount(toSendDenom)
                if (pageHolderVC.mToSendDenom == chainConfig!.stakeDenom) {
                    remainAvailable = currentAvailable.subtracting(toSendAmount).subtracting(feeAmount)
                } else {
                    remainAvailable = currentAvailable.subtracting(toSendAmount)
                }
                
                feeValueLabel.isHidden = true
                sendValueLabel.isHidden = true
                availableValueLabel.isHidden = true
                remainValueLabel.isHidden = true
            }
        }
        
        WDP.dpCoin(chainConfig, pageHolderVC.mToSendAmount[0], sendDenomLabel, sendAmountLabel)
        WDP.dpCoin(chainConfig, pageHolderVC.mFee!.amount[0], feeDenomLabel, feeAmountLabel)
        WDP.dpCoin(chainConfig, toSendDenom, currentAvailable.stringValue, availableDenomLabel, availableAmountLabel)
        WDP.dpCoin(chainConfig, toSendDenom, remainAvailable.stringValue, remainDenomLabel, remainAmountLabel)
        
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
            if (self.pageHolderVC.mTransferType == TRANSFER_EVM) {
                self.onBroadcastEvmTx()
            } else if (chainConfig?.isGrpc == true) {
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
            }
        }
    }
    
    func onGenOkcSendTx() {
        DispatchQueue.global().async {
            let msg = MsgGenerator.genGetSendMsg(self.account!.account_address,
                                                 self.pageHolderVC.mRecipinetAddress!,
                                                 self.pageHolderVC.mToSendAmount,
                                                 self.chainType!)
            let postData = MsgGenerator.getPostData(self.chainConfig!, self.account!,
                                                    [msg],
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!)
            
            DispatchQueue.main.async(execute: {
                let params = try! JSONSerialization.jsonObject(with: postData, options: .allowFragments) as? [String: Any]
                let request = Alamofire.request(BaseNetWork.broadcastUrl(self.chainType), method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:])
                request.responseJSON { response in
                    var txResult = [String:Any]()
                    switch response.result {
                    case .success(let res):
                        if let result = res as? [String : Any]  {
                            txResult = result
                        }
                    case .failure(let error):
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
    
    func onBroadcastEvmTx() {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            let url = URL(string: self.chainConfig!.rpcUrl)
            let web3 = try? Web3.new(url!)
            
            var ethTx = self.pageHolderVC.mEthereumTransaction!
            try? ethTx.sign(privateKey: self.pageHolderVC.privateKey!)
            let result = try? web3!.eth.sendRawTransaction(ethTx)
            
            DispatchQueue.main.async(execute: {
                if (self.waitAlert != nil) {
                    self.waitAlert?.dismiss(animated: true, completion: {
                        self.onStartTxDetailEvm(result!.hash)
                    })
                }
            });
        }
    }
    
    
    //gRPC
    func onFetchAuth(_ address: String) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    if (self.pageHolderVC.mTransferType == TRANSFER_IBC_SIMPLE || self.pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
                        self.onFetchIbcClientState(response)
                    } else {
                        self.onBroadcastTx(response, nil, nil)
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
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
                    $0.channelID = self.pageHolderVC.mMintscanPath!.channel!
                    $0.portID = self.pageHolderVC.mMintscanPath!.port!
                }
                if let response = try? Ibc_Core_Channel_V1_QueryClient(channel: channel).channelClientState(req).response.wait() {
                    let clientState = try! Ibc_Lightclients_Tendermint_V1_ClientState.init(serializedData: response.identifiedClientState.clientState.value)
                    self.onFetchLatestBlock(auth,clientState.latestHeight)
                }
                try channel.close().wait()
            } catch {
                print("onFetchIbcClientState failed: \(error)")
            }
        }
    }
    
    func onFetchLatestBlock(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ height: Ibc_Core_Client_V1_Height?) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.pageHolderVC.mRecipinetChainConfig)!
                let req = Cosmos_Base_Tendermint_V1beta1_GetLatestBlockRequest()
                if let response = try? Cosmos_Base_Tendermint_V1beta1_ServiceClient(channel: channel).getLatestBlock(req).response.wait() {
                    self.onBroadcastTx(auth, height, response.block)
                }
                try channel.close().wait()
            } catch {
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
                print("onFetchLastBlock failed: \(error)")
            }
        }
    }
    
    func onBroadcastTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?, _ height: Ibc_Core_Client_V1_Height?, _ latest: Tendermint_Types_Block?) {
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
                                          self.pageHolderVC.mMintscanPath!, height!, latest!,
                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
                
            } else if (self.pageHolderVC.mTransferType == TRANSFER_WASM) {
                reqTx = Signer.genWasmSend(auth!, self.account!.account_pubkey_type,
                                           self.pageHolderVC.mRecipinetAddress!, self.pageHolderVC.mMintscanTokens!.address,
                                           self.pageHolderVC.mToSendAmount,
                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
                
            } else if (self.pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
                reqTx = Signer.genWasmIbcSend(auth!, self.account!.account_pubkey_type,
                                              self.pageHolderVC.mRecipinetAddress!, self.pageHolderVC.mMintscanTokens!.address,
                                              self.pageHolderVC.mToSendAmount, self.pageHolderVC.mMintscanPath!,
                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                              self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, self.chainType!)
            }
            
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
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
