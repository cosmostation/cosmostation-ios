//
//  TxDetailViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/02/12.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

class TxDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txTableView: UITableView!
    @IBOutlet weak var controlLayer: UIStackView!
    @IBOutlet weak var errorLayer: CardView!
    @IBOutlet weak var errorCode: UILabel!
    @IBOutlet weak var loadingLayer: UIView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var loadingMsg: UILabel!
    @IBOutlet weak var txDetailTitle: UILabel!
    @IBOutlet weak var btnshare: UIButton!
    @IBOutlet weak var btnexplorer: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    var mIsGen: Bool = false
    var mTxHash: String?
    var mTxInfo: TxInfo?
    var mBnbTime: String?
    var mBroadCaseResult: [String:Any]?
    var mFetchCnt = 10
    var mAllValidator = Array<Validator>()
    
    var mBnbNodeInfo: BnbNodeInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.mAllValidator = BaseData.instance.mAllValidator
        
        self.txDetailTitle.text = NSLocalizedString("str_tx_detail", comment: "")
        self.txDetailTitle.text = NSLocalizedString("str_tx_detail", comment: "")
        self.btnshare.setTitle(NSLocalizedString("str_share", comment: ""), for: .normal)
        self.btnexplorer.setTitle(NSLocalizedString("str_explorer", comment: ""), for: .normal)
        self.btnDone.setTitle(NSLocalizedString("str_done", comment: ""), for: .normal)

        
        self.txTableView.delegate = self
        self.txTableView.dataSource = self
        self.txTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.txTableView.register(UINib(nibName: "TxCommonCell", bundle: nil), forCellReuseIdentifier: "TxCommonCell")
        self.txTableView.register(UINib(nibName: "TxTransferCell", bundle: nil), forCellReuseIdentifier: "TxTransferCell")
        self.txTableView.register(UINib(nibName: "TxMultiTransferCell", bundle: nil), forCellReuseIdentifier: "TxMultiTransferCell")
        
        self.txTableView.register(UINib(nibName: "TxOkStakeCell", bundle: nil), forCellReuseIdentifier: "TxOkStakeCell")
        self.txTableView.register(UINib(nibName: "TxOkDirectVoteCell", bundle: nil), forCellReuseIdentifier: "TxOkDirectVoteCell")
        
        self.txTableView.register(UINib(nibName: "TxUnknownCell", bundle: nil), forCellReuseIdentifier: "TxUnknownCell")
        self.txTableView.rowHeight = UITableView.automaticDimension
        self.txTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if (mIsGen) {
            self.loadingMsg.isHidden = false
            self.loadingImg.onStartAnimation()
            if (chainType == ChainType.BINANCE_MAIN) {
                guard let txHash = mBroadCaseResult?["hash"] as? String  else {
                    self.onStartMainTab()
                    return
                }
                mTxHash = txHash
            } else {
                guard let txHash = mBroadCaseResult?["txhash"] as? String  else {
                    self.onStartMainTab()
                    return
                }
                mTxHash = txHash
                if let code = mBroadCaseResult?["code"] as? Int {
                    onShowErrorView(code)
                    return
                }
            }
            self.onFetchTx(mTxHash!)

        } else {
            //TODO TEST HASH for KAVA 
//            mTxHash = "96C56A5DC1C922CB18945C2EF6735F5A2E815A7A3B2932ECC627ED37DCC6102C"
//            self.loadingMsg.isHidden = true
//            self.loadingImg.onStartAnimation()
//            self.onFetchTx(mTxHash!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func onShowErrorView(_ code: Int) {
        var logMsg = ""
        if let errorMsg = mBroadCaseResult?["raw_log"] as? String {
            logMsg = errorMsg;
        }
        if let check_tx = mBroadCaseResult?["check_tx"] as? [String : Any], let errorMsg = check_tx["log"] as? String {
            logMsg = errorMsg;
        }
        self.errorCode.text =  "error code : " + String(code) + "\n" + logMsg
        self.loadingLayer.isHidden = true
        self.errorLayer.isHidden = false
    }
    
    func onUpdateView() {
        self.loadingLayer.isHidden = true
        self.controlLayer.isHidden = false
        self.txTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mTxInfo != nil) {
            return mTxInfo!.getMsgs().count  + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return onBindTxCommon(tableView)
        } else {
            guard let msg = mTxInfo?.getMsg(indexPath.row - 1) else {
                return onBindUnknown(tableView, indexPath.row)
            }
            if (msg.type.contains("Send") || msg.type.contains("MsgSend") || msg.type.contains("MsgMultiSend") ||
                msg.type.contains("MsgTransfer") || msg.type.contains("MsgMultiTransfer")) {
                if ((msg.value.inputs != nil && (msg.value.inputs!.count) > 1) ||  (msg.value.outputs != nil && (msg.value.outputs!.count) > 1)) {
                    //No case yet!
                    return onBindMultiTransfer(tableView, indexPath.row)
                } else {
                    return onBindTransfer(tableView, indexPath.row)
                }
            }
            else if (msg.type == "okexchain/staking/MsgDeposit" || msg.type == "okexchain/staking/MsgWithdraw") {
                return onBindOkStake(tableView, indexPath.row)
                
            } else if (msg.type == "okexchain/staking/MsgAddShares") {
                return onBindOkDirectVote(tableView, indexPath.row)
                
            } else {
                return onBindUnknown(tableView, indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func onBindTxCommon(_ tableView: UITableView) -> UITableViewCell {
        let cell:TxCommonCell? = tableView.dequeueReusableCell(withIdentifier:"TxCommonCell") as? TxCommonCell
        cell?.setDenomType(chainConfig!)
        if (chainType == ChainType.BINANCE_MAIN) {
            cell?.feeLayer.isHidden = false
            cell?.statusImg.image = UIImage(named: "successIc")
            cell?.statusLabel.text = NSLocalizedString("tx_success", comment: "")
            cell?.errorMsg.isHidden = true
            cell?.errorConstraint.priority = .defaultLow
            cell?.successConstraint.priority = .defaultHigh
            
            cell?.heightLabel.text = mTxInfo!.height
            cell?.msgCntLabel.text = String(mTxInfo!.getMsgs().count)
            cell?.gasAmountLabel.text = "-"
            cell?.timeLabel.text = WDP.dpTime(mBnbTime)
            cell?.timeGapLabel.text = WDP.dpTimeGap(mBnbTime)
            cell?.hashLabel.text = mTxInfo!.hash
            cell?.memoLabel.text = mTxInfo!.tx?.value.memo
            cell?.feeAmountLabel.attributedText = WDP.dpAmount(FEE_BINANCE_BASE, cell!.feeAmountLabel.font!, 0, 8)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            cell?.feeLayer.isHidden = false
            if (mTxInfo!.isSuccess()) {
                cell?.statusImg.image = UIImage(named: "successIc")
                cell?.statusLabel.text = NSLocalizedString("tx_success", comment: "")
                cell?.errorMsg.isHidden = true
                cell?.errorConstraint.priority = .defaultLow
                cell?.successConstraint.priority = .defaultHigh
            } else {
                cell?.statusImg.image = UIImage(named: "failIc")
                cell?.statusLabel.text = NSLocalizedString("tx_fail", comment: "")
                cell?.errorMsg.text = mTxInfo?.failMsg()
                cell?.errorMsg.isHidden = false
                cell?.errorConstraint.priority = .defaultHigh
                cell?.successConstraint.priority = .defaultLow
            }
            cell?.heightLabel.text = mTxInfo!.height
            cell?.msgCntLabel.text = String(mTxInfo!.getMsgs().count)
            cell?.gasAmountLabel.text = mTxInfo!.gas_used! + " / " + mTxInfo!.gas_wanted!
            cell?.timeLabel.text = WDP.dpTime(mTxInfo?.timestamp)
            cell?.timeGapLabel.text = WDP.dpTimeGap(mTxInfo?.timestamp)
            cell?.hashLabel.text = mTxInfo!.txhash
            cell?.memoLabel.text = mTxInfo!.tx?.value.memo
            cell?.feeAmountLabel.attributedText = WDP.dpAmount(mTxInfo?.simpleFee().stringValue, cell!.feeAmountLabel.font!, 0, 8)
            
        } else {
            cell?.feeLayer.isHidden = false
            if (mTxInfo!.isSuccess()) {
                cell?.statusImg.image = UIImage(named: "successIc")
                cell?.statusLabel.text = NSLocalizedString("tx_success", comment: "")
                cell?.errorMsg.isHidden = true
                cell?.errorConstraint.priority = .defaultLow
                cell?.successConstraint.priority = .defaultHigh
            } else {
                cell?.statusImg.image = UIImage(named: "failIc")
                cell?.statusLabel.text = NSLocalizedString("tx_fail", comment: "")
                if let bool = mTxInfo?.failMsg().starts(with: "atomic swap not found"), bool {
                    cell?.errorMsg.text = "atomic swap not found"
                } else {
                    cell?.errorMsg.text = mTxInfo?.failMsg()
                }
                cell?.errorMsg.isHidden = false
                cell?.errorConstraint.priority = .defaultHigh
                cell?.successConstraint.priority = .defaultLow
            }
            cell?.heightLabel.text = mTxInfo!.height
            cell?.msgCntLabel.text = String(mTxInfo!.getMsgs().count)
            cell?.gasAmountLabel.text = mTxInfo!.gas_used! + " / " + mTxInfo!.gas_wanted!
            cell?.timeLabel.text = WDP.dpTime(mTxInfo?.timestamp)
            cell?.timeGapLabel.text = WDP.dpTimeGap(mTxInfo?.timestamp)
            cell?.hashLabel.text = mTxInfo!.txhash
            cell?.memoLabel.text = mTxInfo!.tx?.value.memo
            cell?.feeAmountLabel.attributedText = WDP.dpAmount(mTxInfo?.simpleFee().stringValue, cell!.feeAmountLabel.font!, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
            
        }
//        cell?.actionHashCheck = {
//            self.onClickExplorer()
//        }
        
        return cell!
    }
    
    func onBindTransfer(_ tableView: UITableView,  _ position:Int) -> UITableViewCell  {
        let cell:TxTransferCell? = tableView.dequeueReusableCell(withIdentifier:"TxTransferCell") as? TxTransferCell
        let msg = mTxInfo?.getMsg(position - 1)
        cell?.txIcon.image = cell?.txIcon.image?.withRenderingMode(.alwaysTemplate)
        cell?.txIcon.tintColor = chainConfig?.chainColor
        if (chainType == ChainType.BINANCE_MAIN) {
            cell?.fromLabel.text = msg?.value.inputs![0].address
            cell?.toLabel.text = msg?.value.outputs![0].address
            if (self.account?.account_address == msg?.value.inputs![0].address) {
                cell?.txTitleLabel.text = NSLocalizedString("tx_send", comment: "")
            } else if (self.account?.account_address == msg?.value.outputs![0].address) {
                cell?.txTitleLabel.text = NSLocalizedString("tx_receive", comment: "")
            }
            let coins = msg?.value.inputs?[0].coins
            cell?.multiAmountStack.isHidden = false
            cell?.multiAmountLayer0.isHidden = false
            WDP.dpBnbTxCoin(chainConfig!, coins![0], cell!.multiAmountDenom0, cell!.multiAmount0)
            
        } else if (chainType == ChainType.OKEX_MAIN) {
            var coins = msg?.value.getAmounts()
            let convertFromAddress = WKey.convertBech32ToEvm(msg?.value.from_address ?? "")
            let convertToAddress = WKey.convertBech32ToEvm(msg?.value.to_address ?? "")
            
            cell?.fromLabel.text = convertFromAddress
            cell?.toLabel.text = convertToAddress
            
            if (self.account?.account_address == convertFromAddress) {
                cell?.txTitleLabel.text = NSLocalizedString("tx_send", comment: "")
            } else if (self.account?.account_address == convertToAddress) {
                cell?.txTitleLabel.text = NSLocalizedString("tx_receive", comment: "")
            }
            
            coins = sortCoins(coins!, chainType!)
            cell?.multiAmountStack.isHidden = false
            cell?.multiAmountLayer0.isHidden = false
            WDP.dpCoin(chainConfig, coins![0], cell!.multiAmountDenom0, cell!.multiAmount0)
        }
        return cell!
    }
    
    func onBindMultiTransfer(_ tableView: UITableView,  _ position:Int) -> UITableViewCell  {
        let cell:TxMultiTransferCell? = tableView.dequeueReusableCell(withIdentifier:"TxMultiTransferCell") as? TxMultiTransferCell
        return cell!
    }
    
    func onBindOkStake(_ tableView: UITableView, _ position:Int) -> UITableViewCell  {
        let cell:TxOkStakeCell? = tableView.dequeueReusableCell(withIdentifier:"TxOkStakeCell") as? TxOkStakeCell
        let msg = mTxInfo?.getMsg(position - 1)
        if (msg?.type == "okexchain/staking/MsgDeposit") {
            cell?.txIcon.image = UIImage(named: "msgIconCDP")
            cell?.txLabel.text = NSLocalizedString("title_ok_deposit", comment: "")
        } else {
            cell?.txIcon.image = UIImage(named: "msgIconCDP")
            cell?.txLabel.text = NSLocalizedString("title_ok_withdraw", comment: "")
        }
        cell?.txIcon.image = cell?.txIcon.image?.withRenderingMode(.alwaysTemplate)
        cell?.txIcon.tintColor = chainConfig?.chainColor
        
        let convertDelegaterAddress = WKey.convertBech32ToEvm(msg?.value.delegator_address ?? "")
        cell?.delegatorLabel.text = convertDelegaterAddress
        WDP.dpCoin(chainConfig, msg!.value.quantity!, cell!.stakeDenom, cell!.stakeAmount)
        return cell!
    }
    
    func onBindOkDirectVote(_ tableView: UITableView, _ position:Int) -> UITableViewCell {
        let cell:TxOkDirectVoteCell? = tableView.dequeueReusableCell(withIdentifier:"TxOkDirectVoteCell") as? TxOkDirectVoteCell
        let msg = mTxInfo?.getMsg(position - 1)
        cell?.txIcon.image = cell?.txIcon.image?.withRenderingMode(.alwaysTemplate)
        cell?.txIcon.tintColor = chainConfig?.chainColor
        
        let convertDelegaterAddress = WKey.convertBech32ToEvm(msg?.value.delegator_address ?? "")
        cell?.voterLabel.text = convertDelegaterAddress
        
        var monikers = ""
        let validators = msg?.value.validator_addresses
        for validator in validators! {
            for allVal in BaseData.instance.mAllValidator {
                if (allVal.operator_address == validator) {
                    monikers = monikers + allVal.description.moniker + ", "
                }
            }
        }
        cell?.validatorList.text = monikers
        return cell!
    }
    
    
    
    func onBindUnknown(_ tableView: UITableView, _ position:Int) -> UITableViewCell  {
        let cell:TxUnknownCell? = tableView.dequeueReusableCell(withIdentifier:"TxUnknownCell") as? TxUnknownCell
        cell?.txIcon.image = cell?.txIcon.image?.withRenderingMode(.alwaysTemplate)
        cell?.txIcon.tintColor = chainConfig?.chainColor
        return cell!
    }
    
    
    @IBAction func onClickShare(_ sender: UIButton) {
        var hash = ""
        if (mTxInfo?.hash != nil) {
            hash = mTxInfo!.hash!
        } else if (mTxInfo?.txhash != nil) {
            hash = mTxInfo!.txhash!
        }
        let link = WUtils.getTxExplorer(chainConfig, hash)
        let textToShare = [ link ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        var hash = ""
        if (mTxInfo?.hash != nil) {
            hash = mTxInfo!.hash!
        } else if (mTxInfo?.txhash != nil) {
            hash = mTxInfo!.txhash!
        }
        let link = WUtils.getTxExplorer(chainConfig, hash)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.mFetchCnt = -1
        if (mIsGen){
            self.onStartMainTab()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onShowMoreWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.mFetchCnt = 10
            self.onFetchTx(self.mTxHash!)
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    
    func onFetchTx(_ txHash: String) {
        let url = BaseNetWork.txUrl(chainType, txHash)
        var request:DataRequest?
        if (self.chainType! == ChainType.BINANCE_MAIN) {
            request = Alamofire.request(url, method: .get, parameters: ["format":"json"], encoding: URLEncoding.default, headers: [:])
        } else {
            request = Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        }
        request!.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? [String : Any], info["error"] == nil else {
                    if (self.mIsGen) {
                        self.mFetchCnt = self.mFetchCnt - 1
                        if (self.mFetchCnt > 0) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                                self.onFetchTx(txHash)
                            })
                        } else {
                            self.onShowMoreWait()
                        }
                    } else {
                        self.onUpdateView()
                    }
                    return
                }
                self.mTxInfo = TxInfo.init(info)
                self.onUpdateView()
                
            case .failure(let error):
                print("onFetchTx failure", error)
                if (self.chainType! == ChainType.IRIS_MAIN) {
                    self.mFetchCnt = self.mFetchCnt - 1
                    if(self.mFetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.onFetchTx(txHash)
                        })
                    } else {
                        self.onShowMoreWait()
                    }
                } else if (self.chainType! == ChainType.BINANCE_MAIN) {
                    if (self.mIsGen) {
                        self.mFetchCnt = self.mFetchCnt - 1
                        if (self.mFetchCnt > 0) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                                self.onFetchTx(txHash)
                            })
                        } else {
                            self.onShowMoreWait()
                        }
                        
                    } else {
                        self.onUpdateView()
                    }
                }
                return
            }
            
        }
        
    }
    
    func onFetchBnbNodeInfo() {
        let request = Alamofire.request(BaseNetWork.nodeInfoUrl(self.chainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
//                if(SHOW_LOG) { print("onFetchBnbNodeInfo ", res) }
                if let info = res as? [String : Any] {
                    self.mBnbNodeInfo = BnbNodeInfo.init(info)
                }
                
            case .failure(let error):
                print("onFetchBnbNodeInfo", error)
                return
            }
            self.onUpdateView()
        }
    }
    
    
    
    
    
    func sortCoins(_ coins:Array<Coin>, _ chain:ChainType) -> Array<Coin> {
        if (chainType! == ChainType.OKEX_MAIN) {
            return coins.sorted(by: {
                if ($0.denom == OKT_MAIN_DENOM) {
                    return true
                }
                if ($1.denom == OKT_MAIN_DENOM) {
                    return false
                }
                if ($0.denom == OKT_OKB) {
                    return true
                }
                if ($1.denom == OKT_OKB) {
                    return false
                }
                return false
            })
        }
        return coins
    }
}
