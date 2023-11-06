//
//  MintscanHistory.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct MintscanHistory: Codable {
    var header: MintscanHistoryHeader?
    var data: MintscanHistoryData?
    
    public func isSuccess() -> Bool {
        if let RawCode = self.data?.code {
            if (RawCode != 0) {
                return false
            }
        }
        return true
    }
    
    public func getMsgs() -> Array<JSON>? {
        if let msgs = data?.tx?["body"]["messages"].array {
            return msgs
        }
        if let msgs = data?.tx?["value"]["msg"].array {
            return msgs
        }
        return nil
    }
    
    
    public func getMsgCnt() -> Int {
        guard let msgs = getMsgs() else {
            return 0
        }
        return msgs.count
    }
    
    
    public func getMsgType(_ address: String) -> String {
        var result = NSLocalizedString("tx_known", comment: "")
        if (getMsgCnt() == 0) {
            return result;
            
        } else {
            if let firstMsgType = getMsgs()?[0]["@type"].string {
                result = firstMsgType.components(separatedBy: ".").last?.replacingOccurrences(of: "Msg", with: "") ?? NSLocalizedString("tx_known", comment: "")
            }
            
            if (getMsgCnt() >= 2) {
                var msgType0 = ""
                var msgType1 = ""
                
                if let rawMsgType = getMsgs()?[0]["@type"].string {
                    msgType0 = rawMsgType
                }
                if let rawMsgType = getMsgs()?[0]["type"].string {
                    msgType0 = rawMsgType
                }
                if let rawMsgType = getMsgs()?[1]["@type"].string {
                    msgType1 = rawMsgType
                }
                if let rawMsgType = getMsgs()?[1]["type"].string {
                    msgType1 = rawMsgType
                }
                if ((msgType0.contains("MsgWithdrawDelegatorReward") || msgType0.contains("MsgWithdrawDelegationReward")) && msgType1.contains("MsgDelegate")) {
                    return NSLocalizedString("tx_reinvest", comment: "")
                }
                
                if (msgType1.contains("ibc") && msgType1.contains("MsgRecvPacket")) {
                    return NSLocalizedString("tx_ibc_receive", comment: "")
                }
                
            }
            
            var msgType = ""
            if let rawMsgType = getMsgs()?[0]["@type"].string {
                msgType = rawMsgType
            }
            if let rawMsgType = getMsgs()?[0]["type"].string {
                msgType = rawMsgType
            }
            

            // cosmos default msg type
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
                    if let senderAddr = getMsgs()?[0]["from_address"].string, senderAddr == address {
                        result = NSLocalizedString("tx_send", comment: "")
                    } else if let senderAddr = getMsgs()?[0]["value"]["from_address"].string, senderAddr == address {
                        result = NSLocalizedString("tx_send", comment: "")
                    } else if let receiverAddr = getMsgs()?[0]["to_address"].string, receiverAddr == address {
                        result = NSLocalizedString("tx_receive", comment: "")
                    } else if let receiverAddr = getMsgs()?[0]["value"]["to_address"].string, receiverAddr == address {
                        result = NSLocalizedString("tx_receive", comment: "")
                    } else {
                        result = NSLocalizedString("tx_transfer", comment: "")
                    }
                    
                } else if (msgType.contains("MsgMultiSend")) {
                    result = NSLocalizedString("tx_transfer", comment: "")
                    
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
                    if let innerMsgs = getMsgs()?[0]["msgs"].array, let inner0Type = innerMsgs[0]["@type"].string {
                        var innerTx = NSLocalizedString("tx_known", comment: "")
                        if (inner0Type.contains("MsgSend")) {
                            innerTx = NSLocalizedString("tx_transfer", comment: "")
                        } else if (inner0Type.contains("MsgDelegate")) {
                            innerTx = NSLocalizedString("tx_delegate", comment: "")
                        } else if (inner0Type.contains("MsgUndelegate")) {
                            innerTx = NSLocalizedString("tx_undelegate", comment: "")
                        } else if (inner0Type.contains("MsgBeginRedelegate")) {
                            innerTx = NSLocalizedString("tx_redelegate", comment: "")
                        } else if (inner0Type.contains("MsgVote")) {
                            innerTx = NSLocalizedString("tx_vote", comment: "")
                        } else if (inner0Type.contains("MsgWithdrawDelegatorReward")) {
                            innerTx = NSLocalizedString("tx_get_reward", comment: "")
                        } else if (inner0Type.contains("MsgWithdrawValidatorCommission")) {
                            innerTx = NSLocalizedString("tx_get_commission", comment: "")
                        }
                        if (innerMsgs.count > 1) {
                            innerTx = innerTx +  " + " + String(innerMsgs.count - 1)
                        }
                        result = result + "\n" + innerTx
                    }
                        
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
            
            // ibc msg type
            else if (msgType.contains("ibc.")) {
                if (msgType.contains("MsgTransfer")) {
                    result = NSLocalizedString("tx_ibc_send", comment: "")
                    
                } else if (msgType.contains("MsgUpdateClient")) {
                    result = NSLocalizedString("tx_ibc_client_update", comment: "")
                    
                } else if (msgType.contains("MsgAcknowledgement")) {
                    result = NSLocalizedString("tx_ibc_acknowledgement", comment: "")
                    
                } else if (msgType.contains("MsgRecvPacket")) {
                    result = NSLocalizedString("tx_ibc_receive", comment: "")
                    
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
                    if let senderAddr = getMsgs()?[0]["sender"].string, senderAddr == address {
                        result = NSLocalizedString("tx_nft_send", comment: "")
                    } else if let receiverAddr = getMsgs()?[0]["recipient"].string, receiverAddr == address {
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
                    if let senderAddr = getMsgs()?[0]["sender"].string, senderAddr == address {
                        result = NSLocalizedString("tx_nft_send", comment: "")
                    } else if let receiverAddr = getMsgs()?[0]["recipient"].string, receiverAddr == address {
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
            else if (msgType.contains("osmosis.") && msgType.contains("gamm")) {
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
            
            // sif msg type
            else if (msgType.contains("sifnode.") && msgType.contains("clp")) {
                if (msgType.contains("MsgRemoveLiquidity")) {
                    result = NSLocalizedString("tx_remove_liquidity", comment: "")
                    
                } else if (msgType.contains("MsgCreatePool")) {
                    result = NSLocalizedString("tx_create_pool", comment: "")
                    
                } else if (msgType.contains("MsgAddLiquidity")) {
                    result = NSLocalizedString("tx_add_liquidity", comment: "")
                    
                } else if (msgType.contains("MsgSwap")) {
                    result = NSLocalizedString("tx_coin_swap", comment: "")
                    
                } else if (msgType.contains("MsgDecommissionPool")) {
                    
                } else if (msgType.contains("MsgUnlockLiquidityRequest")) {
                    
                } else if (msgType.contains("MsgUpdateRewardsParamsRequest")) {
                    
                } else if (msgType.contains("MsgAddRewardPeriodRequest")) {
                    
                } else if (msgType.contains("MsgModifyPmtpRates")) {
                    
                } else if (msgType.contains("MsgUpdatePmtpParams")) {
                    
                } else if (msgType.contains("MsgUpdateStakingRewardParams")) {
                    
                }
                
            } else if (msgType.contains("sifnode.") && msgType.contains("dispensation")) {
                if (msgType.contains("MsgCreateUserClaim")) {
                    result = NSLocalizedString("tx_despensation_claim", comment: "")
                    
                } else if (msgType.contains("MsgRunDistribution")) {
                    result = NSLocalizedString("tx_distribution_run", comment: "")
                    
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
                    
                } else if (msgType.contains("MsgRequestDTagTransfer")) {
                    
                } else if (msgType.contains("MsgCancelDTagTransferRequest")) {
                    
                } else if (msgType.contains("MsgAcceptDTagTransferRequest")) {
                    
                } else if (msgType.contains("MsgRefuseDTagTransferRequest")) {
                    
                } else if (msgType.contains("MsgLinkChainAccount")) {
                    result = NSLocalizedString("tx_desmos_link_chain_account", comment: "")
                    
                } else if (msgType.contains("MsgUnlinkChainAccount")) {
                    
                } else if (msgType.contains("MsgLinkApplication")) {
                    
                } else if (msgType.contains("MsgUnlinkApplication")) {
                    
                }
            }
            
            // wasm msg type
            else if (msgType.contains("cosmwasm.")) {
                if (msgType.contains("MsgStoreCode")) {
                    result = NSLocalizedString("tx_cosmwasm_store_code", comment: "")
                    
                } else if (msgType.contains("MsgInstantiateContract")) {
                    result = NSLocalizedString("tx_cosmwasm_instantiate", comment: "")
                    
                } else if (msgType.contains("MsgExecuteContract")) {
                    result = NSLocalizedString("tx_cosmwasm_execontract", comment: "")
                    
                } else if (msgType.contains("MsgMigrateContract")) {
                    
                } else if (msgType.contains("MsgUpdateAdmin")) {
                    
                } else if (msgType.contains("MsgClearAdmin")) {
                    
                } else if (msgType.contains("PinCodesProposal")) {
                    
                } else if (msgType.contains("UnpinCodesProposal")) {
                    
                } else if (msgType.contains("StoreCodeProposal")) {
                    
                } else if (msgType.contains("InstantiateContractProposal")) {
                    
                } else if (msgType.contains("MigrateContractProposal")) {
                    
                } else if (msgType.contains("UpdateAdminProposal")) {
                    
                } else if (msgType.contains("ClearAdminProposal")) {
                    
                }
            }
            
            // evm msg type
            else if (msgType.contains("ethermint.evm")) {
                if (msgType.contains("MsgEthereumTx")) {
                    result = NSLocalizedString("tx_ethereum_evm", comment: "")
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
                
                } else if (msgType.contains("ExecutePendingTransfersRequest")) {

                } else if (msgType.contains("RegisterIBCPathRequest")) {

                } else if (msgType.contains("AddCosmosBasedChainRequest")) {

                } else if (msgType.contains("RegisterAssetRequest")) {

                } else if (msgType.contains("RegisterFeeCollectorRequest")) {

                } else if (msgType.contains("RetryIBCTransferRequest")) {

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

            if (getMsgCnt() > 1) {
                result = result +  " + " + String(getMsgCnt() - 1)
            }
            
        }
        return result
    }
    
    
    func getDpCoin(_ chain: CosmosClass) -> [Cosmos_Base_V1beta1_Coin]? {
        //display staking reward amount
        var result = Array<Cosmos_Base_V1beta1_Coin>()
        if (getMsgCnt() > 0) {
            var allReward = true
            for msg in getMsgs()! {
                var msgType = ""
                if let rawMsgType = msg["@type"].string { msgType = rawMsgType }
                if let rawMsgType = msg["type"].string { msgType = rawMsgType }
                if (!msgType.contains("MsgWithdrawDelegatorReward")) {
                    allReward = false
                }
            }
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
            
            
            var ibcReceived = false
            for msg in getMsgs()! {
                var msgType = ""
                if let rawMsgType = msg["@type"].string { msgType = rawMsgType }
                if let rawMsgType = msg["type"].string { msgType = rawMsgType }
                if (msgType.contains("ibc") && msgType.contains("MsgRecvPacket")) {
                    ibcReceived = true
                }
            }
            if (ibcReceived) {
                data?.logs?.forEach({ log in
                    if let event = log["events"].array?.filter({ $0["type"].string == "transfer" }).first {
                        event["attributes"].array?.forEach({ attribute in
                            if (attribute["value"].string == chain.address!) {
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
        }
        
        //display re-invset amount
        if (getMsgCnt() == 2) {
            var msgType0 = ""
            var msgType1 = ""
            if let rawMsgType = getMsgs()?[0]["@type"].string { msgType0 = rawMsgType }
            if let rawMsgType = getMsgs()?[0]["type"].string { msgType0 = rawMsgType }
            if let rawMsgType = getMsgs()?[1]["@type"].string { msgType1 = rawMsgType }
            if let rawMsgType = getMsgs()?[1]["type"].string { msgType1 = rawMsgType }
            if (msgType0.contains("MsgWithdrawDelegatorReward") && msgType1.contains("MsgDelegate")) {
                if let rawAmount = getMsgs()?[1]["amount"] {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmount["denom"].stringValue
                        $0.amount = rawAmount["amount"].stringValue
                    }
                    result.append(value)
                }
                return sortedCoins(chain, result)
            }
        }


        if (getMsgCnt() == 0 || getMsgCnt() > 1) { return nil }

        var msgType = ""
        if let rawMsgType = getMsgs()?[0]["@type"].string { msgType = rawMsgType }
        if let rawMsgType = getMsgs()?[0]["type"].string { msgType = rawMsgType }

        if (msgType.contains("MsgSend")) {
            if let rawAmounts = getMsgs()?[0]["amount"].array {
                let value = Cosmos_Base_V1beta1_Coin.with {
                    $0.denom = rawAmounts[0]["denom"].stringValue
                    $0.amount = rawAmounts[0]["amount"].stringValue
                }
                result.append(value)
            }
            if let rawAmounts = getMsgs()?[0]["value"]["amount"].array {
                let value = Cosmos_Base_V1beta1_Coin.with {
                    $0.denom = rawAmounts[0]["denom"].stringValue
                    $0.amount = rawAmounts[0]["amount"].stringValue
                }
                result.append(value)
            }

        } else if (msgType.contains("MsgDelegate") || msgType.contains("MsgUndelegate") || msgType.contains("MsgBeginRedelegate")) {
            if let rawAmount = getMsgs()?[0]["amount"] {
                if (!rawAmount.isEmpty) {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmount["denom"].stringValue
                        $0.amount = rawAmount["amount"].stringValue
                    }
                    result.append(value)
                }

            }
            if let rawAmount = getMsgs()?[0]["value"]["amount"] {
                if (!rawAmount.isEmpty) {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmount["denom"].stringValue
                        $0.amount = rawAmount["amount"].stringValue
                    }
                    result.append(value)
                }
            }

        } else if (msgType.contains("ibc") && msgType.contains("MsgTransfer")) {
            if let rawAmount = getMsgs()?[0]["token"] {
                if (!rawAmount.isEmpty) {
                    let value = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = rawAmount["denom"].stringValue
                        $0.amount = rawAmount["amount"].stringValue
                    }
                    result.append(value)
                }
            }
        }
        return sortedCoins(chain, result)
    }
    
    
    public func getVoteOption() -> String {
        var result = ""
        var msgType = ""
        if let rawMsgType = getMsgs()?[0]["@type"].string { msgType = rawMsgType }
        if let rawMsgType = getMsgs()?[0]["type"].string { msgType = rawMsgType }
        if (msgType.contains("MsgVote")) {
            if let rawOption = getMsgs()?[0]["option"].string {
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
    
    func sortedCoins(_ chain: CosmosClass, _ input: [Cosmos_Base_V1beta1_Coin]?) -> [Cosmos_Base_V1beta1_Coin]? {
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
            if ($0.denom == chain.stakeDenom && $1.denom != chain.stakeDenom) { return true }
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
    var data: String?
    var raw_log: String?
    var info: String?
    var gas_wanted: String?
    var gas_used: String?
    var timestamp: String?
    var tx: JSON?
    var logs: Array<JSON>?
    
}
