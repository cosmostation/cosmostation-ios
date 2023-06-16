//
//  StepGenTxViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 08/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import GRPC
import NIO
import HDWalletKit
import SwiftKeychainWrapper
import web3swift
import SwiftyJSON


class StepGenTxViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    
    fileprivate var currentIndex = 0
    var disableBounce = false
    
    var topVC: TransactionViewController!
    var mType: String?
    
    var mAccount: Account?
    var chainType: ChainType?
    var chainConfig: ChainConfig?
    var mBalances = Array<Balance>()
    
    var mToSendDenom: String?                   //denom or contract_address
    var mToSendAmount = Array<Coin>()
    var mRecipinetChainConfig: ChainConfig?
    var mRecipinetAddress: String?
    var mTransferType:String?
    var mMintscanAsset: MintscanAsset?
    var mMintscanTokens: MintscanToken?
    var mMintscanPath: MintscanPath?
    
    var mTargetValidator_gRPC: Cosmos_Staking_V1beta1_Validator?
    var mToDelegateAmount: Coin?
    var mToUndelegateAmount:Coin?
    var mRewardAddress: String?
    var mRewardTargetValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    
    var mToReDelegateAmount: Coin?
    var mToReDelegateValidator_gRPC: Cosmos_Staking_V1beta1_Validator?
    var mToReDelegateValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    
    var mCurrentRewardAddress: String?
    var mToChangeRewardAddress: String?
    
    var mReinvestReward: Coin?
    
    var mMemo: String?
    var mFee: Fee?
    
    var mCollateral = Coin.init()
    var mPrincipal = Coin.init()
    var mPayment = Coin.init()
    var mSender: String?
    
    var currentPrice: NSDecimalNumber?
    var liquidationPrice: NSDecimalNumber?
    var riskRate: NSDecimalNumber?
    var beforeLiquidationPrice: NSDecimalNumber?
    var afterLiquidationPrice: NSDecimalNumber?
    var beforeRiskRate: NSDecimalNumber?
    var afterRiskRate: NSDecimalNumber?
    var totalDepositAmount: NSDecimalNumber?
    var totalLoanAmount: NSDecimalNumber?
    
    var mBnbToken: BnbToken?
    
    var mVoteOpinion: String?
    var mProposals = Array<MintscanProposalDetail>()
    
    var mCollateralParamType: String?
    var mCDenom: String?
    var mPDenom: String?
    var mMarketID: String?
    var mIncentiveKavaReceivable = NSDecimalNumber.zero
    var mIncentiveHardReceivable = NSDecimalNumber.zero
    var mHardMoneyMarketDenom: String?
    var mHardPoolCoins: Array<Coin>?
    var mHardPoolCoin = Coin.init()
    var mKavaShareAmount = NSDecimalNumber.zero
    var mKavaCollateralParam: Kava_Cdp_V1beta1_CollateralParam?
    var mKavaSwapPool: Kava_Swap_V1beta1_PoolResponse?
    var mKavaSwapPoolDeposit: Kava_Swap_V1beta1_DepositResponse?
    var mKavaEarnDeposit = Array<Coin>()
    var mKavaEarnCoin = Coin.init()
    
    
    var mHtlcDenom: String?
    var mHtlcToChain: ChainType?
    var mHtlcToAccount: Account?
    var mHtlcSendFee: Fee?
    var mHtlcClaimFee: Fee?
    var mKavaSwapParam: KavaSwapParam?
    var mKavaSwapSupply: KavaSwapSupply?
    
    
    var mSwapRemainCap: NSDecimalNumber = NSDecimalNumber.zero
    var mSwapMaxOnce: NSDecimalNumber = NSDecimalNumber.zero
    
    var mOkToStaking = Coin.init()
    var mOkToWithdraw = Coin.init()
    var mOkVoteValidators: Array<String> = Array<String>()
    
    var mStarnameDomain: String?
    var mStarnameAccount: String?
    var mStarnameTime: Int64?
    var mStarnameDomainType: String?
    var mStarnameResources_gRPC: Array<Starnamed_X_Starname_V1beta1_Resource> = Array<Starnamed_X_Starname_V1beta1_Resource>()
    
    var mPoolId: String?
    var mSwapInDenom: String?
    var mSwapOutDenom: String?
    var mSwapInAmount: NSDecimalNumber?
    var mSwapOutAmount: NSDecimalNumber?
    var mSwapInCoin: Coin?
    var mPoolCoin0: Coin?
    var mPoolCoin1: Coin?
    var mLPCoin: Coin?
    var mLockupDuration: Int64?
    
    var mNFTHash: String?
    var mNFTName: String?
    var mNFTDescription: String?
    var mNFTDenomId: String?
    var mNFTDenomName: String?
    var mNFTTokenId: String?
    var irisResponse: Irismod_Nft_QueryNFTResponse?
    var croResponse: Chainmain_Nft_V1_QueryNFTResponse?
    
    var mDesmosDtag: String?
    var mDesmosNickName: String?
    var mDesmosBio: String?
    var mDesmosCoverHash: String?
    var mDesmosProfileHash: String?
    var mDesmosToLinkChain: ChainType?
    var mDesmosToLinkAccountId: Int64!
    var mDesmosAirDropAmount: String?

    var mGrant: Cosmos_Authz_V1beta1_Grant?
    var mGranterData: GranterData?
    
    var mEthereumTransaction: EthereumTransaction?
    
    var mChainId: String?
    var mStride_Stakeibc_HostZone: Stride_Stakeibc_HostZone?
    
    
    var neutronVault: NeutronVault?
    var neutronVaultAmount = Array<Coin>()
    var neutronProposalModule: NeutronProposalModule?
    var neutronProposal: JSON?
    var neutronVoteSingleOpinion: String?
    var neutronVoteMultiOpinion: Int?
    var neutronSwapPool: NeutronSwapPool?
    var neutronInputPair: NeutronSwapPoolPair?
    var neutronOutputPair: NeutronSwapPoolPair?
    var beliefPrice: NSDecimalNumber?
    
    lazy var orderedViewControllers: [UIViewController] = {
        if (mType == TASK_TYPE_TRANSFER) {
            if (WUtils.isGRPC(chainType!)) {
                return [Transfer1ViewController(nibName: "Transfer1ViewController", bundle: nil),
                        Transfer2ViewController(nibName: "Transfer2ViewController", bundle: nil),
                        MemoViewController(nibName: "MemoViewController", bundle: nil),
                        FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                        Transfer5ViewController(nibName: "Transfer5ViewController", bundle: nil)]
            } else {
                return [Transfer1ViewController(nibName: "Transfer1ViewController", bundle: nil),
                        Transfer2ViewController(nibName: "Transfer2ViewController", bundle: nil),
                        MemoViewController(nibName: "MemoViewController", bundle: nil),
                        FeeLcdViewController(nibName: "FeeLcdViewController", bundle: nil),
                        Transfer5ViewController(nibName: "Transfer5ViewController", bundle: nil)]
            }
            
        } else if (mType == TASK_TYPE_DELEGATE) {
            return [Delegate1ViewController(nibName: "Delegate1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    Delegate4ViewController(nibName: "Delegate4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_UNDELEGATE) {
            return [Undelegate1ViewController(nibName: "Undelegate1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    Undelegate4ViewController(nibName: "Undelegate4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_REDELEGATE) {
            return [Redelegate1ViewController(nibName: "Redelegate1ViewController", bundle: nil),
                    Redelegate2ViewController(nibName: "Redelegate2ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    Redelegate5ViewController(nibName: "Redelegate5ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
            return [ClaimReward1ViewController(nibName: "ClaimReward1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    ClaimReward4ViewController(nibName: "ClaimReward4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
            return [RewardAddress1ViewController(nibName: "RewardAddress1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    RewardAddress4ViewController(nibName: "RewardAddress4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_REINVEST) {
            return [ReInvest1ViewController(nibName: "ReInvest1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    ReInvest4ViewController(nibName: "ReInvest4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_VOTE) {
            return [Vote1ViewController(nibName: "Vote1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    Vote4ViewController(nibName: "Vote4ViewController", bundle: nil)]
        }
        
        //KAVA
        else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
            return [CdpCreate1ViewController(nibName: "CdpCreate1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    CdpCreate4ViewController(nibName: "CdpCreate4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
            return [CdpDeposit1ViewController(nibName: "CdpDeposit1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    CdpDeposit4ViewController(nibName: "CdpDeposit4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
            return [CdpWithdraw1ViewController(nibName: "CdpWithdraw1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    CdpWithdraw4ViewController(nibName: "CdpWithdraw4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
            return [CdpDrawDebt1ViewController(nibName: "CdpDrawDebt1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    CdpDrawDebt4ViewController(nibName: "CdpDrawDebt4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
            return [CdpDrawRepay1ViewController(nibName: "CdpDrawRepay1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    CdpDrawRepay4ViewController(nibName: "CdpDrawRepay4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
            return [HardPoolDeposit0ViewController(nibName: "HardPoolDeposit0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    HardPoolDeposit3ViewController(nibName: "HardPoolDeposit3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
            return [HardPoolWithdraw0ViewController(nibName: "HardPoolWithdraw0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    HardPoolWithdraw3ViewController(nibName: "HardPoolWithdraw3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
            return [HardPoolBorrow0ViewController(nibName: "HardPoolBorrow0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    HardPoolBorrow3ViewController(nibName: "HardPoolBorrow3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
            return [HardPoolRepay0ViewController(nibName: "HardPoolRepay0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    HardPoolRepay3ViewController(nibName: "HardPoolRepay3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
            return [KavaSwap0ViewController(nibName: "KavaSwap0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    KavaSwap3ViewController(nibName: "KavaSwap3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
            return [KavaSwapJoin0ViewController(nibName: "KavaSwapJoin0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    KavaSwapJoin3ViewController(nibName: "KavaSwapJoin3ViewController", bundle: nil)]

        } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
            return [KavaSwapExit0ViewController(nibName: "KavaSwapExit0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    KavaSwapExit3ViewController(nibName: "KavaSwapExit3ViewController", bundle: nil)]

        } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
            return [KavaIncentiveClaim0ViewController(nibName: "KavaIncentiveClaim0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    KavaIncentiveClaim3ViewController(nibName: "KavaIncentiveClaim3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT || mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW) {
            return [KavaLiquidity0ViewController(nibName: "KavaLiquidity0ViewController", bundle: nil),
                    KavaLiquidity1ViewController(nibName: "KavaLiquidity1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    KavaLiquidity4ViewController(nibName: "KavaLiquidity4ViewController", bundle: nil)]
        }
        
        //BEP3 Stranfer (KAVA, BINANCE)
        else if (mType == TASK_TYPE_HTLC_SWAP) {
            return [HtlcSend0ViewController(nibName: "HtlcSend0ViewController", bundle: nil),
                    HtlcSend1ViewController(nibName: "HtlcSend1ViewController", bundle: nil),
                    HtlcSend2ViewController(nibName: "HtlcSend2ViewController", bundle: nil),
                    HtlcSend3ViewController(nibName: "HtlcSend3ViewController", bundle: nil)]
        }
        
        //OEC
        else if (mType == TASK_TYPE_OK_DEPOSIT) {
            return [OkDeposit1ViewController(nibName: "OkDeposit1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeLcdViewController(nibName: "FeeLcdViewController", bundle: nil),
                    OkDeposit4ViewController(nibName: "OkDeposit4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_OK_WITHDRAW) {
            return [OkWithdraw1ViewController(nibName: "OkWithdraw1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeLcdViewController(nibName: "FeeLcdViewController", bundle: nil),
                    OkWithdraw4ViewController(nibName: "OkWithdraw4ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
            return [OkVote1ViewController(nibName: "OkVote1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeLcdViewController(nibName: "FeeLcdViewController", bundle: nil),
                    OkVote4ViewController(nibName: "OkVote4ViewController", bundle: nil)]
        }
        
        //STARTNAME
        else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
            return [RegisterDomain0ViewController(nibName: "RegisterDomain0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    RegisterDomain3ViewController(nibName: "RegisterDomain3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
            return [RegisterAccount0ViewController(nibName: "RegisterAccount0ViewController", bundle: nil),
                    RegisterAccount1ViewController(nibName: "RegisterAccount1ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    RegisterAccount4ViewController(nibName: "RegisterAccount4ViewController", bundle: nil)]

        } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN || mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            return [DeleteStarname0ViewController(nibName: "DeleteStarname0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    DeleteStarname3ViewController(nibName: "DeleteStarname3ViewController", bundle: nil)]

        } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN || mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            return [RenewStarname0ViewController(nibName: "RenewStarname0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    RenewStarname3ViewController(nibName: "RenewStarname3ViewController", bundle: nil)]

        } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
            return [ReplaceResource0ViewController(nibName: "ReplaceResource0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    ReplaceResource3ViewController(nibName: "ReplaceResource3ViewController", bundle: nil)]
        }
        
        //OSMOSIS
        else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
            return [Swap0ViewController(nibName: "Swap0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    Swap3ViewController(nibName: "Swap3ViewController", bundle: nil)]
            
        }
        
        //DESMOS
        else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
            return [GenProfile0ViewController(nibName: "GenProfile0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    GenProfile3ViewController(nibName: "GenProfile3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
            return [LinkChainAccount0ViewController(nibName: "LinkChainAccount0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    LinkChainAccount3ViewController(nibName: "LinkChainAccount3ViewController", bundle: nil)]
        }
        
        //NFT
        else if (mType == TASK_TYPE_NFT_ISSUE) {
            return [GenNFT0ViewController(nibName: "GenNFT0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    GenNFT3ViewController(nibName: "GenNFT3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_NFT_SEND) {
            return [SendNFT0ViewController(nibName: "SendNFT0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    SendNFT3ViewController(nibName: "SendNFT3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
            return [GenDenom0ViewController(nibName: "GenDenom0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    GenDenom3ViewController(nibName: "GenDenom3ViewController", bundle: nil)]
        }
        
        //AUTHZ
        else if (mType == TASK_TYPE_AUTHZ_CLAIM_REWARDS) {
           return [AuthzClaimReward1ViewController(nibName: "AuthzClaimReward1ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzClaimReward4ViewController(nibName: "AuthzClaimReward4ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN) {
           return [AuthzClaimCommisstion1ViewController(nibName: "AuthzClaimCommisstion1ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzClaimCommisstion4ViewController(nibName: "AuthzClaimCommisstion4ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_AUTHZ_VOTE) {
           return [AuthzVote1ViewController(nibName: "AuthzVote1ViewController", bundle: nil),
                   AuthzVote2ViewController(nibName: "AuthzVote2ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzVote5ViewController(nibName: "AuthzVote5ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_AUTHZ_DELEGATE) {
           return [AuthzDelegate1ViewController(nibName: "AuthzDelegate1ViewController", bundle: nil),
                   AuthzDelegate2ViewController(nibName: "AuthzDelegate2ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzDelegate5ViewController(nibName: "AuthzDelegate5ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_AUTHZ_UNDELEGATE) {
           return [AuthzUndelegate1ViewController(nibName: "AuthzUndelegate1ViewController", bundle: nil),
                   AuthzUndelegate2ViewController(nibName: "AuthzUndelegate2ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzUndelegate5ViewController(nibName: "AuthzUndelegate5ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_AUTHZ_REDELEGATE) {
           return [AuthzRedelegate1ViewController(nibName: "AuthzRedelegate1ViewController", bundle: nil),
                   AuthzRedelegate2ViewController(nibName: "AuthzRedelegate2ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzRedelegate5ViewController(nibName: "AuthzRedelegate5ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_AUTHZ_SEND) {
           return [AuthzSend1ViewController(nibName: "AuthzSend1ViewController", bundle: nil),
                   AuthzSend2ViewController(nibName: "AuthzSend2ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   AuthzSend5ViewController(nibName: "AuthzSend5ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_STAKE) {
           return [StrideLiquid0ViewController(nibName: "StrideLiquid0ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   StrideLiquid4ViewController(nibName: "StrideLiquid4ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
           return [StrideLiquid0ViewController(nibName: "StrideLiquid0ViewController", bundle: nil),
                   StrideLiquid1ViewController(nibName: "StrideLiquid1ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   StrideLiquid4ViewController(nibName: "StrideLiquid4ViewController", bundle: nil)]
           
       } else if (mType == TASK_TYPE_PERSIS_LIQUIDITY_STAKE || mType == TASK_TYPE_PERSIS_LIQUIDITY_REDEEM) {
           return [PersisLiquid0ViewController(nibName: "PersisLiquid0ViewController", bundle: nil),
                   MemoViewController(nibName: "MemoViewController", bundle: nil),
                   FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                   PersisLiquid3ViewController(nibName: "PersisLiquid3ViewController", bundle: nil)]
       }
        
        else if (mType == TASK_TYPE_NEUTRON_VAULTE_DEPOSIT || mType == TASK_TYPE_NEUTRON_VAULTE_WITHDRAW) {
            return [VaultContract0ViewController(nibName: "VaultContract0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    VaultContract3ViewController(nibName: "VaultContract3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_NEUTRON_VOTE_SINGLE) {
            return [SingleVote0ViewController(nibName: "SingleVote0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    NeuVote3ViewController(nibName: "NeuVote3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_NEUTRON_VOTE_MULTI) {
            return [MultiVote0ViewController(nibName: "MultiVote0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    NeuVote3ViewController(nibName: "NeuVote3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_NEUTRON_VOTE_OVERRULE) {
            return [OverruleVote0ViewController(nibName: "OverruleVote0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    NeuVote3ViewController(nibName: "NeuVote3ViewController", bundle: nil)]
            
        } else if (mType == TASK_TYPE_NEUTRON_SWAP_TOKEN) {
            return [NeuSwap0ViewController(nibName: "NeuSwap0ViewController", bundle: nil),
                    MemoViewController(nibName: "MemoViewController", bundle: nil),
                    FeeGrpcViewController(nibName: "FeeGrpcViewController", bundle: nil),
                    NeuSwap3ViewController(nibName: "NeuSwap3ViewController", bundle: nil)]
        }
                  
        
        else {
            return[]
        }
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mAccount        = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        mBalances       = mAccount!.account_balances
        chainType       = ChainFactory.getChainType(mAccount!.account_base_chain)
        chainConfig     = ChainFactory.getChainConfig(chainType)
        mBnbToken       = BaseData.instance.bnbToken(mToSendDenom)
        
        self.getKey()
        
        if (mType == TASK_TYPE_REDELEGATE) {
            self.onFetchBondedValidators(0)
            
        } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
            if let votedVals = BaseData.instance.mOkStaking?.validator_address {
                self.mOkVoteValidators = votedVals
            } else {
                self.mOkVoteValidators = Array<String>()
            }
        }
            
        self.dataSource = self
        self.delegate = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.delegate = self
                subView.isScrollEnabled = false
                subView.bouncesZoom = false
            }
        }
        disableBounce = true
    }
    
    func newVc(viewController: String) ->UIViewController {
        return UIStoryboard(name: "GenTx", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }

    func onBeforePage() {
        disableBounce = false
        if (currentIndex == 0) {
            self.navigationController?.popViewController(animated: true)
        } else {
            setViewControllers([orderedViewControllers[currentIndex - 1]], direction: .reverse, animated: true, completion: { (finished) -> Void in
                self.currentIndex = self.currentIndex - 1
                let value:[String: Int] = ["step": self.currentIndex ]
                NotificationCenter.default.post(name: Notification.Name("stepChanged"), object: nil, userInfo: value)
                let currentVC = self.orderedViewControllers[self.currentIndex] as! BaseViewController
                currentVC.enableUserInteraction()
                self.disableBounce = true
            })
        }
        
    }
    
    func onNextPage() {
        disableBounce = false
        if (currentIndex >= (orderedViewControllers.count - 1)) { return }
        
        setViewControllers([orderedViewControllers[currentIndex + 1]], direction: .forward, animated: true, completion: { (finished) -> Void in
            self.currentIndex = self.currentIndex + 1
            let value:[String: Int] = ["step": self.currentIndex ]
            NotificationCenter.default.post(name: Notification.Name("stepChanged"), object: nil, userInfo: value)
            let currentVC = self.orderedViewControllers[self.currentIndex] as! BaseViewController
            currentVC.enableUserInteraction()
            self.disableBounce = true
        })
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(!completed) {
            
        } else {
            if let currentViewController = pageViewController.viewControllers?.first,
                let index = orderedViewControllers.index(of: currentViewController) {
                currentIndex = index
            }
            let value:[String: Int] = ["step": currentIndex]
            NotificationCenter.default.post(name: Notification.Name("stepChanged"), object: nil, userInfo: value)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(disableBounce) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(disableBounce) {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
        }
    }
    
    func onFetchBondedValidators(_ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
                let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
                let response = try Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req).response.wait()
                response.validators.forEach { validator in
                    if (validator.operatorAddress != self.mTargetValidator_gRPC?.operatorAddress) {
                        self.mToReDelegateValidators_gRPC.append(validator)
                    }
                }
            } catch {
                print("onFetchgRPCBondedValidators failed: \(error)")
            }
            
            DispatchQueue.main.async(execute: {
                self.sortByPower()
            });
        }
        
    }
    
    func sortByPower() {
        mToReDelegateValidators_gRPC.sort{
            if ($0.description_p.moniker == "Cosmostation") { return true }
            if ($1.description_p.moniker == "Cosmostation") { return false }
            if ($0.jailed && !$1.jailed) { return false }
            if (!$0.jailed && $1.jailed) { return true }
            return Double($0.tokens)! > Double($1.tokens)!
        }
    }
    
    
    var privateKey: Data?
    var publicKey: Data?
    func getKey() {
        DispatchQueue.global().async {
            if (BaseData.instance.getUsingEnginerMode()) {
                if (self.mAccount?.account_from_mnemonic == true) {
                    if let words = KeychainWrapper.standard.string(forKey: self.mAccount!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") {
                        self.privateKey = KeyFac.getPrivateRaw(words, self.mAccount!)
                        self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    }
                    
                } else {
                    if let key = KeychainWrapper.standard.string(forKey: self.mAccount!.getPrivateKeySha1()) {
                        self.privateKey = KeyFac.getPrivateFromString(key)
                        self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                    }
                }
                
            } else {
                //Speed up for get privatekey with non-enginerMode
                if let key = KeychainWrapper.standard.string(forKey: self.mAccount!.getPrivateKeySha1()) {
                    self.privateKey = KeyFac.getPrivateFromString(key)
                    self.publicKey = KeyFac.getPublicFromPrivateKey(self.privateKey!)
                }
            }
        }
    }
}
