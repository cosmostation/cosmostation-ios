//
//  Signer.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/12/14.
//  Copyright © 2020 wannabit. All rights reserved.
//

import Foundation
import HDWalletKit
import secp256k1
import SwiftProtobuf

class Signer {
    
    static func genSignedSendTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                    _ toAddress: String, _ amount: Array<Coin>, _ fee: Fee, _ memo: String,
                                    _ privateKey: Data, _ publicKey: Data, _ chainId: String)  -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount[0].denom
            $0.amount = amount[0].amount
        }
        let sendMsg = Cosmos_Bank_V1beta1_MsgSend.with {
            $0.fromAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.toAddress = toAddress
            $0.amount = [sendCoin]
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.bank.v1beta1.MsgSend"
            $0.value = try! sendMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSendTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                      _ toAddress: String, _ amount: Array<Coin>, _ fee: Fee, _ memo: String,
                                      _ privateKey: Data, _ publicKey: Data, _ chainId: String)  -> Cosmos_Tx_V1beta1_SimulateRequest {
        let sendCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount[0].denom
            $0.amount = amount[0].amount
        }
        let sendMsg = Cosmos_Bank_V1beta1_MsgSend.with {
            $0.fromAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.toAddress = toAddress
            $0.amount = [sendCoin]
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.bank.v1beta1.MsgSend"
            $0.value = try! sendMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ toValAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                        _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let toCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let deleMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = toValAddress
            $0.amount = toCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
            $0.value = try! deleMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ toValAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                          _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let toCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let deleMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = toValAddress
            $0.amount = toCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
            $0.value = try! deleMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedUnDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ toValAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                          _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let toCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let undeleMsg = Cosmos_Staking_V1beta1_MsgUndelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = toValAddress
            $0.amount = toCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgUndelegate"
            $0.value = try! undeleMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateUnDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ toValAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                            _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let toCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let undeleMsg = Cosmos_Staking_V1beta1_MsgUndelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = toValAddress
            $0.amount = toCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgUndelegate"
            $0.value = try! undeleMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedReDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ fromValAddress: String, _ toValAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                          _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let toCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let redeleMsg = Cosmos_Staking_V1beta1_MsgBeginRedelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorSrcAddress = fromValAddress
            $0.validatorDstAddress = toValAddress
            $0.amount = toCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgBeginRedelegate"
            $0.value = try! redeleMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateReDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ fromValAddress: String, _ toValAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                            _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let toCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let redeleMsg = Cosmos_Staking_V1beta1_MsgBeginRedelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorSrcAddress = fromValAddress
            $0.validatorDstAddress = toValAddress
            $0.amount = toCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgBeginRedelegate"
            $0.value = try! redeleMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedClaimRewardsTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ validators: Array<Cosmos_Staking_V1beta1_Validator>, _ fee: Fee, _ memo: String,
                                            _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        for validator in validators{
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
                $0.validatorAddress = validator.operatorAddress
            }
            let anyMsg = Google_Protobuf2_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateClaimRewardsTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ validators: Array<Cosmos_Staking_V1beta1_Validator>, _ fee: Fee, _ memo: String,
                                              _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        for validator in validators{
            let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
                $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
                $0.validatorAddress = validator.operatorAddress
            }
            let anyMsg = Google_Protobuf2_Any.with {
                $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
                $0.value = try! claimMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedReInvestTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ valAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                        _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = valAddress
        }
        let claimAnyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
            $0.value = try! claimMsg.serializedData()
        }
        anyMsgs.append(claimAnyMsg)
        let deleCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let deleMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = valAddress
            $0.amount = deleCoin
        }
        let deleAnyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
            $0.value = try! deleMsg.serializedData()
        }
        anyMsgs.append(deleAnyMsg)
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateReInvestTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ valAddress: String, _ amount: Coin, _ fee: Fee, _ memo: String,
                                          _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        let claimMsg = Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = valAddress
        }
        let claimAnyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward"
            $0.value = try! claimMsg.serializedData()
        }
        anyMsgs.append(claimAnyMsg)
        let deleCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = amount.denom
            $0.amount = amount.amount
        }
        let deleMsg = Cosmos_Staking_V1beta1_MsgDelegate.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.validatorAddress = valAddress
            $0.amount = deleCoin
        }
        let deleAnyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.staking.v1beta1.MsgDelegate"
            $0.value = try! deleMsg.serializedData()
        }
        anyMsgs.append(deleAnyMsg)
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedVoteTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                    _ proposalId: String, _ opinion: String, _ fee: Fee, _ memo: String,
                                    _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let voteMsg = Cosmos_Gov_V1beta1_MsgVote.with {
            $0.voter = WUtils.onParseAuthGrpc(auth).0!
            $0.proposalID = UInt64(proposalId)!
            if (opinion == "Yes") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.yes
            } else if (opinion == "No") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.no
            } else if (opinion == "NoWithVeto") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.noWithVeto
            } else if (opinion == "Abstain") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.abstain
            }
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.gov.v1beta1.MsgVote"
            $0.value = try! voteMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateVoteTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                      _ proposalId: String, _ opinion: String, _ fee: Fee, _ memo: String,
                                      _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let voteMsg = Cosmos_Gov_V1beta1_MsgVote.with {
            $0.voter = WUtils.onParseAuthGrpc(auth).0!
            $0.proposalID = UInt64(proposalId)!
            if (opinion == "Yes") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.yes
            } else if (opinion == "No") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.no
            } else if (opinion == "NoWithVeto") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.noWithVeto
            } else if (opinion == "Abstain") {
                $0.option = Cosmos_Gov_V1beta1_VoteOption.abstain
            }
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.gov.v1beta1.MsgVote"
            $0.value = try! voteMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedSetRewardAddressTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ newRewardAddress: String, _ fee: Fee, _ memo: String,
                                                _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let rewardAddressMsg = Cosmos_Distribution_V1beta1_MsgSetWithdrawAddress.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.withdrawAddress = newRewardAddress
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgSetWithdrawAddress"
            $0.value = try! rewardAddressMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    
    static func genSimulateetRewardAddressTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ newRewardAddress: String, _ fee: Fee, _ memo: String,
                                                _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let rewardAddressMsg = Cosmos_Distribution_V1beta1_MsgSetWithdrawAddress.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.withdrawAddress = newRewardAddress
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgSetWithdrawAddress"
            $0.value = try! rewardAddressMsg.serializedData()
        }
        
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    //for Starname custom msgs
    static func genSignedRegisterDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ domain: String, _ admin: String, _ type: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let rgisterdomainMsg = Starnamed_X_Starname_V1beta1_MsgRegisterDomain.with {
            $0.name = domain
            $0.admin = admin
            $0.domainType = type
            $0.broker = ""
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRegisterDomain"
            $0.value = try! rgisterdomainMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateRegisterDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                   _ domain: String, _ admin: String, _ type: String,
                                                   _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let registerdomainMsg = Starnamed_X_Starname_V1beta1_MsgRegisterDomain.with {
            $0.name = domain
            $0.admin = admin
            $0.domainType = type
            $0.broker = ""
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRegisterDomain"
            $0.value = try! registerdomainMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedRegisterAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ domain: String, _ name: String, _ owner: String, _ registerer: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let registerAccountMsg = Starnamed_X_Starname_V1beta1_MsgRegisterAccount.with {
            $0.domain = domain
            $0.name = name
            $0.owner = owner
            $0.registerer = registerer
            $0.resources = resources
            $0.broker = ""
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRegisterAccount"
            $0.value = try! registerAccountMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateRegisterAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ domain: String, _ name: String, _ owner: String, _ registerer: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let registerAccountMsg = Starnamed_X_Starname_V1beta1_MsgRegisterAccount.with {
            $0.domain = domain
            $0.name = name
            $0.owner = owner
            $0.registerer = registerer
            $0.resources = resources
            $0.broker = ""
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRegisterAccount"
            $0.value = try! registerAccountMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedDeleteDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ domain: String, _ owner: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let deleteDomainMsg = Starnamed_X_Starname_V1beta1_MsgDeleteDomain.with {
            $0.domain = domain
            $0.owner = owner
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgDeleteDomain"
            $0.value = try! deleteDomainMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateDeleteDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ domain: String, _ owner: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let deleteDomainMsg = Starnamed_X_Starname_V1beta1_MsgDeleteDomain.with {
            $0.domain = domain
            $0.owner = owner
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgDeleteDomain"
            $0.value = try! deleteDomainMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }

    static func genSignedDeleteAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ domain: String, _ name: String, _ owner: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let deleteAccountMsg = Starnamed_X_Starname_V1beta1_MsgDeleteAccount.with {
            $0.domain = domain
            $0.name = name
            $0.owner = owner
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgDeleteAccount"
            $0.value = try! deleteAccountMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }

    static func genSimulateDeleteAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ domain: String, _ name: String, _ owner: String,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let deleteAccountMsg = Starnamed_X_Starname_V1beta1_MsgDeleteAccount.with {
            $0.domain = domain
            $0.name = name
            $0.owner = owner
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgDeleteAccount"
            $0.value = try! deleteAccountMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
     
    static func genSignedRenewDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ domain: String, _ signer: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let renewDomainMsg =  Starnamed_X_Starname_V1beta1_MsgRenewDomain.with {
            $0.domain = domain
            $0.signer = signer
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRenewDomain"
            $0.value = try! renewDomainMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateRenewDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ domain: String, _ signer: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let renewDomainMsg = Starnamed_X_Starname_V1beta1_MsgRenewDomain.with {
            $0.domain = domain
            $0.signer = signer
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRenewDomain"
            $0.value = try! renewDomainMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedRenewAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ domain: String, _ name: String, _ signer: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let renewAccountMsg = Starnamed_X_Starname_V1beta1_MsgRenewAccount.with {
            $0.domain = domain
            $0.name = name
            $0.signer = signer
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRenewAccount"
            $0.value = try! renewAccountMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateRenewAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ domain: String, _ name: String, _ signer: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let renewAccountMsg = Starnamed_X_Starname_V1beta1_MsgRenewAccount.with {
            $0.domain = domain
            $0.name = name
            $0.signer = signer
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRenewAccount"
            $0.value = try! renewAccountMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedReplaceResourceMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ domain: String, _ name: String?, _ owner: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let replaceResourceMsg = Starnamed_X_Starname_V1beta1_MsgReplaceAccountResources.with {
            if (name != nil) { $0.name = name! }
            else { $0.name = "" }
            $0.domain = domain
            $0.owner = owner
            $0.newResources = resources
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgReplaceAccountResources"
            $0.value = try! replaceResourceMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateReplaceResourceMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ domain: String, _ name: String?, _ owner: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let replaceResourceMsg = Starnamed_X_Starname_V1beta1_MsgReplaceAccountResources.with {
            if (name != nil) { $0.name = name! }
            else { $0.name = "" }
            $0.domain = domain
            $0.owner = owner
            $0.newResources = resources
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgReplaceAccountResources"
            $0.value = try! replaceResourceMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    //for Osmosis custom msgs
    static func genSignedSwapInMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ swapRoutes: [Osmosis_Gamm_V1beta1_SwapAmountInRoute], _ inputDenom: String, _ inputAmount: String, _ outputAmount: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let inputCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = inputDenom
            $0.amount = inputAmount
        }
        let swapMsg = Osmosis_Gamm_V1beta1_MsgSwapExactAmountIn.with {
            $0.sender = WUtils.onParseAuthGrpc(auth).0!
            $0.routes = swapRoutes
            $0.tokenIn = inputCoin
            $0.tokenOutMinAmount = outputAmount
            
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.gamm.v1beta1.MsgSwapExactAmountIn"
            $0.value = try! swapMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSwapInMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ swapRoutes: [Osmosis_Gamm_V1beta1_SwapAmountInRoute], _ inputDenom: String, _ inputAmount: String, _ outputAmount: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let inputCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = inputDenom
            $0.amount = inputAmount
        }
        let swapMsg = Osmosis_Gamm_V1beta1_MsgSwapExactAmountIn.with {
            $0.sender = WUtils.onParseAuthGrpc(auth).0!
            $0.routes = swapRoutes
            $0.tokenIn = inputCoin
            $0.tokenOutMinAmount = outputAmount
            
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.gamm.v1beta1.MsgSwapExactAmountIn"
            $0.value = try! swapMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedDepositPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ poolId: String, _ deposit0Coin: Coin, _ deposit1Coin: Coin, _ shareAmount: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let input0Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = deposit0Coin.denom; $0.amount = deposit0Coin.amount }
        let input1Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = deposit1Coin.denom; $0.amount = deposit1Coin.amount }
        var tokenMax = Array<Cosmos_Base_V1beta1_Coin>()
        tokenMax.append(input0Coin)
        tokenMax.append(input1Coin)
        
        let joinPoolMsg = Osmosis_Gamm_V1beta1_MsgJoinPool.with {
            $0.sender = WUtils.onParseAuthGrpc(auth).0!
            $0.poolID = UInt64(poolId)!
            $0.tokenInMaxs = tokenMax
            $0.shareOutAmount = shareAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.gamm.v1beta1.MsgJoinPool"
            $0.value = try! joinPoolMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateDepositPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ poolId: String, _ deposit0Coin: Coin, _ deposit1Coin: Coin, _ shareAmount: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let input0Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = deposit0Coin.denom; $0.amount = deposit0Coin.amount }
        let input1Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = deposit1Coin.denom; $0.amount = deposit1Coin.amount }
        var tokenMax = Array<Cosmos_Base_V1beta1_Coin>()
        tokenMax.append(input0Coin)
        tokenMax.append(input1Coin)
        
        let joinPoolMsg = Osmosis_Gamm_V1beta1_MsgJoinPool.with {
            $0.sender = WUtils.onParseAuthGrpc(auth).0!
            $0.poolID = UInt64(poolId)!
            $0.tokenInMaxs = tokenMax
            $0.shareOutAmount = shareAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.gamm.v1beta1.MsgJoinPool"
            $0.value = try! joinPoolMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedWithdrawPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ poolId: String, _ withdraw0Coin: Coin, _ withdraw1Coin: Coin, _ shareAmount: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let input0Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdraw0Coin.denom; $0.amount = withdraw0Coin.amount }
        let input1Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdraw1Coin.denom; $0.amount = withdraw1Coin.amount }
        var tokenMin = Array<Cosmos_Base_V1beta1_Coin>()
        tokenMin.append(input0Coin)
        tokenMin.append(input1Coin)
        
        let exitPoolMsg = Osmosis_Gamm_V1beta1_MsgExitPool.with {
            $0.sender = WUtils.onParseAuthGrpc(auth).0!
            $0.poolID = UInt64(poolId)!
            $0.tokenOutMins = tokenMin
            $0.shareInAmount = shareAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.gamm.v1beta1.MsgExitPool"
            $0.value = try! exitPoolMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateWithdrawPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ poolId: String, _ withdraw0Coin: Coin, _ withdraw1Coin: Coin, _ shareAmount: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let input0Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdraw0Coin.denom; $0.amount = withdraw0Coin.amount }
        let input1Coin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdraw1Coin.denom; $0.amount = withdraw1Coin.amount }
        var tokenMin = Array<Cosmos_Base_V1beta1_Coin>()
        tokenMin.append(input0Coin)
        tokenMin.append(input1Coin)
        
        let exitPoolMsg = Osmosis_Gamm_V1beta1_MsgExitPool.with {
            $0.sender = WUtils.onParseAuthGrpc(auth).0!
            $0.poolID = UInt64(poolId)!
            $0.tokenOutMins = tokenMin
            $0.shareInAmount = shareAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.gamm.v1beta1.MsgExitPool"
            $0.value = try! exitPoolMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedLockTokensMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ lpCoin: Coin, _ duration: Int64,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let lockupCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = lpCoin.denom; $0.amount = lpCoin.amount }
        var lockupTokens = Array<Cosmos_Base_V1beta1_Coin>()
        lockupTokens.append(lockupCoin)
        
        let lockTokensMsg = Osmosis_Lockup_MsgLockTokens.with {
            $0.owner = WUtils.onParseAuthGrpc(auth).0!
            $0.duration = SwiftProtobuf.Google_Protobuf_Duration.init(seconds: duration, nanos: 0)
            $0.coins = lockupTokens
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.lockup.MsgLockTokens"
            $0.value = try! lockTokensMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateLockTokensMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ lpCoin: Coin, _ duration: Int64,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let lockupCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = lpCoin.denom; $0.amount = lpCoin.amount }
        var lockupTokens = Array<Cosmos_Base_V1beta1_Coin>()
        lockupTokens.append(lockupCoin)
        
        let lockTokensMsg = Osmosis_Lockup_MsgLockTokens.with {
            $0.owner = WUtils.onParseAuthGrpc(auth).0!
            $0.duration = SwiftProtobuf.Google_Protobuf_Duration.init(seconds: duration, nanos: 0)
            $0.coins = lockupTokens
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/osmosis.lockup.MsgLockTokens"
            $0.value = try! lockTokensMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedBeginUnlockingsMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ ids: Array<UInt64>,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        for id in ids {
            let unlockMsg = Osmosis_Lockup_MsgBeginUnlocking.with {
                $0.owner = WUtils.onParseAuthGrpc(auth).0!
                $0.id = id
            }
            let anyMsg = Google_Protobuf2_Any.with {
                $0.typeURL = "/osmosis.lockup.MsgBeginUnlocking"
                $0.value = try! unlockMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateBeginUnlockingsMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ ids: Array<UInt64>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        for id in ids {
            let unlockMsg = Osmosis_Lockup_MsgBeginUnlocking.with {
                $0.owner = WUtils.onParseAuthGrpc(auth).0!
                $0.id = id
            }
            let anyMsg = Google_Protobuf2_Any.with {
                $0.typeURL = "/osmosis.lockup.MsgBeginUnlocking"
                $0.value = try! unlockMsg.serializedData()
            }
            anyMsgs.append(anyMsg)
        }
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedUnlockPeriodLocksMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ ids: Array<UInt64>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
//        for id in ids {
//            let unlockMsg = Osmosis_Lockup_MsgUnlockPeriodLock.with {
//                $0.owner = WUtils.onParseAuthGrpc(auth).0!
//                $0.id = id
//            }
//            let anyMsg = Google_Protobuf2_Any.with {
//                $0.typeURL = "/osmosis.lockup.MsgUnlockPeriodLock"
//                $0.value = try! unlockMsg.serializedData()
//            }
//            anyMsgs.append(anyMsg)
//        }
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateUnlockPeriodLocksMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                      _ ids: Array<UInt64>,
                                                      _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        var anyMsgs = Array<Google_Protobuf2_Any>()
//        for id in ids {
//            let unlockMsg = Osmosis_Lockup_MsgUnlockPeriodLock.with {
//                $0.owner = WUtils.onParseAuthGrpc(auth).0!
//                $0.id = id
//            }
//            let anyMsg = Google_Protobuf2_Any.with {
//                $0.typeURL = "/osmosis.lockup.MsgUnlockPeriodLock"
//                $0.value = try! unlockMsg.serializedData()
//            }
//            anyMsgs.append(anyMsg)
//        }
        let txBody = getGrpcTxBody(anyMsgs, memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedSwapBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ requester: String, _ poolId: String, _ swapType: String, _ offerCoin: Coin, _ offerCoinFee: Coin,
                                            _ demandCoinDenom: String, _ orderPrice: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapBatchMsg = Tendermint_Liquidity_V1beta1_MsgSwapWithinBatch.with {
            $0.swapRequesterAddress = requester
            $0.poolID = UInt64(poolId)!
            $0.swapTypeID = UInt32("1")!
            $0.offerCoin = Cosmos_Base_V1beta1_Coin.with({ $0.denom = offerCoin.denom; $0.amount = offerCoin.amount })
            $0.offerCoinFee = Cosmos_Base_V1beta1_Coin.with({ $0.denom = offerCoinFee.denom; $0.amount = offerCoinFee.amount })
            $0.demandCoinDenom = demandCoinDenom
            $0.orderPrice = orderPrice
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgSwapWithinBatch"
            $0.value = try! swapBatchMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSwapBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ requester: String, _ poolId: String, _ swapType: String, _ offerCoin: Coin, _ offerCoinFee: Coin,
                                              _ demandCoinDenom: String, _ orderPrice: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapBatchMsg = Tendermint_Liquidity_V1beta1_MsgSwapWithinBatch.with {
            $0.swapRequesterAddress = requester
            $0.poolID = UInt64(poolId)!
            $0.swapTypeID = UInt32("1")!
            $0.offerCoin = Cosmos_Base_V1beta1_Coin.with({ $0.denom = offerCoin.denom; $0.amount = offerCoin.amount })
            $0.offerCoinFee = Cosmos_Base_V1beta1_Coin.with({ $0.denom = offerCoinFee.denom; $0.amount = offerCoinFee.amount })
            $0.demandCoinDenom = demandCoinDenom
            $0.orderPrice = orderPrice
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgSwapWithinBatch"
            $0.value = try! swapBatchMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedDepositBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ depositor: String, _ poolId: String, _ depositCoins: Array<Coin>,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let depositBatchMsg = Tendermint_Liquidity_V1beta1_MsgDepositWithinBatch.with {
            $0.depositorAddress = depositor
            $0.poolID = UInt64(poolId)!
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            depositCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.depositCoins = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgDepositWithinBatch"
            $0.value = try! depositBatchMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateDepositBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ depositor: String, _ poolId: String, _ depositCoins: Array<Coin>,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let depositBatchMsg = Tendermint_Liquidity_V1beta1_MsgDepositWithinBatch.with {
            $0.depositorAddress = depositor
            $0.poolID = UInt64(poolId)!
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            depositCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.depositCoins = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgDepositWithinBatch"
            $0.value = try! depositBatchMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedWithdrawBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ withdrawer: String, _ poolId: String, _ withdrawCoin: Coin,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let withdrawBatchMsg = Tendermint_Liquidity_V1beta1_MsgWithdrawWithinBatch.with {
            $0.withdrawerAddress = withdrawer
            $0.poolID = UInt64(poolId)!
            $0.poolCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdrawCoin.denom; $0.amount = withdrawCoin.amount }
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgWithdrawWithinBatch"
            $0.value = try! withdrawBatchMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateWithdrawBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ withdrawer: String, _ poolId: String, _ withdrawCoin: Coin,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let withdrawBatchMsg = Tendermint_Liquidity_V1beta1_MsgWithdrawWithinBatch.with {
            $0.withdrawerAddress = withdrawer
            $0.poolID = UInt64(poolId)!
            $0.poolCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdrawCoin.denom; $0.amount = withdrawCoin.amount }
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgWithdrawWithinBatch"
            $0.value = try! withdrawBatchMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedIbcTransferMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ sender: String, _ receiver: String, _ ibcSendDenom: String, _ ibcSendAmount: String, _ ibcPath: Path, _ lastHeight: Ibc_Core_Client_V1_Height,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let re_timeout_height = Ibc_Core_Client_V1_Height.with {
            $0.revisionNumber = lastHeight.revisionNumber
            $0.revisionHeight = lastHeight.revisionHeight + 500
        }
        let re_token = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = ibcSendDenom
            $0.amount = ibcSendAmount
        }

        let ibcSendMsg = Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = sender
            $0.receiver = receiver
            $0.sourcePort = ibcPath.port_id!
            $0.sourceChannel = ibcPath.channel_id!
            $0.timeoutHeight = re_timeout_height
            $0.timeoutTimestamp = 0
            $0.token = re_token
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/ibc.applications.transfer.v1.MsgTransfer"
            $0.value = try! ibcSendMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateIbcTransferMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ sender: String, _ receiver: String, _ ibcSendDenom: String, _ ibcSendAmount: String, _ ibcPath: Path, _ lastHeight: Ibc_Core_Client_V1_Height,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let re_timeout_height = Ibc_Core_Client_V1_Height.with {
            $0.revisionNumber = lastHeight.revisionNumber
            $0.revisionHeight = lastHeight.revisionHeight + 500
        }
        let re_token = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = ibcSendDenom
            $0.amount = ibcSendAmount
        }

        let ibcSendMsg = Ibc_Applications_Transfer_V1_MsgTransfer.with {
            $0.sender = sender
            $0.receiver = receiver
            $0.sourcePort = ibcPath.port_id!
            $0.sourceChannel = ibcPath.channel_id!
            $0.timeoutHeight = re_timeout_height
            $0.timeoutTimestamp = 0
            $0.token = re_token
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/ibc.applications.transfer.v1.MsgTransfer"
            $0.value = try! ibcSendMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedSifIncentiveMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ userClaimAddress: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let claimIncentiveMsg = Sifnode_Dispensation_V1_MsgCreateUserClaim.with {
            $0.userClaimAddress = userClaimAddress
            $0.userClaimType = Sifnode_Dispensation_V1_DistributionType.liquidityMining
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.dispensation.v1.MsgCreateUserClaim"
            $0.value = try! claimIncentiveMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSifIncentiveMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ userClaimAddress: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let claimIncentiveMsg = Sifnode_Dispensation_V1_MsgCreateUserClaim.with {
            $0.userClaimAddress = userClaimAddress
            $0.userClaimType = Sifnode_Dispensation_V1_DistributionType.liquidityMining
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.dispensation.v1.MsgCreateUserClaim"
            $0.value = try! claimIncentiveMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedSifSwapMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ signer: String, _ inputDenom: String, _ inputAmount: String, _ outputDenom: String, _ outputAmount: String,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let inputAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = inputDenom
        }
        let outputAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = outputDenom
        }
        let swapMsg = Sifnode_Clp_V1_MsgSwap.with {
            $0.signer = signer
            $0.sentAsset = inputAsset
            $0.sentAmount = inputAmount
            $0.receivedAsset = outputAsset
            $0.minReceivingAmount = outputAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.clp.v1.MsgSwap"
            $0.value = try! swapMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSifSwapMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ signer: String, _ inputDenom: String, _ inputAmount: String, _ outputDenom: String, _ outputAmount: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let inputAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = inputDenom
        }
        let outputAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = outputDenom
        }
        let swapMsg = Sifnode_Clp_V1_MsgSwap.with {
            $0.signer = signer
            $0.sentAsset = inputAsset
            $0.sentAmount = inputAmount
            $0.receivedAsset = outputAsset
            $0.minReceivingAmount = outputAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.clp.v1.MsgSwap"
            $0.value = try! swapMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedSifAddLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ signer: String, _ nativeAmount: String, _ externalDenom: String, _ externalAmount: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        
        let eAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = externalDenom
        }
        let addLpMsg = Sifnode_Clp_V1_MsgAddLiquidity.with {
            $0.signer = signer
            $0.nativeAssetAmount = nativeAmount
            $0.externalAsset = eAsset
            $0.externalAssetAmount = externalAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.clp.v1.MsgAddLiquidity"
            $0.value = try! addLpMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSifAddLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ signer: String, _ nativeAmount: String, _ externalDenom: String, _ externalAmount: String,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        
        let eAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = externalDenom
        }
        let addLpMsg = Sifnode_Clp_V1_MsgAddLiquidity.with {
            $0.signer = signer
            $0.nativeAssetAmount = nativeAmount
            $0.externalAsset = eAsset
            $0.externalAssetAmount = externalAmount
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.clp.v1.MsgAddLiquidity"
            $0.value = try! addLpMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedSifRemoveLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ signer: String, _ externalDenom: String, _ w_basis_points: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let eAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = externalDenom
        }
        let removeLpMsg = Sifnode_Clp_V1_MsgRemoveLiquidity.with {
            $0.signer = signer
            $0.externalAsset = eAsset
            $0.asymmetry = "0"
            $0.wBasisPoints = w_basis_points
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.clp.v1.MsgRemoveLiquidity"
            $0.value = try! removeLpMsg.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSifRemoveLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ signer: String, _ externalDenom: String, _ w_basis_points: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let eAsset = Sifnode_Clp_V1_Asset.with {
            $0.symbol = externalDenom
        }
        let removeLpMsg = Sifnode_Clp_V1_MsgRemoveLiquidity.with {
            $0.signer = signer
            $0.externalAsset = eAsset
            $0.asymmetry = "0"
            $0.wBasisPoints = w_basis_points
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.clp.v1.MsgRemoveLiquidity"
            $0.value = try! removeLpMsg.serializedData()
        }
        
        let txBody = getGrpcTxBody([anyMsg], memo);
        let signerInfo = getGrpcSignerInfo(auth, publicKey);
        let authInfo = getGrpcAuthInfo(signerInfo, fee);
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId);
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedIssueNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ signer: String,
                                            _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let issueNftDenom = Irismod_Nft_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
            $0.symbol = ""
            $0.mintRestricted = false
            $0.updateRestricted = false
        }
        let issueNftDenomMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgIssueDenom"
            $0.value = try! issueNftDenom.serializedData()
        }
        
        let issueNft = Irismod_Nft_MsgMintNFT.with {
            $0.sender = signer
            $0.recipient = signer
            $0.id = id
            $0.denomID = denom_id
            $0.name = name
            $0.uri = uri
            $0.data = data
        }
        let issueNftMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgMintNFT"
            $0.value = try! issueNft.serializedData()
        }
        let txBody = getGrpcTxBody([issueNftDenomMsg, issueNftMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        print("rawTx ", rawTx)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateIssueNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ signer: String,
                                              _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let issueNftDenom = Irismod_Nft_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
            $0.symbol = ""
            $0.mintRestricted = false
            $0.updateRestricted = false
        }
        let issueNftDenomMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgIssueDenom"
            $0.value = try! issueNftDenom.serializedData()
        }
        
        let issueNft = Irismod_Nft_MsgMintNFT.with {
            $0.sender = signer
            $0.recipient = signer
            $0.id = id
            $0.denomID = denom_id
            $0.name = name
            $0.uri = uri
            $0.data = data
        }
        let issueNftMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgMintNFT"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([issueNftDenomMsg, issueNftMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedSendNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ irisResponse: Irismod_Nft_QueryNFTResponse,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let issueNft = Irismod_Nft_MsgTransferNFT.with {
            $0.sender = signer
            $0.recipient = recipient
            $0.id = id
            $0.denomID = denom_id
            $0.name = irisResponse.nft.name
            $0.uri = irisResponse.nft.uri
            $0.data = irisResponse.nft.data
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgTransferNFT"
            $0.value = try! issueNft.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSendNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ irisResponse: Irismod_Nft_QueryNFTResponse,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let issueNft = Irismod_Nft_MsgMintNFT.with {
            $0.sender = signer
            $0.recipient = signer
            $0.id = id
            $0.denomID = denom_id
            $0.name = irisResponse.nft.name
            $0.uri = irisResponse.nft.uri
            $0.data = irisResponse.nft.data
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgTransferNFT"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedIssueNftDenomIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ signer: String,_ denom_id: String, _ denom_name: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let issueNft = Irismod_Nft_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
            $0.symbol = ""
            $0.mintRestricted = false
            $0.updateRestricted = false
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgIssueDenom"
            $0.value = try! issueNft.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateIssueNftDenomIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                   _ signer: String,_ denom_id: String, _ denom_name: String,
                                                   _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let issueNft = Irismod_Nft_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
            $0.symbol = ""
            $0.mintRestricted = false
            $0.updateRestricted = false
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/irismod.nft.MsgIssueDenom"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedIssueNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ signer: String,
                                           _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let issueNftDenom = Chainmain_Nft_V1_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
        }
        let issueNftDenomMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgIssueDenom"
            $0.value = try! issueNftDenom.serializedData()
        }
        
        let issueNft = Chainmain_Nft_V1_MsgMintNFT.with {
            $0.sender = signer
            $0.recipient = signer
            $0.id = id
            $0.denomID = denom_id
            $0.name = name
            $0.uri = uri
            $0.data = data
        }
        let issueNftMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgMintNFT"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([issueNftDenomMsg, issueNftMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateIssueNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ signer: String,
                                             _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let issueNftDenom = Chainmain_Nft_V1_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
        }
        let issueNftDenomMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgIssueDenom"
            $0.value = try! issueNftDenom.serializedData()
        }
        
        let issueNft = Chainmain_Nft_V1_MsgMintNFT.with {
            $0.sender = signer
            $0.recipient = signer
            $0.id = id
            $0.denomID = denom_id
            $0.name = name
            $0.uri = uri
            $0.data = data
        }
        let issueNftMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgMintNFT"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([issueNftDenomMsg, issueNftMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedSendNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ croResponse: Chainmain_Nft_V1_QueryNFTResponse,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let issueNft = Chainmain_Nft_V1_MsgTransferNFT.with {
            $0.sender = signer
            $0.recipient = recipient
            $0.id = id
            $0.denomID = denom_id
//            $0.name = croResponse.nft.name
//            $0.uri = croResponse.nft.uri
//            $0.data = croResponse.nft.data
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgTransferNFT"
            $0.value = try! issueNft.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSendNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ croResponse: Chainmain_Nft_V1_QueryNFTResponse,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let issueNft = Chainmain_Nft_V1_MsgTransferNFT.with {
            $0.sender = signer
            $0.recipient = recipient
            $0.id = id
            $0.denomID = denom_id
            //            $0.name = croResponse.nft.name
            //            $0.uri = croResponse.nft.uri
            //            $0.data = croResponse.nft.data
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgTransferNFT"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedIssueNftDenomCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ signer: String,_ denom_id: String, _ denom_name: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let issueNft = Chainmain_Nft_V1_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgIssueDenom"
            $0.value = try! issueNft.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateIssueNftDenomCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                   _ signer: String,_ denom_id: String, _ denom_name: String,
                                                   _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let issueNft = Chainmain_Nft_V1_MsgIssueDenom.with {
            $0.id = denom_id
            $0.name = denom_name
            $0.schema = ""
            $0.sender = signer
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgIssueDenom"
            $0.value = try! issueNft.serializedData()
        }
        
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    static func genSignedSaveProfileTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ creator: String,_ dtag: String, _ nickname: String, _ bio: String, _ profile_picture: String, _ cover_picture: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let saveProfile = Desmos_Profiles_V1beta1_MsgSaveProfile.with {
            $0.dtag = dtag
            $0.nickname = nickname
            $0.bio = bio
            $0.profilePicture = profile_picture
            $0.coverPicture = cover_picture
            $0.creator = creator
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/desmos.profiles.v1beta1.MsgSaveProfile"
            $0.value = try! saveProfile.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateSaveProfileTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ creator: String,_ dtag: String, _ nickname: String, _ bio: String, _ profile_picture: String, _ cover_picture: String,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let saveProfile = Desmos_Profiles_V1beta1_MsgSaveProfile.with {
            $0.dtag = dtag
            $0.nickname = nickname
            $0.bio = bio
            $0.profilePicture = profile_picture
            $0.coverPicture = cover_picture
            $0.creator = creator
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/desmos.profiles.v1beta1.MsgSaveProfile"
            $0.value = try! saveProfile.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedLinkChainTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ signer: String, _ tochain: ChainType, _ toAccount: Account, _ toPrivateKey: Data, _ toPublicKey: Data,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        
        let plainString = "Link Chain With Cosmostation"
        let sigbyte = getGrpcByteSingleSignature(toPrivateKey, plainString.data(using: .utf8)!)
        
        let desmosBech32 = Desmos_Profiles_V1beta1_Bech32Address.with {
            $0.value = toAccount.account_address
            $0.prefix = WUtils.getDesmosPrefix(tochain)
        }
        let chainAddress = Google_Protobuf2_Any.with {
            $0.typeURL = "/desmos.profiles.v1beta1.Bech32Address"
            $0.value = try! desmosBech32.serializedData()
        }
        
        let toAccountPub = Cosmos_Crypto_Secp256k1_PubKey.with {
            $0.key = toPublicKey
        }
        let toAccountPubKey = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.crypto.secp256k1.PubKey"
            $0.value = try! toAccountPub.serializedData()
        }
        let desmosProof = Desmos_Profiles_V1beta1_Proof.with {
            $0.signature = sigbyte.toHexString()
            $0.plainText = plainString.toHexString()
            $0.pubKey = toAccountPubKey
        }
        
        let desmosChainConfig = Desmos_Profiles_V1beta1_ChainConfig.with {
            $0.name = WUtils.getDesmosChainconfig(tochain)
        }
        
        let linkchain = Desmos_Profiles_V1beta1_MsgLinkChainAccount.with {
            $0.chainAddress = chainAddress
            $0.proof = desmosProof
            $0.chainConfig = desmosChainConfig
            $0.signer = signer
        }
        
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/desmos.profiles.v1beta1.MsgLinkChainAccount"
            $0.value = try! linkchain.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateLinkChainTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ signer: String, _ tochain: ChainType, _ toAccount: Account, _ toPrivateKey: Data, _ toPublicKey: Data,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        
        let plainString = "Link Chain With Cosmostation"
        let sigbyte = getGrpcByteSingleSignature(toPrivateKey, plainString.data(using: .utf8)!)
        
        let desmosBech32 = Desmos_Profiles_V1beta1_Bech32Address.with {
            $0.value = toAccount.account_address
            $0.prefix = WUtils.getDesmosPrefix(tochain)
        }
        let chainAddress = Google_Protobuf2_Any.with {
            $0.typeURL = "/desmos.profiles.v1beta1.Bech32Address"
            $0.value = try! desmosBech32.serializedData()
        }
        let toAccountPub = Cosmos_Crypto_Secp256k1_PubKey.with {
            $0.key = toPublicKey
        }
        let toAccountPubKey = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.crypto.secp256k1.PubKey"
            $0.value = try! toAccountPub.serializedData()
        }
        let desmosProof = Desmos_Profiles_V1beta1_Proof.with {
            $0.signature = sigbyte.toHexString()
            $0.plainText = plainString.toHexString()
            $0.pubKey = toAccountPubKey
        }
        
        let desmosChainConfig = Desmos_Profiles_V1beta1_ChainConfig.with {
            $0.name = WUtils.getDesmosChainconfig(tochain)
        }
        let linkchain = Desmos_Profiles_V1beta1_MsgLinkChainAccount.with {
            $0.chainAddress = chainAddress
            $0.proof = desmosProof
            $0.chainConfig = desmosChainConfig
            $0.signer = signer
        }
        
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/desmos.profiles.v1beta1.MsgLinkChainAccount"
            $0.value = try! linkchain.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    //for kava sign
    static func genSignedKavaCDPCreate(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                       _ sender: String, _ collateral: Coin, _ principal: Coin, _ collateral_type: String,
                                       _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateral.denom
            $0.amount = collateral.amount
        }
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = principal.denom
            $0.amount = principal.amount
        }
        let createCdp = Kava_Cdp_V1beta1_MsgCreateCDP.with {
            $0.sender = sender
            $0.collateral = collateralCoin
            $0.principal = principalCoin
            $0.collateralType = collateral_type
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgCreateCDP"
            $0.value = try! createCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaCDPCreate(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ sender: String, _ collateral: Coin, _ principal: Coin, _ collateral_type: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateral.denom
            $0.amount = collateral.amount
        }
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = principal.denom
            $0.amount = principal.amount
        }
        let createCdp = Kava_Cdp_V1beta1_MsgCreateCDP.with {
            $0.sender = sender
            $0.collateral = collateralCoin
            $0.principal = principalCoin
            $0.collateralType = collateral_type
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgCreateCDP"
            $0.value = try! createCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaCDPDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateral.denom
            $0.amount = collateral.amount
        }
        let depositCdp = Kava_Cdp_V1beta1_MsgDeposit.with {
            $0.depositor = depositor
            $0.owner = owner
            $0.collateral = collateralCoin
            $0.collateralType = collateral_type
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgDeposit"
            $0.value = try! depositCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaCDPDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateral.denom
            $0.amount = collateral.amount
        }
        let depositCdp = Kava_Cdp_V1beta1_MsgDeposit.with {
            $0.depositor = depositor
            $0.owner = owner
            $0.collateral = collateralCoin
            $0.collateralType = collateral_type
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgDeposit"
            $0.value = try! depositCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaCDPWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateral.denom
            $0.amount = collateral.amount
        }
        let withdrawCdp = Kava_Cdp_V1beta1_MsgWithdraw.with {
            $0.depositor = depositor
            $0.owner = owner
            $0.collateral = collateralCoin
            $0.collateralType = collateral_type
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgWithdraw"
            $0.value = try! withdrawCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaCDPWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let collateralCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = collateral.denom
            $0.amount = collateral.amount
        }
        let withdrawCdp = Kava_Cdp_V1beta1_MsgWithdraw.with {
            $0.depositor = depositor
            $0.owner = owner
            $0.collateral = collateralCoin
            $0.collateralType = collateral_type
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgWithdraw"
            $0.value = try! withdrawCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaCDPDrawDebt(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ sender: String, _ principal: Coin, _ collateral_type: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = principal.denom
            $0.amount = principal.amount
        }
        let drawdebtCdp = Kava_Cdp_V1beta1_MsgDrawDebt.with {
            $0.sender = sender
            $0.collateralType = collateral_type
            $0.principal = principalCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgDrawDebt"
            $0.value = try! drawdebtCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaCDPDrawDebt(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ sender: String, _ principal: Coin, _ collateral_type: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let principalCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = principal.denom
            $0.amount = principal.amount
        }
        let drawdebtCdp = Kava_Cdp_V1beta1_MsgDrawDebt.with {
            $0.sender = sender
            $0.collateralType = collateral_type
            $0.principal = principalCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgDrawDebt"
            $0.value = try! drawdebtCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaCDPRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                      _ sender: String, _ payment: Coin, _ collateral_type: String,
                                      _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let paymentCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = payment.denom
            $0.amount = payment.amount
        }
        let repayCdp = Kava_Cdp_V1beta1_MsgRepayDebt.with {
            $0.sender = sender
            $0.collateralType = collateral_type
            $0.payment = paymentCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgRepayDebt"
            $0.value = try! repayCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaCDPRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ sender: String, _ payment: Coin, _ collateral_type: String,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let paymentCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = payment.denom
            $0.amount = payment.amount
        }
        let repayCdp = Kava_Cdp_V1beta1_MsgRepayDebt.with {
            $0.sender = sender
            $0.collateralType = collateral_type
            $0.payment = paymentCoin
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.cdp.v1beta1.MsgRepayDebt"
            $0.value = try! repayCdp.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaHardDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ depositor: String, _ toDepositCoins: Array<Coin>,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let depositHard = Kava_Hard_V1beta1_MsgDeposit.with {
            $0.depositor = depositor
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toDepositCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgDeposit"
            $0.value = try! depositHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaHardDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ depositor: String, _ toDepositCoins: Array<Coin>,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let depositHard = Kava_Hard_V1beta1_MsgDeposit.with {
            $0.depositor = depositor
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toDepositCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgDeposit"
            $0.value = try! depositHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaHardWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ depositor: String, _ toWithdrawCoins: Array<Coin>,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let withdrawHard = Kava_Hard_V1beta1_MsgWithdraw.with {
            $0.depositor = depositor
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toWithdrawCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgWithdraw"
            $0.value = try! withdrawHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaHardWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ depositor: String, _ toWithdrawCoins: Array<Coin>,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let withdrawHard = Kava_Hard_V1beta1_MsgWithdraw.with {
            $0.depositor = depositor
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toWithdrawCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgWithdraw"
            $0.value = try! withdrawHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaHardBorrow(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ borrower: String, _ toBorrowCoins: Array<Coin>,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let borrowHard = Kava_Hard_V1beta1_MsgBorrow.with {
            $0.borrower = borrower
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toBorrowCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgBorrow"
            $0.value = try! borrowHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaHardBorrow(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ borrower: String, _ toBorrowCoins: Array<Coin>,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let borrowHard = Kava_Hard_V1beta1_MsgBorrow.with {
            $0.borrower = borrower
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toBorrowCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgBorrow"
            $0.value = try! borrowHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaHardRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                       _ sender: String, _ owner: String, _ toRepayCoins: Array<Coin>,
                                       _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let repayHard = Kava_Hard_V1beta1_MsgRepay.with {
            $0.sender = sender
            $0.owner = owner
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toRepayCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgRepay"
            $0.value = try! repayHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaHardRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ sender: String, _ owner: String, _ toRepayCoins: Array<Coin>,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let repayHard = Kava_Hard_V1beta1_MsgRepay.with {
            $0.sender = sender
            $0.owner = owner
            var convertedCoins = Array<Cosmos_Base_V1beta1_Coin>()
            toRepayCoins.forEach { coin in
                convertedCoins.append(Cosmos_Base_V1beta1_Coin.with { $0.denom = coin.denom; $0.amount = coin.amount })
            }
            $0.amount = convertedCoins
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.hard.v1beta1.MsgRepay"
            $0.value = try! repayHard.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaSwapDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ depositor: String, _ token_a: Coin, _ token_b: Coin, _ slippage: String, _ deadline: Int64,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapDeposit = Kava_Swap_V1beta1_MsgDeposit.with {
            $0.depositor = depositor
            $0.tokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = token_a.denom; $0.amount = token_a.amount }
            $0.tokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = token_b.denom; $0.amount = token_b.amount }
            $0.slippage = slippage
            $0.deadline = deadline
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgDeposit"
            $0.value = try! swapDeposit.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaSwapDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ depositor: String, _ token_a: Coin, _ token_b: Coin, _ slippage: String, _ deadline: Int64,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapDeposit = Kava_Swap_V1beta1_MsgDeposit.with {
            $0.depositor = depositor
            $0.tokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = token_a.denom; $0.amount = token_a.amount }
            $0.tokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = token_b.denom; $0.amount = token_b.amount }
            $0.slippage = slippage
            $0.deadline = deadline
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgDeposit"
            $0.value = try! swapDeposit.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaSwapWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ from: String, _ shares: String, _ min_token_a: Coin, _ min_token_b: Coin, _ deadline: Int64,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapWithdraw = Kava_Swap_V1beta1_MsgWithdraw.with {
            $0.from = from
            $0.shares = shares
            $0.minTokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = min_token_a.denom; $0.amount = min_token_a.amount }
            $0.minTokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = min_token_b.denom; $0.amount = min_token_b.amount }
            $0.deadline = deadline
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgWithdraw"
            $0.value = try! swapWithdraw.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaSwapWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ from: String, _ shares: String, _ min_token_a: Coin, _ min_token_b: Coin, _ deadline: Int64,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapWithdraw = Kava_Swap_V1beta1_MsgWithdraw.with {
            $0.from = from
            $0.shares = shares
            $0.minTokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = min_token_a.denom; $0.amount = min_token_a.amount }
            $0.minTokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = min_token_b.denom; $0.amount = min_token_b.amount }
            $0.deadline = deadline
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgWithdraw"
            $0.value = try! swapWithdraw.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    static func genSignedKavaSwapExactForTokens(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ requester: String, _ swapIn: Coin, _ swapOut: Coin, _ slippage: String, _ deadline: Int64,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapExactForToken = Kava_Swap_V1beta1_MsgSwapExactForTokens.with {
            $0.requester = requester
            $0.exactTokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = swapIn.denom; $0.amount = swapIn.amount }
            $0.tokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = swapOut.denom; $0.amount = swapOut.amount }
            $0.slippage = slippage
            $0.deadline = deadline
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgSwapExactForTokens"
            $0.value = try! swapExactForToken.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func genSimulateKavaSwapExactForTokens(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ requester: String, _ swapIn: Coin, _ swapOut: Coin, _ slippage: String, _ deadline: Int64,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapExactForToken = Kava_Swap_V1beta1_MsgSwapExactForTokens.with {
            $0.requester = requester
            $0.exactTokenA = Cosmos_Base_V1beta1_Coin.with { $0.denom = swapIn.denom; $0.amount = swapIn.amount }
            $0.tokenB = Cosmos_Base_V1beta1_Coin.with { $0.denom = swapOut.denom; $0.amount = swapOut.amount }
            $0.slippage = slippage
            $0.deadline = deadline
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.swap.v1beta1.MsgSwapExactForTokens"
            $0.value = try! swapExactForToken.serializedData()
        }
        let txBody = getGrpcTxBody([anyMsg], memo)
        let signerInfo = getGrpcSignerInfo(auth, publicKey)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTx(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_SimulateRequest.with {
            $0.tx = simulateTx
        }
    }
    
    
    
    static func getGrpcTxBody(_ msgAnys: Array<Google_Protobuf2_Any>, _ memo: String) -> Cosmos_Tx_V1beta1_TxBody {
        return Cosmos_Tx_V1beta1_TxBody.with {
            $0.memo = memo
            $0.messages = msgAnys
        }
    }
    
    static func getGrpcSignerInfo(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ publicKey: Data) -> Cosmos_Tx_V1beta1_SignerInfo {
        let single = Cosmos_Tx_V1beta1_ModeInfo.Single.with {
            $0.mode = Cosmos_Tx_Signing_V1beta1_SignMode.direct
        }
        let mode = Cosmos_Tx_V1beta1_ModeInfo.with {
            $0.single = single
        }
        let pub = Cosmos_Crypto_Secp256k1_PubKey.with {
            $0.key = publicKey
        }
        let pubKey = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.crypto.secp256k1.PubKey"
//            $0.typeURL = "/injective.crypto.v1beta1.ethsecp256k1.PubKey"
            $0.value = try! pub.serializedData()
        }
        return Cosmos_Tx_V1beta1_SignerInfo.with {
            $0.publicKey = pubKey
            $0.modeInfo = mode
            $0.sequence = WUtils.onParseAuthGrpc(auth).2!
        }
    }
    
    static func getGrpcAuthInfo(_ signerInfo: Cosmos_Tx_V1beta1_SignerInfo, _ fee: Fee) -> Cosmos_Tx_V1beta1_AuthInfo{
        let feeCoin = Cosmos_Base_V1beta1_Coin.with {
            $0.denom = fee.amount[0].denom
            $0.amount = fee.amount[0].amount
        }
        let txFee = Cosmos_Tx_V1beta1_Fee.with {
            $0.amount = [feeCoin]
            $0.gasLimit = UInt64(fee.gas)!
        }
        return Cosmos_Tx_V1beta1_AuthInfo.with {
            $0.fee = txFee
            $0.signerInfos = [signerInfo]
        }
    }
    
    static func getGrpcRawTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ txBody: Cosmos_Tx_V1beta1_TxBody, _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ privateKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_TxRaw {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = chainId
            $0.accountNumber = WUtils.onParseAuthGrpc(auth).1!
        }
        let sigbyte = getGrpcByteSingleSignature(privateKey, try! signDoc.serializedData())
        return Cosmos_Tx_V1beta1_TxRaw.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.signatures = [sigbyte]
        }
    }
    
    static func getGrpcSimulTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ txBody: Cosmos_Tx_V1beta1_TxBody, _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ privateKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_Tx {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = chainId
            $0.accountNumber = WUtils.onParseAuthGrpc(auth).1!
        }
        let sigbyte = getGrpcByteSingleSignature(privateKey, try! signDoc.serializedData())
        return Cosmos_Tx_V1beta1_Tx.with {
            $0.authInfo = authInfo
            $0.body = txBody
            $0.signatures = [sigbyte]
        }
    }
    
    static func getGrpcByteSingleSignature(_ privateKey: Data, _ toSignByte: Data) -> Data {
        let hash = toSignByte.sha256()
        let signedData = try! ECDSA.compactsign(hash, privateKey: privateKey)
        return signedData
    }
}


extension ECDSA {
    public static func compactsign(_ data: Data, privateKey: Data) throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            privateKey.withUnsafeBytes { secp256k1_ecdsa_sign(ctx, signature, ptr, $0, nil, nil) }
        }
        guard status == 1 else { throw HDWalletKitError.failedToSign }
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        let length: size_t = 64
        var compact = Data(count: length)
        guard compact.withUnsafeMutableBytes({ return secp256k1_ecdsa_signature_serialize_compact(ctx, $0, normalizedsig) }) == 1 else { throw HDWalletKitError.noEnoughSpace }
        compact.count = length
        return compact
    }
}
