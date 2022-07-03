//
//  FeeGrpcViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/26.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import HDWalletKit
import GRPC
import NIO

class FeeGrpcViewController: BaseViewController, SBCardPopupDelegate {

    @IBOutlet weak var feeTotalCard: CardView!
    @IBOutlet weak var feeTotalAmount: UILabel!
    @IBOutlet weak var feeTotalDenom: UILabel!
    @IBOutlet weak var feeTotalValue: UILabel!
    @IBOutlet weak var feeTypeCard: CardView!
    @IBOutlet weak var feeTypeImg: UIImageView!
    @IBOutlet weak var feeTypeDenom: UILabel!
    
    @IBOutlet weak var gasDetailCard: CardView!
    @IBOutlet weak var gasAmountLabel: UILabel!
    @IBOutlet weak var gasRateLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var gasSelectSegments: UISegmentedControl!
    
    @IBOutlet weak var btnGasCheck: UIButton!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mSelectedGasRate = NSDecimalNumber.zero
    var mEstimateGasAmount = NSDecimalNumber.zero
    var mFee = NSDecimalNumber.zero
    var mDpDecimal:Int16 = 6
    var mSimulPassed = false
    
    var mFeeInfo = Array<FeeInfo>()
    var mSelectedFeeInfo = 1
    var mFeeData: FeeData!
    var mSelectedFeeData = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.mFeeInfo = WUtils.getFeeInfos(chainConfig)
        print("mFeeInfo ", mFeeInfo)
        
        gasSelectSegments.removeAllSegments()
        for i in 0..<mFeeInfo.count {
            gasSelectSegments.insertSegment(withTitle: mFeeInfo[i].title, at: i, animated: false)
        }
        if #available(iOS 13.0, *) {
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            gasSelectSegments.selectedSegmentTintColor = chainConfig?.chainColor
        } else {
            gasSelectSegments.tintColor = chainConfig?.chainColor
        }
        mSelectedFeeInfo = chainConfig!.getGasDefault()
        gasSelectSegments.selectedSegmentIndex = mSelectedFeeInfo
        
        
        
        self.feeTypeCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickFeeDenom (_:))))
//
        
//        gasSelectSegments.segmentIndex(identifiedBy: <#T##UIAction.Identifier#>)
        
