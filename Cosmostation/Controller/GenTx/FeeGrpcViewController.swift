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
    @IBOutlet weak var feeTitle: UILabel!
    
    @IBOutlet weak var gasDetailCard: CardView!
    @IBOutlet weak var gasSelectSegments: UISegmentedControl!
    @IBOutlet weak var gasDescriptionLabel: UILabel!
    
    @IBOutlet weak var feeWarnTitle: UILabel!
    @IBOutlet weak var feeWarnMsg: UILabel!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var mSimulPassed = false
    var mFee: Fee!
    var mFeeCoin: Coin!
    var mFeeGasAmount = NSDecimalNumber.init(string: "500000")
    
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
        WDP.dpSymbolImg(chainConfig, WUtils.getMainDenom(chainConfig), feeTypeImg)
        WDP.dpSymbol(chainConfig, WUtils.getMainDenom(chainConfig), feeTypeDenom)
//        print("mFeeInfo ", mFeeInfo)
        
        gasSelectSegments.removeAllSegments()
        for i in 0..<mFeeInfo.count {
            gasSelectSegments.insertSegment(withTitle: mFeeInfo[i].title, at: i, animated: false)
        }
        
        feeTotalCard.backgroundColor = chainConfig?.chainColorBG
        if #available(iOS 13.0, *) {
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            gasSelectSegments.setTitleTextAttributes([.foregroundColor: UIColor.font04], for: .normal)
            gasSelectSegments.selectedSegmentTintColor = chainConfig?.chainColor
        } else {
            gasSelectSegments.tintColor = chainConfig?.chainColor
        }
        mSelectedFeeInfo = chainConfig!.getGasDefault()
        gasSelectSegments.selectedSegmentIndex = mSelectedFeeInfo
        
        feeTypeCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickFeeDenom (_:))))
        
        feeTypeCard.layer.borderColor = UIColor.font05.cgColor
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.init(named: "photon")
        
        feeTitle.text = NSLocalizedString("str_total_fee", comment: "")
        feeWarnTitle.text = NSLocalizedString("msg_fee1", comment: "")
        feeWarnMsg.text = NSLocalizedString("msg_fee2", comment: "")
        btnBefore.setTitle(NSLocalizedString("str_back", comment: ""), for: .normal)
        btnNext.setTitle(NSLocalizedString("str_next", comment: ""), for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        feeTypeCard.layer.borderColor = UIColor.font05.cgColor
        btnBefore.borderColor = UIColor.font05
        btnNext.borderColor = UIColor.init(named: "photon")
    }
    
    @IBAction func onSwitchGasRate(_ sender: UISegmentedControl) {
        self.mSelectedFeeInfo = sender.selectedSegmentIndex
        self.onCalculateFees()
        self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
    }
    
    @objc func onClickFeeDenom (_ onClickDenom: UITapGestureRecognizer) {
        let popupVC = SelectPopupViewController(nibName: "SelectPopupViewController", bundle: nil)
        popupVC.type = SELECT_POPUP_FEE_DENOM
        popupVC.feeData = mFeeInfo[mSelectedFeeInfo].FeeDatas
        let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
        cardPopup.resultDelegate = self
        cardPopup.show(onViewController: self)
    }
    
    func SBCardPopupResponse(type: Int, result: Int) {
        self.mSelectedFeeData = result
        self.onCalculateFees()
        self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("automatic gas amount check")
        self.mSimulPassed = false
        if (!BaseData.instance.getUsingEnginerMode()) {
            self.onCalculateFees()
            self.onFetchgRPCAuth(self.pageHolderVC.mAccount!)
        }
    }
    
    func onCalculateFees() {
        self.mFeeData = mFeeInfo[mSelectedFeeInfo].FeeDatas[mSelectedFeeData]
        if (chainType == .SIF_MAIN) {
            mFeeCoin = Coin.init(mFeeData.denom!, "100000000000000000")
        } else if (chainType == .CHIHUAHUA_MAIN) {
            if (mSelectedFeeInfo == 0) {
                mFeeCoin = Coin.init(mFeeData.denom!, "1000000")
            } else if (mSelectedFeeInfo == 1) {
                mFeeCoin = Coin.init(mFeeData.denom!, "5000000")
            } else {
                mFeeCoin = Coin.init(mFeeData.denom!, "10000000")
            }
        } else {
            let amount = (mFeeData.gasRate)!.multiplying(by: mFeeGasAmount, withBehavior: WUtils.handler0Up)
            mFeeCoin = Coin.init(mFeeData.denom!, amount.stringValue)
        }
        mFee = Fee.init(mFeeGasAmount.stringValue, [mFeeCoin])
//        print("onCalculateFees ", mFee)
    }
    
    func onUpdateView() {
        self.onCalculateFees()
        
        WDP.dpSymbolImg(chainConfig, mFeeData.denom, feeTypeImg)
        WDP.dpSymbol(chainConfig, mFeeData.denom, feeTypeDenom)
        WDP.dpCoin(chainConfig, mFee.amount[0], feeTotalDenom, feeTotalAmount)
        
        var feePriceDenom = mFeeData.denom!
        var feeDivideDecimal = WUtils.getDenomDecimal(chainConfig, mFeeData.denom)
        if let feeMsAsset = BaseData.instance.mMintscanAssets.filter({ $0.denom.lowercased() == mFeeData.denom!.lowercased() }).first {
            feePriceDenom = feeMsAsset.priceDenom()
            feeDivideDecimal = feeMsAsset.decimal
        }
        
        feeTotalValue.attributedText = WUtils.dpAssetValue(feePriceDenom, NSDecimalNumber.init(string: mFee.amount[0].amount), feeDivideDecimal, feeTotalValue.font)
        gasDescriptionLabel.text = mFeeInfo[mSelectedFeeInfo].msg
    }
    
    override func enableUserInteraction() {
        btnBefore.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
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
        btnBefore.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.mFee = mFee
        pageHolderVC.onNextPage()
    }
    
    func onFetchgRPCAuth(_ account: Account) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = account.account_address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req).response.wait() {
                    if (self.pageHolderVC.mTransferType == TRANSFER_IBC_SIMPLE || self.pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
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
                    $0.channelID = self.pageHolderVC.mMintscanPath!.channel!
                    $0.portID = self.pageHolderVC.mMintscanPath!.port!
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
                            if (self.chainType == .PROVENANCE_MAIN || self.chainType == .TERITORI_MAIN) {
                                self.mFeeGasAmount = NSDecimalNumber.init(value: response.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 1.3), withBehavior: WUtils.handler0Up)
                            } else {
                                self.mFeeGasAmount = NSDecimalNumber.init(value: response.gasInfo.gasUsed).multiplying(by: NSDecimalNumber.init(value: 1.1), withBehavior: WUtils.handler0Up)
                            }
                            self.mSimulPassed = true
                            self.onShowToast(NSLocalizedString("gas_checked", comment: ""))
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
                            self.onUpdateView()
                            self.onShowToast(NSLocalizedString("error_network", comment: "") + "\n" + "\(error)")
                        })
                    }
                });
            }
        }
    }
    
    func genSimulateReq(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ privateKey: Data, _ publicKey: Data, _ height: Ibc_Core_Client_V1_Height?)  -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if (pageHolderVC.mType == TASK_TYPE_TRANSFER) {
            if (pageHolderVC.mTransferType == TRANSFER_SIMPLE) {
                return Signer.simulSimpleSend(auth, account!.account_pubkey_type,
                                              pageHolderVC.mRecipinetAddress!, pageHolderVC.mToSendAmount,
                                              mFee, pageHolderVC.mMemo!, privateKey, publicKey, chainType!)
                
            } else if (pageHolderVC.mTransferType == TRANSFER_IBC_SIMPLE) {
                return Signer.simulIbcSend(auth, account!.account_pubkey_type,
                                           pageHolderVC.mRecipinetAddress!, pageHolderVC.mToSendAmount,
                                           pageHolderVC.mMintscanPath!, height!,
                                           mFee, pageHolderVC.mMemo!, privateKey, publicKey, chainType!)
                
            } else if (pageHolderVC.mTransferType == TRANSFER_WASM) {
                return Signer.simulWasmSend(auth, account!.account_pubkey_type,
                                            pageHolderVC.mRecipinetAddress!, pageHolderVC.mMintscanTokens!.contract_address,
                                            pageHolderVC.mToSendAmount,
                                            mFee, pageHolderVC.mMemo!, privateKey, publicKey, chainType!)
                
            } else if (pageHolderVC.mTransferType == TRANSFER_IBC_WASM) {
                return Signer.simulWasmIbcSend(auth, account!.account_pubkey_type,
                                               pageHolderVC.mRecipinetAddress!, pageHolderVC.mMintscanTokens!.contract_address,
                                               pageHolderVC.mToSendAmount, pageHolderVC.mMintscanPath!,
                                               mFee, pageHolderVC.mMemo!, privateKey, publicKey, chainType!)
                
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_DELEGATE) {
            if (self.pageHolderVC.chainType == .TGRADE_MAIN) {
                return Signer.genSimulateTgradeDelegate(auth, account!.account_pubkey_type,
                                                        self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!, Coin.init("utgd", "0"),
                                                        self.mFee, self.pageHolderVC.mMemo!,
                                                        privateKey, publicKey, self.chainType!)
            } else {
                return Signer.genSimulateDelegateTxgRPC(auth, account!.account_pubkey_type,
                                                        self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToDelegateAmount!,
                                                        self.mFee, self.pageHolderVC.mMemo!,
                                                        privateKey, publicKey, self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_UNDELEGATE) {
            return Signer.genSimulateUnDelegateTxgRPC(auth, account!.account_pubkey_type,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToUndelegateAmount!,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
                  
            
        } else if (pageHolderVC.mType == TASK_TYPE_REDELEGATE) {
            return Signer.genSimulateReDelegateTxgRPC(auth, account!.account_pubkey_type,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mToReDelegateValidator_gRPC!.operatorAddress,
                                                      self.pageHolderVC.mToReDelegateAmount!,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
            return Signer.genSimulateClaimRewardsTxgRPC(auth, account!.account_pubkey_type,
                                                        self.pageHolderVC.mRewardTargetValidators_gRPC,
                                                        self.mFee, self.pageHolderVC.mMemo!,
                                                        privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_REINVEST) {
            return Signer.genSimulateReInvestTxgRPC(auth, account!.account_pubkey_type,
                                                    self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress, self.pageHolderVC.mReinvestReward!,
                                                    self.mFee, self.pageHolderVC.mMemo!,
                                                    privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
            return Signer.genSimulateetRewardAddressTxgRPC(auth, account!.account_pubkey_type,
                                                           self.pageHolderVC.mToChangeRewardAddress!,
                                                           self.mFee, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_VOTE) {
            return Signer.genSimulateVoteTxgRPC(auth, account!.account_pubkey_type,
                                                self.pageHolderVC.mProposals,
                                                self.mFee, self.pageHolderVC.mMemo!,
                                                privateKey, publicKey, self.chainType!)
            
        }
        
        //for starname custom msg
        else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
            return Signer.genSimulateRegisterDomainMsgTxgRPC(auth, account!.account_pubkey_type,
                                                             self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                             self.pageHolderVC.mStarnameDomainType!,
                                                             self.mFee, self.pageHolderVC.mMemo!,
                                                             privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
            return Signer.genSimulateRegisterAccountMsgTxgRPC(auth, account!.account_pubkey_type,
                                                              self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mAccount!.account_address, self.pageHolderVC.mStarnameResources_gRPC,
                                                              self.mFee, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
            return Signer.genSimulateDeleteDomainMsgTxgRPC (auth, account!.account_pubkey_type,
                                                            self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                            self.mFee, self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            return Signer.genSimulateDeleteAccountMsgTxgRPC (auth, account!.account_pubkey_type,
                                                             self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                             self.mFee, self.pageHolderVC.mMemo!,
                                                             privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            return Signer.genSimulateRenewDomainMsgTxgRPC (auth, account!.account_pubkey_type,
                                                           self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mAccount!.account_address,
                                                           self.mFee, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            return Signer.genSimulateRenewAccountMsgTxgRPC (auth, account!.account_pubkey_type,
                                                            self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount!, self.pageHolderVC.mAccount!.account_address,
                                                            self.mFee, self.pageHolderVC.mMemo!,
                                                            privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
            return Signer.genSimulateReplaceResourceMsgTxgRPC(auth, account!.account_pubkey_type,
                                                              self.pageHolderVC.mStarnameDomain!, self.pageHolderVC.mStarnameAccount, self.pageHolderVC.mAccount!.account_address,
                                                              self.pageHolderVC.mStarnameResources_gRPC,
                                                              self.mFee, self.pageHolderVC.mMemo!,
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
            return Signer.genSimulateSwapInMsgTxgRPC(auth,  account!.account_pubkey_type, swapRoutes,
                                                     self.pageHolderVC.mSwapInDenom!,
                                                     self.pageHolderVC.mSwapInAmount!.stringValue,
                                                     self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
            return Signer.genSimulateDepositPoolMsgTxgRPC(auth, account!.account_pubkey_type,
                                                          self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                          self.pageHolderVC.mLPCoin!.amount,
                                                          self.mFee, self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
            return Signer.genSimulateWithdrawPoolMsgTxgRPC(auth, account!.account_pubkey_type,
                                                           self.pageHolderVC.mPoolId!, self.pageHolderVC.mPoolCoin0!, self.pageHolderVC.mPoolCoin1!,
                                                           self.pageHolderVC.mLPCoin!.amount,
                                                           self.mFee, self.pageHolderVC.mMemo!,
                                                           privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_LOCK) {
            return Signer.genSimulateLockTokensMsgTxgRPC(auth, account!.account_pubkey_type,
                                                         self.pageHolderVC.mLPCoin!,
                                                         self.pageHolderVC.mLockupDuration!,
                                                         self.mFee, self.pageHolderVC.mMemo!,
                                                         privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
            var ids = Array<UInt64>()
            for lockup in self.pageHolderVC.mLockups! {
                ids.append(lockup.id)
            }
            return Signer.genSimulateBeginUnlockingsMsgTxgRPC(auth, account!.account_pubkey_type,
                                                              ids,
                                                              self.mFee, self.pageHolderVC.mMemo!,
                                                              privateKey, publicKey, self.chainType!)
            
        }
        
        else if (pageHolderVC.mType == TASK_TYPE_SIF_ADD_LP) {
            return Signer.genSimulateSifAddLpMsgTxgRPC(auth, account!.account_pubkey_type,
                                                       self.account!.account_address,
                                                       self.pageHolderVC.mPoolCoin0!.amount,
                                                       self.pageHolderVC.mPoolCoin1!.denom,
                                                       self.pageHolderVC.mPoolCoin1!.amount,
                                                       self.mFee, self.pageHolderVC.mMemo!,
                                                       privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_SIF_REMOVE_LP) {
            var basisPoints = ""
            let myShareAllAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyAllUnitAmount)
            let myShareWithdrawAmount = NSDecimalNumber.init(string: self.pageHolderVC.mSifMyWithdrawUnitAmount)
            basisPoints = myShareWithdrawAmount.multiplying(byPowerOf10: 4).dividing(by: myShareAllAmount, withBehavior: WUtils.handler0).stringValue
            
            return Signer.genSimulateSifRemoveLpMsgTxgRPC(auth, account!.account_pubkey_type,
                                                          self.account!.account_address,
                                                          self.pageHolderVC.mSifPool!.externalAsset.symbol,
                                                          basisPoints,
                                                          self.mFee, self.pageHolderVC.mMemo!,
                                                          privateKey, publicKey, self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_SIF_SWAP_CION) {
            return Signer.genSimulateSifSwapMsgTxgRPC(auth, account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mSwapInDenom!,
                                                      self.pageHolderVC.mSwapInAmount!.stringValue,
                                                      self.pageHolderVC.mSwapOutDenom!,
                                                      self.pageHolderVC.mSwapOutAmount!.stringValue,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      privateKey, publicKey, self.chainType!)
        }
        
        //for NFT
        else if (pageHolderVC.mType == TASK_TYPE_NFT_ISSUE) {
            let stationData = StationNFTData.init(self.pageHolderVC.mNFTName!, self.pageHolderVC.mNFTDescription!, NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                  self.pageHolderVC.mNFTDenomId!, self.account!.account_address)
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(stationData)
            
            if (pageHolderVC.chainType == .IRIS_MAIN) {
                return Signer.genSimulateIssueNftIrisTxgRPC(auth, account!.account_pubkey_type,
                                                            self.account!.account_address,
                                                            self.pageHolderVC.mNFTDenomId!,
                                                            self.pageHolderVC.mNFTDenomName!,
                                                            self.pageHolderVC.mNFTHash!.lowercased(),
                                                            self.pageHolderVC.mNFTName!,
                                                            NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                            String(data: jsonData, encoding: .utf8)!,
                                                            self.mFee, self.pageHolderVC.mMemo!,
                                                            self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                            self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftCroTxgRPC(auth, account!.account_pubkey_type,
                                                           self.account!.account_address,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.mNFTDenomName!,
                                                           self.pageHolderVC.mNFTHash!.lowercased(),
                                                           self.pageHolderVC.mNFTName!,
                                                           NFT_INFURA + self.pageHolderVC.mNFTHash!,
                                                           String(data: jsonData, encoding: .utf8)!,
                                                           self.mFee, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_NFT_SEND) {
            if (pageHolderVC.chainType == ChainType.IRIS_MAIN) {
                return Signer.genSimulateSendNftIrisTxgRPC(auth, account!.account_pubkey_type,
                                                           self.account!.account_address,
                                                           self.pageHolderVC.mRecipinetAddress!,
                                                           self.pageHolderVC.mNFTTokenId!,
                                                           self.pageHolderVC.mNFTDenomId!,
                                                           self.pageHolderVC.irisResponse!,
                                                           self.mFee, self.pageHolderVC.mMemo!,
                                                           self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                           self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateSendNftCroTxgRPC(auth, account!.account_pubkey_type,
                                                          self.account!.account_address,
                                                          self.pageHolderVC.mRecipinetAddress!,
                                                          self.pageHolderVC.mNFTTokenId!,
                                                          self.pageHolderVC.mNFTDenomId!,
                                                          self.pageHolderVC.croResponse!,
                                                          self.mFee, self.pageHolderVC.mMemo!,
                                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                          self.chainType!)
            }
            
        } else if (pageHolderVC.mType == TASK_TYPE_NFT_ISSUE_DENOM) {
            if (pageHolderVC.chainType == .IRIS_MAIN) {
                return Signer.genSimulateIssueNftDenomIrisTxgRPC(auth, account!.account_pubkey_type,
                                                                 self.account!.account_address,
                                                                 self.pageHolderVC.mNFTDenomId!,
                                                                 self.pageHolderVC.mNFTDenomName!,
                                                                 self.mFee, self.pageHolderVC.mMemo!,
                                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                 self.chainType!)
                
            } else if (self.chainType == .CRYPTO_MAIN) {
                return Signer.genSimulateIssueNftDenomCroTxgRPC(auth, account!.account_pubkey_type,
                                                                self.account!.account_address,
                                                                self.pageHolderVC.mNFTDenomId!,
                                                                self.pageHolderVC.mNFTDenomName!,
                                                                self.mFee, self.pageHolderVC.mMemo!,
                                                                self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                self.chainType!)
            }
            
        }
        
        //for desmos
        else if (pageHolderVC.mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
            return Signer.genSimulateSaveProfileTxgRPC(auth, account!.account_pubkey_type,
                                                       self.pageHolderVC.mAccount!.account_address,
                                                       self.pageHolderVC.mDesmosDtag!,
                                                       self.pageHolderVC.mDesmosNickName!,
                                                       self.pageHolderVC.mDesmosBio!,
                                                       (self.pageHolderVC.mDesmosProfileHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosProfileHash!,
                                                       (self.pageHolderVC.mDesmosCoverHash?.isEmpty == true) ? "" :  NFT_INFURA + self.pageHolderVC.mDesmosCoverHash!,
                                                       self.mFee, self.pageHolderVC.mMemo!,
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
            return Signer.genSimulateLinkChainTxgRPC(auth, account!.account_pubkey_type,
                                                     self.pageHolderVC.mAccount!.account_address,
                                                     self.pageHolderVC.mDesmosToLinkChain!,
                                                     toAccount,
                                                     toPrivateKey,
                                                     toPublicKey,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        }
        
        //for kava
        else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_CREATE) {
            return Signer.genSimulateKavaCDPCreate(auth, account!.account_pubkey_type,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mCollateral,
                                                   self.pageHolderVC.mPrincipal,
                                                   self.pageHolderVC.mCollateralParamType!,
                                                   self.mFee, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
            return Signer.genSimulateKavaCDPDeposit(auth, account!.account_pubkey_type,
                                                    self.account!.account_address,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mCollateral,
                                                    self.pageHolderVC.mCollateralParamType!,
                                                    self.mFee, self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
            return Signer.genSimulateKavaCDPWithdraw(auth, account!.account_pubkey_type,
                                                     self.account!.account_address,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mCollateral,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
            return Signer.genSimulateKavaCDPDrawDebt(auth, account!.account_pubkey_type,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPrincipal,
                                                     self.pageHolderVC.mCollateralParamType!,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_CDP_REPAY) {
            return Signer.genSimulateKavaCDPRepay(auth, account!.account_pubkey_type,
                                                  self.account!.account_address,
                                                  self.pageHolderVC.mPayment,
                                                  self.pageHolderVC.mCollateralParamType!,
                                                  self.mFee, self.pageHolderVC.mMemo!,
                                                  self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                  self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
            return Signer.genSimulateKavaHardDeposit(auth, account!.account_pubkey_type,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mHardPoolCoins!,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
               
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
            return Signer.genSimulateKavaHardWithdraw(auth, account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mHardPoolCoins!,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
                
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_BORROW) {
            return Signer.genSimulateKavaHardBorrow(auth, account!.account_pubkey_type,
                                                    self.account!.account_address,
                                                    self.pageHolderVC.mHardPoolCoins!,
                                                    self.mFee, self.pageHolderVC.mMemo!,
                                                    self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                    self.chainType!)
              
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_HARD_REPAY) {
            return Signer.genSimulateKavaHardRepay(auth, account!.account_pubkey_type,
                                                   self.account!.account_address,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mHardPoolCoins!,
                                                   self.mFee, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
             
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
            let slippage = "30000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return Signer.genSimulateKavaSwapDeposit(auth, account!.account_pubkey_type,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mPoolCoin0!,
                                                     self.pageHolderVC.mPoolCoin1!,
                                                     slippage,
                                                     deadline,
                                                     self.mFee, self.pageHolderVC.mMemo!,
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
            return Signer.genSimulateKavaSwapWithdraw(auth, account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mKavaShareAmount.stringValue,
                                                      coin0,
                                                      coin1,
                                                      deadline,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
            let inCoin = Coin.init(self.pageHolderVC.mSwapInDenom!, self.pageHolderVC.mSwapInAmount!.stringValue)
            let outCoin = Coin.init(self.pageHolderVC.mSwapOutDenom!, self.pageHolderVC.mSwapOutAmount!.stringValue)
            let slippage = "30000000000000000"
            let deadline = (Date().millisecondsSince1970 / 1000) + 300
            return  Signer.genSimulateKavaSwapExactForTokens(auth, account!.account_pubkey_type,
                                                             self.account!.account_address,
                                                             inCoin,
                                                             outCoin,
                                                             slippage,
                                                             deadline,
                                                             self.mFee, self.pageHolderVC.mMemo!,
                                                             self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                             self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
            // 2022.10.30 HARDCODING FOR FIX INCENTIVE
            return Signer.genSimulateKavaIncentiveAll(auth, account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      "large",
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
            return Signer.genSimulateKavaEarnDelegateMintDeposit(auth, account!.account_pubkey_type,
                                                                 self.account!.account_address,
                                                                 self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                                 self.pageHolderVC.mKavaEarnCoin,
                                                                 self.mFee, self.pageHolderVC.mMemo!,
                                                                 self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                                 self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW) {
            return Signer.genSimulateKavaEarnWithdraw(auth, account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                      self.pageHolderVC.mKavaEarnCoin,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
            
        }
        
        //for authz
        else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_CLAIM_REWARDS) {
            return Signer.genSimulateAuthzClaimReward(auth, account!.account_pubkey_type,
                                                      self.account!.account_address,
                                                      self.pageHolderVC.mGranterAddress!,
                                                      self.pageHolderVC.mGranterReward,
                                                      self.mFee, self.pageHolderVC.mMemo!,
                                                      self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                      self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN) {
            return Signer.genSimulateAuthzClaimCommission(auth, account!.account_pubkey_type,
                                                          self.account!.account_address,
                                                          self.pageHolderVC.mGranterAddress!,
                                                          WKey.getOpAddressFromAddress(self.pageHolderVC.mGranterAddress!, self.chainConfig),
                                                          self.mFee, self.pageHolderVC.mMemo!,
                                                          self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                          self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_VOTE) {
            return Signer.genSimulateAuthzVote(auth, account!.account_pubkey_type,
                                               self.account!.account_address,
                                               self.pageHolderVC.mGranterAddress!,
                                               self.pageHolderVC.mProposals,
                                               self.mFee, self.pageHolderVC.mMemo!,
                                               self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                               self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_DELEGATE) {
            return Signer.genSimulateAuthzDelegate(auth, account!.account_pubkey_type,
                                                   self.account!.account_address,
                                                   self.pageHolderVC.mGranterAddress!,
                                                   self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                   self.pageHolderVC.mToDelegateAmount!,
                                                   self.mFee, self.pageHolderVC.mMemo!,
                                                   self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                   self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_UNDELEGATE) {
            return Signer.genSimulateAuthzUndelegate(auth, account!.account_pubkey_type,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mGranterAddress!,
                                                     self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                     self.pageHolderVC.mToUndelegateAmount!,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_REDELEGATE) {
            return Signer.genSimulateAuthzRedelegate(auth, account!.account_pubkey_type,
                                                     self.account!.account_address,
                                                     self.pageHolderVC.mGranterAddress!,
                                                     self.pageHolderVC.mTargetValidator_gRPC!.operatorAddress,
                                                     self.pageHolderVC.mToReDelegateValidator_gRPC!.operatorAddress,
                                                     self.pageHolderVC.mToReDelegateAmount!,
                                                     self.mFee, self.pageHolderVC.mMemo!,
                                                     self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                                     self.chainType!)
            
        } else if (pageHolderVC.mType == TASK_TYPE_AUTHZ_SEND) {
            return Signer.genSimulateAuthzSend(auth, account!.account_pubkey_type,
                                               self.account!.account_address,
                                               self.pageHolderVC.mGranterAddress!,
                                               self.pageHolderVC.mRecipinetAddress!,
                                               self.pageHolderVC.mToSendAmount,
                                               self.mFee, self.pageHolderVC.mMemo!,
                                               self.pageHolderVC.privateKey!, self.pageHolderVC.publicKey!,
                                               self.chainType!)
        }
        
        return nil
    }
}
