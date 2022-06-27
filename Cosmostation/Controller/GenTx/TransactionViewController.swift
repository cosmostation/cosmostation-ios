//
//  TransactionViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 08/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController {

    @IBOutlet weak var chainBg: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepView: UIView!
    @IBOutlet weak var stepImg: UIImageView!
    @IBOutlet weak var stepDescription: UILabel!
    
    var mAccount: Account?
    var mUserChain: ChainType?
    var mType: String?
    
    var mTargetValidator_gRPC: Cosmos_Staking_V1beta1_Validator?
    var mRewardTargetValidators_gRPC = Array<Cosmos_Staking_V1beta1_Validator>()
    
    var mProposeId: String?
    var mProposalTitle: String?
    var mProposer: String?
    
    var mCollateralParamType: String?
    var mCDenom: String?
    var mMarketID: String?
    var mHardMoneyMarketDenom: String?
    var mKavaSwapPool: Kava_Swap_V1beta1_PoolResponse?
    var mKavaSwapPoolDeposit: Kava_Swap_V1beta1_DepositResponse?
    
    var mHtlcDenom: String = BNB_MAIN_DENOM     //now only support bnb bep3
    var mHtlcRefundSwapId: String?
    
    var mStarnameDomain: String?
    var mStarnameAccount: String?
    var mStarnameTime: Int64?
    var mStarnameDomainType: String?
    var mStarnameResources_gRPC: Array<Starnamed_X_Starname_V1beta1_Resource> = Array<Starnamed_X_Starname_V1beta1_Resource>()
    
    var mToSendDenom: String?
    
    var mPoolId: String?
    var mSwapInDenom: String?
    var mSwapOutDenom: String?
    var mPool: Osmosis_Gamm_Balancer_V1beta1_Pool?
    var mLockupDuration: Int64?
    var mLockups: Array<Osmosis_Lockup_PeriodLock>?
    
    var mSifPool: Sifnode_Clp_V1_Pool?
    
    var mIBCSendDenom: String?
    var mCw20SendContract: String?
    
    var mNFTDenomId: String?
    var mNFTTokenId: String?
    var irisResponse: Irismod_Nft_QueryNFTResponse?
    var croResponse: Chainmain_Nft_V1_QueryNFTResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mAccount = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        mUserChain = ChainFactory.getChainType(mAccount!.account_base_chain)
        
        if (mType == TASK_TYPE_DELEGATE) {
            stepDescription.text = NSLocalizedString("delegate_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_delegate", comment: "")
            
        } else if (mType == TASK_TYPE_UNDELEGATE) {
            stepDescription.text = NSLocalizedString("undelegate_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_undelegate", comment: "")
            
        } else if (mType == TASK_TYPE_REDELEGATE) {
            stepDescription.text = NSLocalizedString("redelegate_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_redelegate", comment: "")
            
        } else if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_IBC_CW20_TRANSFER) {
            stepDescription.text = NSLocalizedString("send_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_send", comment: "")
            
        } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
            stepDescription.text = NSLocalizedString("withdraw_single_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_reward", comment: "")
            
        } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
            stepDescription.text = NSLocalizedString("reward_address_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_reword_address_change", comment: "")
            
        } else if (mType == TASK_TYPE_REINVEST) {
            stepDescription.text = NSLocalizedString("reinvest_step_1", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_reinvest", comment: "")
            
        }
        
        else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
            stepDescription.text = NSLocalizedString("creat_cdp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_create_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
            stepDescription.text = NSLocalizedString("deposit_cdp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_deposit_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
            stepDescription.text = NSLocalizedString("withdraw_cdp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_withdraw_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
            stepDescription.text = NSLocalizedString("drawdebt_cdp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_drawdebt_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
            stepDescription.text = NSLocalizedString("repay_cdp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_repay_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_HTLC_SWAP) {
            stepDescription.text = NSLocalizedString("htlc_swap_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_interchain_swap", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
            stepDescription.text = NSLocalizedString("deposit_hardpool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_deposit_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
            stepDescription.text = NSLocalizedString("withdraw_hardpool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_withdraw_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
            stepDescription.text = NSLocalizedString("borrow_hardpool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_borrow_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
            stepDescription.text = NSLocalizedString("repay_hardpool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_repay_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
            stepDescription.text = NSLocalizedString("str_swap_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_swap_token", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
            stepDescription.text = NSLocalizedString("str_join_pool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_join", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
            stepDescription.text = NSLocalizedString("str_exit_pool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_exit", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
            stepDescription.text = NSLocalizedString("claim_incentive_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_claim_incentive", comment: "")
            
        } else if (mType == TASK_TYPE_OK_DEPOSIT) {
            stepDescription.text = NSLocalizedString("str_ok_stake_deposit_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_ok_deposit", comment: "")
            
        } else if (mType == TASK_TYPE_OK_WITHDRAW) {
            stepDescription.text = NSLocalizedString("str_ok_stake_withdraw_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_ok_withdraw", comment: "")
            
        } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
            stepDescription.text = NSLocalizedString("str_ok_direct_vote_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_ok_vote", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
            stepDescription.text = NSLocalizedString("str_starname_register_domain_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_registe_domain", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
            stepDescription.text = NSLocalizedString("str_starname_register_account_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_registe_account", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
            stepDescription.text = NSLocalizedString("str_starname_delete_starname_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_delete_domain", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            stepDescription.text = NSLocalizedString("str_starname_delete_starname_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_delete_account", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            stepDescription.text = NSLocalizedString("str_starname_renew_starname_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_renew_domain", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            stepDescription.text = NSLocalizedString("str_starname_renew_starname_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_renew_account", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
            stepDescription.text = NSLocalizedString("str_starname_replace_starname_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_update_resource", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
            stepDescription.text = NSLocalizedString("str_swap_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_swap_token", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
            stepDescription.text = NSLocalizedString("str_join_pool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_join", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
            stepDescription.text = NSLocalizedString("str_exit_pool_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_exit", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
            stepDescription.text = NSLocalizedString("str_osmosis_lock_token_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_lock_token_osmosis", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
            stepDescription.text = NSLocalizedString("str_osmosis_begin_unbonding_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_begin_unbonding_osmosis", comment: "")
            
        } else if (mType == TASK_TYPE_IBC_TRANSFER) {
            stepDescription.text = NSLocalizedString("str_ibc_transfer_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_ibc_transfer", comment: "")
            
        } else if (mType == TASK_TYPE_SIF_ADD_LP) {
            stepDescription.text = NSLocalizedString("str_sif_add_lp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_join", comment: "")
            
        } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
            stepDescription.text = NSLocalizedString("str_sif_remove_lp_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_exit", comment: "")
            
        } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
            stepDescription.text = NSLocalizedString("str_sif_swap_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_swap_token", comment: "")
            
        } else if (mType == TASK_TYPE_NFT_ISSUE) {
            stepDescription.text = NSLocalizedString("str_issue_nft_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_issue_nft", comment: "")
            
        } else if (mType == TASK_TYPE_NFT_SEND) {
            stepDescription.text = NSLocalizedString("str_send_nft_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_send_nft", comment: "")
            
        } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
            stepDescription.text = NSLocalizedString("str_issue_nft_denom_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_issue_nft_denom", comment: "")
            
        } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
            stepDescription.text = NSLocalizedString("str_create_profile_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_profile_create", comment: "")
            
        } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
            stepDescription.text = NSLocalizedString("str_account_link_step_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_account_chain_link", comment: "")
            
        }
        
        
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:))))
        self.stepView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:))))
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.stepChanged(_:)),
                                               name: Notification.Name("stepChanged"),
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("stepChanged"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "containerTxPage") {
            let StepVc = segue.destination as! StepGenTxViewController
            StepVc.topVC = self
            StepVc.mType = self.mType
            StepVc.mTargetValidator_gRPC = self.mTargetValidator_gRPC
            StepVc.mRewardTargetValidators_gRPC = self.mRewardTargetValidators_gRPC
            StepVc.mProposeId = self.mProposeId
            StepVc.mProposalTitle = self.mProposalTitle
            StepVc.mProposer = self.mProposer
            StepVc.mToSendDenom = self.mToSendDenom
            
            StepVc.mCDenom = self.mCDenom
            StepVc.mMarketID = self.mMarketID
            StepVc.mHtlcDenom = self.mHtlcDenom
            StepVc.mHtlcRefundSwapId = self.mHtlcRefundSwapId
            StepVc.mHardMoneyMarketDenom = self.mHardMoneyMarketDenom
            StepVc.mCollateralParamType = self.mCollateralParamType
            
            //grpc
            StepVc.mKavaSwapPool = self.mKavaSwapPool
            StepVc.mKavaSwapPoolDeposit = self.mKavaSwapPoolDeposit
            
            StepVc.mStarnameDomain = self.mStarnameDomain
            StepVc.mStarnameAccount = self.mStarnameAccount
            StepVc.mStarnameTime = self.mStarnameTime
            StepVc.mStarnameDomainType = self.mStarnameDomainType
            StepVc.mStarnameResources_gRPC = self.mStarnameResources_gRPC
            
            StepVc.mPoolId = self.mPoolId
            StepVc.mSwapInDenom = self.mSwapInDenom
            StepVc.mSwapOutDenom = self.mSwapOutDenom
            StepVc.mPool = self.mPool
            StepVc.mLockupDuration = self.mLockupDuration
            StepVc.mLockups = self.mLockups
            
            StepVc.mIBCSendDenom = self.mIBCSendDenom
            StepVc.mCw20SendContract = self.mCw20SendContract
            
            StepVc.mSifPool = self.mSifPool
            
            StepVc.mNFTDenomId = self.mNFTDenomId
            StepVc.mNFTTokenId = self.mNFTTokenId
            StepVc.irisResponse = self.irisResponse
            StepVc.croResponse = self.croResponse
        }
    }
    
    
    @objc func stepChanged(_ notification: NSNotification) {
        if let step = notification.userInfo?["step"] as? Int {
            if (step == 0) {
                if (mType == TASK_TYPE_DELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("delegate_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_UNDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("undelegate_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_REDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    stepDescription.text = NSLocalizedString("redelegate_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_IBC_CW20_TRANSFER) {
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    stepDescription.text = NSLocalizedString("send_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("withdraw_single_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("reward_address_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_REINVEST) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("reinvest_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_VOTE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("vote_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("creat_cdp_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("deposit_cdp_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("withdraw_cdp_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("drawdebt_cdp_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("repay_cdp_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("deposit_hardpool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("withdraw_hardpool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
                    stepDescription.text = NSLocalizedString("borrow_hardpool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
                    stepDescription.text = NSLocalizedString("repay_hardpool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
                    stepDescription.text = NSLocalizedString("str_swap_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
                    stepDescription.text = NSLocalizedString("claim_incentive_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_HTLC_SWAP) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("htlc_swap_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_OK_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_deposit_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OK_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_withdraw_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
                    stepDescription.text = NSLocalizedString("str_ok_direct_vote_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
                    stepDescription.text = NSLocalizedString("str_ok_direct_vote_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    stepDescription.text = NSLocalizedString("str_starname_register_account_step_0", comment: "")
                    
                } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN || mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_delete_starname_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN || mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_renew_starname_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
                    stepDescription.text = NSLocalizedString("str_starname_replace_starname_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
                    stepDescription.text = NSLocalizedString("str_swap_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_lock_token_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_begin_unbonding_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_IBC_TRANSFER) {
                    stepDescription.text = NSLocalizedString("str_ibc_transfer_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_SIF_ADD_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_add_lp_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_remove_lp_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
                    stepDescription.text = NSLocalizedString("str_sif_swap_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NFT_SEND) {
                    stepDescription.text = NSLocalizedString("str_send_nft_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_denom_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
                    stepDescription.text = NSLocalizedString("str_create_profile_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_account_link_step_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                }
                
                
            } else if (step == 1) {
                if (mType == TASK_TYPE_DELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("delegate_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_UNDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("delegate_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_REDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep5_2")
                    stepDescription.text = NSLocalizedString("redelegate_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_IBC_CW20_TRANSFER) {
                    stepImg.image = UIImage.init(named: "txStep5_2")
                    stepDescription.text = NSLocalizedString("send_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("delegate_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("delegate_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_REINVEST) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("delegate_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_VOTE) {
                   stepImg.image = UIImage.init(named: "txStep4_2")
                   stepDescription.text = NSLocalizedString("delegate_step_2", comment: "")
                   
                } else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("creat_cdp_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("deposit_cdp_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("withdraw_cdp_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("drawdebt_cdp_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("repay_cdp_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("deposit_hardpool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("withdraw_hardpool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
                    stepDescription.text = NSLocalizedString("borrow_hardpool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
                    stepDescription.text = NSLocalizedString("repay_hardpool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
                    stepDescription.text = NSLocalizedString("str_swap_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
                    stepDescription.text = NSLocalizedString("claim_incentive_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_HTLC_SWAP) {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    stepDescription.text = NSLocalizedString("htlc_swap_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_OK_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_deposit_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OK_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_withdraw_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
                    stepDescription.text = NSLocalizedString("str_ok_direct_vote_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
                    stepDescription.text = NSLocalizedString("str_starname_register_domain_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                    stepImg.image = UIImage.init(named: "txStep5_2")
                    stepDescription.text = NSLocalizedString("str_starname_register_account_step_1", comment: "")
                    
                } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN || mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_delete_starname_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN || mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_renew_starname_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
                    stepDescription.text = NSLocalizedString("str_starname_replace_starname_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
                    stepDescription.text = NSLocalizedString("str_swap_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_lock_token_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_begin_unbonding_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_IBC_TRANSFER) {
                    stepDescription.text = NSLocalizedString("str_ibc_transfer_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_2")
                    
                } else if (mType == TASK_TYPE_SIF_ADD_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_add_lp_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_remove_lp_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
                    stepDescription.text = NSLocalizedString("str_sif_swap_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_NFT_SEND) {
                    stepDescription.text = NSLocalizedString("str_send_nft_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_denom_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
                    stepDescription.text = NSLocalizedString("str_create_profile_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_account_link_step_1", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    
                }
                
                
            } else if (step == 2) {
                if (mType == TASK_TYPE_DELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("delegate_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_UNDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("delegate_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_REDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep5_3")
                    stepDescription.text = NSLocalizedString("redelegate_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_IBC_CW20_TRANSFER) {
                    stepImg.image = UIImage.init(named: "txStep5_3")
                    stepDescription.text = NSLocalizedString("send_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("delegate_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("delegate_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_REINVEST) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("delegate_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_VOTE) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("delegate_step_3", comment: "")
                  
                } else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("creat_cdp_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("deposit_cdp_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("withdraw_cdp_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("drawdebt_cdp_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("repay_cdp_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("deposit_hardpool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("withdraw_hardpool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
                    stepDescription.text = NSLocalizedString("borrow_hardpool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
                    stepDescription.text = NSLocalizedString("repay_hardpool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
                    stepDescription.text = NSLocalizedString("str_swap_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
                    stepDescription.text = NSLocalizedString("claim_incentive_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_HTLC_SWAP) {
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    stepDescription.text = NSLocalizedString("htlc_swap_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_OK_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_deposit_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OK_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_withdraw_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
                    stepDescription.text = NSLocalizedString("str_ok_direct_vote_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
                    stepDescription.text = NSLocalizedString("str_starname_register_domain_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                    stepImg.image = UIImage.init(named: "txStep5_3")
                    stepDescription.text = NSLocalizedString("str_starname_register_account_step_2", comment: "")
                    
                } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN || mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_delete_starname_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN || mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_renew_starname_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
                    stepDescription.text = NSLocalizedString("str_starname_replace_starname_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
                    stepDescription.text = NSLocalizedString("str_swap_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_lock_token_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_begin_unbonding_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_IBC_TRANSFER) {
                    stepDescription.text = NSLocalizedString("str_ibc_transfer_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_3")
                    
                } else if (mType == TASK_TYPE_SIF_ADD_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_add_lp_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_remove_lp_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
                    stepDescription.text = NSLocalizedString("str_sif_swap_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_NFT_SEND) {
                    stepDescription.text = NSLocalizedString("str_send_nft_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_denom_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
                    stepDescription.text = NSLocalizedString("str_create_profile_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_account_link_step_2", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                    
                }
                
                
            } else if (step == 3) {
                if (mType == TASK_TYPE_DELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("delegate_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_UNDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("undelegate_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_REDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep5_4")
                    stepDescription.text = NSLocalizedString("redelegate_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_IBC_CW20_TRANSFER) {
                    stepImg.image = UIImage.init(named: "txStep5_4")
                    stepDescription.text = NSLocalizedString("send_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("withdraw_single_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("reward_address_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_REINVEST) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("reinvest_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_VOTE) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("reinvest_step_4", comment: "")
                 
                } else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("creat_cdp_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("deposit_cdp_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("withdraw_cdp_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("drawdebt_cdp_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("repay_cdp_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("deposit_hardpool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("withdraw_hardpool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
                    stepDescription.text = NSLocalizedString("borrow_hardpool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
                    stepDescription.text = NSLocalizedString("repay_hardpool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
                    stepDescription.text = NSLocalizedString("str_swap_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
                    stepDescription.text = NSLocalizedString("claim_incentive_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_HTLC_SWAP) {
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    stepDescription.text = NSLocalizedString("htlc_swap_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_OK_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_deposit_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OK_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("str_ok_stake_withdraw_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
                    stepDescription.text = NSLocalizedString("str_ok_direct_vote_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
                    stepDescription.text = NSLocalizedString("str_starname_register_domain_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                    stepImg.image = UIImage.init(named: "txStep5_4")
                    stepDescription.text = NSLocalizedString("str_starname_register_account_step_3", comment: "")
                    
                } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN || mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_delete_starname_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN || mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_starname_renew_starname_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
                    stepDescription.text = NSLocalizedString("str_starname_replace_starname_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
                    stepDescription.text = NSLocalizedString("str_swap_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
                    stepDescription.text = NSLocalizedString("str_join_pool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
                    stepDescription.text = NSLocalizedString("str_exit_pool_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_lock_token_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
                    stepDescription.text = NSLocalizedString("str_osmosis_begin_unbonding_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_IBC_TRANSFER) {
                    stepDescription.text = NSLocalizedString("str_ibc_transfer_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_4")
                    
                } else if (mType == TASK_TYPE_SIF_ADD_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_add_lp_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
                    stepDescription.text = NSLocalizedString("str_sif_remove_lp_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
                    stepDescription.text = NSLocalizedString("str_sif_swap_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_NFT_SEND) {
                    stepDescription.text = NSLocalizedString("str_send_nft_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
                    stepDescription.text = NSLocalizedString("str_issue_nft_denom_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
                    stepDescription.text = NSLocalizedString("str_create_profile_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                    
                } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("str_account_link_step_3", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                }
                
            } else if (step == 4) {
                if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_IBC_CW20_TRANSFER) {
                    stepImg.image = UIImage.init(named: "txStep5_5")
                    stepDescription.text = NSLocalizedString("send_step_5", comment: "")
                    
                } else if (mType == TASK_TYPE_REDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep5_5")
                    stepDescription.text = NSLocalizedString("redelegate_step_5", comment: "")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                    stepImg.image = UIImage.init(named: "txStep5_5")
                    stepDescription.text = NSLocalizedString("str_starname_register_account_step_4", comment: "")
                    
                } else if (mType == TASK_TYPE_IBC_TRANSFER) {
                    stepDescription.text = NSLocalizedString("str_ibc_transfer_step_4", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_5")
                }
//                else if (mType == KAVA_MSG_TYPE_CLAIM_HARD_INCENTIVE_VV) {
//                    stepImg.image = UIImage.init(named: "txStep5_5")
//                    stepDescription.text = NSLocalizedString("reward_harvest_vv_step_4", comment: "")
//
//                }
                
            }
        }
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
}
