//
//  HtlcResultViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/04/16.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import HDWalletKit
import Alamofire
import GRPC
import NIO


class HtlcResultViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var htlcResultTableView: UITableView!
    @IBOutlet weak var bottomControlLayer: UIStackView!
    @IBOutlet weak var btnSentWallet: UIButton!
    @IBOutlet weak var btnReceievedWallet: UIButton!
    
    @IBOutlet weak var errorCard: CardView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var errorCodeLabel: UILabel!
    
    @IBOutlet weak var loadingLayer: UIView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var loadingProgressLabel: UILabel!
    
    var mHtlcDenom: String?
    var mHtlcToSendAmount = Array<Coin>()
    var mHtlcToChain: ChainType?
    var mHtlcToAccount: Account?
    var mHtlcSendFee: Fee?
    var mHtlcClaimFee: Fee?
    
    var mTimeStamp: Int64?
    var mRandomNumber: String?
    var mRandomNumberHash: String?
    
    var mSendHash: String?
    var mSendTxInfo: TxInfo?
    var mSendTxInfogRPC: Cosmos_Tx_V1beta1_GetTxResponse?
    var mClaimHash: String?
    var mClaimTxInfo: TxInfo?
    var mClaimTxInfogRPC: Cosmos_Tx_V1beta1_GetTxResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.htlcResultTableView.delegate = self
        self.htlcResultTableView.dataSource = self
        self.htlcResultTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.htlcResultTableView.register(UINib(nibName: "HtlcResultSentCell", bundle: nil), forCellReuseIdentifier: "HtlcResultSentCell")
        self.htlcResultTableView.register(UINib(nibName: "HtlcResultClaimCell", bundle: nil), forCellReuseIdentifier: "HtlcResultClaimCell")
        self.htlcResultTableView.rowHeight = UITableView.automaticDimension
        self.htlcResultTableView.estimatedRowHeight = UITableView.automaticDimension
        

        self.loadingProgressLabel.text = NSLocalizedString("msg_htlc_swap_progress_0", comment: "")
        self.loadingImg.onStartAnimation()
        self.onCheckCreateHtlcSwap()
        
    }
    
    func onUpdateProgress(_ step: Int) {
        if (step == 1) {
            loadingProgressLabel.text = NSLocalizedString("msg_htlc_swap_progress_1", comment: "")
        } else if (step == 2) {
            loadingProgressLabel.text = NSLocalizedString("msg_htlc_swap_progress_2", comment: "")
        } else if (step == 3) {
            loadingProgressLabel.text = NSLocalizedString("msg_htlc_swap_progress_3", comment: "")
        }
    }
    
    func onUpdateView(_ errorMSg: String) {
        self.loadingLayer.isHidden = false
        if (!errorMSg.isEmpty) {
            //TODO handle error case
            self.bottomControlLayer.isHidden = false
            self.loadingLayer.isHidden = true
            self.errorCard.isHidden = false
            self.errorCodeLabel.text = errorMSg
            
        } else {
            if (self.chainType == .BINANCE_MAIN) {
                if (mSendTxInfo != nil && mClaimTxInfogRPC != nil && mClaimTxInfogRPC!.tx.body.messages.count > 0) {
                    self.htlcResultTableView.reloadData()
                    self.htlcResultTableView.isHidden = false
                    self.htlcResultTableView.isHidden = false
                    self.bottomControlLayer.isHidden = false
                    self.loadingLayer.isHidden = true
                    return
                }
                
            } else {
                if (mSendTxInfogRPC != nil && mClaimTxInfo != nil && mSendTxInfogRPC!.tx.body.messages.count > 0) {
                    self.htlcResultTableView.reloadData()
                    self.htlcResultTableView.isHidden = false
                    self.htlcResultTableView.isHidden = false
                    self.bottomControlLayer.isHidden = false
                    self.loadingLayer.isHidden = true
                    return
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.chainType == .BINANCE_MAIN) {
            if (mSendTxInfo != nil && mClaimTxInfogRPC != nil) {
                return 2
            }
        } else {
            if (mSendTxInfogRPC != nil && mClaimTxInfo != nil) {
                return 2
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return onSetHtlcSentItems(tableView, indexPath);
        } else if (indexPath.row == 1) {
            return onSetHtlcClaimItems(tableView, indexPath);
        } else {
            let cell:HtlcResultSentCell? = tableView.dequeueReusableCell(withIdentifier:"HtlcResultSentCell") as? HtlcResultSentCell
            return cell!
        }
    }
    
    func onSetHtlcSentItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell:HtlcResultSentCell? = tableView.dequeueReusableCell(withIdentifier:"HtlcResultSentCell") as? HtlcResultSentCell
        cell?.sendImg.image = cell?.sendImg.image?.withRenderingMode(.alwaysTemplate)
        cell?.sendImg.tintColor = ChainFactory.getChainConfig(chainType!)?.chainColor
        
        if (self.chainType == ChainType.BINANCE_MAIN) {
            let msg = mSendTxInfo?.getMsgs()[0]
            cell?.blockHeightLabel.text = mSendTxInfo?.height
            cell?.txHashLabel.text = mSendTxInfo?.hash
            cell?.memoLabel.text = mSendTxInfo?.tx?.value.memo
            
            let sendCoin = msg?.value.getAmounts()![0]
            cell?.sentAmountLabel.attributedText = WDP.dpAmount(sendCoin?.amount, cell!.sentAmountLabel.font!, 8, 8)
            WDP.dpMainSymbol(chainConfig, cell!.sentDenom)
            
            cell?.feeLabel.attributedText = WDP.dpAmount(FEE_BINANCE_BASE, cell!.feeLabel.font!, 0, 8)
            WDP.dpMainSymbol(chainConfig, cell!.feeDenom)
            
            cell?.senderLabel.text = msg?.value.from
            cell?.relayRecipientLabel.text = msg?.value.to
            cell?.relaySenderLabel.text = msg?.value.sender_other_chain
            cell?.recipientLabel.text = msg?.value.recipient_other_chain
            cell?.randomHashLabel.text = msg?.value.random_number_hash
            
        } else if (self.chainType == ChainType.KAVA_MAIN) {
            cell?.blockHeightLabel.text = String(mSendTxInfogRPC!.txResponse.height)
            cell?.txHashLabel.text = mSendTxInfogRPC?.txResponse.txhash
            cell?.memoLabel.text = mSendTxInfogRPC?.tx.body.memo
            
            
            let msg = try! Kava_Bep3_V1beta1_MsgCreateAtomicSwap.init(serializedData: mSendTxInfogRPC!.tx.body.messages[0].value)
            var coins = Array<Coin>()
            for coin in msg.amount {
                coins.append(Coin.init(coin.denom, coin.amount))
            }
            
            let sendCoin = Coin.init(msg.amount[0].denom, msg.amount[0].amount)
            let sendCoinDecimal = BaseData.instance.mMintscanAssets.filter({ $0.denom == sendCoin.denom }).first?.decimals ?? 6
            cell?.sentAmountLabel.attributedText = WDP.dpAmount(sendCoin.amount, cell!.sentAmountLabel.font!, sendCoinDecimal, sendCoinDecimal)
            cell?.sentDenom.text = sendCoin.denom.uppercased()
            
            cell!.feeDenom.text = ""
            cell!.feeLabel.text = ""
            
            cell?.senderLabel.text = msg.from
            cell?.relayRecipientLabel.text = msg.recipientOtherChain
            cell?.relaySenderLabel.text = msg.senderOtherChain
            cell?.recipientLabel.text = msg.to
            cell?.randomHashLabel.text = msg.randomNumberHash
        }
        return cell!
    }
    
    func onSetHtlcClaimItems(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell:HtlcResultClaimCell? = tableView.dequeueReusableCell(withIdentifier:"HtlcResultClaimCell") as? HtlcResultClaimCell
        let toChainConfig = ChainFactory.getChainConfig(mHtlcToChain!)
        cell?.claimImg.image = cell?.claimImg.image?.withRenderingMode(.alwaysTemplate)
        cell?.claimImg.tintColor = toChainConfig!.chainColor
        if (self.mHtlcToChain == ChainType.BINANCE_MAIN) {
            let msg = mClaimTxInfo?.getMsgs()[0]
            cell?.blockHeightLabel.text = mClaimTxInfo?.height
            cell?.txHashLabel.text = mClaimTxInfo?.hash
            cell?.memoLabel.text = mClaimTxInfo?.tx?.value.memo
            
            cell?.receivedAmountLabel.text = ""
            cell?.receivedDenom.text = ""
            
            cell?.feeLabel.attributedText = WDP.dpAmount(FEE_BINANCE_BASE, cell!.feeLabel.font!, 0, 8)
            WDP.dpMainSymbol(toChainConfig, cell!.feeDenomLabel)
            
            cell?.claimerAddress.text = msg?.value.from
            cell?.randomNumberLabel.text = msg?.value.random_number
            cell?.swapIdLabel.text = msg?.value.swap_id
            
            
        } else if (self.mHtlcToChain == ChainType.KAVA_MAIN) {
            cell?.blockHeightLabel.text = String(mClaimTxInfogRPC!.txResponse.height)
            cell?.txHashLabel.text = mClaimTxInfogRPC?.txResponse.txhash
            cell?.memoLabel.text = mClaimTxInfogRPC?.tx.body.memo
            
            if let msg = try? Kava_Bep3_V1beta1_MsgClaimAtomicSwap.init(serializedData: mClaimTxInfogRPC!.tx.body.messages[0].value) {
                cell!.feeDenomLabel.text = ""
                cell!.feeLabel.text = ""
                cell?.receivedAmountLabel.text = ""
                cell?.receivedDenom.text = ""
                
                cell?.claimerAddress.text = msg.from
                cell?.randomNumberLabel.text = msg.randomNumber
                cell?.swapIdLabel.text = msg.swapID
            }
        }
        return cell!
    }
    
    
    @IBAction func onClickSentWallet(_ sender: UIButton) {
        self.onStartMainTab()
    }
    
    @IBAction func onClickReceivedWallet(_ sender: UIButton) {
        if (BaseData.instance.dpSortedChains().contains(ChainFactory.getChainType(mHtlcToAccount!.account_base_chain)!)) {
            BaseData.instance.setRecentAccountId(mHtlcToAccount!.account_id)
            BaseData.instance.setLastTab(1)
            self.onStartMainTab()
            
        } else {
            self.onShowToast(NSLocalizedString("error_hided_chain", comment: ""))
            return
        }
    }
    
    
    
    func onCheckCreateHtlcSwap() {
        if (self.chainType == ChainType.BINANCE_MAIN) {
            self.onCheckCreateHtlcSwapBinance()
        } else {
            self.onCheckCreateHtlcSwapKava()
        }
    }
    
    func onCheckCreateHtlcSwapBinance() {
        let request = Alamofire.request(BaseNetWork.accountInfoUrl(self.chainType, account!.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? [String : Any] else {
                    _ = BaseData.instance.deleteBalance(account: self.account!)
                    self.onUpdateView(NSLocalizedString("error_network", comment: ""))
                    return
                }
                let bnbAccountInfo = BnbAccountInfo.init(info)
                _ = BaseData.instance.updateAccount(WUtils.getAccountWithBnbAccountInfo(self.account!, bnbAccountInfo))
                BaseData.instance.updateBalances(self.account!.account_id, WUtils.getBalancesWithBnbAccountInfo(self.account!, bnbAccountInfo))
                self.onCreateHtlcSwapBinance()

            case .failure(let error):
                self.onUpdateView(error.localizedDescription)
                self.onShowToast(error.localizedDescription)
            }
        }
    }
    
    func onCreateHtlcSwapBinance() {
        DispatchQueue.global().async {
            var privateKey: Data?
            if (self.account!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    privateKey = KeyFac.getPrivateRaw(words, self.account!)
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    privateKey = KeyFac.getPrivateFromString(key)
                }
            }
            
            self.mTimeStamp = Date().millisecondsSince1970 / 1000
            self.mRandomNumber = WKey.generateRandomBytes()
            self.mRandomNumberHash = WKey.getRandomNumnerHash(self.mRandomNumber!, self.mTimeStamp!)

            let bnbMsg = MsgGenerator.genBnbCreateHTLCSwapMsg(self.chainType!,
                                                              self.mHtlcToChain!,
                                                              self.account!,
                                                              self.mHtlcToAccount!,
                                                              self.mHtlcToSendAmount,
                                                              self.mTimeStamp!,
                                                              self.mRandomNumberHash!,
                                                              PrivateKey.init(pk: privateKey!.hexEncodedString(), coin: .bitcoin)!)
            DispatchQueue.main.async(execute: {
                do {
                    var encoding: ParameterEncoding = URLEncoding.default
                    encoding = HexEncoding(data: try bnbMsg.encode())
                    let param: Parameters = [ "address" : self.account!.account_address ]
                    let request = Alamofire.request(BaseNetWork.broadcastUrl(self.chainType), method: .post, parameters: param, encoding: encoding, headers: [:])
                    request.responseJSON { response in
                        switch response.result {
                        case .success(let res):
                            if let result = res as? Array<NSDictionary> {
                                self.mSendHash = result[0].object(forKey:"hash") as? String
                            }
                            DispatchQueue.main.async(execute: {
                                self.onFetchSwapId()
                            });

                        case .failure(let error):
                            self.onUpdateView(error.localizedDescription)
                        }
                    }

                } catch {
                    print(error)
                    self.onUpdateView(error.localizedDescription)
                }
            });
        }
    }
    
    func onCheckCreateHtlcSwapKava() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = self.account!.account_address }
                let response = try Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait()
                self.onCreateHtlcSwapKava(response)
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
                DispatchQueue.main.async(execute: {
                    self.onUpdateView(error.localizedDescription)
                    self.onShowToast(error.localizedDescription)
                });
            }
        }
    }
    
    func onCreateHtlcSwapKava(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
        DispatchQueue.global().async {
            var privateKey: Data?
            var publicKey: Data?
            if (self.account!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.account!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    privateKey = KeyFac.getPrivateRaw(words, self.account!)
                    publicKey = KeyFac.getPublicFromPrivateKey(privateKey!)
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.account!.getPrivateKeySha1()) {
                    privateKey = KeyFac.getPrivateFromString(key)
                    publicKey = KeyFac.getPublicFromPrivateKey(privateKey!)
                }
            }
            self.mTimeStamp = Date().millisecondsSince1970 / 1000
            self.mRandomNumber = WKey.generateRandomBytes()
            self.mRandomNumberHash = WKey.getRandomNumnerHash(self.mRandomNumber!, self.mTimeStamp!)
            
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let reqTx = Signer.genSignedKavaCreateHTLCSwap(auth!, self.account!.account_pubkey_type,
                                                               self.account!.account_address,
                                                               self.mHtlcToAccount!.account_address,
                                                               self.mHtlcToSendAmount,
                                                               self.mTimeStamp!,
                                                               self.mRandomNumberHash!,
                                                               self.mHtlcSendFee!,
                                                               SWAP_MEMO_CREATE,
                                                               privateKey!, publicKey!,
                                                               self.chainType!)
                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx).response.wait()
                DispatchQueue.main.async(execute: {
                    self.mSendHash = response.txResponse.txhash
                    DispatchQueue.main.async(execute: {
                        self.onFetchSwapId()
                    });
                });
            } catch {
                print("onCreateHtlcSwapKava failed: \(error)")
                DispatchQueue.main.async(execute: {
                    self.onUpdateView(error.localizedDescription)
                });
            }
        }
    }
    
    
    
    var mSwapFetchCnt = 15
    func onFetchSwapId() {
        onUpdateProgress(1)
        let swapId = WKey.getSwapId(self.mHtlcToChain!, self.mHtlcToSendAmount, self.mRandomNumberHash!, self.account!.account_address)
        let url = BaseNetWork.swapIdBep3Url(self.mHtlcToChain, swapId)
        let request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                self.mSwapFetchCnt = self.mSwapFetchCnt - 1
                guard let info = res as? [String : Any], info["error"] == nil else {
                    if (self.mSwapFetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.onFetchSwapId()
                        })
                    } else {
                        self.onShowMoreSwapWait()
                    }
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                    self.onCheckClaimHtlcSwap()
                })
            
            case .failure(let error):
                print("onFetchSwapId failure", error , " ", self.mSwapFetchCnt)
                self.mSwapFetchCnt = self.mSwapFetchCnt - 1
                if (self.mSwapFetchCnt > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.onFetchSwapId()
                    })
                } else {
                    self.onShowMoreSwapWait()
                }
            }
        }
    }
    
    func onCheckClaimHtlcSwap() {
        onUpdateProgress(2)
        if (self.mHtlcToChain == ChainType.BINANCE_MAIN) {
            self.onCheckClaimHtlcSwapBinance()
        } else {
            self.onCheckClaimHtlcSwapKava()
        }
    }
    
    func onCheckClaimHtlcSwapBinance() {
        let request = Alamofire.request(BaseNetWork.accountInfoUrl(mHtlcToChain, mHtlcToAccount!.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? [String : Any] else {
                    _ = BaseData.instance.deleteBalance(account: self.mHtlcToAccount!)
                    self.onUpdateView(NSLocalizedString("error_network", comment: ""))
                    return
                }
                let bnbAccountInfo = BnbAccountInfo.init(info)
                _ = BaseData.instance.updateAccount(WUtils.getAccountWithBnbAccountInfo(self.mHtlcToAccount!, bnbAccountInfo))
                BaseData.instance.updateBalances(self.mHtlcToAccount!.account_id, WUtils.getBalancesWithBnbAccountInfo(self.mHtlcToAccount!, bnbAccountInfo))
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000), execute: {
                    self.onClaimHtlcSwapBinance()
                })

            case .failure(let error):
                self.onUpdateView(error.localizedDescription)
                self.onShowToast(error.localizedDescription)
            }
        }
    }
    
    func onClaimHtlcSwapBinance() {
        DispatchQueue.global().async {
            let group = DispatchGroup()
            var mHtlcToChainId = ""
            let request = Alamofire.request(BaseNetWork.nodeInfoUrl(self.mHtlcToChain), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
            group.enter()
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    guard let responseData = res as? NSDictionary, let nodeInfo = responseData.object(forKey: "node_info") as? NSDictionary else {
                        return
                    }
                    mHtlcToChainId = NodeInfo.init(nodeInfo).network!
                    
                case .failure(let error):
                    print("Htlc Claim node info ", error)
                }
                group.leave()
            }
            group.wait()
            
            var privateKey: Data?
            if (self.mHtlcToAccount!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.mHtlcToAccount!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    privateKey = KeyFac.getPrivateRaw(words, self.mHtlcToAccount!)
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.mHtlcToAccount!.getPrivateKeySha1()) {
                    privateKey = KeyFac.getPrivateFromString(key)
                }
            }
            
            let swapId = WKey.getSwapId(self.mHtlcToChain!, self.mHtlcToSendAmount, self.mRandomNumberHash!, self.account!.account_address)
            let bnbMsg = MsgGenerator.genBnbClaimHTLCSwapMsg(self.mHtlcToAccount!,
                                                             self.mRandomNumber!,
                                                             swapId,
                                                             PrivateKey.init(pk: privateKey!.hexEncodedString(), coin: .bitcoin)!,
                                                             mHtlcToChainId)
            
            DispatchQueue.main.async(execute: {
                do {
                    var encoding: ParameterEncoding = URLEncoding.default
                    encoding = HexEncoding(data: try bnbMsg.encode())
                    let request = Alamofire.request(BaseNetWork.broadcastUrl(self.mHtlcToChain), method: .post, parameters: [:], encoding: encoding, headers: [:])
                    request.responseJSON { response in
                        switch response.result {
                        case .success(let res):
                            if let result = res as? Array<NSDictionary> {
                                self.mClaimHash = result[0].object(forKey:"hash") as? String
                                DispatchQueue.main.async(execute: {
                                    self.onFetchSendTx()
                                    self.onFetchClaimTx()
                                });
                            }
                            
                        case .failure(let error):
                            self.onUpdateView(error.localizedDescription)
                        }
                    }
                    
                } catch {
                    print(error)
                    self.onUpdateView(error.localizedDescription)
                }
            });
        }
    }
    
    func onCheckClaimHtlcSwapKava() {
        DispatchQueue.global().async {
            do {
                let htlcToChainConfig = ChainKava(.KAVA_MAIN)
                let channel = BaseNetWork.getConnection(htlcToChainConfig)!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with {  $0.address = self.mHtlcToAccount!.account_address }
                let response = try Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait()
                self.onClaimHtlcSwapKava1(response)
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
                DispatchQueue.main.async(execute: {
                    self.onUpdateView(error.localizedDescription)
                    self.onShowToast(error.localizedDescription)
                });
            }
        }
    }
    
    func onClaimHtlcSwapKava1(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?) {
        DispatchQueue.global().async {
            do {
                let htlcToChainConfig = ChainKava(.KAVA_MAIN)
                let channel = BaseNetWork.getConnection(htlcToChainConfig)!
                let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest()
                if let response = try? Cosmos_Base_Tendermint_V1beta1_ServiceClient(channel: channel).getNodeInfo(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.onClaimHtlcSwapKava2(auth, response.defaultNodeInfo.network)
                    })
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCNodeInfo failed: \(error)")
            }
        }
        
    }
    
    func onClaimHtlcSwapKava2(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?, _ chainId: String) {
        DispatchQueue.global().async {
            var privateKey: Data?
            var publicKey: Data?
            if (self.mHtlcToAccount!.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: self.mHtlcToAccount!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    privateKey = KeyFac.getPrivateRaw(words, self.mHtlcToAccount!)
                    publicKey = KeyFac.getPublicFromPrivateKey(privateKey!)
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: self.mHtlcToAccount!.getPrivateKeySha1()) {
                    privateKey = KeyFac.getPrivateFromString(key)
                    publicKey = KeyFac.getPublicFromPrivateKey(privateKey!)
                }
            }
            
            do {
                let swapId = WKey.getSwapId(self.mHtlcToChain!, self.mHtlcToSendAmount, self.mRandomNumberHash!, self.account!.account_address)
                let htlcToChainConfig = ChainKava(.KAVA_MAIN)
                let channel = BaseNetWork.getConnection(htlcToChainConfig)!
                let reqTx = Signer.genSignedKavaClaimHTLCSwap(auth!, self.mHtlcToAccount!.account_pubkey_type,
                                                              self.mHtlcToAccount!.account_address,
                                                              swapId,
                                                              self.mRandomNumber!,
                                                              self.mHtlcClaimFee!,
                                                              SWAP_MEMO_CLAIM,
                                                              privateKey!, publicKey!,
                                                              chainId)
                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).broadcastTx(reqTx).response.wait()
                DispatchQueue.main.async(execute: {
                    self.mClaimHash = response.txResponse.txhash
                    self.onFetchSendTx()
                    self.onFetchClaimTx()
                });
                
            } catch {
                print("onClaimHtlcSwapKava2 failed: \(error)")
            }
        }
    }
    
    
    func onShowMoreSwapWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_swap_title", comment: ""), message: NSLocalizedString("more_wait_swap_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.mSwapFetchCnt = 15
            self.onFetchSwapId()
        }))
        self.present(noticeAlert, animated: true, completion: nil)
    }
    
    
    
    func onFetchSendTx() {
        if (self.chainType == ChainType.BINANCE_MAIN) {
            let request = Alamofire.request(BaseNetWork.txUrl(self.chainType, mSendHash!), method: .get, parameters: ["format":"json"], encoding: URLEncoding.default, headers: [:])
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    guard let info = res as? [String : Any], info["error"] == nil else {
                        self.onUpdateView(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    self.mSendTxInfo = TxInfo.init(info)
                    self.onUpdateView("")
                    
                case .failure(let error):
                    print("onFetchSendTx failure", error)
                    self.onUpdateView(error.localizedDescription)
                    return
                }
            }
            
            
        } else if (self.chainType == ChainType.KAVA_MAIN) {
            DispatchQueue.global().async {
                do {
                    let htlcToChainConfig = ChainKava(.KAVA_MAIN)
                    let channel = BaseNetWork.getConnection(htlcToChainConfig)!
                    let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = self.mSendHash! }
                    self.mSendTxInfogRPC = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).getTx(req).response.wait()
                    DispatchQueue.main.async(execute: { self.onUpdateView("") });
                    
                } catch {
                    print("onFetchSendTx failure", error)
                    DispatchQueue.main.async(execute: { self.onUpdateView(error.localizedDescription) });
                }
            }
        }
    }
    
    var mClaimTxFetchCnt = 15
    func onFetchClaimTx() {
        onUpdateProgress(3)
        if (self.mHtlcToChain == ChainType.BINANCE_MAIN) {
            let request = Alamofire.request(BaseNetWork.txUrl(self.mHtlcToChain, mClaimHash!), method: .get, parameters: ["format":"json"], encoding: URLEncoding.default, headers: [:])
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    self.mClaimTxFetchCnt = self.mClaimTxFetchCnt - 1
                    guard let info = res as? [String : Any], info["error"] == nil else {
                        if (self.mClaimTxFetchCnt > 0) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                                self.onFetchClaimTx()
                            })
                        }
                        return
                    }
                    self.mClaimTxInfo = TxInfo.init(info)
                    self.onUpdateView("")
                    
                case .failure(let error):
                    self.mClaimTxFetchCnt = self.mClaimTxFetchCnt - 1
                    if (self.mClaimTxFetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.onFetchClaimTx()
                        })
                    } else {
                        self.onUpdateView(error.localizedDescription)
                    }
                    print("onFetchClaimTx failure", error)
                    return
                }
            }
            
            
        } else if (self.mHtlcToChain == ChainType.KAVA_MAIN) {
            DispatchQueue.global().async {
                do {
                    let htlcToChainConfig = ChainKava(.KAVA_MAIN)
                    let channel = BaseNetWork.getConnection(htlcToChainConfig)!
                    let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = self.mClaimHash! }
                    self.mClaimTxInfogRPC = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).getTx(req).response.wait()
                    DispatchQueue.main.async(execute: { self.onUpdateView("") });
                    
                } catch {
                    print("onFetchClaimTx failure", error)
                    self.mClaimTxFetchCnt = self.mClaimTxFetchCnt - 1
                    if (self.mClaimTxFetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.onFetchClaimTx()
                        })
                    } else {
                        DispatchQueue.main.async(execute: { self.onUpdateView(error.localizedDescription) });
                    }
                }
            }
        }
        
    }
}
