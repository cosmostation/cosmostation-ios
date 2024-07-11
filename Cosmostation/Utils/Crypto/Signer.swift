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

class Signer {
    //Tx for Transfer
    static func genSendMsg(_ toSend: Cosmos_Bank_V1beta1_MsgSend) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.bank.v1beta1.MsgSend"
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
    
    //Tx for Common Delegate
    static func genDelegateMsg(_ toDelegate: Cosmos_Staking_V1beta1_MsgDelegate) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
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
    
    //Tx for Common CancelUnbonding
    static func genCancelUnbondingMsg(_ toCancel: Cosmos_Staking_V1beta1_MsgCancelUnbondingDelegation) -> [Google_Protobuf_Any] {
        let anyMsg = Google_Protobuf_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgCancelUnbondingDelegation"
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
    
    //Tx for Common Vote
    static func genVoteMsg(_ votes: [Cosmos_Gov_V1beta1_MsgVote]) -> [Google_Protobuf_Any] {
        var anyMsgs = Array<Google_Protobuf_Any>()
        votes.forEach { vote in
            let anyMsg = Google_Protobuf_Any.with {
                $0.typeURL = "/cosmos.gov.v1beta1.MsgVote"
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
    

    
    
    
    static func setTip(_ posiion: Int, _ txFee: Cosmos_Tx_V1beta1_Fee, _ txTip: Cosmos_Tx_V1beta1_Tip) -> Cosmos_Tx_V1beta1_Tip {
        let feeDenom = txFee.amount[0].denom
        let feeAmount = txFee.amount[0].getAmount()
        
        var result = Cosmos_Tx_V1beta1_Tip()
        result.tipper = txTip.tipper
        if (posiion == 0) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, "0")]
        } else if (posiion == 1) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount.multiplying(by: NSDecimalNumber(string: "0.2"), withBehavior: handler0Down).stringValue)]
        } else if (posiion == 2) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount.multiplying(by: NSDecimalNumber(string: "0.5"), withBehavior: handler0Down).stringValue)]
        } else if (posiion == 3) {
            result.amount = [Cosmos_Base_V1beta1_Coin(feeDenom, feeAmount.stringValue)]
        }
        return result
    }
    
    static func genSimul(_ baseChain: BaseChain,
                         _ msgs: [Google_Protobuf_Any],
                         _ memo: String, _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip?) async throws -> Cosmos_Tx_V1beta1_SimulateRequest? {
        if let grpcFetcher = baseChain.getGrpcfetcher(),
           let account = try await grpcFetcher.fetchAuth(),
           let height = try? await grpcFetcher.fetchLastBlock()!.block.header.height {
            let txBody = getTxBody(msgs, memo, UInt64(height))
            let authInfo = getAuthInfo(account, baseChain, fee, tip)
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
        if let grpcFetcher = baseChain.getGrpcfetcher(),
           let account = try await grpcFetcher.fetchAuth(),
           let height = try? await grpcFetcher.fetchLastBlock()!.block.header.height {
            let txBody = getTxBody(msgs, memo, UInt64(height))
            let authInfo = getAuthInfo(account, baseChain, fee, tip)
            let rawTx = getRawTxs(account, txBody, authInfo, baseChain)
            return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
                $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
                $0.txBytes = try! rawTx.serializedData()
            }
        }
        return nil
    }
    
    static func getTxBody(_ msgAnys: [Google_Protobuf_Any], _ memo: String, _ timeout: UInt64) -> Cosmos_Tx_V1beta1_TxBody {
        return Cosmos_Tx_V1beta1_TxBody.with {
            $0.memo = memo
            $0.messages = msgAnys
            $0.timeoutHeight = timeout + 30
        }
    }
    
    static func getAuthInfo(_ account: Google_Protobuf_Any, _ baseChain: BaseChain, _ fee: Cosmos_Tx_V1beta1_Fee, _ tip: Cosmos_Tx_V1beta1_Tip? = nil) -> Cosmos_Tx_V1beta1_AuthInfo {
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
            $0.sequence = account.accountInfos().2!
        }
        
        return Cosmos_Tx_V1beta1_AuthInfo.with {
            $0.fee = fee
            $0.signerInfos = [signerInfo]
            if let Tip = tip, !Tip.tipper.isEmpty,  Tip.amount.count > 0 {
                $0.tip = Tip
            }
        }
    }
    
    static func getRawTxs(_ account: Google_Protobuf_Any, _ txBody: Cosmos_Tx_V1beta1_TxBody,
                          _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ baseChain: BaseChain) -> Cosmos_Tx_V1beta1_TxRaw {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = baseChain.chainIdCosmos!
            $0.accountNumber = account.accountInfos().1!
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
            baseChain.accountKeyType.pubkeyType == .ARTELA_Keccak256) {
            hash = toSignByte.sha3(.keccak256)
            
        } else {
            hash = toSignByte.sha256()
        }
        return SECP256K1.compactsign(hash!, privateKey: baseChain.privateKey!)!
    }
    
    static func getSimulsignatures(_ cnt: Int) -> [Data] {
        var result = [Data]()
        let emptyDayta = Data(capacity: 64)
        for _ in 0..<cnt {
            result.append(emptyDayta)
        }
        return result
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
