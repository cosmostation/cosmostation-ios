//
//  StepFeeGrpcViewController.swift
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

class StepFeeGrpcViewController: BaseViewController, PasswordViewDelegate {

    @IBOutlet weak var feeTotalCard: CardView!
    @IBOutlet weak var feeTotalAmount: UILabel!
    @IBOutlet weak var feeTotalDenom: UILabel!
    @IBOutlet weak var feeTotalValue: UILabel!
    
    @IBOutlet weak var gasDetailCard: CardView!
    @IBOutlet weak var gasAmountLabel: UILabel!
    @IBOutlet weak var gasRateLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var gasSelectSegments: UISegmentedControl!
    
    @IBOutlet weak var speedImg: UIImageView!
    @IBOutlet weak var speedTxt: UILabel!
    
    @IBOutlet weak var btnGasCheck: UIButton!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mSelectedGasPosition = 1
    var mSelectedGasRate = NSDecimalNumber.zero
    var mEstimateGasAmount = NSDecimalNumber.zero
    var mFee = NSDecimalNumber.zero
    var mDpDecimal:Int16 = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        feeTotalCard.backgroundColor = WUtils.getChainBg(chainType)
        WUtils.setDenomTitle(chainType, feeTotalDenom)
        mDpDecimal = WUtils.mainDivideDecimal(chainType)
        if #available(iOS 13.0, *) {
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            gasSelectSegments.selectedSegmentTintColor = WUtils.getChainColor(chainType)
        } else {
            gasSelectSegments.tintColor = WUtils.getChainColor(chainType!)
        }
        
        if (chainType == ChainType.SIF_MAIN) {
            gasDetailCard.isHidden = true
        }
        
        mEstimateGasAmount = WUtils.getEstimateGasAmount(chainType!, pageHolderVC.mType!, pageHolderVC.mRewardTargetValidators_gRPC.count)
        onUpdateView()
    }
    
    func onCalculateFees() {
        mSelectedGasRate = WUtils.getGasRate(chainType!, mSelectedGasPosition)
        if (chainType == ChainType.SIF_MAIN) {
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
        feeTotalValue.attributedText = WUtils.dpUserCurrencyValue(WUtils.getMainDenom(chainType), mFee, WUtils.mainDivideDecimal(chainType), feeTotalValue.font)
        
        gasRateLabel.attributedText = WUtils.displayGasRate(mSelectedGasRate.rounding(accordingToBehavior: WUtils.handler6), font: gasRateLabel.font, 5)
        gasAmountLabel.text = mEstimateGasAmount.stringValue
        gasFeeLabel.text = mFee.stringValue
        
        if (mSelectedGasPosition == 0) {
            self.speedImg.image = UIImage.init(named: "bycicle")
            self.speedTxt.text = NSLocalizedString("fee_speed_title_0", comment: "")
        } else if (mSelectedGasPosition == 1) {
            self.speedImg.image = UIImage.init(named: "car")
            self.speedTxt.text = NSLocalizedString("fee_speed_title_1", comment: "")
        } else {
            self.speedImg.image = UIImage.init(named: "roket")
            self.speedTxt.text = NSLocalizedString("fee_speed_title_2", comment: "")
        }
        
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
        onSetFee()
        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
        passwordVC.resultDelegate = self
        self.navigationController?.pushViewController(passwordVC, animated: false)
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (onCheckValidate()) {
            onSetFee()
            btnBefore.isUserInteractionEnabled = false
            btnNext.isUserInteractionEnabled = false
            pageHolderVC.onNextPage()
        }
    }
    
    func onSetFee() {
        let gasCoin = Coin.init(WUtils.getMainDenom(chainType), mFee.stringValue)
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
    
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(310), execute: {
                self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
            })
        }
    }
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait() {
                    if (self.pageHolderVC.mType == TASK_IBC_TRANSFER) {
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
                            self.onUpdateView()
                        })
                    }
                });
            } catch {
                DispatchQueue.main.async(execute: {
                    if (self.waitAlert != nil) {
                        self.waitAlert?.dismiss(animated: true, completion: {
                            self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        })
                    }
                    print("onSimulateGrpcTx failed: \(error)")
                });
            }
        }
    }
    
    func genSimulateReq(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ privateKey: Data, _ publicKey: Data, _ height: Ibc_Core_Client_V1_Height?)  -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if (pageHolderVC.mType == COSMOS_MSG_TYPE_TRANSFER2) {
            return Signer.genSimulateSendTxgRPC(auth,
                                                self.pageHolderVC.mToSendRecipientAddress!, self.pageHolderVC.mToSendAmount,
                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == COSMOS_MSG_TYPE_DELEGATE) {
            return Signer.genSimulateDelegateTxgRPC(auth,
                                                    self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                    privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == COSMOS_MSG_TYPE_UNDELEGATE2) {
            return Signer.genSimulateUnDelegateTxgRPC(auth,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToUndelegateAmount!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
                  
            
        } else if (pageHolderVC.mType == COSMOS_MSG_TYPE_REDELEGATE2) {
            return Signer.genSimulateReDelegateTxgRPC(auth,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToReDelegateValidator_gRPC!.operatorAddress,
                                                      self.pageHolderVC.mToReDelegateAmount!,
                                                      self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == COSMOS_MSG_TYPE_WITHDRAW_DEL) {
            return Signer.genSimulateClaimRewardsTxgRPC(auth, self.pageHolderVC.mRewardTargetValidators_gRPC, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey,
                                                        BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == COSMOS_MULTI_MSG_TYPE_REINVEST) {
            return Signer.genSimulateReInvestTxgRPC(auth, self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mReinvestReward!,
                                                    self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey,
                                                    BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == COSMOS_MSG_TYPE_WITHDRAW_MIDIFY) {
            return Signer.genSimulateetRewardAddressTxgRPC(auth, self.pageHolderVC.mToChangeRewardAddress!, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           privateKey,publicKey,BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == TASK_TYPE_VOTE) {
            return Signer.genSimulateVoteTxgRPC(auth, self.pageHolderVC.mProposeId!, self.pageHolderVC.mVoteOpinion!, self.pageHolderVC.mFee!,
                                                self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        }
        
        //for starname custom msg
        else if (pageHolderVC.mType == IOV_MSG_TYPE_REGISTER_DOMAIN) {
            return Signer.genSimulateRegisterDomainMsgTxgRPC(auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mStarnameDomainType!, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == IOV_MSG_TYPE_REGISTER_ACCOUNT) {
            return Signer.genSimulateRegisterAccountMsgTxgRPC(auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mAccount!.account_address, self.pageHolderVC.mStarnameResources_gRPC, self.pageHolderVC.mFee!,
                                                              self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == IOV_MSG_TYPE_DELETE_DOMAIN) {
            return Signer.genSimulateDeleteDomainMsgTxgRPC (auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address, self.pageHolderVC.mFee!,
                                                            self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == IOV_MSG_TYPE_DELETE_ACCOUNT) {
            return Signer.genSimulateDeleteAccountMsgTxgRPC (auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == IOV_MSG_TYPE_RENEW_DOMAIN) {
            return Signer.genSimulateRenewDomainMsgTxgRPC (auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address, self.pageHolderVC.mFee!,
                                                           self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == IOV_MSG_TYPE_RENEW_ACCOUNT) {
            return Signer.genSimulateRenewAccountMsgTxgRPC (auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                            self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == IOV_MSG_TYPE_REPLACE_ACCOUNT_RESOURCE) {
            return Signer.genSimulateReplaceResourceMsgTxgRPC(auth, self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mStarnameResources_gRPC, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey, BaseData.instance.getChainId(self.chainType))
        }
        
        //for osmosis custom msg
        else if (pageHolderVC.mType == OSMOSIS_MSG_TYPE_SWAP) {
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
                                                     self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, privateKey, publicKey,
                                                     BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == OSMOSIS_MSG_TYPE_JOIN_POOL) {
            return Signer.genSimulateDepositPoolMsgTxgRPC(auth,
                                                          self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                          self.pageHolderVC.mLPCoin!.amount, self.pageHolderVC.mFee!,
                                                          self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey,
                                                          BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == OSMOSIS_MSG_TYPE_EXIT_POOL) {
            return Signer.genSimulateWithdrawPoolMsgTxgRPC(auth,
                                                           self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                           self.pageHolderVC.mLPCoin!.amount, self.pageHolderVC.mFee!,
                                                           self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey,
                                                           BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == OSMOSIS_MSG_TYPE_LOCK) {
            return Signer.genSimulateLockTokensMsgTxgRPC(auth,
                                                         self.pageHolderVC.mLPCoin!,
                                                         self.pageHolderVC.mLockupDuration!,
                                                         self.pageHolderVC.mFee!,
                                                         self.pageHolderVC.mMemo!,
                                                         privateKey, publicKey,
                                                         BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == OSMOSIS_MSG_TYPE_BEGIN_UNLCOK) {
            var ids = Array<UInt64>()
            for lockup in self.pageHolderVC.mLockups! {
                ids.append(lockup.id)
            }
            return Signer.genSimulateBeginUnlockingsMsgTxgRPC(auth,
                                                              ids,
                                                              self.pageHolderVC.mFee!,
                                                              self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey,
                                                              BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == OSMOSIS_MSG_TYPE_PERIOD_UNLOCK) {
            var ids = Array<UInt64>()
            for lockup in self.pageHolderVC.mLockups! {
                ids.append(lockup.id)
            }
            return Signer.genSimulateUnlockPeriodLocksMsgTxgRPC(auth,
                                                                ids,
                                                                self.pageHolderVC.mFee!,
                                                                self.pageHolderVC.mMemo!,
                                                                privateKey, publicKey,
                                                                BaseData.instance.getChainId(self.chainType))
        }
        
        
        //for gDex custom msg
        else if (pageHolderVC.mType == LIQUIDITY_MSG_TYPE_SWAP) {
            let offerFee = self.pageHolderVC.mSwapInAmount!.multiplying(byPowerOf10: -4).multiplying(by: NSDecimalNumber.init(string: "15"), withBehavior: WUtils.handler0)
            return Signer.genSimulateSwapBatchMsgTxgRPC(auth,
                                                        self.pageHolderVC.mAccount!.account_address,
                                                        String(self.pageHolderVC.mGDexPool!.id),
                                                        "1",
                                                        Coin.init(self.pageHolderVC.mSwapInDenom!, self.pageHolderVC.mSwapInAmount!.stringValue),
                                                        Coin.init(self.pageHolderVC.mSwapInDenom!, offerFee.stringValue),
                                                        self.pageHolderVC.mSwapOutDenom!,
                                                        self.pageHolderVC.mGDexSwapOrderPrice!.stringValue,
                                                        self.pageHolderVC.mFee!,
                                                        self.pageHolderVC.mMemo!,
                                                        privateKey, publicKey,
                                                        BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == LIQUIDITY_MSG_TYPE_JOIN_POOL) {
            return Signer.genSimulateDepositBatchMsgTxgRPC(auth,
                                                           self.pageHolderVC.mAccount!.account_address,
                                                           String(self.pageHolderVC.mGDexPool!.id),
                                                           [self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!],
                                                           self.pageHolderVC.mFee!,
                                                           self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey,
                                                           BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == LIQUIDITY_MSG_TYPE_EXIT_POOL) {
            return Signer.genSimulateWithdrawBatchMsgTxgRPC(auth,
                                                            self.pageHolderVC.mAccount!.account_address,
                                                            String(self.pageHolderVC.mGDexPool!.id),
                                                            self.pageHolderVC.mLPCoin!,
                                                            self.pageHolderVC.mFee!,
                                                            self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey,
                                                            BaseData.instance.getChainId(self.chainType))
        }
        
        //for IBC Transfer or Cw20
        else if (pageHolderVC.mType == TASK_IBC_TRANSFER) {
            return Signer.genSimulateIbcTransferMsgTxgRPC(auth,
                                                          self.pageHolderVC.mAccount!.account_address,
                                                          self.pageHolderVC.mIBCRecipient!,
                                                          self.pageHolderVC.mIBCSendDenom!,
                                                          self.pageHolderVC.mIBCSendAmount!,
                                                          self.pageHolderVC.mIBCSendPath!,
                                                          height!,
                                                          self.pageHolderVC.mFee!,
                                                          IBC_TRANSFER_MEMO,
                                                          privateKey, publicKey,
                                                          BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == TASK_CW20_TRANSFER) {
            return Signer.genSimulateCw20Send(auth,
                                              self.account!.account_address,
                                              self.pageHolderVC.mToSendRecipientAddress!,
                                              self.pageHolderVC.mCw20SendContract!,
                                              self.pageHolderVC.mToSendAmount,
                                              self.pageHolderVC.mFee!,
                                              self.pageHolderVC.mMemo!,
                                              privateKey, publicKey,
                                              BaseData.instance.getChainId(self.chainType))
            
        }
        
        else if (pageHolderVC.mType == SIF_MSG_TYPE_CLAIM_INCENTIVE) {
            return Signer.genSimulateSifIncentiveMsgTxgRPC(auth,
                                                           self.account!.account_address,
                                                           self.pageHolderVC.mFee!,
                                                           self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey,
                                                           BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == SIF_MSG_TYPE_ADD_LP) {
            return Signer.genSimulateSifAddLpMsgTxgRPC(auth,
                                                       self.account!.account_address,
                                                       self.pageHolderVC.mPoolCoin0!.amount,
                                                       self.pageHolderVC.mPoolCoin1!.denom,
                                                       self.pageHolderVC.mPoolCoin1!.amount,
                                                       self.pageHolderVC.mFee!,
                                                       self.pageHolderVC.mMemo!,
                                                       privateKey, publicKey,
                                                       BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == SIF_MSG_TYPE_REMOVE_LP) {
            var basisPoints = ""
            let myShareAllAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyAllUnitAmount)
            let myShareWithdrawAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyWithdrawUnitAmount)
            basisPoints = myShareWithdrawAmount.multiplying(byPowerOf10: 4).dividing(by: myShareAllAmount, withBehavior: WUtils.handler0).stringValue
            
            return Signer.genSimulateSifRemoveLpMsgTxgRPC(auth,
                                                          self.account!.account_address,
                                                          self.pageHolderVC.mSifPool!.externalAsset.symbol,
                                                          basisPoints,
                                                          self.pageHolderVC.mFee!,
                                                          self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey,
                                                          BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == SIF_MSG_TYPE_SWAP_CION) {
            return Signer.genSimulateSifSwapMsgTxgRPC(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mSwapInDenom!,
                                                      self.pageHolderVC.mSwapInAmount!.stringValue,
                                                      self.pageHolderVC.mSwapOutDenom!,
                                                      self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                      self.pageHolderVC.mFee!,
                                                      self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey,
                                                      BaseData.instance.getChainId(self.chainType))
        }
        
        //for NFT
        else if (pageHolderVC.mType == TASK_ISSUE_NFT) {
            let stationData = StationNFTData.init(self.pageHolderVC.mNFTName!, self.pageHolderVC.mNFTDescription!, NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                  self.pageHolderVC.mNFTDenomId!, self.account!.account_address)
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(stationData)
            
            if (pageHolderVC.chainType == ChainType.IRIS_MAIN) {
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
                                                            BaseData.instance.getChainId(self.chainType))
                
            } else if (self.chainType == ChainType.CRYPTO_MAIN) {
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
                                                           BaseData.instance.getChainId(self.chainType))
            }
            
        } else if (pageHolderVC.mType == TASK_SEND_NFT) {
            if (pageHolderVC.chainType == ChainType.IRIS_MAIN) {
                return Signer.genSimulateSendNftIrisTxgRPC(auth, self.account!.account_address,
                                                           self.pageHolderVC.mToSendRecipientAddress!,
                                                           self.pageHolderVC.mNFTTokenId!,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.irisResponse!,
                                                           self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           BaseData.instance.getChainId(self.chainType))
                
            } else if (self.chainType == ChainType.CRYPTO_MAIN) {
                return Signer.genSimulateSendNftCroTxgRPC(auth, self.account!.account_address,
                                                          self.pageHolderVC.mToSendRecipientAddress!,
                                                          self.pageHolderVC.mNFTTokenId!,
                                                          self.pageHolderVC.mNFTDenomId!,
                                                          self.pageHolderVC.croResponse!,
                                                          self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                          BaseData.instance.getChainId(self.chainType))
            }
            
        } else if (pageHolderVC.mType == TASK_ISSUE_NFT_DENOM) {
            if (pageHolderVC.chainType == ChainType.IRIS_MAIN) {
                return Signer.genSimulateIssueNftDenomIrisTxgRPC(auth, self.account!.account_address,
                                                                 self.pageHolderVC.mNFTDenomId!,
                                                                 self.pageHolderVC.mNFTDenomName!,
                                                                 self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                 BaseData.instance.getChainId(self.chainType))
                
            } else if (self.chainType == ChainType.CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftDenomCroTxgRPC(auth, self.account!.account_address,
                                                                self.pageHolderVC.mNFTDenomId!,
                                                                self.pageHolderVC.mNFTDenomName!,
                                                                self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!,
                                                                self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                BaseData.instance.getChainId(self.chainType))
            }
            
        }
        
        //for desmos
        else if (pageHolderVC.mType == TASK_GEN_PROFILE) {
            return Signer.genSimulateSaveProfileTxgRPC(auth,
                                                       self.pageHolderVC.mAccount!.account_address,
                                                       self.pageHolderVC.mDesmosDtag!,
                                                       self.pageHolderVC.mDesmosNickName!,
                                                       self.pageHolderVC.mDesmosBio!,
                                                       (self.pageHolderVC.mDesmosProfileHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosProfileHash!,
                                                       (self.pageHolderVC.mDesmosCoverHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosCoverHash!,
                                                       self.pageHolderVC.mFee!,
                                                       self.pageHolderVC.mMemo!,
                                                       self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                       BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == TASK_LINK_CHAIN_ACCOUNT) {
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
                                                     self.pageHolderVC.mFee!,
                                                     self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     BaseData.instance.getChainId(self.chainType))
            
        }
        
        //for kava
        else if (pageHolderVC.mType == KAVA_MSG_TYPE_CREATE_CDP) {
            return Signer.genSimulateKavaCDPCreate(auth,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mCollateral,
                                                   self.pageHolderVC.mPrincipal,
                                                   self.pageHolderVC.mCollateralParamType!,
                                                   self.pageHolderVC.mFee!,
                                                   self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_DEPOSIT_CDP) {
            return Signer.genSimulateKavaCDPDeposit(auth,
                                                    self.account!.account_address,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mCollateral,
                                                    self.pageHolderVC.mCollateralParamType!,
                                                    self.pageHolderVC.mFee!,
                                                    self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_WITHDRAW_CDP) {
            return Signer.genSimulateKavaCDPWithdraw(auth,
                                                     self.account!.account_address,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mCollateral,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.pageHolderVC.mFee!,
                                                     self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_DRAWDEBT_CDP) {
            return Signer.genSimulateKavaCDPDrawDebt(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPrincipal,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.pageHolderVC.mFee!,
                                                     self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_REPAYDEBT_CDP) {
            return Signer.genSimulateKavaCDPRepay(auth,
                                                  self.account!.account_address,
                                                  self.pageHolderVC.mPayment,
                                                  self.pageHolderVC.mCollateralParamType!,
                                                  self.pageHolderVC.mFee!,
                                                  self.pageHolderVC.mMemo!,
                                                  self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                  BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_DEPOSIT_HARD) {
            return Signer.genSimulateKavaHardDeposit(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mHardPoolCoins!,
                                                     self.pageHolderVC.mFee!,
                                                     self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_WITHDRAW_HARD) {
            return Signer.genSimulateKavaHardWithdraw(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mHardPoolCoins!,
                                                      self.pageHolderVC.mFee!,
                                                      self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_BORROW_HARD) {
            return Signer.genSimulateKavaHardBorrow(auth,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mHardPoolCoins!,
                                                    self.pageHolderVC.mFee!,
                                                    self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_REPAY_HARD) {
            return Signer.genSimulateKavaHardRepay(auth,
                                                   self.account!.account_address,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mHardPoolCoins!,
                                                   self.pageHolderVC.mFee!,
                                                   self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_SWAP_DEPOSIT) {
            let slippage = "300000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return Signer.genSimulateKavaSwapDeposit(auth,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPoolCoin0!,
                                                     self.pageHolderVC.mPoolCoin1!,
                                                     slippage,
                                                     deadline,
                                                     self.pageHolderVC.mFee!,
                                                     self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_SWAP_WITHDRAW) {
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
                                                      self.pageHolderVC.mFee!,
                                                      self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_SWAP_TOKEN) {
            let inCoin = Coin.init(self.pageHolderVC.mSwapInDenom!, self.pageHolderVC.mSwapInAmount!.stringValue)
            let outCoin = Coin.init(self.pageHolderVC.mSwapOutDenom!, self.pageHolderVC.mSwapOutAmount!.stringValue)
            let slippage = "300000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return  Signer.genSimulateKavaSwapExactForTokens(auth,
                                                             self.account!.account_address,
                                                             inCoin,
                                                             outCoin,
                                                             slippage,
                                                             deadline,
                                                             self.pageHolderVC.mFee!,
                                                             self.pageHolderVC.mMemo!,
                                                             self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                             BaseData.instance.getChainId(self.chainType))
            
        } else if (pageHolderVC.mType == KAVA_MSG_TYPE_INCENTIVE_ALL) {
            return Signer.genSimulateKavaIncentiveAll(auth,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mIncentiveMultiplier!,
                                                      self.pageHolderVC.mFee!,
                                                      self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      BaseData.instance.getChainId(self.chainType))
        }
        
        return nil
    }
}
