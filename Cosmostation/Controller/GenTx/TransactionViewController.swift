//
//  TransactionViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 08/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    
    var mProposals = Array<MintscanProposalDetail>()
    
    var mCollateralParamType: String?
    var mCDenom: String?
    var mMarketID: String?
    var mHardMoneyMarketDenom: String?
    var mKavaSwapPool: Kava_Swap_V1beta1_PoolResponse?
    var mKavaSwapPoolDeposit: Kava_Swap_V1beta1_DepositResponse?
    var mKavaEarnDeposit = Array<Coin>()
    
    var mHtlcDenom: String = BNB_MAIN_DENOM     //now only support bnb bep3
    
    var mStarnameDomain: String?
    var mStarnameAccount: String?
    var mStarnameTime: Int64?
    var mStarnameDomainType: String?
    var mStarnameResources_gRPC: Array<Starnamed_X_Starname_V1beta1_Resource> = Array<Starnamed_X_Starname_V1beta1_Resource>()
    
    var mToSendDenom: String?
    
    var mPoolId: String?
    var mSwapInDenom: String?
    var mSwapOutDenom: String?
    var mLockupDuration: Int64?
    
    var mSifPool: Sifnode_Clp_V1_Pool?
    
    var mNFTDenomId: String?
    var mNFTTokenId: String?
    var irisResponse: Irismod_Nft_QueryNFTResponse?
    var croResponse: Chainmain_Nft_V1_QueryNFTResponse?
    
    var neutronVault: NeutronVault?
    var neutronProposalModule: NeutronProposalModule?
    var neutronProposal: JSON?
    var neutronSwapPool: NeutronSwapPool?
    var neutronInputPair: NeutronSwapPoolPair?
    var neutronOutputPair: NeutronSwapPoolPair?
    
    // MARK: - for authz tx
    var mGrant: Cosmos_Authz_V1beta1_Grant?
    var mGranterData: GranterData?
    
    var mChainId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mAccount = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        mUserChain = ChainFactory.getChainType(mAccount!.account_base_chain)
        
        if (mType == TASK_TYPE_DELEGATE) {
            stepImg.image = UIImage.init(named: "txStep4_1")
            stepDescription.text = NSLocalizedString("tx_delegate_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_delegate", comment: "")
            
        } else if (mType == TASK_TYPE_UNDELEGATE) {
            stepImg.image = UIImage.init(named: "txStep4_1")
            stepDescription.text = NSLocalizedString("tx_undelegate_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_undelegate", comment: "")
            
        } else if (mType == TASK_TYPE_REDELEGATE) {
            stepImg.image = UIImage.init(named: "txStep5_1")
            stepDescription.text = NSLocalizedString("tx_redelegate_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_redelegate", comment: "")
            
        } else if (mType == TASK_TYPE_TRANSFER) {
            stepImg.image = UIImage.init(named: "txStep5_1")
            stepDescription.text = NSLocalizedString("tx_send_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_send", comment: "")
            
        } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
            stepImg.image = UIImage.init(named: "txStep4_1")
            stepDescription.text = NSLocalizedString("tx_claim_staking_reward_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_reward", comment: "")
            
        } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
            stepImg.image = UIImage.init(named: "txStep4_1")
            stepDescription.text = NSLocalizedString("tx_change_reward_address_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_reword_address_change", comment: "")
            
        } else if (mType == TASK_TYPE_REINVEST) {
            stepImg.image = UIImage.init(named: "txStep4_1")
            stepDescription.text = NSLocalizedString("tx_compounding_0", comment: "")
            self.titleLabel.text =  NSLocalizedString("title_reinvest", comment: "")
            
        }
        
        else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
            stepDescription.text = NSLocalizedString("tx_create_cdp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_create_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
            stepDescription.text = NSLocalizedString("tx_deposit_cdp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_deposit_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
            stepDescription.text = NSLocalizedString("tx_withdraw_cdp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_withdraw_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
            stepDescription.text = NSLocalizedString("tx_drawdebt_cdp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_drawdebt_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
            stepDescription.text = NSLocalizedString("tx_repayt_cdp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_repay_cdp", comment: "")
            
        } else if (mType == TASK_TYPE_HTLC_SWAP) {
            stepDescription.text = NSLocalizedString("tx_bep_swap_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_interchain_swap", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
            stepDescription.text = NSLocalizedString("tx_deposit_hardpool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_deposit_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
            stepDescription.text = NSLocalizedString("tx_withdraw_hardpool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_withdraw_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
            stepDescription.text = NSLocalizedString("tx_borrow_hardpool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_borrow_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
            stepDescription.text = NSLocalizedString("tx_repay_hardpool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_repay_hardpool", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
            stepDescription.text = NSLocalizedString("tx_swap_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_swap_token", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
            stepDescription.text = NSLocalizedString("tx_join_pool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_join", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
            stepDescription.text = NSLocalizedString("tx_exit_pool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_exit", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
            stepDescription.text = NSLocalizedString("tx_claim_incentive_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_claim_incentive", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
            stepDescription.text = NSLocalizedString("tx_add_liquidity_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_add_liquidity", comment: "")
            
        } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW) {
            stepDescription.text = NSLocalizedString("tx_remove_liquidity_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_remove_liquidity", comment: "")
            
        } else if (mType == TASK_TYPE_OK_DEPOSIT) {
            stepDescription.text = NSLocalizedString("tx_ok_stake_deposit_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_ok_deposit", comment: "")
            
        } else if (mType == TASK_TYPE_OK_WITHDRAW) {
            stepDescription.text = NSLocalizedString("tx_ok_stake_withdraw_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_ok_withdraw", comment: "")
            
        } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
            stepDescription.text = NSLocalizedString("tx_ok_direct_vote_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_ok_vote", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
            stepDescription.text = NSLocalizedString("tx_starname_register_domain_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_registe_domain", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
            stepDescription.text = NSLocalizedString("tx_starname_register_account_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_registe_account", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN) {
            stepDescription.text = NSLocalizedString("tx_starname_delete_starname_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_delete_domain", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
            stepDescription.text = NSLocalizedString("tx_starname_delete_starname_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_delete_account", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN) {
            stepDescription.text = NSLocalizedString("tx_starname_renew_starname_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_renew_domain", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
            stepDescription.text = NSLocalizedString("tx_starname_renew_starname_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_renew_account", comment: "")
            
        } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
            stepDescription.text = NSLocalizedString("tx_starname_replace_starname_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_starname_update_resource", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
            stepDescription.text = NSLocalizedString("tx_swap_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_swap_token", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
            stepDescription.text = NSLocalizedString("tx_join_pool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_join", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
            stepDescription.text = NSLocalizedString("tx_exit_pool_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_exit", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
            stepDescription.text = NSLocalizedString("tx_osmosis_lock_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_lock_token_osmosis", comment: "")
            
        } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
            stepDescription.text = NSLocalizedString("tx_osmosis_begin_unbonding_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_begin_unbonding_osmosis", comment: "")
            
        } else if (mType == TASK_TYPE_SIF_ADD_LP) {
            stepDescription.text = NSLocalizedString("tx_sif_add_lp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_join", comment: "")
            
        } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
            stepDescription.text = NSLocalizedString("tx_sif_remove_lp_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_pool_exit", comment: "")
            
        } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
            stepDescription.text = NSLocalizedString("tx_swap_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_swap_token", comment: "")
            
        } else if (mType == TASK_TYPE_NFT_ISSUE) {
            stepDescription.text = NSLocalizedString("tx_issue_nft_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_issue_nft", comment: "")
            
        } else if (mType == TASK_TYPE_NFT_SEND) {
            stepDescription.text = NSLocalizedString("tx_send_nft_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_send_nft", comment: "")
            
        } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
            stepDescription.text = NSLocalizedString("tx_issue_nft_denom_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_issue_nft_denom", comment: "")
            
        } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
            stepDescription.text = NSLocalizedString("tx_desmos_create_profile_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_profile_create", comment: "")
            
        } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
            stepDescription.text = NSLocalizedString("tx_desmos_account_link_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_account_chain_link", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_CLAIM_REWARDS) {
            stepDescription.text = NSLocalizedString("tx_authz_claim_reward_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_claim_reward", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN) {
            stepDescription.text = NSLocalizedString("tx_authz_claim_commission_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_claim_commission", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_VOTE) {
            stepDescription.text = NSLocalizedString("tx_authz_vote_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_vote", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_DELEGATE) {
            stepDescription.text = NSLocalizedString("tx_authz_delegate_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_delegate", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_UNDELEGATE) {
            stepDescription.text = NSLocalizedString("tx_authz_undelegate_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_undelegate", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_REDELEGATE) {
            stepDescription.text = NSLocalizedString("tx_authz_redelegate_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_redelegate", comment: "")
            
        } else if (mType == TASK_TYPE_AUTHZ_SEND) {
            stepDescription.text = NSLocalizedString("tx_authz_send_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_authz_send", comment: "")
            
        } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_STAKE) {
            stepDescription.text = NSLocalizedString("tx_liquid_staking_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_liquid_staking", comment: "")
            
        } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
            stepDescription.text = NSLocalizedString("tx_liquid_unstaking_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep5_1")
            self.titleLabel.text =  NSLocalizedString("title_liquid_unstaking", comment: "")
            
        } else if (mType == TASK_TYPE_PERSIS_LIQUIDITY_STAKE) {
            stepDescription.text = NSLocalizedString("tx_liquid_staking_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_liquid_staking", comment: "")
            
        } else if (mType == TASK_TYPE_PERSIS_LIQUIDITY_REDEEM) {
            stepDescription.text = NSLocalizedString("tx_liquid_redeem_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            self.titleLabel.text =  NSLocalizedString("title_liquid_redeem", comment: "")
            
        }
        
        else if (mType == TASK_TYPE_NEUTRON_VAULTE_DEPOSIT) {
            stepDescription.text = NSLocalizedString("tx_vaults_deposit_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            titleLabel.text =  NSLocalizedString("title_vaults_deposit", comment: "")
            
        } else if (mType == TASK_TYPE_NEUTRON_VAULTE_WITHDRAW) {
            stepDescription.text = NSLocalizedString("tx_vaults_withdraw_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            titleLabel.text =  NSLocalizedString("title_vaults_withdraw", comment: "")
            
        } else if (mType == TASK_TYPE_NEUTRON_VOTE_SINGLE) {
            stepDescription.text = NSLocalizedString("tx_neutron_vote_single_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            titleLabel.text =  NSLocalizedString("title_neutron_vote_single", comment: "")
            
        } else if (mType == TASK_TYPE_NEUTRON_VOTE_MULTI) {
            stepDescription.text = NSLocalizedString("tx_neutron_vote_multi_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            titleLabel.text =  NSLocalizedString("title_neutron_vote_multi", comment: "")
            
        } else if (mType == TASK_TYPE_NEUTRON_VOTE_OVERRULE) {
            stepDescription.text = NSLocalizedString("tx_neutron_vote_overrule_0", comment: "")
            stepImg.image = UIImage.init(named: "txStep4_1")
            titleLabel.text =  NSLocalizedString("title_neutron_vote_overrule", comment: "")
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
            
            StepVc.mProposals = self.mProposals
            StepVc.mToSendDenom = self.mToSendDenom
            
            StepVc.mCDenom = self.mCDenom
            StepVc.mMarketID = self.mMarketID
            StepVc.mHtlcDenom = self.mHtlcDenom
            StepVc.mHardMoneyMarketDenom = self.mHardMoneyMarketDenom
            StepVc.mCollateralParamType = self.mCollateralParamType
            
            //grpc
            StepVc.mKavaSwapPool = self.mKavaSwapPool
            StepVc.mKavaSwapPoolDeposit = self.mKavaSwapPoolDeposit
            StepVc.mKavaEarnDeposit = self.mKavaEarnDeposit
            
            StepVc.mStarnameDomain = self.mStarnameDomain
            StepVc.mStarnameAccount = self.mStarnameAccount
            StepVc.mStarnameTime = self.mStarnameTime
            StepVc.mStarnameDomainType = self.mStarnameDomainType
            StepVc.mStarnameResources_gRPC = self.mStarnameResources_gRPC
            
            StepVc.mPoolId = self.mPoolId
            StepVc.mSwapInDenom = self.mSwapInDenom
            StepVc.mSwapOutDenom = self.mSwapOutDenom
//            StepVc.mPool = self.mPool
            StepVc.mLockupDuration = self.mLockupDuration
//            StepVc.mLockups = self.mLockups
            
            StepVc.mSifPool = self.mSifPool
            
            StepVc.mNFTDenomId = self.mNFTDenomId
            StepVc.mNFTTokenId = self.mNFTTokenId
            StepVc.irisResponse = self.irisResponse
            StepVc.croResponse = self.croResponse
            
            
            StepVc.neutronVault = self.neutronVault
            StepVc.neutronProposalModule = self.neutronProposalModule
            StepVc.neutronProposal = self.neutronProposal
            StepVc.neutronSwapPool = self.neutronSwapPool
            StepVc.neutronInputPair = self.neutronInputPair
            StepVc.neutronOutputPair = self.neutronOutputPair
            
            StepVc.mGrant = mGrant
            StepVc.mGranterData = mGranterData
            
            StepVc.mChainId = mChainId
        }
    }
    
    
    @objc func stepChanged(_ notification: NSNotification) {
        if let step = notification.userInfo?["step"] as? Int {
            if (step == 0) {
                if (mType == TASK_TYPE_DELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_delegate_0", comment: "")
                    
                } else if (mType == TASK_TYPE_UNDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_undelegate_0", comment: "")
                    
                } else if (mType == TASK_TYPE_REDELEGATE) {
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    stepDescription.text = NSLocalizedString("tx_redelegate_0", comment: "")
                    
                } else if (mType == TASK_TYPE_TRANSFER) {
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    stepDescription.text = NSLocalizedString("tx_send_0", comment: "")
                    
                } else if (mType == TASK_TYPE_CLAIM_STAKE_REWARD) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_claim_staking_reward_0", comment: "")
                    
                } else if (mType == TASK_TYPE_MODIFY_REWARD_ADDRESS) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_change_reward_address_0", comment: "")
                    
                } else if (mType == TASK_TYPE_REINVEST) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_compounding_0", comment: "")
                    
                } else if (mType == TASK_TYPE_VOTE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_vote_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_CREATE) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_create_cdp_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DEPOSIT) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_deposit_cdp_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_WITHDRAW) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_withdraw_cdp_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_DRAWDEBT) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_drawdebt_cdp_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_CDP_REPAY) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_repayt_cdp_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("tx_deposit_hardpool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("tx_withdraw_hardpool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_BORROW) {
                    stepDescription.text = NSLocalizedString("tx_borrow_hardpool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_HARD_REPAY) {
                    stepDescription.text = NSLocalizedString("tx_repay_hardpool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_TOKEN) {
                    stepDescription.text = NSLocalizedString("tx_swap_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("tx_join_pool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_SWAP_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("tx_exit_pool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_KAVA_INCENTIVE_ALL) {
                    stepDescription.text = NSLocalizedString("tx_claim_incentive_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_HTLC_SWAP) {
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    stepDescription.text = NSLocalizedString("tx_bep_swap_0", comment: "")
                    
                } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("tx_add_liquidity_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("tx_remove_liquidity_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_OK_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("tx_ok_stake_deposit_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OK_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("tx_ok_stake_withdraw_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OK_DIRECT_VOTE) {
                    stepDescription.text = NSLocalizedString("tx_ok_direct_vote_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_DOMAIN) {
                    stepDescription.text = NSLocalizedString("tx_ok_direct_vote_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    stepDescription.text = NSLocalizedString("tx_starname_register_account_0", comment: "")
                    
                } else if (mType == TASK_TYPE_STARNAME_DELETE_DOMAIN || mType == TASK_TYPE_STARNAME_DELETE_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("tx_starname_delete_starname_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_RENEW_DOMAIN || mType == TASK_TYPE_STARNAME_RENEW_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("tx_starname_renew_starname_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STARNAME_REPLACE_RESOURCE) {
                    stepDescription.text = NSLocalizedString("tx_starname_replace_starname_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_SWAP) {
                    stepDescription.text = NSLocalizedString("tx_swap_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_JOIN_POOL) {
                    stepDescription.text = NSLocalizedString("tx_join_pool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_EXIT_POOL) {
                    stepDescription.text = NSLocalizedString("tx_exit_pool_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_LOCK) {
                    stepDescription.text = NSLocalizedString("tx_osmosis_lock_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_OSMOSIS_BEGIN_UNLCOK) {
                    stepDescription.text = NSLocalizedString("tx_osmosis_begin_unbonding_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_SIF_ADD_LP) {
                    stepDescription.text = NSLocalizedString("tx_sif_add_lp_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_SIF_REMOVE_LP) {
                    stepDescription.text = NSLocalizedString("tx_sif_remove_lp_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_SIF_SWAP_CION) {
                    stepDescription.text = NSLocalizedString("tx_swap_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE) {
                    stepDescription.text = NSLocalizedString("tx_issue_nft_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NFT_SEND) {
                    stepDescription.text = NSLocalizedString("tx_send_nft_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NFT_ISSUE_DENOM) {
                    stepDescription.text = NSLocalizedString("tx_issue_nft_denom_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_DESMOS_GEN_PROFILE) {
                    stepDescription.text = NSLocalizedString("tx_desmos_create_profile_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_DESMOS_LINK_CHAIN_ACCOUNT) {
                    stepDescription.text = NSLocalizedString("tx_desmos_account_link_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_CLAIM_REWARDS) {
                    stepDescription.text = NSLocalizedString("tx_authz_claim_reward_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_CLAIM_COMMISSIOMN) {
                    stepDescription.text = NSLocalizedString("tx_authz_claim_commission_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_VOTE) {
                    stepDescription.text = NSLocalizedString("tx_authz_vote_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_DELEGATE) {
                    stepDescription.text = NSLocalizedString("tx_authz_delegate_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_UNDELEGATE) {
                    stepDescription.text = NSLocalizedString("tx_authz_undelegate_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_REDELEGATE) {
                    stepDescription.text = NSLocalizedString("tx_authz_redelegate_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_AUTHZ_SEND) {
                    stepDescription.text = NSLocalizedString("tx_authz_send_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_STAKE) {
                    stepDescription.text = NSLocalizedString("tx_liquid_staking_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
                    stepDescription.text = NSLocalizedString("tx_liquid_unstaking_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_1")
                    
                } else if (mType == TASK_TYPE_PERSIS_LIQUIDITY_STAKE) {
                    stepDescription.text = NSLocalizedString("tx_liquid_staking_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_PERSIS_LIQUIDITY_REDEEM) {
                    stepDescription.text = NSLocalizedString("tx_liquid_redeem_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NEUTRON_VAULTE_DEPOSIT) {
                    stepDescription.text = NSLocalizedString("tx_vaults_deposit_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NEUTRON_VAULTE_WITHDRAW) {
                    stepDescription.text = NSLocalizedString("tx_vaults_withdraw_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NEUTRON_VOTE_SINGLE) {
                    stepDescription.text = NSLocalizedString("tx_neutron_vote_single_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NEUTRON_VOTE_MULTI) {
                    stepDescription.text = NSLocalizedString("tx_neutron_vote_multi_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                    
                } else if (mType == TASK_TYPE_NEUTRON_VOTE_OVERRULE) {
                    stepDescription.text = NSLocalizedString("tx_neutron_vote_overrule_0", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_1")
                }
                
                
            } else if (step == 1) {
                if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_REDELEGATE || mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT ||
                    mType == TASK_TYPE_AUTHZ_VOTE || mType == TASK_TYPE_AUTHZ_DELEGATE || mType == TASK_TYPE_AUTHZ_UNDELEGATE ||
                    mType == TASK_TYPE_AUTHZ_REDELEGATE || mType == TASK_TYPE_AUTHZ_SEND || mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT ||
                    mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW || mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
                    stepImg.image = UIImage.init(named: "txStep5_2")
                    if (mType == TASK_TYPE_TRANSFER) {
                        stepDescription.text = NSLocalizedString("tx_send_1", comment: "")
                    } else if (mType == TASK_TYPE_REDELEGATE) {
                        stepDescription.text = NSLocalizedString("tx_redelegate_1", comment: "")
                    } else if (mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT) {
                        stepDescription.text = NSLocalizedString("tx_starname_register_account_1", comment: "")
                    } else if (mType == TASK_TYPE_AUTHZ_VOTE) {
                        stepDescription.text = NSLocalizedString("tx_authz_vote_1", comment: "")
                    } else if (mType == TASK_TYPE_AUTHZ_DELEGATE) {
                        stepDescription.text = NSLocalizedString("tx_authz_delegate_1", comment: "")
                    } else if (mType == TASK_TYPE_AUTHZ_UNDELEGATE) {
                        stepDescription.text = NSLocalizedString("tx_authz_undelegate_1", comment: "")
                    } else if (mType == TASK_TYPE_AUTHZ_REDELEGATE) {
                        stepDescription.text = NSLocalizedString("tx_authz_redelegate_1", comment: "")
                    } else if (mType == TASK_TYPE_AUTHZ_SEND) {
                        stepDescription.text = NSLocalizedString("tx_authz_send_1", comment: "")
                    } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT) {
                        stepDescription.text = NSLocalizedString("tx_add_liquidity_1", comment: "")
                    } else if (mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW) {
                        stepDescription.text = NSLocalizedString("tx_remove_liquidity_1", comment: "")
                    } else if (mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
                        stepDescription.text = NSLocalizedString("tx_liquid_unstaking_1", comment: "")
                    }
                    
                } else {
                    stepImg.image = UIImage.init(named: "txStep4_2")
                    if (mType == TASK_TYPE_HTLC_SWAP) {
                        stepDescription.text = NSLocalizedString("tx_bep_swap_1", comment: "")
                    } else {
                        stepDescription.text = NSLocalizedString("tx_set_memo", comment: "")
                    }
                }
                
                
            } else if (step == 2) {
                if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_REDELEGATE || mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT ||
                    mType == TASK_TYPE_AUTHZ_VOTE || mType == TASK_TYPE_AUTHZ_DELEGATE || mType == TASK_TYPE_AUTHZ_UNDELEGATE ||
                    mType == TASK_TYPE_AUTHZ_REDELEGATE || mType == TASK_TYPE_AUTHZ_SEND || mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT ||
                    mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW || mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
                    stepDescription.text = NSLocalizedString("tx_set_memo", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_3")
                    
                } else {
                    stepDescription.text = NSLocalizedString("tx_set_fee", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_3")
                }
                
                
            } else if (step == 3) {
                if (mType == TASK_TYPE_TRANSFER || mType == TASK_TYPE_REDELEGATE || mType == TASK_TYPE_STARNAME_REGISTER_ACCOUNT ||
                    mType == TASK_TYPE_AUTHZ_VOTE || mType == TASK_TYPE_AUTHZ_DELEGATE || mType == TASK_TYPE_AUTHZ_UNDELEGATE ||
                    mType == TASK_TYPE_AUTHZ_REDELEGATE || mType == TASK_TYPE_AUTHZ_SEND || mType == TASK_TYPE_KAVA_LIQUIDITY_DEPOSIT ||
                    mType == TASK_TYPE_KAVA_LIQUIDITY_WITHDRAW || mType == TASK_TYPE_STRIDE_LIQUIDITY_UNSTAKE) {
                    stepDescription.text = NSLocalizedString("tx_set_fee", comment: "")
                    stepImg.image = UIImage.init(named: "txStep5_4")
                    
                } else {
                    stepDescription.text = NSLocalizedString("tx_set_confirm", comment: "")
                    stepImg.image = UIImage.init(named: "txStep4_4")
                }
                
            } else if (step == 4) {
                stepDescription.text = NSLocalizedString("tx_set_confirm", comment: "")
                stepImg.image = UIImage.init(named: "txStep5_5")
                
            }
        }
    }
    
}