//        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
//        WUtils.setGasDenomTitle(chainType, feeTotalDenom)
//        mDpDecimal = WUtils.mainDivideDecimal(chainType)
//
//        if (chainType == .SIF_MAIN) {
//            gasDetailCard.isHidden = true
//        }
//
//        mEstimateGasAmount = WUtils.getEstimateGasAmount(chainType!, pageHolderVC.mType!, pageHolderVC.mRewardTargetValidators_gRPC.count)
//        onUpdateView()
    }
    
    @objc func onClickFeeDenom (_ onClickDenom: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_FEE_DENOM
        
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        print("SBCardPopupResponse ", result)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        print("automatic gas amount check")
//        self.mSimulPassed = false
//        if (!BaseData.instance.getUsingEnginerMode()) {
//            self.onSetFee()
//            self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
//        }
//    }
    
    func onCalculateFees() {
//        mSelectedGasRate = WUtils.getGasRate(chainType!, mSelectedGasPosition)
//        if (chainType == .SIF_MAIN) {
//            mFee = NSDecimalNumber.init(string: "100000000000000000")
//        } else {
//            mFee = mSelectedGasRate.multiplying(by: mEstimateGasAmount, withBehavior: WUtils.handler0Up)
//        }
//        print("mSelectedGasRate ", mSelectedGasRate)
//        print("mEstimateGasAmount ", mEstimateGasAmount)
//        print("mFee ", mFee)
    }
    
    func onUpdateView() {
        let selectedFeeInfo = mFeeInfo[mSelectedFeeInfo]
        self.mFeeData = selectedFeeInfo.FeeDatas[mSelectedFeeData]
        print("mFeeData ", mFeeData)
        
//        onCalculateFees()
//
//        feeTotalAmount.attributedText = WUtils.displayAmount2(mFee.stringValue, feeTotalAmount.font!, mDpDecimal, mDpDecimal)
//        feeTotalValue.attributedText = WUtils.dpUserCurrencyValue(WUtils.getGasDenom(chainType), mFee, WUtils.mainDivideDecimal(chainType), feeTotalValue.font)
//
//        gasRateLabel.attributedText = WUtils.displayGasRate(mSelectedGasRate.rounding(accordingToBehavior: WUtils.handler6), font: gasRateLabel.font, 5)
//        gasAmountLabel.text = mEstimateGasAmount.stringValue
//        gasFeeLabel.text = mFee.stringValue
    }

    @IBAction func onSwitchGasRate(_ sender: UISegmentedControl) {
//        mSelectedGasPosition = sender.selectedSegmentIndex
//        onUpdateView()
    }
    
    override func enableUserInteraction() {
        btnBefore.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickCheckGas(_ sender: UIButton) {
//        self.onSetFee()
//        self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
//        if (!mSimulPassed) {
//            self.onShowToast(NSLocalizedString("error_simul_error", comment: ""))
//            return
//        }
//
//        onSetFee()
//        btnBefore.isUserInteractionEnabled = false
//        btnNext.isUserInteractionEnabled = false
//        pageHolderVC.onNextPage()
    }
    
    func onSetFee() {
//        let gasCoin = Coin.init(WUtils.getGasDenom(chainType), mFee.stringValue)
//        var amount: Array<Coin> = Array<Coin>()
//        amount.append(gasCoin)
//
//        var fee = Fee.init()
//        fee.amount = amount
//        fee.gas = mEstimateGasAmount.stringValue
//
//        pageHolderVC.mFee = fee
    }
    
    func onCheckValidate() -> Bool {
        return true
    }
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait() {
                    if (self.pageHolderVC.mType == TASK_TYPE_IBC_TRANSFER) {
                        self.onFetchIbcClientState(response)
                    } else {
                        self.onSimulateGrpcTx(response, nil)
                    }
                }
                try channel.close().wait()
            } catch {
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onFetchIbcClientState(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
                    $0.channelID = self.pageHolderVC.mIBCSendPath!.channel_id!
                    $0.portID = self.pageHolderVC.mIBCSendPath!.port_id!
                }
                if let response = try? Ibc_Core_Channel_V1_QueryClient(channel: channel).channelClientState(req).response.wait() {
                    let clientState = try! Ibc_Lightclients_Tendermint_V1_ClientState.init(serializedData: response.identifiedClientState.clientState.value)
                    self.onSimulateGrpcTx(auth, clientState.latestHeight)
                }
                try channel.close().wait()
            } catch {
                print("onFetchIbcClientState failed: \(error)")
            }
        }
    }
    
    func onSimulateGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?, _ height: Ibc_Core_Client_V1_Height?) {
        DispatchQueue.global().async {
            let simulateReq = self.genSimulateReq(auth!, self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, height)
            
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).simulate(simulateReq!).response.wait()
//                print("response ", response.gasInfo)
                DispatchQueue.main.async(execute: {
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.mEstimateGasAmount = NSDecimalNumber.init(value: response.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 1.1), withBehavior: WUtils.handler0Up)
                            self.mSimulPassed = true
                            self.onUpdateView()
                        })
                    }
                });
            } catch {
                DispatchQueue.main.async(execute: {
                    print("onSimulateGrpcTx failed: \(error)")
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.mSimulPassed = false
                            self.onShowToast(NSLocalizedString("error_network", comment: "") + "\n" + "\(error)")
                        })
                    }
                });
            }
        }
    }
    
    func genSimulateReq(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ privateKey: Data, _ publicKey: Data, _ height: Ibc_Core_Client_V1_Height?)  -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if (pageHolderVC.mType == TASK_TYPE_TRANSFER) {
            return Signer.genSimulateSendTxgRPC(auth,
                                                self.pageHolderVC.mToSendRecipientAddress!, self.pageHolderVC.mToSendAmount,
                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_DELEGATE) {
            return Signer.genSimulateDelegateTxgRPC(auth,
                                                    self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_UNDELEGATE) {
            return Signer.genSimulateUnDelegateTxgRPC(auth,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToUndelegateAmount!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
                  
            
        } else if (pageHolderVC.mType == TASK_TYPE_REDELEGATE) {
            return Signer.genSimulateReDelegateTxgRPC(auth,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToReDelegateValidator_gRPC!.operatorAddress,
                                                      self.pageHolderVC.mToReDelegateAmount!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
            return Signer.genSimulateClaimRewardsTxgRPC(auth,
                                                        self.pageHolderVC.mRewardTargetValidators_gRPC,
                                                        self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                        privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_REINVEST) {
            return Signer.genSimulateReInvestTxgRPC(auth,
                                                    self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mReinvestReward!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
            return Signer.genSimulateetRewardAddressTxgRPC(auth,
                                                           self.pageHolderVC.mToChangeRewardAddress!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_VOTE) {
            return Signer.genSimulateVoteTxgRPC(auth,
                                                self.pageHolderVC.mProposeId!, self.pageHolderVC.mVoteOpinion!,
                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                privateKey, publicKey, self.chainType!)
            
        }
        
        //for starname custom msg
        else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
            return Signer.genSimulateRegisterDomainMsgTxgRPC(auth,
                                                             self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mStarnameDomainType!,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                             privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
            return Signer.genSimulateRegisterAccountMsgTxgRPC(auth,
                                                              self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mAccount!.account_address, self.pageHolderVC.mStarnameResources_gRPC,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
            return Signer.genSimulateDeleteDomainMsgTxgRPC (auth,
                                                            self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            return Signer.genSimulateDeleteAccountMsgTxgRPC (auth,
                                                             self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                             privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            return Signer.genSimulateRenewDomainMsgTxgRPC (auth,
                                                           self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            return Signer.genSimulateRenewAccountMsgTxgRPC (auth,
                                                            self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
            return Signer.genSimulateReplaceResourceMsgTxgRPC(auth,
                                                              self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mStarnameResources_gRPC,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
        }
        
        //for osmosis custom msg
        else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_SWAP) {
            var swapRoutes = Array<Osmosis_Gamm_V1beta1_SwapAmountInRoute>()
            let swapRoute = Osmosis_Gamm_V1beta1_SwapAmountInRoute.with {
                $0.poolID = self.pageHolderVC.mPool!.id
                $0.tokenOutDenom = self.pageHolderVC.mSwapOutDenom!
            }
            swapRoutes.append(swapRoute)
            return Signer.genSimulateSwapInMsgTxgRPC(auth, swapRoutes,
                                                     self.pageHolderVC.mSwapInDenom!,
                                                     self.pageHolderVC.mSwapInAmount!.stringValue,
                                                     self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
            return Signer.genSimulateDepositPoolMsgTxgRPC(auth,
                                                          self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                          self.pageHolderVC.mLPCoin!.amount,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
            return Signer.genSimulateWithdrawPoolMsgTxgRPC(auth,
                                                           self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                           self.pageHolderVC.mLPCoin!.amount,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_LOCK) {
            return Signer.genSimulateLockTokensMsgTxgRPC(auth,
                                                         self.pageHolderVC.mLPCoin!,
                                                         self.pageHolderVC.mLockupDuration!,
                                                         self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                         privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
            var ids = Array<UInt64>()
            for lockup in self.pageHolderVC.mLockups! {
                ids.append(lockup.id)
            }
            return Signer.genSimulateBeginUnlockingsMsgTxgRPC(auth,
                                                              ids,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
            
        }
        
        
        //for IBC Transfer or Cw20
        else if (pageHolderVC.mType == TASK_TYPE_IBC_TRANSFER) {
            return Signer.genSimulateIbcTransferMsgTxgRPC(auth,
                                                          self.pageHolderVC.mAccount!.account_address,
                                                          self.pageHolderVC.mIBCRecipient!,
                                                          self.pageHolderVC.mIBCSendDenom!,
                                                          self.pageHolderVC.mIBCSendAmount!,
                                                          self.pageHolderVC.mIBCSendPath!,
                                                          height!,
                                                          self.pageHolderVC.mFee!, IBC_TRANSFER_MEMO,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_IBC_CW20_TRANSFER) {
            return Signer.genSimulateCw20Send(auth,
                                              self.account!.account_address,
                                              self.pageHolderVC.mToSendRecipientAddress!,
                                              self.pageHolderVC.mCw20SendContract!,
                                              self.pageHolderVC.mToSendAmount,
                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                              privateKey, publicKey, self.chainType!)
            
        }
        
        else if (pageHolderVC.mType == TASK_TYPE_SIF_ADD_LP) {
            return Signer.genSimulateSifAddLpMsgTxgRPC(auth,
                                                       self.account!.account_address,
                                                       self.pageHolderVC.mPoolCoin0!.amount,
                                                       self.pageHolderVC.mPoolCoin1!.denom,
                                                       self.pageHolderVC.mPoolCoin1!.amount,
                                                       self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                       privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_SIF_REMOVE_LP) {
            var basisPoints = ""
            let myShareAllAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyAllUnitAmount)
            let myShareWithdrawAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyWithdrawUnitAmount)
            basisPoints = myShareWithdrawAmount.multiplying(byPowerOf10: 4).dividing(by: myShareAllAmount, withBehavior: WUtils.handler0).stringValue
            
            return Signer.genSimulateSifRemoveLpMsgTxgRPC(auth,
                                                          self.account!.account_address,
                                                          self.pageHolderVC.mSifPool!.externalAsset.symbol,
                                                          basisPoints,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_SIF_SWAP_CION) {
            return Signer.genSimulateSifSwapMsgTxgRPC(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mSwapInDenom!,
                                                      self.pageHolderVC.mSwapInAmount!.stringValue,
                                                      self.pageHolderVC.mSwapOutDenom!,
                                                      self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
        }
        
        //for NFT
        else if (pageHolderVC.mType == TASK_TYPE_NFT_ISSUE) {
            let stationData = StationNFTData.init(self.pageHolderVC.mNFTName!, self.pageHolderVC.mNFTDescription!, NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                  self.pageHolderVC.mNFTDenomId!, self.account!.account_address)
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(stationData)
            
            if (pageHolderVC.chainType == .IRIS_MAIN) {
                return Signer.genSimulateIssueNftIrisTxgRPC(auth,
                                                            self.account!.account_address,
                                                            self.pageHolderVC.mNFTDenomId!,
                                                            self.pageHolderVC.mNFTDenomName!,
                                                            self.pageHolderVC.mNFTHash!.lowercased(),
                                                            self.pageHolderVC.mNFTName!,
                                                            NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                            String(data: jsonData, encoding: .utf8)!,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                            self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                            self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftCroTxgRPC(auth,
                                                           self.account!.account_address,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.mNFTDenomName!,
                                                           self.pageHolderVC.mNFTHash!.lowercased(),
                                                           self.pageHolderVC.mNFTName!,
                                                           NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                           String(data: jsonData, encoding: .utf8)!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_NFT_SEND) {
            if (pageHolderVC.chainType == ChainType.IRIS_MAIN) {
                return Signer.genSimulateSendNftIrisTxgRPC(auth, self.account!.account_address,
                                                           self.pageHolderVC.mToSendRecipientAddress!,
                                                           self.pageHolderVC.mNFTTokenId!,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.irisResponse!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateSendNftCroTxgRPC(auth, self.account!.account_address,
                                                          self.pageHolderVC.mToSendRecipientAddress!,
                                                          self.pageHolderVC.mNFTTokenId!,
                                                          self.pageHolderVC.mNFTDenomId!,
                                                          self.pageHolderVC.croResponse!,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                          self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_NFT_ISSUE_DENOM) {
            if (pageHolderVC.chainType == .IRIS_MAIN) {
                return Signer.genSimulateIssueNftDenomIrisTxgRPC(auth, self.account!.account_address,
                                                                 self.pageHolderVC.mNFTDenomId!,
                                                                 self.pageHolderVC.mNFTDenomName!,
                                                                 self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                 self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftDenomCroTxgRPC(auth, self.account!.account_address,
                                                                self.pageHolderVC.mNFTDenomId!,
                                                                self.pageHolderVC.mNFTDenomName!,
                                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                                self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                self.chainType!)
            }
            
        }
        
        //for desmos
        else if (pageHolderVC.mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
            return Signer.genSimulateSaveProfileTxgRPC(auth,
                                                       self.pageHolderVC.mAccount!.account_address,
                                                       self.pageHolderVC.mDesmosDtag!,
                                                       self.pageHolderVC.mDesmosNickName!,
                                                       self.pageHolderVC.mDesmosBio!,
                                                       (self.pageHolderVC.mDesmosProfileHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosProfileHash!,
                                                       (self.pageHolderVC.mDesmosCoverHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosCoverHash!,
                                                       self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                       self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                       self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
            let toAccount = BaseData.instance.selectAccountById(id: self.pageHolderVC.mDesmosToLinkAccountId)!
            var toPrivateKey: Data!
            var toPublicKey: Data!
            if (toAccount.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: toAccount.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    toPrivateKey = KeyFac.getPrivateRaw(words, toAccount)
                    toPublicKey = KeyFac.getPublicFromPrivateKey(toPrivateKey)
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: toAccount.getPrivateKeySha1()) {
                    toPrivateKey = KeyFac.getPrivateFromString(key)
                    toPublicKey = KeyFac.getPublicFromPrivateKey(toPrivateKey)
                }
            }
            return Signer.genSimulateLinkChainTxgRPC(auth,
                                                     self.pageHolderVC.mAccount!.account_address,
                                                     self.pageHolderVC.mDesmosToLinkChain!,
                                                     toAccount,
                                                     toPrivateKey,
                                                     toPublicKey,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        }
        
        //for kava
        else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_CREATE) {
            return Signer.genSimulateKavaCDPCreate(auth,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mCollateral,
                                                   self.pageHolderVC.mPrincipal,
                                                   self.pageHolderVC.mCollateralParamType!,
                                                   self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
            return Signer.genSimulateKavaCDPDeposit(auth,
                                                    self.account!.account_address,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mCollateral,
                                                    self.pageHolderVC.mCollateralParamType!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
            return Signer.genSimulateKavaCDPWithdraw(auth,
                                                     self.account!.account_address,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mCollateral,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
            return Signer.genSimulateKavaCDPDrawDebt(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPrincipal,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_REPAY) {
            return Signer.genSimulateKavaCDPRepay(auth,
                                                  self.account!.account_address,
                                                  self.pageHolderVC.mPayment,
                                                  self.pageHolderVC.mCollateralParamType!,
                                                  self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                  self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                  self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
            return Signer.genSimulateKavaHardDeposit(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mHardPoolCoins!,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
               
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
            return Signer.genSimulateKavaHardWithdraw(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mHardPoolCoins!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
                
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_BORROW) {
            return Signer.genSimulateKavaHardBorrow(auth,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mHardPoolCoins!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
              
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_REPAY) {
            return Signer.genSimulateKavaHardRepay(auth,
                                                   self.account!.account_address,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mHardPoolCoins!,
                                                   self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
             
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
            let slippage = "30000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return Signer.genSimulateKavaSwapDeposit(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPoolCoin0!,
                                                     self.pageHolderVC.mPoolCoin1!,
                                                     slippage,
                                                     deadline,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
            let sharesOwned = NSDecimalNumber.init(string: pageHolderVC.mKavaSwapPoolDeposit?.sharesOwned)
            let depositRate = (pageHolderVC.mKavaShareAmount).dividing(by: sharesOwned, withBehavior: WUtils.handler18)
            let padding = NSDecimalNumber(string: "0.97")
            let sharesValue0 = NSDecimalNumber.init(string: pageHolderVC.mKavaSwapPoolDeposit?.sharesValue[0].amount)
            let sharesValue1 = NSDecimalNumber.init(string: pageHolderVC.mKavaSwapPoolDeposit?.sharesValue[1].amount)
            let coin0Amount = sharesValue0.multiplying(by: padding).multiplying(by: depositRate, withBehavior: WUtils.handler0)
            let coin1Amount = sharesValue1.multiplying(by: padding).multiplying(by: depositRate, withBehavior: WUtils.handler0)
            let coin0 = Coin.init(pageHolderVC.mKavaSwapPoolDeposit!.sharesValue[0].denom, coin0Amount.stringValue)
            let coin1 = Coin.init(pageHolderVC.mKavaSwapPoolDeposit!.sharesValue[1].denom, coin1Amount.stringValue)
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return Signer.genSimulateKavaSwapWithdraw(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mKavaShareAmount.stringValue,
                                                      coin0,
                                                      coin1,
                                                      deadline,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
            let inCoin = Coin.init(self.pageHolderVC.mSwapInDenom!, self.pageHolderVC.mSwapInAmount!.stringValue)
            let outCoin = Coin.init(self.pageHolderVC.mSwapOutDenom!, self.pageHolderVC.mSwapOutAmount!.stringValue)
            let slippage = "30000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return  Signer.genSimulateKavaSwapExactForTokens(auth,
                                                             self.account!.account_address,
                                                             inCoin,
                                                             outCoin,
                                                             slippage,
                                                             deadline,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                             self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                             self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
            return Signer.genSimulateKavaIncentiveAll(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mIncentiveMultiplier!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
        }
        
        return nil
    }
}

/*
class FeeGrpcViewController: BaseViewController {

    @IBOutlet weak var feeTotalCard: CardView!
    @IBOutlet weak var feeTotalAmount: UILabel!
    @IBOutlet weak var feeTotalDenom: UILabel!
    @IBOutlet weak var feeTotalValue: UILabel!
    
    @IBOutlet weak var gasDetailCard: CardView!
    @IBOutlet weak var gasAmountLabel: UILabel!
    @IBOutlet weak var gasRateLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var gasSelectSegments: UISegmentedControl!
    
    @IBOutlet weak var btnGasCheck: UIButton!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mSelectedGasPosition = 1
    var mSelectedGasRate = NSDecimalNumber.zero
    var mEstimateGasAmount = NSDecimalNumber.zero
    var mFee = NSDecimalNumber.zero
    var mDpDecimal:Int16 = 6
    var mSimulPassed = false
    
    var mFeeInfo = Array<FeeInfo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.mFeeInfo = WUtils.getFeeInfos(chainConfig)
        print("mFeeInfo ", mFeeInfo)
        
        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
        WUtils.setGasDenomTitle(chainType, feeTotalDenom)
        mDpDecimal = WUtils.mainDivideDecimal(chainType)
        if #available(iOS 13.0, *) {
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            gasSelectSegments.selectedSegmentTintColor = chainConfig?.chainColor
        } else {
            gasSelectSegments.tintColor = chainConfig?.chainColor
        }
        
        if (chainType == .SIF_MAIN) {
            gasDetailCard.isHidden = true
        }
        
        mEstimateGasAmount = WUtils.getEstimateGasAmount(chainType!, pageHolderVC.mType!, pageHolderVC.mRewardTargetValidators_gRPC.count)
        onUpdateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("automatic gas amount check")
        self.mSimulPassed = false
        if (!BaseData.instance.getUsingEnginerMode()) {
            self.onSetFee()
            self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
        }
    }
    
    func onCalculateFees() {
        mSelectedGasRate = WUtils.getGasRate(chainType!, mSelectedGasPosition)
        if (chainType == .SIF_MAIN) {
            mFee = NSDecimalNumber.init(string: "100000000000000000")
        } else {
            mFee = mSelectedGasRate.multiplying(by: mEstimateGasAmount, withBehavior: WUtils.handler0Up)
        }
//        print("mSelectedGasRate ", mSelectedGasRate)
//        print("mEstimateGasAmount ", mEstimateGasAmount)
//        print("mFee ", mFee)
    }
    
    func onUpdateView() {
        onCalculateFees()
        
        feeTotalAmount.attributedText = WUtils.displayAmount2(mFee.stringValue, feeTotalAmount.font!, mDpDecimal, mDpDecimal)
        feeTotalValue.attributedText = WUtils.dpUserCurrencyValue(WUtils.getGasDenom(chainType), mFee, WUtils.mainDivideDecimal(chainType), feeTotalValue.font)
        
        gasRateLabel.attributedText = WUtils.displayGasRate(mSelectedGasRate.rounding(accordingToBehavior: WUtils.handler6), font: gasRateLabel.font, 5)
        gasAmountLabel.text = mEstimateGasAmount.stringValue
        gasFeeLabel.text = mFee.stringValue
    }

    @IBAction func onSwitchGasRate(_ sender: UISegmentedControl) {
        mSelectedGasPosition = sender.selectedSegmentIndex
        onUpdateView()
    }
    
    override func enableUserInteraction() {
        btnBefore.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickCheckGas(_ sender: UIButton) {
        self.onSetFee()
        self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (!mSimulPassed) {
            self.onShowToast(NSLocalizedString("error_simul_error", comment: ""))
            return
        }
        
        onSetFee()
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
    
    func onSetFee() {
        let gasCoin = Coin.init(WUtils.getGasDenom(chainType), mFee.stringValue)
        var amount: Array<Coin> = Array<Coin>()
        amount.append(gasCoin)
        
        var fee = Fee.init()
        fee.amount = amount
        fee.gas = mEstimateGasAmount.stringValue
        
        pageHolderVC.mFee = fee
    }
    
    func onCheckValidate() -> Bool {
        return true
    }
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait() {
                    if (self.pageHolderVC.mType == TASK_TYPE_IBC_TRANSFER) {
                        self.onFetchIbcClientState(response)
                    } else {
                        self.onSimulateGrpcTx(response, nil)
                    }
                }
                try channel.close().wait()
            } catch {
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
                print("onFetchgRPCAuth failed: \(error)")
            }
        }
    }
    
    func onFetchIbcClientState(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
                    $0.channelID = self.pageHolderVC.mIBCSendPath!.channel_id!
                    $0.portID = self.pageHolderVC.mIBCSendPath!.port_id!
                }
                if let response = try? Ibc_Core_Channel_V1_QueryClient(channel: channel).channelClientState(req).response.wait() {
                    let clientState = try! Ibc_Lightclients_Tendermint_V1_ClientState.init(serializedData: response.identifiedClientState.clientState.value)
                    self.onSimulateGrpcTx(auth, clientState.latestHeight)
                }
                try channel.close().wait()
            } catch {
                print("onFetchIbcClientState failed: \(error)")
            }
        }
    }
    
    func onSimulateGrpcTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse?, _ height: Ibc_Core_Client_V1_Height?) {
        DispatchQueue.global().async {
            let simulateReq = self.genSimulateReq(auth!, self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!, height)
            
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).simulate(simulateReq!).response.wait()
//                print("response ", response.gasInfo)
                DispatchQueue.main.async(execute: {
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.mEstimateGasAmount = NSDecimalNumber.init(value: response.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 1.1), withBehavior: WUtils.handler0Up)
                            self.mSimulPassed = true
                            self.onUpdateView()
                        })
                    }
                });
            } catch {
                DispatchQueue.main.async(execute: {
                    print("onSimulateGrpcTx failed: \(error)")
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.mSimulPassed = false
                            self.onShowToast(NSLocalizedString("error_network", comment: "") + "\n" + "\(error)")
                        })
                    }
                });
            }
        }
    }
    
    func genSimulateReq(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ privateKey: Data, _ publicKey: Data, _ height: Ibc_Core_Client_V1_Height?)  -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if (pageHolderVC.mType == TASK_TYPE_TRANSFER) {
            return Signer.genSimulateSendTxgRPC(auth,
                                                self.pageHolderVC.mToSendRecipientAddress!, self.pageHolderVC.mToSendAmount,
                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_DELEGATE) {
            return Signer.genSimulateDelegateTxgRPC(auth,
                                                    self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_UNDELEGATE) {
            return Signer.genSimulateUnDelegateTxgRPC(auth,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToUndelegateAmount!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
                  
            
        } else if (pageHolderVC.mType == TASK_TYPE_REDELEGATE) {
            return Signer.genSimulateReDelegateTxgRPC(auth,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToReDelegateValidator_gRPC!.operatorAddress,
                                                      self.pageHolderVC.mToReDelegateAmount!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
            return Signer.genSimulateClaimRewardsTxgRPC(auth,
                                                        self.pageHolderVC.mRewardTargetValidators_gRPC,
                                                        self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                        privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_REINVEST) {
            return Signer.genSimulateReInvestTxgRPC(auth,
                                                    self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mReinvestReward!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
            return Signer.genSimulateetRewardAddressTxgRPC(auth,
                                                           self.pageHolderVC.mToChangeRewardAddress!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_VOTE) {
            return Signer.genSimulateVoteTxgRPC(auth,
                                                self.pageHolderVC.mProposeId!, self.pageHolderVC.mVoteOpinion!,
                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                privateKey, publicKey, self.chainType!)
            
        }
        
        //for starname custom msg
        else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
            return Signer.genSimulateRegisterDomainMsgTxgRPC(auth,
                                                             self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mStarnameDomainType!,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                             privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
            return Signer.genSimulateRegisterAccountMsgTxgRPC(auth,
                                                              self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mAccount!.account_address, self.pageHolderVC.mStarnameResources_gRPC,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
            return Signer.genSimulateDeleteDomainMsgTxgRPC (auth,
                                                            self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            return Signer.genSimulateDeleteAccountMsgTxgRPC (auth,
                                                             self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                             privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            return Signer.genSimulateRenewDomainMsgTxgRPC (auth,
                                                           self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            return Signer.genSimulateRenewAccountMsgTxgRPC (auth,
                                                            self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
            return Signer.genSimulateReplaceResourceMsgTxgRPC(auth,
                                                              self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mStarnameResources_gRPC,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
        }
        
        //for osmosis custom msg
        else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_SWAP) {
            var swapRoutes = Array<Osmosis_Gamm_V1beta1_SwapAmountInRoute>()
            let swapRoute = Osmosis_Gamm_V1beta1_SwapAmountInRoute.with {
                $0.poolID = self.pageHolderVC.mPool!.id
                $0.tokenOutDenom = self.pageHolderVC.mSwapOutDenom!
            }
            swapRoutes.append(swapRoute)
            return Signer.genSimulateSwapInMsgTxgRPC(auth, swapRoutes,
                                                     self.pageHolderVC.mSwapInDenom!,
                                                     self.pageHolderVC.mSwapInAmount!.stringValue,
                                                     self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
            return Signer.genSimulateDepositPoolMsgTxgRPC(auth,
                                                          self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                          self.pageHolderVC.mLPCoin!.amount,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
            return Signer.genSimulateWithdrawPoolMsgTxgRPC(auth,
                                                           self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                           self.pageHolderVC.mLPCoin!.amount,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_LOCK) {
            return Signer.genSimulateLockTokensMsgTxgRPC(auth,
                                                         self.pageHolderVC.mLPCoin!,
                                                         self.pageHolderVC.mLockupDuration!,
                                                         self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                         privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
            var ids = Array<UInt64>()
            for lockup in self.pageHolderVC.mLockups! {
                ids.append(lockup.id)
            }
            return Signer.genSimulateBeginUnlockingsMsgTxgRPC(auth,
                                                              ids,
                                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
            
        }
        
        
        //for IBC Transfer or Cw20
        else if (pageHolderVC.mType == TASK_TYPE_IBC_TRANSFER) {
            return Signer.genSimulateIbcTransferMsgTxgRPC(auth,
                                                          self.pageHolderVC.mAccount!.account_address,
                                                          self.pageHolderVC.mIBCRecipient!,
                                                          self.pageHolderVC.mIBCSendDenom!,
                                                          self.pageHolderVC.mIBCSendAmount!,
                                                          self.pageHolderVC.mIBCSendPath!,
                                                          height!,
                                                          self.pageHolderVC.mFee!, IBC_TRANSFER_MEMO,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_IBC_CW20_TRANSFER) {
            return Signer.genSimulateCw20Send(auth,
                                              self.account!.account_address,
                                              self.pageHolderVC.mToSendRecipientAddress!,
                                              self.pageHolderVC.mCw20SendContract!,
                                              self.pageHolderVC.mToSendAmount,
                                              self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                              privateKey, publicKey, self.chainType!)
            
        }
        
        else if (pageHolderVC.mType == TASK_TYPE_SIF_ADD_LP) {
            return Signer.genSimulateSifAddLpMsgTxgRPC(auth,
                                                       self.account!.account_address,
                                                       self.pageHolderVC.mPoolCoin0!.amount,
                                                       self.pageHolderVC.mPoolCoin1!.denom,
                                                       self.pageHolderVC.mPoolCoin1!.amount,
                                                       self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                       privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_SIF_REMOVE_LP) {
            var basisPoints = ""
            let myShareAllAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyAllUnitAmount)
            let myShareWithdrawAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyWithdrawUnitAmount)
            basisPoints = myShareWithdrawAmount.multiplying(byPowerOf10: 4).dividing(by: myShareAllAmount, withBehavior: WUtils.handler0).stringValue
            
            return Signer.genSimulateSifRemoveLpMsgTxgRPC(auth,
                                                          self.account!.account_address,
                                                          self.pageHolderVC.mSifPool!.externalAsset.symbol,
                                                          basisPoints,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_SIF_SWAP_CION) {
            return Signer.genSimulateSifSwapMsgTxgRPC(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mSwapInDenom!,
                                                      self.pageHolderVC.mSwapInAmount!.stringValue,
                                                      self.pageHolderVC.mSwapOutDenom!,
                                                      self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
        }
        
        //for NFT
        else if (pageHolderVC.mType == TASK_TYPE_NFT_ISSUE) {
            let stationData = StationNFTData.init(self.pageHolderVC.mNFTName!, self.pageHolderVC.mNFTDescription!, NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                  self.pageHolderVC.mNFTDenomId!, self.account!.account_address)
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(stationData)
            
            if (pageHolderVC.chainType == .IRIS_MAIN) {
                return Signer.genSimulateIssueNftIrisTxgRPC(auth,
                                                            self.account!.account_address,
                                                            self.pageHolderVC.mNFTDenomId!,
                                                            self.pageHolderVC.mNFTDenomName!,
                                                            self.pageHolderVC.mNFTHash!.lowercased(),
                                                            self.pageHolderVC.mNFTName!,
                                                            NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                            String(data: jsonData, encoding: .utf8)!,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                            self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                            self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftCroTxgRPC(auth,
                                                           self.account!.account_address,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.mNFTDenomName!,
                                                           self.pageHolderVC.mNFTHash!.lowercased(),
                                                           self.pageHolderVC.mNFTName!,
                                                           NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                           String(data: jsonData, encoding: .utf8)!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_NFT_SEND) {
            if (pageHolderVC.chainType == ChainType.IRIS_MAIN) {
                return Signer.genSimulateSendNftIrisTxgRPC(auth, self.account!.account_address,
                                                           self.pageHolderVC.mToSendRecipientAddress!,
                                                           self.pageHolderVC.mNFTTokenId!,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.irisResponse!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateSendNftCroTxgRPC(auth, self.account!.account_address,
                                                          self.pageHolderVC.mToSendRecipientAddress!,
                                                          self.pageHolderVC.mNFTTokenId!,
                                                          self.pageHolderVC.mNFTDenomId!,
                                                          self.pageHolderVC.croResponse!,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                          self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_NFT_ISSUE_DENOM) {
            if (pageHolderVC.chainType == .IRIS_MAIN) {
                return Signer.genSimulateIssueNftDenomIrisTxgRPC(auth, self.account!.account_address,
                                                                 self.pageHolderVC.mNFTDenomId!,
                                                                 self.pageHolderVC.mNFTDenomName!,
                                                                 self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                 self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftDenomCroTxgRPC(auth, self.account!.account_address,
                                                                self.pageHolderVC.mNFTDenomId!,
                                                                self.pageHolderVC.mNFTDenomName!,
                                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                                self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                self.chainType!)
            }
            
        }
        
        //for desmos
        else if (pageHolderVC.mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
            return Signer.genSimulateSaveProfileTxgRPC(auth,
                                                       self.pageHolderVC.mAccount!.account_address,
                                                       self.pageHolderVC.mDesmosDtag!,
                                                       self.pageHolderVC.mDesmosNickName!,
                                                       self.pageHolderVC.mDesmosBio!,
                                                       (self.pageHolderVC.mDesmosProfileHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosProfileHash!,
                                                       (self.pageHolderVC.mDesmosCoverHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosCoverHash!,
                                                       self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                       self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                       self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
            let toAccount = BaseData.instance.selectAccountById(id: self.pageHolderVC.mDesmosToLinkAccountId)!
            var toPrivateKey: Data!
            var toPublicKey: Data!
            if (toAccount.account_from_mnemonic == true) {
                if let words = KeychainWrapper.standard.string(forKey: toAccount.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                    toPrivateKey = KeyFac.getPrivateRaw(words, toAccount)
                    toPublicKey = KeyFac.getPublicFromPrivateKey(toPrivateKey)
                }
                
            } else {
                if let key = KeychainWrapper.standard.string(forKey: toAccount.getPrivateKeySha1()) {
                    toPrivateKey = KeyFac.getPrivateFromString(key)
                    toPublicKey = KeyFac.getPublicFromPrivateKey(toPrivateKey)
                }
            }
            return Signer.genSimulateLinkChainTxgRPC(auth,
                                                     self.pageHolderVC.mAccount!.account_address,
                                                     self.pageHolderVC.mDesmosToLinkChain!,
                                                     toAccount,
                                                     toPrivateKey,
                                                     toPublicKey,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        }
        
        //for kava
        else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_CREATE) {
            return Signer.genSimulateKavaCDPCreate(auth,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mCollateral,
                                                   self.pageHolderVC.mPrincipal,
                                                   self.pageHolderVC.mCollateralParamType!,
                                                   self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
            return Signer.genSimulateKavaCDPDeposit(auth,
                                                    self.account!.account_address,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mCollateral,
                                                    self.pageHolderVC.mCollateralParamType!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
            return Signer.genSimulateKavaCDPWithdraw(auth,
                                                     self.account!.account_address,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mCollateral,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
            return Signer.genSimulateKavaCDPDrawDebt(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPrincipal,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_REPAY) {
            return Signer.genSimulateKavaCDPRepay(auth,
                                                  self.account!.account_address,
                                                  self.pageHolderVC.mPayment,
                                                  self.pageHolderVC.mCollateralParamType!,
                                                  self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                  self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                  self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
            return Signer.genSimulateKavaHardDeposit(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mHardPoolCoins!,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
               
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
            return Signer.genSimulateKavaHardWithdraw(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mHardPoolCoins!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
                
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_BORROW) {
            return Signer.genSimulateKavaHardBorrow(auth,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mHardPoolCoins!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
              
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_REPAY) {
            return Signer.genSimulateKavaHardRepay(auth,
                                                   self.account!.account_address,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mHardPoolCoins!,
                                                   self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
             
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
            let slippage = "30000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return Signer.genSimulateKavaSwapDeposit(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPoolCoin0!,
                                                     self.pageHolderVC.mPoolCoin1!,
                                                     slippage,
                                                     deadline,
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
            let sharesOwned = NSDecimalNumber.init(string: pageHolderVC.mKavaSwapPoolDeposit?.sharesOwned)
            let depositRate = (pageHolderVC.mKavaShareAmount).dividing(by: sharesOwned, withBehavior: WUtils.handler18)
            let padding = NSDecimalNumber(string: "0.97")
            let sharesValue0 = NSDecimalNumber.init(string: pageHolderVC.mKavaSwapPoolDeposit?.sharesValue[0].amount)
            let sharesValue1 = NSDecimalNumber.init(string: pageHolderVC.mKavaSwapPoolDeposit?.sharesValue[1].amount)
            let coin0Amount = sharesValue0.multiplying(by: padding).multiplying(by: depositRate, withBehavior: WUtils.handler0)
            let coin1Amount = sharesValue1.multiplying(by: padding).multiplying(by: depositRate, withBehavior: WUtils.handler0)
            let coin0 = Coin.init(pageHolderVC.mKavaSwapPoolDeposit!.sharesValue[0].denom, coin0Amount.stringValue)
            let coin1 = Coin.init(pageHolderVC.mKavaSwapPoolDeposit!.sharesValue[1].denom, coin1Amount.stringValue)
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return Signer.genSimulateKavaSwapWithdraw(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mKavaShareAmount.stringValue,
                                                      coin0,
                                                      coin1,
                                                      deadline,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
            let inCoin = Coin.init(self.pageHolderVC.mSwapInDenom!, self.pageHolderVC.mSwapInAmount!.stringValue)
            let outCoin = Coin.init(self.pageHolderVC.mSwapOutDenom!, self.pageHolderVC.mSwapOutAmount!.stringValue)
            let slippage = "30000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return  Signer.genSimulateKavaSwapExactForTokens(auth,
                                                             self.account!.account_address,
                                                             inCoin,
                                                             outCoin,
                                                             slippage,
                                                             deadline,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                             self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                             self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
            return Signer.genSimulateKavaIncentiveAll(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mIncentiveMultiplier!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
        }
        
        return nil
    }
}
*/
