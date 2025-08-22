//
//  MintscanHistory.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON
import web3swift


public struct MintscanHistory: Codable {
    var header: MintscanHistoryHeader?
    var data: MintscanHistoryData?
    var search_after: String?
    
    public func isSuccess() -> Bool {
        if let RawCode = self.data?.code {
            if (RawCode != 0) {
                return false
            }
        }
        return true
    }
    
    public func getMsgs() -> Array<JSON>? {
        return data?.tx?["/cosmos-tx-v1beta1-Tx"]["body"]["messages"].array
    }
    
    
    public func getMsgCnt() -> Int {
        guard let msgs = getMsgs() else {
            return 0
        }
        return msgs.count
    }
    
    
    func getMsgType(_ chain: BaseChain) -> String {
        let bechAddress = chain.bechAddress
        let evmAddress = chain.evmAddress
        
        if (getMsgCnt() == 0) {
            return NSLocalizedString("tx_known", comment: "")
        }
        
        if getMsgCnt() == 2,
            let msgType0 = getMsgs()?[0]["@type"].string,
            let msgType1 = getMsgs()?[1]["@type"].string {
            if ((msgType0.contains("MsgWithdrawDelegatorReward") || msgType0.contains("MsgWithdrawDelegationReward")) && msgType1.contains("MsgDelegate")) {
                return NSLocalizedString("tx_reinvest", comment: "")
            }
        }
        
        
        if (getMsgCnt() > 1) {
            //check send case
            var allSend = true
            getMsgs()?.forEach({ msg in
                if (msg["@type"].string?.contains("MsgSend") == false) {
                    allSend = false
                }
            })
            if (allSend) {
                for msg in getMsgs()! {
                    let msgType = msg["@type"].stringValue
                    let msgValue = msg[msgType.replacingOccurrences(of: ".", with: "-")]
                    if let senderAddr = msgValue["from_address"].string, senderAddr == bechAddress {
                        return NSLocalizedString("tx_send", comment: "") + " + " + String(getMsgCnt() - 1)
                    } else if let receiverAddr = msgValue["to_address"].string, receiverAddr == bechAddress {
                        return NSLocalizedString("tx_receive", comment: "") + " + " + String(getMsgCnt() - 1)
                    }
                }
                return NSLocalizedString("tx_transfer", comment: "") + " + " + String(getMsgCnt() - 1)
            }
        }
        
        var result = NSLocalizedString("tx_known", comment: "")
        if let firstMsg = getMsgs()?[0],
           let msgType = firstMsg["@type"].string {
            result = msgType.components(separatedBy: ".").last?.replacingOccurrences(of: "Msg", with: "") ?? NSLocalizedString("tx_known", comment: "")
            
            let msgValue = firstMsg[msgType.replacingOccurrences(of: ".", with: "-")]
            if (msgType.contains("cosmos.") && msgType.contains("staking")) {
                if (msgType.contains("MsgCreateValidator")) {
                    result = NSLocalizedString("tx_create_validator", comment: "")
                    
                } else if (msgType.contains("MsgEditValidator")) {
                    result = NSLocalizedString("tx_edit_validator", comment: "")
                    
                } else if (msgType.contains("MsgDelegate")) {
                    result = NSLocalizedString("tx_delegate", comment: "")
                    
                } else if (msgType.contains("MsgUndelegate")) {
                    result = NSLocalizedString("tx_undelegate", comment: "")
                    
                } else if (msgType.contains("MsgBeginRedelegate")) {
                    result = NSLocalizedString("tx_redelegate", comment: "")
                    
                } else if (msgType.contains("MsgCancelUnbondingDelegation")) {
                    result = NSLocalizedString("tx_cancel_undelegate", comment: "")
                }
                
            } else if (msgType.contains("cosmos.") && msgType.contains("bank")) {
                if (msgType.contains("MsgSend")) {
                    if let senderAddr = msgValue["from_address"].string, senderAddr == bechAddress {
                        result = NSLocalizedString("tx_send", comment: "")
                    } else if let receiverAddr = msgValue["to_address"].string, receiverAddr == bechAddress {
                        result = NSLocalizedString("tx_receive", comment: "")
                    } else {
                        result = NSLocalizedString("tx_transfer", comment: "")
                    }
                    
                } else if (msgType.contains("MsgMultiSend")) {
                    result = NSLocalizedString("tx_multi_transfer", comment: "")
                    for input in msgValue["inputs"].arrayValue {
                        if (input["address"].string == bechAddress) {
                            result = NSLocalizedString("tx_multi_send", comment: "")
                            break
                        }
                    }
                    for output in msgValue["outputs"].arrayValue {
                        if (output["address"].string == bechAddress) {
                            result = NSLocalizedString("tx_multi_received", comment: "")
                            break
                        }
                    }
                }
                
            } else if (msgType.contains("cosmos.") && msgType.contains("distribution")) {
                if (msgType.contains("MsgSetWithdrawAddress") || msgType.contains("MsgModifyWithdrawAddress")) {
                    result = NSLocalizedString("tx_change_reward_address", comment: "")
                    
                } else if (msgType.contains("MsgWithdrawDelegatorReward") || msgType.contains("MsgWithdrawDelegationReward")) {
                    result = NSLocalizedString("tx_get_reward", comment: "")
                    
                } else if (msgType.contains("MsgWithdrawValidatorCommission")) {
                    result = NSLocalizedString("tx_get_commission", comment: "")
                    
                } else if (msgType.contains("MsgFundCommunityPool")) {
                    result = NSLocalizedString("tx_fund_pool", comment: "")
                }
                
            } else if (msgType.contains("cosmos.") && msgType.contains("gov")) {
                if (msgType.contains("MsgSubmitProposal")) {
                    result = NSLocalizedString("tx_submit_proposal", comment: "")
                    
                } else if (msgType.contains("MsgDeposit")) {
                    result = NSLocalizedString("tx_proposal_deposit", comment: "")
                    
                } else if (msgType.contains("MsgVote")) {
                    result = NSLocalizedString("tx_vote", comment: "")
                    
                } else if (msgType.contains("MsgVoteWeighted")) {
                    result = NSLocalizedString("tx_vote_weighted", comment: "")
                }
                
            } else if (msgType.contains("cosmos.") && msgType.contains("authz")) {
                if (msgType.contains("MsgGrant")) {
                    result = NSLocalizedString("tx_authz_grant", comment: "")
                    
                } else if (msgType.contains("MsgRevoke")) {
                    result = NSLocalizedString("tx_authz_revoke", comment: "")
                    
                } else if (msgType.contains("MsgExec")) {
                    result = NSLocalizedString("tx_authz_exe", comment: "")
                }
                
            } else if (msgType.contains("cosmos.") && msgType.contains("slashing")) {
                if (msgType.contains("MsgUnjail")) {
                    result = NSLocalizedString("tx_unjail_validator", comment: "")
                }
            
            } else if (msgType.contains("cosmos.") && msgType.contains("feegrant")) {
                if (msgType.contains("MsgGrantAllowance")) {
                    result = NSLocalizedString("tx_feegrant_allowance", comment: "")
                    
                } else if (msgType.contains("MsgRevokeAllowance")) {
                    result = NSLocalizedString("tx_feegrant_revoke", comment: "")
                }
            }
            
            // stride msg type
            else if (msgType.contains("stride.") && msgType.contains("stakeibc")) {
                if (msgType.contains("MsgLiquidStake")) {
                    result = NSLocalizedString("tx_stride_liquid_stake", comment: "")
                
                } else if (msgType.contains("MsgRedeemStake")) {
                    result = NSLocalizedString("tx_stride_liquid_unstake", comment: "")
                }
            }
            
            // crescent msg type
            else if (msgType.contains("crescent.") && msgType.contains("liquidstaking")) {
                if (msgType.contains("MsgLiquidStake")) {
                    result = NSLocalizedString("tx_crescent_liquid_stake", comment: "")
                    
                } else if (msgType.contains("MsgLiquidUnstake")) {
                    result = NSLocalizedString("tx_crescent_liquid_unstake", comment: "")
                }
                
            } else if (msgType.contains("crescent.") && msgType.contains("liquidity")) {
                if (msgType.contains("MsgCreatePair")) {
                    result = NSLocalizedString("tx_crescent_create_pair", comment: "")
                    
                } else if (msgType.contains("MsgCreatePool")) {
                    result = NSLocalizedString("tx_crescent_create_pool", comment: "")
                    
                } else if (msgType.contains("MsgDeposit")) {
                    result = NSLocalizedString("tx_crescent_deposit", comment: "")
                    
                } else if (msgType.contains("MsgWithdraw")) {
                    result = NSLocalizedString("tx_crescent_withdraw", comment: "")
                    
                } else if (msgType.contains("MsgLimitOrder")) {
                    result = NSLocalizedString("tx_crescent_limit_order", comment: "")
                    
                } else if (msgType.contains("MsgMarketOrder")) {
                    result = NSLocalizedString("tx_crescent_market_order", comment: "")
                    
                } else if (msgType.contains("MsgCancelOrder")) {
                    result = NSLocalizedString("tx_crescent_cancel_order", comment: "")
                    
                } else if (msgType.contains("MsgCancelAllOrders")) {
                    result = NSLocalizedString("tx_crescent_cancel_all_orders", comment: "")
                }
                
            } else if (msgType.contains("crescent.") && msgType.contains("farming")) {
                if (msgType.contains("MsgStake")) {
                    result = NSLocalizedString("tx_crescent_stake", comment: "")
                    
                } else if (msgType.contains("MsgUnstake")) {
                    result = NSLocalizedString("tx_crescent_unstake", comment: "")
                    
                } else if (msgType.contains("MsgHarvest")) {
                    result = NSLocalizedString("tx_crescent_harvest", comment: "")
                    
                } else if (msgType.contains("MsgCreateFixedAmountPlan")) {
                    result = NSLocalizedString("tx_crescent_create_fixed_amount_plan", comment: "")
                    
                } else if (msgType.contains("MsgCreateRatioPlan")) {
                    result = NSLocalizedString("tx_crescent_create_ratio_plan", comment: "")
                    
                } else if (msgType.contains("MsgRemovePlan")) {
                    result = NSLocalizedString("tx_crescent_remove_plan", comment: "")
                    
                } else if (msgType.contains("MsgAdvanceEpoch")) {
                    result = NSLocalizedString("tx_crescent_advance_epoch", comment: "")
                }
                
            } else if (msgType.contains("crescent.") && msgType.contains("claim")) {
                if (msgType.contains("MsgClaim")) {
                    result = NSLocalizedString("tx_crescent_claim", comment: "")
                }
            }
            
            // irismod msg type
            else if (msgType.contains("irismod.") && msgType.contains("nft")) {
                if (msgType.contains("MsgMintNFT")) {
                    result = NSLocalizedString("tx_nft_mint", comment: "")
                    
                } else if (msgType.contains("MsgTransferNFT")) {
                    if let senderAddr = msgValue["sender"].string, senderAddr == bechAddress {
                        result = NSLocalizedString("tx_nft_send", comment: "")
                    } else if let receiverAddr = msgValue["recipient"].string, receiverAddr == bechAddress {
                        result = NSLocalizedString("tx_nft_receive", comment: "")
                    } else {
                        result = NSLocalizedString("tx_nft_transfer", comment: "")
                    }
                    
                } else if (msgType.contains("MsgEditNFT")) {
                    result = NSLocalizedString("tx_nft_edit", comment: "")
                    
                } else if (msgType.contains("MsgIssueDenom")) {
                    result = NSLocalizedString("tx_nft_issueDenom", comment: "")
                    
                }
            
            } else if (msgType.contains("irismod.") && msgType.contains("coinswap")) {
                if (msgType.contains("MsgSwapOrder")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                } else if (msgType.contains("MsgAddLiquidity")) {
                    result = NSLocalizedString("tx_add_liquidity", comment: "")
                } else if (msgType.contains("MsgRemoveLiquidity")) {
                    result = NSLocalizedString("tx_remove_liquidity", comment: "")
                }

            } else if (msgType.contains("irismod.") && msgType.contains("farm")) {
                if (msgType.contains("MsgStake")) {
                    result = NSLocalizedString("tx_farm_stake", comment: "")
                } else if (msgType.contains("MsgHarvest")) {
                    result = NSLocalizedString("tx_farm_harvest", comment: "")
                }
            }
            
            // crypto msg type
            else if (msgType.contains("chainmain.") && msgType.contains("nft")) {
                if (msgType.contains("MsgMintNFT")) {
                    result = NSLocalizedString("tx_nft_mint", comment: "")
                    
                } else if (msgType.contains("MsgTransferNFT")) {
                    if let senderAddr = msgValue["sender"].string, senderAddr == bechAddress {
                        result = NSLocalizedString("tx_nft_send", comment: "")
                    } else if let receiverAddr = msgValue["recipient"].string, receiverAddr == bechAddress {
                        result = NSLocalizedString("tx_nft_receive", comment: "")
                    } else {
                        result = NSLocalizedString("tx_nft_transfer", comment: "")
                    }
                    
                } else if (msgType.contains("MsgEditNFT")) {
                    result = NSLocalizedString("tx_nft_edit", comment: "")
                    
                } else if (msgType.contains("MsgIssueDenom")) {
                    result = NSLocalizedString("tx_nft_issueDenom", comment: "")
                }
            }
            
            // starname msg type
            else if (msgType.contains("starnamed.") && msgType.contains("starname")) {
                if (msgType.contains("MsgRegisterDomain")) {
                    result = NSLocalizedString("tx_starname_registe_domain", comment: "")
                    
                } else if (msgType.contains("MsgRegisterAccount")) {
                    result = NSLocalizedString("tx_starname_registe_account", comment: "")
                    
                } else if (msgType.contains("MsgDeleteDomain")) {
                    result = NSLocalizedString("tx_starname_delete_domain", comment: "")
                    
                } else if (msgType.contains("MsgDeleteAccount")) {
                    result = NSLocalizedString("tx_starname_delete_account", comment: "")
                    
                } else if (msgType.contains("MsgRenewDomain")) {
                    result = NSLocalizedString("tx_starname_renew_domain", comment: "")
                    
                } else if (msgType.contains("MsgRenewAccount")) {
                    result = NSLocalizedString("tx_starname_renew_account", comment: "")
                    
                } else if (msgType.contains("MsgReplaceAccountResources")) {
                    result = NSLocalizedString("tx_starname_update_resource", comment: "")
                }
            }
            
            // osmosis msg type
            else if (msgType.contains("osmosis.")) {
                if (msgType.contains("MsgSwapExactAmountIn")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgSwapExactAmountOut")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgJoinPool")) {
                    result = NSLocalizedString("tx_join_pool", comment: "")
                    
                } else if (msgType.contains("MsgExitPool")) {
                    result = NSLocalizedString("tx_exit_pool", comment: "")
                    
                } else if (msgType.contains("MsgJoinSwapExternAmountIn")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgJoinSwapShareAmountOut")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgExitSwapExternAmountOut")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgExitSwapShareAmountIn")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgCreatePool")) {
                    result = NSLocalizedString("tx_create_pool", comment: "")
                    
                } else if (msgType.contains("MsgCreateBalancerPool")) {
                    result = NSLocalizedString("tx_create_pool", comment: "")
                }
                
            } else if (msgType.contains("osmosis.") && msgType.contains("lockup")) {
                if (msgType.contains("MsgLockTokens")) {
                    result = NSLocalizedString("tx_osmosis_token_lockup", comment: "")
                    
                } else if (msgType.contains("MsgBeginUnlockingAll")) {
                    result = NSLocalizedString("tx_osmosis_begin_unlucking_all", comment: "")
                    
                } else if (msgType.contains("MsgBeginUnlocking")) {
                    result = NSLocalizedString("tx_osmosis_begin_unlucking", comment: "")
                }
                
            } else if (msgType.contains("osmosis.") && msgType.contains("superfluid")) {
                if (msgType.contains("MsgSuperfluidDelegate")) {
                    result = NSLocalizedString("tx_osmosis_super_fluid_delegate", comment: "")
                    
                } else if (msgType.contains("MsgSuperfluidUndelegate")) {
                    result = NSLocalizedString("tx_osmosis_super_fluid_undelegate", comment: "")
                    
                } else if (msgType.contains("MsgSuperfluidUnbondLock")) {
                    result = NSLocalizedString("tx_osmosis_super_fluid_unbondinglock", comment: "")
                    
                } else if (msgType.contains("MsgLockAndSuperfluidDelegate")) {
                    result = NSLocalizedString("tx_osmosis_super_fluid_lockanddelegate", comment: "")
                }
            }
            
            // medi msg type
            else if (msgType.contains("panacea.") && msgType.contains("aol")) {
                if (msgType.contains("MsgAddRecord")) {
                    result = NSLocalizedString("tx_med_add_record", comment: "")
                    
                } else if (msgType.contains("MsgCreateTopic")) {
                    result = NSLocalizedString("tx_med_create_topic", comment: "")
                    
                } else if (msgType.contains("MsgAddWriter")) {
                    result = NSLocalizedString("tx_med_add_writer", comment: "")
                }
                
            } else if (msgType.contains("panacea.") && msgType.contains("did")) {
                if (msgType.contains("MsgCreateDID")) {
                    result = NSLocalizedString("tx_med_create_did", comment: "")
                }
            }
            
            // rizon msg type
            else if (msgType.contains("rizonworld.") && msgType.contains("tokenswap")) {
                if (msgType.contains("MsgCreateTokenswapRequest")) {
                    result = NSLocalizedString("tx_rizon_event_horizon", comment: "")
                }
            }
            
            // gravity dex msg type
            else if (msgType.contains("tendermint.") && msgType.contains("liquidity")) {
                if (msgType.contains("MsgDepositWithinBatch")) {
                    result = NSLocalizedString("tx_join_pool", comment: "")
                    
                } else if (msgType.contains("MsgSwapWithinBatch")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgWithdrawWithinBatch")) {
                    result = NSLocalizedString("tx_exit_pool", comment: "")
                }
            }
            
            // desmos msg type
            else if (msgType.contains("desmos.") && msgType.contains("profiles")) {
                if (msgType.contains("MsgSaveProfile")) {
                    result = NSLocalizedString("tx_desmos_save_profile", comment: "")
                    
                } else if (msgType.contains("MsgDeleteProfile")) {
                    result = NSLocalizedString("tx_desmos_delete_profile", comment: "")
                    
                } else if (msgType.contains("MsgCreateRelationship")) {
                    result = NSLocalizedString("tx_desmos_create_relation", comment: "")
                    
                } else if (msgType.contains("MsgDeleteRelationship")) {
                    result = NSLocalizedString("tx_desmos_delete_relation", comment: "")
                    
                } else if (msgType.contains("MsgBlockUser")) {
                    result = NSLocalizedString("tx_desmos_delete_block_user", comment: "")
                    
                } else if (msgType.contains("MsgUnblockUser")) {
                    result = NSLocalizedString("tx_desmos_delete_unblock_user", comment: "")
                    
                } else if (msgType.contains("MsgLinkChainAccount")) {
                    result = NSLocalizedString("tx_desmos_link_chain_account", comment: "")
                }
            }
            
            // kava msg type
            else if (msgType.contains("kava.") && msgType.contains("auction")) {
                if (msgType.contains("MsgPlaceBid")) {
                    result = NSLocalizedString("tx_kava_auction_bid", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("cdp")) {
                if (msgType.contains("MsgCreateCDP")) {
                    result =  NSLocalizedString("tx_kava_create_cdp", comment: "")
                    
                } else if (msgType.contains("MsgDeposit")) {
                    result =  NSLocalizedString("tx_kava_deposit_cdp", comment: "")
                    
                } else if (msgType.contains("MsgWithdraw")) {
                    result =  NSLocalizedString("tx_kava_withdraw_cdp", comment: "")
                    
                } else if (msgType.contains("MsgDrawDebt")) {
                    result =  NSLocalizedString("tx_kava_drawdebt_cdp", comment: "")
                    
                } else if (msgType.contains("MsgRepayDebt")) {
                    result =  NSLocalizedString("tx_kava_repaydebt_cdp", comment: "")
                    
                } else if (msgType.contains("MsgLiquidate")) {
                    result =  NSLocalizedString("tx_kava_liquidate_cdp", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("swap")) {
                if (msgType.contains("MsgDeposit")) {
                    result = NSLocalizedString("tx_kava_swap_deposit", comment: "")
                    
                } else if (msgType.contains("MsgWithdraw")) {
                    result = NSLocalizedString("tx_kava_swap_withdraw", comment: "")
                    
                } else if (msgType.contains("MsgSwapExactForTokens")) {
                    result = NSLocalizedString("tx_kava_swap_token", comment: "")
                    
                } else if (msgType.contains("MsgSwapForExactTokens")) {
                    result = NSLocalizedString("tx_kava_swap_token", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("hard")) {
                if (msgType.contains("MsgDeposit")) {
                    result = NSLocalizedString("tx_kava_hard_deposit", comment: "")
                    
                } else if (msgType.contains("MsgWithdraw")) {
                    result = NSLocalizedString("tx_kava_hard_withdraw", comment: "")
                    
                } else if (msgType.contains("MsgBorrow")) {
                    result = NSLocalizedString("tx_kava_hard_borrow", comment: "")
                    
                } else if (msgType.contains("MsgRepay")) {
                    result = NSLocalizedString("tx_kava_hard_repay", comment: "")
                    
                } else if (msgType.contains("MsgLiquidate")) {
                    result = NSLocalizedString("tx_kava_hard_liquidate", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("savings")) {
                if (msgType.contains("MsgDeposit")) {
                    result = NSLocalizedString("tx_kava_save_deposit", comment: "")
                    
                } else if (msgType.contains("MsgWithdraw")) {
                    result = NSLocalizedString("tx_kava_save_withdraw", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("incentive")) {
                if (msgType.contains("MsgClaimUSDXMintingReward")) {
                    result = NSLocalizedString("tx_kava_mint_incentive", comment: "")
                    
                } else if (msgType.contains("MsgClaimHardReward")) {
                    result = NSLocalizedString("tx_kava_hard_incentive", comment: "")
                    
                } else if (msgType.contains("MsgClaimDelegatorReward")) {
                    result = NSLocalizedString("tx_kava_delegator_incentive", comment: "")
                    
                } else if (msgType.contains("MsgClaimSwapReward")) {
                    result = NSLocalizedString("tx_kava_swap_incentive", comment: "")
                    
                } else if (msgType.contains("MsgClaimSavingsReward")) {
                    result = NSLocalizedString("tx_kava_save_incentive", comment: "")
                    
                } else if (msgType.contains("MsgClaimEarnReward")) {
                    result = NSLocalizedString("tx_kava_earn_incentive", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("bep3")) {
                if (msgType.contains("MsgCreateAtomicSwap")) {
                    result = NSLocalizedString("tx_kava_bep3_create", comment: "")
                    
                } else if (msgType.contains("MsgClaimAtomicSwap")) {
                    result = NSLocalizedString("tx_kava_bep3_claim", comment: "")
                    
                } else if (msgType.contains("MsgRefundAtomicSwap")) {
                    result = NSLocalizedString("tx_kava_bep3_refund", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("pricefeed")) {
                if (msgType.contains("MsgPostPrice")) {
                    result = NSLocalizedString("tx_kava_post_price", comment: "")
                }
                
            } else if (msgType.contains("kava.") && msgType.contains("router")) {
                if (msgType.contains("MsgDelegateMintDeposit")) {
                    result = NSLocalizedString("tx_kava_earn_delegateDeposit", comment: "")
                    
                } else if (msgType.contains("MsgMintDeposit")) {
                    result = NSLocalizedString("tx_kava_earn_Deposit", comment: "")
                    
                } else if (msgType.contains("MsgWithdrawBurn")) {
                    result = NSLocalizedString("tx_kava_earn_withdraw", comment: "")
                }
            }
            
            // axelar msg type
            else if (msgType.contains("axelar.") && msgType.contains("reward")) {
                if (msgType.contains("RefundMsgRequest")) {
                    result = NSLocalizedString("tx_axelar_refund_msg_request", comment: "")
                }

            } else if (msgType.contains("axelar.") && msgType.contains("axelarnet")) {
                if (msgType.contains("LinkRequest")) {
                    result = NSLocalizedString("tx_axelar_link_request", comment: "")
                
                } else if (msgType.contains("ConfirmDepositRequest")) {
                    result = NSLocalizedString("tx_axelar_confirm_deposit_request", comment: "")
                
                } else if (msgType.contains("RouteIBCTransfersRequest")) {
                    result = NSLocalizedString("tx_axelar_route_ibc_request", comment: "")
                }
            }
            
            // injective msg type
            else if (msgType.contains("injective.") && msgType.contains("exchange")) {
                if (msgType.contains("MsgBatchUpdateOrders")) {
                    result = NSLocalizedString("tx_injective_batch_update_order", comment: "")
                
                } else if (msgType.contains("MsgBatchCreateDerivativeLimitOrders") || msgType.contains("MsgCreateDerivativeLimitOrder")) {
                    result = NSLocalizedString("tx_injective_create_limit_order", comment: "")
                
                } else if (msgType.contains("MsgBatchCreateSpotLimitOrders") || msgType.contains("MsgCreateSpotLimitOrder")) {
                    result = NSLocalizedString("tx_injective_create_spot_order", comment: "")
                
                } else if (msgType.contains("MsgBatchCancelDerivativeOrders") || msgType.contains("MsgCancelDerivativeOrder")) {
                    result = NSLocalizedString("tx_injective_cancel_limit_order", comment: "")
                
                } else if (msgType.contains("MsgBatchCancelSpotOrder") || msgType.contains("MsgCancelSpotOrder")) {
                    result = NSLocalizedString("tx_injective_cancel_spot_order", comment: "")
                }
            }
            
            // persistence msg type
            else if (msgType.contains("pstake.") && msgType.contains("lscosmos")) {
                if (msgType.contains("MsgLiquidStake")) {
                    result = NSLocalizedString("tx_stride_liquid_stake", comment: "")
                    
                } else if (msgType.contains("MsgLiquidUnstake")) {
                    result = NSLocalizedString("tx_stride_liquid_unstake", comment: "")
                    
                } else if (msgType.contains("MsgRedeem")) {
                    result = NSLocalizedString("tx_persis_liquid_redeem", comment: "")
                    
                } else if (msgType.contains("MsgClaim")) {
                    result = NSLocalizedString("tx_persis_liquid_claim", comment: "")
                }
            }
            
            
            
            // ibc msg type
            else if (msgType.contains("ibc.")) {
                if (msgType.contains("MsgTransfer")) {
                    result = NSLocalizedString("tx_ibc_send", comment: "")
                    
                } else if (msgType.contains("v2.MsgSendPacket")) {
                    result = NSLocalizedString("tx_ibc_eureka_send", comment: "")
                    
                } else if (msgType.contains("MsgUpdateClient")) {
                    result = NSLocalizedString("tx_ibc_client_update", comment: "")
                    
                } else if (msgType.contains("v2.MsgRecvPacket")) {
                    result = NSLocalizedString("tx_ibc_eureka_receive", comment: "")
                    
                } else if (msgType.contains("MsgRecvPacket")) {
                    result = NSLocalizedString("tx_ibc_receive", comment: "")
                    
                } else if (msgType.contains("MsgAcknowledgement")) {
                    result = NSLocalizedString("tx_ibc_acknowledgement", comment: "")
                }
                
                if (getMsgCnt() >= 2) {
                    getMsgs()?.forEach({ msg in
                        if (msg["@type"].string?.contains("MsgAcknowledgement") == true) {
                            result = NSLocalizedString("tx_ibc_acknowledgement", comment: "")
                        }
                    })
                    getMsgs()?.forEach({ msg in
                        if (msg["@type"].string?.contains("MsgRecvPacket") == true) {
                            result = NSLocalizedString("tx_ibc_receive", comment: "")
                        }
                    })
                    getMsgs()?.forEach({ msg in
                        if (msg["@type"].string?.contains("v2.MsgRecvPacket") == true) {
                            result = NSLocalizedString("tx_ibc_eureka_receive", comment: "")
                        }
                    })
                }
            }
            
            // wasm msg type
            else if (msgType.contains("cosmwasm.")) {
                if (msgType.contains("MsgStoreCode")) {
                    result = NSLocalizedString("tx_cosmwasm_store_code", comment: "")
                    
                } else if (msgType.contains("MsgInstantiateContract")) {
                    result = NSLocalizedString("tx_cosmwasm_instantiate", comment: "")
                    
                } else if (msgType.contains("MsgExecuteContract")) {
                    if let wasmMsg = msgValue["msg__@stringify"].string,
                       let wasmFunc = try? JSONDecoder().decode(JSON.self, from: wasmMsg.data(using: .utf8) ?? Data()) {
                        if let recipient = wasmFunc["transfer"]["recipient"].string,
                           let amount = wasmFunc["transfer"]["amount"].string {
                            if (recipient == bechAddress) {
                                result = NSLocalizedString("tx_cosmwasm_token_receive", comment: "")
                            } else {
                                result = NSLocalizedString("tx_cosmwasm_token_send", comment: "")
                            }
                            
                        } else {
                            let description = wasmFunc.dictionaryValue.keys.first ?? ""
                            result = NSLocalizedString("tx_cosmwasm", comment: "") + " " + description
                            result = result.replacingOccurrences(of: "_", with: " ").capitalized
                            
                        }
                        
                    } else {
                        result = NSLocalizedString("tx_cosmwasm_execontract", comment: "")
                    }
                }
            }
            
            // evm msg type
            else if (msgType.contains("ethermint.evm") && msgType.contains("MsgEthereumTx")) {
                result = NSLocalizedString("tx_ethereum_evm", comment: "")
                if let dataValue = msgValue.evmDataValue() {
                    let amount = dataValue["value"].stringValue
                    let data = dataValue["data"].stringValue
                    
                    if (data.isEmpty == true && amount.isEmpty == false && amount != "0") {
                        if (dataValue["to"].stringValue.lowercased() == evmAddress) {
                            result = NSLocalizedString("tx_evm_coin_receive", comment: "")
                        } else {
                            result = NSLocalizedString("tx_evm_coin_send", comment: "")
                        }
                        
                    } else if (data.isEmpty == false) {
                        if let hexData = Data(base64Encoded: data)?.toHexString(),
                           let evmAddress = evmAddress {
                            if hexData.starts(with: "a9059cbb") {
                                if (hexData.contains(evmAddress.replacingOccurrences(of: "0x", with: ""))) {
                                    result = NSLocalizedString("tx_evm_token_receive", comment: "")
                                } else {
                                    result = NSLocalizedString("tx_evm_token_send", comment: "")
                                }
                            }
                        }
                    }
                }
            }
            
            if (getMsgCnt() > 1) {
                result = result +  " + " + String(getMsgCnt() - 1)
            }
            
        }
        return result
    }
    
    
    func getDpCoin(_ chain: BaseChain) -> [Cosmos_Base_V1beta1_Coin]? {
        var result = Array<Cosmos_Base_V1beta1_Coin>()
        if (getMsgCnt() > 0) {
            //display staking reward amount
            var allReward = true
            getMsgs()?.forEach({ msg in
                if (msg["@type"].string?.contains("MsgWithdrawDelegatorReward") == false) {
                    allReward = false
                }
            })
            if (allReward) {
                data?.logs?.forEach({ log in
                    if let event = log["events"].array?.filter({ $0["type"].string == "transfer" }).first {
                        if let attribute = event["attributes"].array?.filter({ $0["key"].string == "amount" }).first {
                            for rawAmount in attribute["value"].stringValue.components(separatedBy: ",") {
                                if let range = rawAmount.range(of: "[0-9]*", options: .regularExpression) {
                                    let amount = String(rawAmount[range])
                                    let denomIndex = rawAmount.index(rawAmount.startIndex, offsetBy: amount.count)
                                    let denom = String(rawAmount[denomIndex...])
                                    let value = Cosmos_Base_V1beta1_Coin.with {
                                        $0.denom = denom
                                        $0.amount = amount
                                    }
                                    result.append(value)
                                }
                            }
                        }
                    }
                })
                return sortedCoins(chain, result)
            }
            
            //check send case
            var allSend = true
            getMsgs()?.forEach({ msg in
                if (msg["@type"].string?.contains("MsgSend") == false) {
                    allSend = false
                }
            })
            if (allSend) {
                for msg in getMsgs()! {
                    let msgType = msg["@type"].stringValue
                    let msgValue = msg[msgType.replacingOccurrences(of: ".", with: "-")]
                    if let senderAddr = msgValue["from_address"].string, senderAddr == chain.bechAddress {
                        if let rawAmounts = msgValue["amount"].array {
                            let value = Cosmos_Base_V1beta1_Coin.with {
                                $0.denom = rawAmounts[0]["denom"].stringValue
                                $0.amount = rawAmounts[0]["amount"].stringValue
                            }
                            result.append(value)
                        }
                        return sortedCoins(chain, result)
                    } else if let receiverAddr = msgValue["to_address"].string, receiverAddr == chain.bechAddress {
                        if let rawAmounts = msgValue["amount"].array {
                            let value = Cosmos_Base_V1beta1_Coin.with {
                                $0.denom = rawAmounts[0]["denom"].stringValue
                                $0.amount = rawAmounts[0]["amount"].stringValue
                            }
                            result.append(value)
                        }
                        return sortedCoins(chain, result)
                    }
                }
            }
            
            
            var ibcReceived = false
            getMsgs()?.forEach({ msg in
                if (msg["@type"].string?.contains("ibc") == true && msg["@type"].string?.contains("MsgRecvPacket") == true) {
                    ibcReceived = true
                }
            })
            if (ibcReceived) {
                data?.logs?.forEach({ log in
                    if let event = log["events"].array?.filter({ $0["type"].string == "transfer" }).first {
                        event["attributes"].array?.forEach({ attribute in
                            if (attribute["value"].string == chain.bechAddress) {
                                if let attribute = event["attributes"].array?.filter({ $0["key"].string == "amount" }).first {
                                    for rawAmount in attribute["value"].stringValue.components(separatedBy: ",") {
                                        if let range = rawAmount.range(of: "[0-9]*", options: .regularExpression) {
                                            let amount = String(rawAmount[range])
                                            let denomIndex = rawAmount.index(rawAmount.startIndex, offsetBy: amount.count)
                                            let denom = String(rawAmount[denomIndex...])
                                            let value = Cosmos_Base_V1beta1_Coin.with {
                                                $0.denom = denom
                                                $0.amount = amount
                                            }
                                            result.append(value)
                                        }
                                    }
                                }
                            }
                        })
                    }
                })
                return sortedCoins(chain, result)
            }
            
            var ibcEurekaSend = false
            getMsgs()?.forEach({ msg in
                if (msg["@type"].string?.contains("ibc") == true && msg["@type"].string?.contains("v2.MsgSendPacket") == true) {
                    ibcEurekaSend = true
                }
            })
            if (ibcEurekaSend) {
                data?.logs?.forEach({ log in
                    if let event = log["events"].array?.filter({ $0["type"].string == "ibc_transfer" }).first {
                        event["attributes"].array?.forEach({ attribute in
                            if (attribute["value"].string == chain.bechAddress) {
                                if let rawAmount = event["attributes"].array?.filter({ $0["key"].string == "amount" }).first?["value"].string,
                                   let rawDenom = event["attributes"].array?.filter({ $0["key"].string == "denom" }).first?["value"].string {
                                    let value = Cosmos_Base_V1beta1_Coin.with {
                                        $0.denom = rawDenom
                                        $0.amount = rawAmount
                                    }
                                    result.append(value)
                                }
                            }
                        })
                    }
                })
                return sortedCoins(chain, result)
            }
            
        }
        
        //display re-invset amount
        if (getMsgCnt() == 2) {
            if let msgType0 = getMsgs()?[0]["@type"].string,
               let msgType1 = getMsgs()?[1]["@type"].string,
               msgType0.contains("MsgWithdrawDelegatorReward"),
               msgType1.contains("MsgDelegate") {
                if let msgValue1 = getMsgs()?[1][msgType1.replacingOccurrences(of: ".", with: "-")] {
                    let rawAmount = msgValue1["amount"]
                    if (!rawAmount.isEmpty) {
                        let value = Cosmos_Base_V1beta1_Coin.with {
                            $0.denom = rawAmount["denom"].stringValue
                            $0.amount = rawAmount["amount"].stringValue
                        }
                        result.append(value)
                    }
                }
                return sortedCoins(chain, result)
            }
        }


        if (getMsgCnt() == 0 || getMsgCnt() > 1) { return nil }
        if let firstMsg = getMsgs()?[0],
           let msgType = firstMsg["@type"].string {
            let msgValue = firstMsg[msgType.replacingOccurrences(of: ".", with: "-")]
            
            if (msgType.contains("MsgSend")) {
                if let rawAmounts = msgValue["amount"].array {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmounts[0]["denom"].stringValue
                        $0.amount = rawAmounts[0]["amount"].stringValue
                    }
                    result.append(value)
                }
                if let rawAmounts = msgValue["value"]["amount"].array {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmounts[0]["denom"].stringValue
                        $0.amount = rawAmounts[0]["amount"].stringValue
                    }
                    result.append(value)
                }

            } else if (msgType.contains("MsgMultiSend")) {
                for input in msgValue["inputs"].arrayValue {
                    if (input["address"].string == chain.bechAddress) {
                        let value = Cosmos_Base_V1beta1_Coin.with {
                            $0.denom = input["coins"][0]["denom"].stringValue
                            $0.amount = input["coins"][0]["amount"].stringValue
                        }
                        result.append(value)
                        break
                    }
                }
                for output in msgValue["outputs"].arrayValue {
                    if (output["address"].string == chain.bechAddress) {
                        let value = Cosmos_Base_V1beta1_Coin.with {
                            $0.denom = output["coins"][0]["denom"].stringValue
                            $0.amount = output["coins"][0]["amount"].stringValue
                        }
                        result.append(value)
                        break
                    }
                }
                
            } else if (msgType.contains("MsgDelegate") || msgType.contains("MsgUndelegate") ||
                       msgType.contains("MsgBeginRedelegate") || msgType.contains("MsgCancelUnbondingDelegation")) {
                let rawAmount = msgValue["amount"]
                if (!rawAmount.isEmpty) {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmount["denom"].stringValue
                        $0.amount = rawAmount["amount"].stringValue
                    }
                    result.append(value)
                }

            } else if (msgType.contains("ibc") && msgType.contains("MsgTransfer")) {
                let rawAmount = msgValue["token"]
                if (!rawAmount.isEmpty) {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmount["denom"].stringValue
                        $0.amount = rawAmount["amount"].stringValue
                    }
                    result.append(value)
                }
                
            } else if (msgType.contains("ethermint.evm") && msgType.contains("MsgEthereumTx")) {
                if let dataValue = msgValue.evmDataValue() {
                    let amount = dataValue["value"].stringValue
                    let data = dataValue["data"].stringValue
                    if (data.isEmpty == true && amount.isEmpty == false && amount != "0") {
                        let value = Cosmos_Base_V1beta1_Coin.with {
                            if (chain.tag == "kava60") {
                                $0.denom = "akava"
                            } else {
                                $0.denom = chain.stakingAssetDenom()
                            }
                            $0.amount = amount
                        }
                        result.append(value)
                        
                    }
                }
            }
        }
        return sortedCoins(chain, result)
    }
    
    func getDpToken(_ chain: BaseChain) -> (erc20: MintscanToken, amount: NSDecimalNumber)? {
        if let firstMsg = getMsgs()?[0],
           let msgType = firstMsg["@type"].string {
            let msgValue = firstMsg[msgType.replacingOccurrences(of: ".", with: "-")]
            
            if (msgType.contains("cosmwasm.") && msgType.contains("MsgExecuteContract")) {
                if let contractAddress = msgValue["contract"].string,
                   let wasmMsg = msgValue["msg__@stringify"].string,
                   let wasmFunc = try? JSONDecoder().decode(JSON.self, from: wasmMsg.data(using: .utf8) ?? Data()),
                   let amount = wasmFunc["transfer"]["amount"].string,
                   let cw20 = chain.getCosmosfetcher()?.mintscanCw20Tokens.first(where: { $0.address == contractAddress }) {
                       return (cw20, NSDecimalNumber(string: amount))
                }
                
            } else if (msgType.contains("ethermint.evm") && msgType.contains("MsgEthereumTx")) {
                if let dataValue = msgValue.evmDataValue(),
                   let data = dataValue["data"].string,
                   let hexData = Data(base64Encoded: data)?.toHexString(),
                   let contractAddress = dataValue["to"].string,
                   let erc20 = chain.getEvmfetcher()?.mintscanErc20Tokens.first(where: { $0.address == contractAddress }) {
                    let suffix = String(hexData.suffix(64))
                    if (suffix.count < 15) {
                        return (erc20, suffix.hexToNSDecimal())
                    } else {
                        return (erc20, NSDecimalNumber.zero)
                    }
                }
            }
        }
        return nil
    }
    
    public func getVoteOption() -> String {
        var result = ""
        if let firstMsg = getMsgs()?[0],
           let msgType = firstMsg["@type"].string,
           msgType.contains("MsgVote") {
            let msgValue = firstMsg[msgType.replacingOccurrences(of: ".", with: "-")]
            if let rawOption = msgValue["option"].string {
                if (rawOption == "VOTE_OPTION_YES") {
                    result = "YES"
                } else if (rawOption == "VOTE_OPTION_ABSTAIN") {
                    result = "ABSTAIN"
                } else if (rawOption == "VOTE_OPTION_NO") {
                    result = "NO"
                } else if (rawOption == "VOTE_OPTION_NO_WITH_VETO") {
                    result = "VETO"
                }
            }
        }
        return result
    }
    
    func sortedCoins(_ chain: BaseChain, _ input: [Cosmos_Base_V1beta1_Coin]?) -> [Cosmos_Base_V1beta1_Coin]? {
        var sorted = Array<Cosmos_Base_V1beta1_Coin>()
        input?.forEach { coin in
            if let index = sorted.firstIndex(where: { $0.denom == coin.denom }) {
                let exist = NSDecimalNumber(string: sorted[index].amount)
                let addes = exist.adding(NSDecimalNumber(string: coin.amount))
                sorted[index].amount = addes.stringValue
            } else {
                sorted.append(coin)
            }
        }
        sorted.sort {
            if ($0.denom == chain.stakingAssetDenom() && $1.denom != chain.stakingAssetDenom()) { return true }
            return false
        }
        return sorted
    }
    
}


public struct MintscanHistoryHeader: Codable {
    var id: Int64?
    var chain_id: String?
    var block_id: Int64?
    var timestamp: String?
}

public struct MintscanHistoryData: Codable {
    var height: String?
    var txhash: String?
    var codespace: String?
    var code: Int?
    var info: String?
    var timestamp: String?
    var tx: JSON?
    var logs: Array<JSON>?
    
}


extension JSON {
    func evmDataValue() -> JSON? {
        let dataType = self["data"]["@type"].stringValue
        return self["data"][dataType.replacingOccurrences(of: ".", with: "-")]
    }
    
}
