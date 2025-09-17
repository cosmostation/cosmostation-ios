//
//  Signer.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/12/14.
//  Copyright © 2020 wannabit. All rights reserved.
//

import Foundation
import SwiftProtobuf
import Web3Core
import secp256k1
import Blake2
import ed25519swift
import SwiftyJSON

class Signer {
    //Tx for Transfer
    static func genSendMsg(_ toSend: Cosmos_Bank_V1beta1_MsgSend) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.bank.v1beta1.MsgSend"
            $0.value = try! toSend.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Thor Send
    static func genThorSendMsg(_ toSend: Types_MsgSend) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/types.MsgSend"
            $0.value = try! toSend.serializedData()
        }
        return [anyMsg]
    }
    
    static func genGnoSendMsg(_ toSend: Gno_Bank_MsgSend) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/bank.MsgSend"
            $0.value = try! toSend.serializedData()
        }
        return [anyMsg]
    }
    
    // gno grc20 send
    static func genGnoSendMsg(_ toSend: Gno_Vm_MsgCall) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/vm.m_call"
            $0.value = try! toSend.serializedData()
        }
        return [anyMsg]
    }

    
    //Tx for Ibc Transfer
    static func genIbcSendMsg(_ ibcTransfer: Ibc_Applications_Transfer_V1_MsgTransfer) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/ibc.applications.transfer.v1.MsgTransfer"
            $0.value = try! ibcTransfer.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Wasm Exe
    static func genWasmMsg(_ wasmContracts: [Cosmwasm_Wasm_V1_MsgExecuteContract]) -> [Google_Protobuf_Any] {
        var result = [Google_Protobuf_Any]()
        wasmContracts.forEach { msg in
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmwasm.wasm.v1.MsgExecuteContract"
                $0.value = try! msg.serializedData()
            }
            result.append(anyMsg)
        }
        return result
    }
    
    //Tx for Ibc Eureka Transfer
    static func genIbcEurekaSendMsg(_ ibcEurekaTransfer: [Ibc_Core_Channel_V2_MsgSendPacket]) -> [Google_Protobuf_Any] {
        var result = [Google_Protobuf_Any]()
        ibcEurekaTransfer.forEach { msg in
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/ibc.core.channel.v2.MsgSendPacket"
                $0.value = try! msg.serializedData()
            }
            result.append(anyMsg)
        }
        return result
    }
    
    //Tx for Common Delegate
    static func genDelegateMsg(_ toDelegate: Cosmos_Staking_V1beta1_MsgDelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
            $0.value = try! toDelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genDelegateMsg(_ toDelegate: Initia_Mstaking_V1_MsgDelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/initia.mstaking.v1.MsgDelegate"
            $0.value = try! toDelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genDelegateMsg(_ toDelegate: Zrchain_Validation_MsgDelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/zrchain.validation.MsgDelegate"
            $0.value = try! toDelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genDelegateMsg(_ toDelegate: Babylon_Epoching_V1_MsgWrappedDelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/babylon.epoching.v1.MsgWrappedDelegate"
            $0.value = try! toDelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genDelegateMsg(_ toDelegate: Babylon_Btcstaking_V1_MsgCreateBTCDelegation) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/babylon.btcstaking.v1.MsgCreateBTCDelegation"
            $0.value = try! toDelegate.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Common UnDelegate
    static func genUndelegateMsg(_ toUndelegate: Cosmos_Staking_V1beta1_MsgUndelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgUndelegate"
            $0.value = try! toUndelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genUndelegateMsg(_ toUndelegate: Initia_Mstaking_V1_MsgUndelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/initia.mstaking.v1.MsgUndelegate"
            $0.value = try! toUndelegate.serializedData()
        }
        return [anyMsg]
    }

    static func genUndelegateMsg(_ toUndelegate: Zrchain_Validation_MsgUndelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/zrchain.validation.MsgUndelegate"
            $0.value = try! toUndelegate.serializedData()
        }
        return [anyMsg]
    }

    static func genUndelegateMsg(_ toUndelegate: Babylon_Epoching_V1_MsgWrappedUndelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/babylon.epoching.v1.MsgWrappedUndelegate"
            $0.value = try! toUndelegate.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Common CancelUnbonding
    static func genCancelUnbondingMsg(_ toCancel: Cosmos_Staking_V1beta1_MsgCancelUnbondingDelegation) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgCancelUnbondingDelegation"
            $0.value = try! toCancel.serializedData()
        }
        return [anyMsg]
    }
    
    static func genCancelUnbondingMsg(_ toCancel: Initia_Mstaking_V1_MsgCancelUnbondingDelegation) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/initia.mstaking.v1.MsgCancelUnbondingDelegation"
            $0.value = try! toCancel.serializedData()
        }
        return [anyMsg]
    }

    static func genCancelUnbondingMsg(_ toCancel: Zrchain_Validation_MsgCancelUnbondingDelegation) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/zrchain.validation.MsgCancelUnbondingDelegation"
            $0.value = try! toCancel.serializedData()
        }
        return [anyMsg]
    }
    
    static func genCancelUnbondingMsg(_ toCancel: Babylon_Epoching_V1_MsgWrappedCancelUnbondingDelegation) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/babylon.epoching.v1.MsgWrappedCancelUnbondingDelegation"
            $0.value = try! toCancel.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Common ReDelegate
    static func genRedelegateMsg(_ toRedelegate: Cosmos_Staking_V1beta1_MsgBeginRedelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgBeginRedelegate"
            $0.value = try! toRedelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genRedelegateMsg(_ toRedelegate: Initia_Mstaking_V1_MsgBeginRedelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/initia.mstaking.v1.MsgBeginRedelegate"
            $0.value = try! toRedelegate.serializedData()
        }
        return [anyMsg]
    }
    
    static func genRedelegateMsg(_ toRedelegate: Zrchain_Validation_MsgBeginRedelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/zrchain.validation.MsgBeginRedelegate"
            $0.value = try! toRedelegate.serializedData()
        }
        return [anyMsg]
    }

    static func genRedelegateMsg(_ toRedelegate: Babylon_Epoching_V1_MsgWrappedBeginRedelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/babylon.epoching.v1.MsgWrappedBeginRedelegate"
            $0.value = try! toRedelegate.serializedData()
        }
        return [anyMsg]
    }
    

    //Tx for Common Claim Staking Rewards
    static func genClaimStakingRewardMsg(_ address: String, _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        for reward in rewards {
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
            }
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        return anyMsgs
    }
    
    static func genBabylonClaimStakingRewardMsg(_ address: String, _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        for reward in rewards {
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
            }
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        
        let claimMsg = Babylon_Incentive_MsgWithdrawReward.with {
            $0.address = address
            $0.type = "BTC_STAKER"
        }
        
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/babylon.incentive.MsgWithdrawReward"
            $0.value = try! claimMsg.serializedData()
        }
        anyMsgs.append(anyMsg)

        return anyMsgs
    }
    
    static func genNeutronClaimStakingRewardMsg(_ address: String, _ contract: String) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        let claimMsg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = address
            $0.contract = contract
            $0.funds = []
            let msg: JSON = ["claim_rewards" : JSON()]
            $0.msg = try! msg.rawData()
        }
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmwasm.wasm.v1.MsgExecuteContract"
            $0.value = try! claimMsg.serializedData()
        }
        anyMsgs.append(anyMsg)
        
        return anyMsgs
    }
    
    
    //Tx for Common Claim Commission
    static func genClaimCommissionMsg(_ commission: Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawValidatorCommission"
            $0.value = try! commission.serializedData()
        }
        return [anyMsg]
    }
    
    
    //Tx for Common Compounding
    static func genCompoundingMsg(_ address: String,
                                  _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward],
                                  _ stakingDenom: String) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        rewards.forEach { reward in
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
            }
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
            
            let rewardCoin = reward.reward.filter({ $0.denom == stakingDenom }).first
            let deleCoin = Cosmos_Base_V1beta1_Coin.with {
                $0.denom = rewardCoin!.denom
                $0.amount = NSDecimalNumber.init(string: rewardCoin!.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down).stringValue
            }
            let deleMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
                $0.amount = deleCoin
            }
            let deleAnyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
                $0.value = try! deleMsg.serializedData()
            }
            anyMsgs.append(deleAnyMsg)
        }
        return anyMsgs
    }
    
    static func genInitiaCompoundingMsg(_ address: String,
                                        _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward],
                                        _ stakingDenom: String) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        rewards.forEach { reward in
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
            }
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
            
            let rewardCoin = reward.reward.filter({ $0.denom == stakingDenom }).first
            let deleCoin = Cosmos_Base_V1beta1_Coin.with {
                $0.denom = rewardCoin!.denom
                $0.amount = NSDecimalNumber.init(string: rewardCoin!.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down).stringValue
            }
            let deleMsg = Initia_Mstaking_V1_MsgDelegate.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
                $0.amount = [deleCoin]
            }
            let deleAnyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/initia.mstaking.v1.MsgDelegate"
                $0.value = try! deleMsg.serializedData()
            }
            anyMsgs.append(deleAnyMsg)
        }
        return anyMsgs
    }
    
    static func genZenrockCompoundingMsg(_ address: String,
                                        _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward],
                                        _ stakingDenom: String) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        rewards.forEach { reward in
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
            }
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
            
            let rewardCoin = reward.reward.filter({ $0.denom == stakingDenom }).first
            let deleCoin = Cosmos_Base_V1beta1_Coin.with {
                $0.denom = rewardCoin!.denom
                $0.amount = NSDecimalNumber.init(string: rewardCoin!.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down).stringValue
            }
            let deleMsg = Zrchain_Validation_MsgDelegate.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
                $0.amount = deleCoin
            }
            let deleAnyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/zrchain.validation.MsgDelegate"
                $0.value = try! deleMsg.serializedData()
            }
            anyMsgs.append(deleAnyMsg)
        }
        return anyMsgs
    }
    
    static func genBabylonCompoundingMsg(_ address: String,
                                         _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward],
                                         _ stakingDenom: String) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        rewards.forEach { reward in
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = address
                $0.validatorAddress = reward.validatorAddress
            }
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
            
            let rewardCoin = reward.reward.filter({ $0.denom == stakingDenom }).first
            let deleCoin = Cosmos_Base_V1beta1_Coin.with {
                $0.denom = rewardCoin!.denom
                $0.amount = NSDecimalNumber.init(string: rewardCoin!.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down).stringValue
            }
            let deleMsg = Babylon_Epoching_V1_MsgWrappedDelegate.with {
                $0.msg.delegatorAddress = address
                $0.msg.validatorAddress = reward.validatorAddress
                $0.msg.amount = deleCoin
            }
            let deleAnyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/babylon.epoching.v1.MsgWrappedDelegate"
                $0.value = try! deleMsg.serializedData()
            }
            anyMsgs.append(deleAnyMsg)
        }
        return anyMsgs
    }
    
    static func genNeutronCompoundingMsg(_ address: String,
                                         _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward],
                                         _ stakingDenom: String,
                                         _ validatorAddress: String,
                                         _ contract: String) -> [Google_Protobuf_Any] {
        var anyMsgs = [Google_Protobuf_Any]()
        let claimMsg = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = address
            $0.contract = contract
            $0.funds = []
            let msg: JSON = ["claim_rewards" : JSON()]
            $0.msg = try! msg.rawData()
        }
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmwasm.wasm.v1.MsgExecuteContract"
            $0.value = try! claimMsg.serializedData()
        }
        anyMsgs.append(anyMsg)
            
        rewards.forEach { reward in
            let rewardCoin = reward.reward.filter({ $0.denom == stakingDenom }).first
            let deleCoin = Cosmos_Base_V1beta1_Coin.with {
                $0.denom = rewardCoin!.denom
                $0.amount = NSDecimalNumber.init(string: rewardCoin!.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down).stringValue
            }
            let deleMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
                $0.delegatorAddress = address
                $0.validatorAddress = validatorAddress
                $0.amount = deleCoin
            }
            let deleAnyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
                $0.value = try! deleMsg.serializedData()
            }
            anyMsgs.append(deleAnyMsg)
        }
        return anyMsgs
    }
    
    //Tx for Common Vote
    static func genVoteMsg(_ chain: BaseChain, _ votes: [Cosmos_Gov_V1beta1_MsgVote]) -> [Google_Protobuf_Any] {
        var anyMsgs = Array<Google_Protobuf_Any>()
        votes.forEach { vote in
            let anyMsg = Google_Protobuf_Any.with {
                if (chain is ChainGovgen) {
                    $0.typeURL = "/govgen.gov.v1beta1.MsgVote"
                    
                } else if (chain is ChainAtomone) {
                    $0.typeURL = "/atomone.gov.v1beta1.MsgVote"
                    
                } else {
                    $0.typeURL = "/cosmos.gov.v1beta1.MsgVote"
                }
                $0.value = try! vote.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        return anyMsgs
    }
    
    //Tx for Common Reward Address Change
    static func genRewardAddressMsg(_ setAddress: Cosmos_Distribution_V1beta1_MsgSetWithdrawAddress) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgSetWithdrawAddress"
            $0.value = try! setAddress.serializedData()
        }
        return [anyMsg]
    }
    
    
    //for kava sign
    //Tx for Kava CDP Create
    static func genKavaCDPCreateMsg(_ toCreate: Kava_Cdp_V1beta1_MsgCreateCDP) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgCreateCDP"
            $0.value = try! toCreate.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava CDP Deposit
    static func genKavaCDPDepositMsg(_ toDeposit: Kava_Cdp_V1beta1_MsgDeposit) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgDeposit"
            $0.value = try! toDeposit.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava CDP Withdraw
    static func genKavaCDPWithdrawMsg(_ toWithdraw: Kava_Cdp_V1beta1_MsgWithdraw) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgWithdraw"
            $0.value = try! toWithdraw.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava CDP Draw Debt
    static func genKavaCDPDrawMsg(_ toDrawDebt: Kava_Cdp_V1beta1_MsgDrawDebt) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgDrawDebt"
            $0.value = try! toDrawDebt.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava CDP Repay
    static func genKavaCDPRepayMsg(_ toRepay: Kava_Cdp_V1beta1_MsgRepayDebt) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgRepayDebt"
            $0.value = try! toRepay.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Hard Deposit
    static func genKavaHardDepositMsg(_ toDeposit: Kava_Hard_V1beta1_MsgDeposit) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgDeposit"
            $0.value = try! toDeposit.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Hard Withdraw
    static func genKavaHardWithdrawMsg(_ toWithdraw: Kava_Hard_V1beta1_MsgWithdraw) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgWithdraw"
            $0.value = try! toWithdraw.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Hard Borrow
    static func genKavaHardBorrowMsg(_ toBorrow: Kava_Hard_V1beta1_MsgBorrow) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgBorrow"
            $0.value = try! toBorrow.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Hard Repay
    static func genKavaHardRepayMsg(_ toRepay: Kava_Hard_V1beta1_MsgRepay) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgRepay"
            $0.value = try! toRepay.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Swap Deposit
    static func genKavaSwpDepositMsg(_ toDeposit: Kava_Swap_V1beta1_MsgDeposit) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgDeposit"
            $0.value = try! toDeposit.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Swap Withdraw
    static func genKavaSwpWithdrawMsg(_ toWithdraw: Kava_Swap_V1beta1_MsgWithdraw) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgWithdraw"
            $0.value = try! toWithdraw.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Incentive All
    static func genKavaIncentiveMsgs(_ address: String, _ incentives: Kava_Incentive_V1beta1_QueryRewardsResponse) -> [Google_Protobuf_Any] {
        var msgs = [Google_Protobuf_Any]()
        if (incentives.hasUsdxMinting()) {
            let incentiveMint = Kava_Incentive_V1beta1_MsgClaimUSDXMintingReward.with {
                $0.sender = address
                $0.multiplierName = "large"
            }
            let msg = Google_Protobuf_Any.with {
                $0.typeURL = "/kava.incentive.v1beta1.MsgClaimUSDXMintingReward"
                $0.value = try! incentiveMint.serializedData()
            }
            msgs.append(msg)
        }
        if (incentives.getHardRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentives.getHardRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = "large" })
            }
            let incentiveHard = Kava_Incentive_V1beta1_MsgClaimHardReward.with {
                $0.sender = address
                $0.denomsToClaim = denoms_to_claims
            }
            let msg = Google_Protobuf_Any.with {
                $0.typeURL = "/kava.incentive.v1beta1.MsgClaimHardReward"
                $0.value = try! incentiveHard.serializedData()
            }
            msgs.append(msg)
        }
        if (incentives.getDelegatorRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentives.getDelegatorRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = "large" })
            }
            let incentiveDelegator = Kava_Incentive_V1beta1_MsgClaimDelegatorReward.with {
                $0.sender = address
                $0.denomsToClaim = denoms_to_claims
            }
            let msg = Google_Protobuf_Any.with {
                $0.typeURL = "/kava.incentive.v1beta1.MsgClaimDelegatorReward"
                $0.value = try! incentiveDelegator.serializedData()
            }
            msgs.append(msg)
        }
        if (incentives.getSwapRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentives.getSwapRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = "large" })
            }
            let incentiveSwap = Kava_Incentive_V1beta1_MsgClaimSwapReward.with {
                $0.sender = address
                $0.denomsToClaim = denoms_to_claims
            }
            let msg = Google_Protobuf_Any.with {
                $0.typeURL = "/kava.incentive.v1beta1.MsgClaimSwapReward"
                $0.value = try! incentiveSwap.serializedData()
            }
            msgs.append(msg)
        }
        if (incentives.getEarnRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentives.getEarnRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = "large" })
            }
            let incentiveEarn = Kava_Incentive_V1beta1_MsgClaimEarnReward.with {
                $0.sender = address
                $0.denomsToClaim = denoms_to_claims
            }
            let msg = Google_Protobuf_Any.with {
                $0.typeURL = "/kava.incentive.v1beta1.MsgClaimEarnReward"
                $0.value = try! incentiveEarn.serializedData()
            }
            msgs.append(msg)
        }
        return msgs
    }
    
    //Tx for Kava Earn Deposit
    static func genKavaEarnDepositMsg(_ earnDeposit: Kava_Router_V1beta1_MsgDelegateMintDeposit) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.router.v1beta1.MsgDelegateMintDeposit"
            $0.value = try! earnDeposit.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Kava Earn Withdraw
    static func genKavaEarnWithdrawMsg(_ earnWithdraw: Kava_Router_V1beta1_MsgWithdrawBurn) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/kava.router.v1beta1.MsgWithdrawBurn"
            $0.value = try! earnWithdraw.serializedData()
        }
        return [anyMsg]
    }
    
    
    
    //Tx for Atomone burn and mint photon
    static func genPhtonMintMsg(_ mint: Atomone_Photon_V1_MsgMintPhoton) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/atomone.photon.v1.MsgMintPhoton"
            $0.value = try! mint.serializedData()
        }
        return [anyMsg]
    }
    

    
    
    static func setFee(_ posiion: Int, _ baseFee: Cosmos_Tx_V1beta1_Fee) -> Cosmos_Tx_V1beta1_Fee {
        let feeDenom = baseFee.amount[0].denom
        let feeAmount = baseFee.amount[0].getAmount()
        
        var result = Cosmos_Tx_V1beta1_Fee()
        result.gasLimit = baseFee.gasLimit
        if (posiion == 0) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount)]
        } else if (posiion == 1) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount.multiplying(by: NSDecimalNumber(string: "1.2"), withBehavior: handler0Down).stringValue)]
        } else if (posiion == 2) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount.multiplying(by: NSDecimalNumber(string: "1.5"), withBehavior: handler0Down).stringValue)]
        } else if (posiion == 3) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount.multiplying(by: NSDecimalNumber(string: "2"), withBehavior: handler0Down).stringValue)]
        }
        return result
    }
    
    static func genSimul(_ baseChain: BaseChain,
                         _ msgs: [Google_Protobuf_Any],
                         _ memo: String, _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip?) async throws -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if let cosmosFetcher = baseChain.getCosmosfetcher(),
           let height = try await cosmosFetcher.fetchLastBlock() {
            try? await cosmosFetcher.fetchAuth()
            let txBody = getTxBody(baseChain, msgs, memo, height)
            let authInfo = getAuthInfo(baseChain, fee, tip)
            let simulateTx = getSimulTxs(txBody, authInfo)
            return Cosmos_Tx_V1beta1_SimulateRequest.with {
                $0.tx = simulateTx
            }
        }
        return nil
    }
    
    static func genTx(_ baseChain: BaseChain,
                      _ msgs: [Google_Protobuf_Any],
                      _ memo: String, _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip?) async throws -> Cosmos_Tx_V1beta1_BroadcastTxRequest? {
        if let cosmosFetcher = baseChain.getCosmosfetcher(),
           let height = try await cosmosFetcher.fetchLastBlock() {
            try? await cosmosFetcher.fetchAuth()
            let txBody = getTxBody(baseChain, msgs, memo, height)
            let authInfo = getAuthInfo(baseChain, fee, tip)
            let rawTx = getRawTxs(txBody, authInfo, baseChain)
            return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
                $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
                $0.txBytes = try! rawTx.serializedData()
            }
        }
        return nil
    }
    
    static func getTxBody(_ baseChain: BaseChain, _ msgAnys: [Google_Protobuf_Any], _ memo: String, _ timeout: Int64?) -> Cosmos_Tx_V1beta1_TxBody {
        return Cosmos_Tx_V1beta1_TxBody.with {
            $0.memo = memo
            $0.messages = msgAnys
            if let height = timeout {
                $0.timeoutHeight = UInt64(height) + baseChain.getTimeoutPadding()
            }
        }
    }
    
    static func getAuthInfo(_ baseChain: BaseChain, _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip? = nil) -> Cosmos_Tx_V1beta1_AuthInfo {
        let single = Cosmos_Tx_V1beta1_ModeInfo.Single.with {
            $0.mode = Cosmos_Tx_Signing_V1beta1_SignMode.direct
        }
        let mode = Cosmos_Tx_V1beta1_ModeInfo.with {
            $0.single = single
        }

        var pubKey: Google_Protobuf_Any?
        if (baseChain.accountKeyType.pubkeyType == .BERA_Secp256k1) {
            let pub = Ethermint_Crypto_V1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/polaris.crypto.ethsecp256k1.v1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else if (baseChain.accountKeyType.pubkeyType == .INJECTIVE_Secp256k1) {
            let pub = Injective_Crypto_V1beta1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/injective.crypto.v1beta1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else if (baseChain.accountKeyType.pubkeyType == .ARTELA_Keccak256) {
            let pub = Artela_Crypto_V1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/artela.crypto.v1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
        
        } else if (baseChain.accountKeyType.pubkeyType == .ETH_Keccak256) {
            let pub = Ethermint_Crypto_V1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/ethermint.crypto.v1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else if (baseChain.accountKeyType.pubkeyType == .STRATOS_Keccak256) {
            let pub = Stratos_Crypto_V1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/stratos.crypto.v1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else if (baseChain.accountKeyType.pubkeyType == .INITIA_Keccak256) {
            let pub = Initia_Crypto_V1beta1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/initia.crypto.v1beta1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else if (baseChain.accountKeyType.pubkeyType == .COSMOS_EVM_Keccak256) {
            let pub = Cosmos_Evm_Crypto_V1_Ethsecp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.evm.crypto.v1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else {
            let pub = Cosmos_Crypto_Secp256k1_PubKey.with {
                $0.key = baseChain.publicKey!
            }
            pubKey = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.crypto.secp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
        }
        
        
        let signerInfo =  Cosmos_Tx_V1beta1_SignerInfo.with {
            $0.publicKey = pubKey!
            $0.modeInfo = mode
            $0.sequence = baseChain.getCosmosfetcher()!.cosmosSequenceNum!
        }
        
        return Cosmos_Tx_V1beta1_AuthInfo.with {
            $0.fee = fee
            $0.signerInfos = [signerInfo]
            if let Tip = tip, !Tip.tipper.isEmpty,  Tip.amount.count > 0 {
                $0.tip = Tip
            }
        }
    }
    
    static func getRawTxs(_ txBody: Cosmos_Tx_V1beta1_TxBody,
                          _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ baseChain: BaseChain) -> Cosmos_Tx_V1beta1_TxRaw {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = baseChain.chainIdCosmos!
            $0.accountNumber = baseChain.getCosmosfetcher()!.cosmosAccountNumber!
        }
        let sigbyte = getByteSingleSignatures(try! signDoc.serializedData(), baseChain)
        return Cosmos_Tx_V1beta1_TxRaw.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.signatures = [sigbyte]
        }
    }
    
    static func getSimulTxs(_ txBody: Cosmos_Tx_V1beta1_TxBody, _ authInfo: Cosmos_Tx_V1beta1_AuthInfo) -> Cosmos_Tx_V1beta1_Tx {
        return Cosmos_Tx_V1beta1_Tx.with {
            $0.authInfo = authInfo
            $0.body = txBody
            $0.signatures = getSimulsignatures(authInfo.signerInfos.count)
        }
    }
    
    static func getByteSingleSignatures(_ toSignByte: Data, _ baseChain: BaseChain) -> Data {
        var hash: Data?
        if (baseChain.accountKeyType.pubkeyType == .BERA_Secp256k1 ||
            baseChain.accountKeyType.pubkeyType == .INJECTIVE_Secp256k1 ||
            baseChain.accountKeyType.pubkeyType == .ETH_Keccak256 ||
            baseChain.accountKeyType.pubkeyType == .STRATOS_Keccak256 ||
            baseChain.accountKeyType.pubkeyType == .ARTELA_Keccak256 ||
            baseChain.accountKeyType.pubkeyType == .INITIA_Keccak256 ||
            baseChain.accountKeyType.pubkeyType == .COSMOS_EVM_Keccak256) {
            hash = toSignByte.sha3(.keccak256)
            
        } else {
            hash = toSignByte.sha256()
        }
        return SECP256K1.compactsign(hash!, privateKey: baseChain.privateKey!)!
    }
    
    static func getSimulsignatures(_ cnt: Int) -> [Data] {
        let dummySig = Data(repeating: 0, count: 64)
        return Array(repeating: dummySig, count: cnt)
    }
}

extension Signer  {
    
    static func suiSignatures(_ baseChain: BaseChain, _ txByte: String) -> [String] {
        return suiSignatures(baseChain.privateKey!, baseChain.publicKey!, Data(base64Encoded: txByte)!)
    }
    
    static func suiSignatures(_ privateKey: Data, _ pubKey: Data, _ data: Data) -> [String] {
        let hash = try! Blake2b.hash(size: 32, data: Data([0, 0, 0]) + data)
        let signature = Ed25519.sign(message: [UInt8](hash), secretKey: [UInt8](privateKey))
        return [(Data([0x00]) + Data(signature) + pubKey).base64EncodedString()]
    }
    
    static func iotaSignatures(_ baseChain: BaseChain, _ txByte: String) -> [String] {
        return iotaSignatures(baseChain.privateKey!, baseChain.publicKey!, Data(base64Encoded: txByte)!)
    }
    
    static func iotaSignatures(_ privateKey: Data, _ pubKey: Data, _ data: Data) -> [String] {
        let hash = try! Blake2b.hash(size: 32, data: Data([0, 0, 0]) + data)
        let signature = Ed25519.sign(message: [UInt8](hash), secretKey: [UInt8](privateKey))
        return [(Data([0x00]) + Data(signature) + pubKey).base64EncodedString()]
    }

}

// MARK: Gno chain
extension Signer {
    struct TxSignPayload: Codable {
        let chain_id: String
        let account_number: String
        let sequence: String
        let fee: Fee
        let msgs: [Msg]
        let memo: String
    }
    
    struct Msg: Codable {
        var type: String
        
        // bank.MsgSend
        var from_address: String?
        var to_address: String?
        var amount: String?
        
        // vm.m_call
        var caller: String?
        var send: String?
        var pkg_path: String?
        var `func`: String?
        var args: [String]?
        
        enum CodingKeys: String, CodingKey {
            case type = "@type"
            
            case from_address
            case to_address
            case amount
            
            case caller
            case send
            case pkg_path
            case `func`
            case args
        }
    }
    
    struct Fee: Codable {
        let gas_wanted: String
        let gas_fee: String
    }
    
    static func gnoSignature(_ baseChain: BaseChain, _ msgs: [Msg], _ memo: String, _ fee: Fee) -> Data? {
        guard let fetcher = (baseChain as? ChainGno)?.getGnoFetcher(),
              let chainId = baseChain.chainIdCosmos,
              let accountNum = fetcher.gnoAccountNumber,
              let sequence = fetcher.gnoSequenceNum else { return nil }
        
        let txSignPayload = TxSignPayload(chain_id: chainId,
                                          account_number: String(accountNum),
                                          sequence: String(sequence),
                                          fee: fee,
                                          msgs: msgs,
                                          memo: memo)
        
        guard let jsonString = try? txSignPayload.json(),
              let sortedJsonData = try? JSON(parseJSON: jsonString).rawData(options: [.sortedKeys, .withoutEscapingSlashes]) else { return nil }
        let sig = getByteSingleSignatures(sortedJsonData, baseChain)
        return sig
    }
    
    static func genSimul(_ baseChain: BaseChain,
                         _ msgs: [Google_Protobuf_Any],
                         _ memo: String, _ fee: Tm2_Tx_TxFee) -> Tm2_Tx_Tx? {
        
        return Tm2_Tx_Tx.with {
            $0.messages = msgs
            $0.memo = memo
            $0.fee = fee
            $0.signatures = [Tm2_Tx_TxSignature()]
        }
    }
    
    static func genTx(_ baseChain: BaseChain,
                      _ msgs: [Google_Protobuf_Any],
                      _ memo: String, _ fee: Tm2_Tx_TxFee,
                      _ sig: Data) -> Tm2_Tx_Tx {
        
        let pub = Tm2_Tx_PubKeySecp256k1.with {
            $0.key = baseChain.publicKey!
        }
        
        let pubkey = Google_Protobuf_Any.with {
            $0.typeURL = "/tm.PubKeySecp256k1"
            $0.value = try! pub.serializedData()
        }
        
        return Tm2_Tx_Tx.with {
            $0.messages = msgs
            $0.memo = memo
            $0.fee = fee
            $0.signatures = [Tm2_Tx_TxSignature.with { $0.pubKey = pubkey; $0.signature = sig }]
        }
    }
}

extension SECP256K1 {
    public static func compactsign(_ data: Data, privateKey: Data) -> Data? {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            privateKey.withUnsafeBytes { secp256k1_ecdsa_sign(ctx, signature, ptr, $0, nil, nil) }
        }
        guard status == 1 else { return nil }
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        let length: size_t = 64
        var compact = Data(count: length)
        guard compact.withUnsafeMutableBytes({ return secp256k1_ecdsa_signature_serialize_compact(ctx, $0, normalizedsig) }) == 1 else { return nil }
        compact.count = length
        return compact
    }
}
