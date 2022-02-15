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
    
    //Tx for Common Denom Transfer
    static func genSignedSendTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                    _ toAddress: String, _ amount: Array<Coin>,
                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType)  -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let sendMsg = genSendMsg(auth, toAddress, amount)
        return getGrpcSignedTx(auth, chainType, sendMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSendTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                      _ toAddress: String, _ amount: Array<Coin>,
                                      _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType)  -> Cosmos_Tx_V1beta1_SimulateRequest {
        let sendMsg = genSendMsg(auth, toAddress, amount)
        return getGrpcSimulateTx(auth, chainType, sendMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSendMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toAddress: String, _ amount: Array<Coin>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Common Delegate
    static func genSignedDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ toValAddress: String, _ amount: Coin,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let deleMsg = genDelegateMsg(auth, toValAddress, amount)
        return getGrpcSignedTx(auth, chainType, deleMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ toValAddress: String, _ amount: Coin,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let deleMsg = genDelegateMsg(auth, toValAddress, amount)
        return getGrpcSimulateTx(auth, chainType, deleMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genDelegateMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toValAddress: String, _ amount: Coin) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Common UnDelegate
    static func genSignedUnDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ toValAddress: String, _ amount: Coin,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let undeleMsg = genDelegateMsg(auth, toValAddress, amount)
        return getGrpcSignedTx(auth, chainType, undeleMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateUnDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ toValAddress: String, _ amount: Coin,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let undeleMsg = genDelegateMsg(auth, toValAddress, amount)
        return getGrpcSimulateTx(auth, chainType, undeleMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genUndelegateMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ toValAddress: String, _ amount: Coin) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Common ReDelegate
    static func genSignedReDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ fromValAddress: String, _ toValAddress: String, _ amount: Coin,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let redeleMsg = genRedelegateMsg(auth, fromValAddress, toValAddress, amount)
        return getGrpcSignedTx(auth, chainType, redeleMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateReDelegateTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ fromValAddress: String, _ toValAddress: String, _ amount: Coin,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let redeleMsg = genRedelegateMsg(auth, fromValAddress, toValAddress, amount)
        return getGrpcSimulateTx(auth, chainType, redeleMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genRedelegateMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ fromValAddress: String, _ toValAddress: String, _ amount: Coin) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Common Claim Staking Reward
    static func genSignedClaimRewardsTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ validators: Array<Cosmos_Staking_V1beta1_Validator>,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let claimRewardMsg = genClaimStakingRewardMsg(auth, validators)
        return getGrpcSignedTx(auth, chainType, claimRewardMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateClaimRewardsTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ validators: Array<Cosmos_Staking_V1beta1_Validator>,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let claimRewardMsg = genClaimStakingRewardMsg(auth, validators)
        return getGrpcSimulateTx(auth, chainType, claimRewardMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genClaimStakingRewardMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ validators: Array<Cosmos_Staking_V1beta1_Validator>) -> [Google_Protobuf2_Any] {
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
        return anyMsgs
    }
    
    //Tx for Common Re-Invest
    static func genSignedReInvestTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ valAddress: String, _ amount: Coin,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let reinvestMsg = genReInvestMsg(auth, valAddress, amount)
        return getGrpcSignedTx(auth, chainType, reinvestMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateReInvestTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ valAddress: String, _ amount: Coin,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let reinvestMsg = genReInvestMsg(auth, valAddress, amount)
        return getGrpcSimulateTx(auth, chainType, reinvestMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genReInvestMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ valAddress: String, _ amount: Coin) -> [Google_Protobuf2_Any] {
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
        return anyMsgs
    }
    
    //Tx for Common Vote
    static func genSignedVoteTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                    _ proposalId: String, _ opinion: String,
                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let voteMsg = genVoteMsg(auth, proposalId, opinion)
        return getGrpcSignedTx(auth, chainType, voteMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateVoteTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                      _ proposalId: String, _ opinion: String,
                                      _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let voteMsg = genVoteMsg(auth, proposalId, opinion)
        return getGrpcSimulateTx(auth, chainType, voteMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genVoteMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ proposalId: String, _ opinion: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Common Reward Address Change
    static func genSignedSetRewardAddressTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ newRewardAddress: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let setRewardAddressMsg = genSetRewardAddressMsg(auth, newRewardAddress)
        return getGrpcSignedTx(auth, chainType, setRewardAddressMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateetRewardAddressTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ newRewardAddress: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let setRewardAddressMsg = genSetRewardAddressMsg(auth, newRewardAddress)
        return getGrpcSimulateTx(auth, chainType, setRewardAddressMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSetRewardAddressMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ newRewardAddress: String) -> [Google_Protobuf2_Any] {
        let rewardAddressMsg = Cosmos_Distribution_V1beta1_MsgSetWithdrawAddress.with {
            $0.delegatorAddress = WUtils.onParseAuthGrpc(auth).0!
            $0.withdrawAddress = newRewardAddress
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmos.distribution.v1beta1.MsgSetWithdrawAddress"
            $0.value = try! rewardAddressMsg.serializedData()
        }
        return [anyMsg]
    }
    
    
    //for Starname custom msgs
    //Tx for Starname Register Domain
    static func genSignedRegisterDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ domain: String, _ admin: String, _ type: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let setRegisterDomainMsg = genSetRegisterDomainMsg(domain, admin, type)
        return getGrpcSignedTx(auth, chainType, setRegisterDomainMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateRegisterDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                   _ domain: String, _ admin: String, _ type: String,
                                                   _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let setRegisterDomainMsg = genSetRegisterDomainMsg(domain, admin, type)
        return getGrpcSimulateTx(auth, chainType, setRegisterDomainMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSetRegisterDomainMsg(_ domain: String, _ admin: String, _ type: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Starname Register Account
    static func genSignedRegisterAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ domain: String, _ name: String, _ owner: String, _ registerer: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let registerAccountMsg = genRegisterAccountMsg(domain, name, owner, registerer, resources)
        return getGrpcSignedTx(auth, chainType, registerAccountMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateRegisterAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ domain: String, _ name: String, _ owner: String, _ registerer: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let registerAccountMsg = genRegisterAccountMsg(domain, name, owner, registerer, resources)
        return getGrpcSimulateTx(auth, chainType, registerAccountMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genRegisterAccountMsg(_ domain: String, _ name: String, _ owner: String, _ registerer: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Starname Delete Domain
    static func genSignedDeleteDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ domain: String, _ owner: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let deleteDomainMsg = genDeleteDomainMsg(domain, owner)
        return getGrpcSignedTx(auth, chainType, deleteDomainMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateDeleteDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ domain: String, _ owner: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let deleteDomainMsg = genDeleteDomainMsg(domain, owner)
        return getGrpcSimulateTx(auth, chainType, deleteDomainMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genDeleteDomainMsg(_ domain: String, _ owner: String) -> [Google_Protobuf2_Any] {
        let deleteDomainMsg = Starnamed_X_Starname_V1beta1_MsgDeleteDomain.with {
            $0.domain = domain
            $0.owner = owner
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgDeleteDomain"
            $0.value = try! deleteDomainMsg.serializedData()
        }
        return [anyMsg]
    }

    //Tx for Starname Delete Account
    static func genSignedDeleteAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ domain: String, _ name: String, _ owner: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let deleteAccountMsg = genDeleteAccountMsg(domain, name, owner)
        return getGrpcSignedTx(auth, chainType, deleteAccountMsg, privateKey, publicKey, fee, memo)
    }

    static func genSimulateDeleteAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ domain: String, _ name: String, _ owner: String,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let deleteAccountMsg = genDeleteAccountMsg(domain, name, owner)
        return getGrpcSimulateTx(auth, chainType, deleteAccountMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genDeleteAccountMsg(_ domain: String, _ name: String, _ owner: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
     
    //Tx for Starname Renew Domain
    static func genSignedRenewDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ domain: String, _ signer: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let renewDomainMsg = genRenewDomainMsg(domain, signer)
        return getGrpcSignedTx(auth, chainType, renewDomainMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateRenewDomainMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ domain: String, _ signer: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let renewDomainMsg = genRenewDomainMsg(domain, signer)
        return getGrpcSimulateTx(auth, chainType, renewDomainMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genRenewDomainMsg(_ domain: String, _ signer: String) -> [Google_Protobuf2_Any] {
        let renewDomainMsg = Starnamed_X_Starname_V1beta1_MsgRenewDomain.with {
            $0.domain = domain
            $0.signer = signer
            $0.payer = ""
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/starnamed.x.starname.v1beta1.MsgRenewDomain"
            $0.value = try! renewDomainMsg.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Starname Renew Account
    static func genSignedRenewAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ domain: String, _ name: String, _ signer: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let renewAccountMsg = genRenewAccountMsg(domain, name, signer)
        return getGrpcSignedTx(auth, chainType, renewAccountMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateRenewAccountMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ domain: String, _ name: String, _ signer: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let renewAccountMsg = genRenewAccountMsg(domain, name, signer)
        return getGrpcSimulateTx(auth, chainType, renewAccountMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genRenewAccountMsg(_ domain: String, _ name: String, _ signer: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Starname Replace Resource
    static func genSignedReplaceResourceMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ domain: String, _ name: String?, _ owner: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let replaceResourceMsg = genReplaceResourceMsg(domain, name, owner, resources)
        return getGrpcSignedTx(auth, chainType, replaceResourceMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateReplaceResourceMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ domain: String, _ name: String?, _ owner: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let replaceResourceMsg = genReplaceResourceMsg(domain, name, owner, resources)
        return getGrpcSimulateTx(auth, chainType, replaceResourceMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genReplaceResourceMsg(_ domain: String, _ name: String?, _ owner: String, _ resources: Array<Starnamed_X_Starname_V1beta1_Resource>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    
    //for Osmosis custom msgs
    //Tx for Osmosis Swap In
    static func genSignedSwapInMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ swapRoutes: [Osmosis_Gamm_V1beta1_SwapAmountInRoute], _ inputDenom: String, _ inputAmount: String, _ outputAmount: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let SwapInMsg = genSwapInMsg(auth, swapRoutes, inputDenom, inputAmount, outputAmount)
        return getGrpcSignedTx(auth, chainType, SwapInMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSwapInMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ swapRoutes: [Osmosis_Gamm_V1beta1_SwapAmountInRoute], _ inputDenom: String, _ inputAmount: String, _ outputAmount: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let SwapInMsg = genSwapInMsg(auth, swapRoutes, inputDenom, inputAmount, outputAmount)
        return getGrpcSimulateTx(auth, chainType, SwapInMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSwapInMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ swapRoutes: [Osmosis_Gamm_V1beta1_SwapAmountInRoute],
                             _ inputDenom: String, _ inputAmount: String, _ outputAmount: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Osmosis Deposit LP
    static func genSignedDepositPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ poolId: String, _ deposit0Coin: Coin, _ deposit1Coin: Coin, _ shareAmount: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let depositPoolMsg = genDepositPoolMsg(auth, poolId, deposit0Coin, deposit1Coin, shareAmount)
        return getGrpcSignedTx(auth, chainType, depositPoolMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateDepositPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ poolId: String, _ deposit0Coin: Coin, _ deposit1Coin: Coin, _ shareAmount: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let depositPoolMsg = genDepositPoolMsg(auth, poolId, deposit0Coin, deposit1Coin, shareAmount)
        return getGrpcSimulateTx(auth, chainType, depositPoolMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genDepositPoolMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                  _ poolId: String, _ deposit0Coin: Coin, _ deposit1Coin: Coin, _ shareAmount: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Osmosis Withdraw LP
    static func genSignedWithdrawPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ poolId: String, _ withdraw0Coin: Coin, _ withdraw1Coin: Coin, _ shareAmount: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let withdrawPoolMsg = genDepositPoolMsg(auth, poolId, withdraw0Coin, withdraw1Coin, shareAmount)
        return getGrpcSignedTx(auth, chainType, withdrawPoolMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateWithdrawPoolMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ poolId: String, _ withdraw0Coin: Coin, _ withdraw1Coin: Coin, _ shareAmount: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let withdrawPoolMsg = genDepositPoolMsg(auth, poolId, withdraw0Coin, withdraw1Coin, shareAmount)
        return getGrpcSimulateTx(auth, chainType, withdrawPoolMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genWithdrawPoolMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                   _ poolId: String, _ withdraw0Coin: Coin, _ withdraw1Coin: Coin, _ shareAmount: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Osmosis Lock Tokens
    static func genSignedLockTokensMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ lpCoin: Coin, _ duration: Int64,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let lockTokensMsg = genLockTokensMsg(auth, lpCoin, duration)
        return getGrpcSignedTx(auth, chainType, lockTokensMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateLockTokensMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ lpCoin: Coin, _ duration: Int64,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let lockTokensMsg = genLockTokensMsg(auth, lpCoin, duration)
        return getGrpcSimulateTx(auth, chainType, lockTokensMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genLockTokensMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ lpCoin: Coin, _ duration: Int64) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Osmosis Begin Unlocking
    static func genSignedBeginUnlockingsMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ ids: Array<UInt64>,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let beginUnlockingsMsg = genBeginUnlockingsMsg(auth, ids)
        return getGrpcSignedTx(auth, chainType, beginUnlockingsMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateBeginUnlockingsMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                    _ ids: Array<UInt64>,
                                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let beginUnlockingsMsg = genBeginUnlockingsMsg(auth, ids)
        return getGrpcSimulateTx(auth, chainType, beginUnlockingsMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genBeginUnlockingsMsg(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ ids: Array<UInt64>) -> [Google_Protobuf2_Any] {
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
        return anyMsgs
    }
    
    //for Gravity-Dex custom msgs
    //Tx for Gravity-Dex Swap Batch
    static func genSignedSwapBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ requester: String, _ poolId: String, _ swapType: String, _ offerCoin: Coin, _ offerCoinFee: Coin,
                                            _ demandCoinDenom: String, _ orderPrice: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapBatchMsg = genSwapBatchMsg(requester, poolId, swapType, offerCoin, offerCoinFee, demandCoinDenom, orderPrice)
        return getGrpcSignedTx(auth, chainType, swapBatchMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSwapBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ requester: String, _ poolId: String, _ swapType: String, _ offerCoin: Coin, _ offerCoinFee: Coin,
                                              _ demandCoinDenom: String, _ orderPrice: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapBatchMsg = genSwapBatchMsg(requester, poolId, swapType, offerCoin, offerCoinFee, demandCoinDenom, orderPrice)
        return getGrpcSimulateTx(auth, chainType, swapBatchMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSwapBatchMsg(_ requester: String, _ poolId: String, _ swapType: String, _ offerCoin: Coin, _ offerCoinFee: Coin,
                                _ demandCoinDenom: String, _ orderPrice: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Gravity-Dex Deposit Batch
    static func genSignedDepositBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ depositor: String, _ poolId: String, _ depositCoins: Array<Coin>,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let depositBatchMsg = genDepositBatchMsg(depositor, poolId, depositCoins)
        return getGrpcSignedTx(auth, chainType, depositBatchMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateDepositBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ depositor: String, _ poolId: String, _ depositCoins: Array<Coin>,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let depositBatchMsg = genDepositBatchMsg(depositor, poolId, depositCoins)
        return getGrpcSimulateTx(auth, chainType, depositBatchMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genDepositBatchMsg(_ depositor: String, _ poolId: String, _ depositCoins: Array<Coin>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Gravity-Dex Withdraw Batch
    static func genSignedWithdrawBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ withdrawer: String, _ poolId: String, _ withdrawCoin: Coin,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let withdrawBatchMsg = genWithdrawBatchMsg(withdrawer, poolId, withdrawCoin)
        return getGrpcSignedTx(auth, chainType, withdrawBatchMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateWithdrawBatchMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ withdrawer: String, _ poolId: String, _ withdrawCoin: Coin,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let withdrawBatchMsg = genWithdrawBatchMsg(withdrawer, poolId, withdrawCoin)
        return getGrpcSimulateTx(auth, chainType, withdrawBatchMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genWithdrawBatchMsg(_ withdrawer: String, _ poolId: String, _ withdrawCoin: Coin) -> [Google_Protobuf2_Any] {
        let withdrawBatchMsg = Tendermint_Liquidity_V1beta1_MsgWithdrawWithinBatch.with {
            $0.withdrawerAddress = withdrawer
            $0.poolID = UInt64(poolId)!
            $0.poolCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = withdrawCoin.denom; $0.amount = withdrawCoin.amount }
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/tendermint.liquidity.v1beta1.MsgWithdrawWithinBatch"
            $0.value = try! withdrawBatchMsg.serializedData()
        }
        return [anyMsg]
    }
    
    //for IBC Transfer custom msgs
    //Tx for Ibc Transfer
    static func genSignedIbcTransferMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ sender: String, _ receiver: String, _ ibcSendDenom: String, _ ibcSendAmount: String, _ ibcPath: Path, _ lastHeight: Ibc_Core_Client_V1_Height,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let ibcTransferMsg = genIbcTransferMsg(sender, receiver, ibcSendDenom, ibcSendAmount, ibcPath, lastHeight)
        return getGrpcSignedTx(auth, chainType, ibcTransferMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateIbcTransferMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ sender: String, _ receiver: String, _ ibcSendDenom: String, _ ibcSendAmount: String, _ ibcPath: Path, _ lastHeight: Ibc_Core_Client_V1_Height,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let ibcTransferMsg = genIbcTransferMsg(sender, receiver, ibcSendDenom, ibcSendAmount, ibcPath, lastHeight)
        return getGrpcSimulateTx(auth, chainType, ibcTransferMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genIbcTransferMsg(_ sender: String, _ receiver: String, _ ibcSendDenom: String, _ ibcSendAmount: String, _ ibcPath: Path, _ lastHeight: Ibc_Core_Client_V1_Height) -> [Google_Protobuf2_Any] {
        let re_timeout_height = Ibc_Core_Client_V1_Height.with {
            $0.revisionNumber = lastHeight.revisionNumber
            $0.revisionHeight = lastHeight.revisionHeight + 1000
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
        return [anyMsg]
    }
    
    //for SIF custom msgs
    //Tx for Sif Incentive
    static func genSignedSifIncentiveMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                               _ userClaimAddress: String,
                                               _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let sifIncentiveMsg = genSifIncentiveMsg(userClaimAddress)
        return getGrpcSignedTx(auth, chainType, sifIncentiveMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSifIncentiveMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ userClaimAddress: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let sifIncentiveMsg = genSifIncentiveMsg(userClaimAddress)
        return getGrpcSimulateTx(auth, chainType, sifIncentiveMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSifIncentiveMsg(_ userClaimAddress: String) -> [Google_Protobuf2_Any] {
        let claimIncentiveMsg = Sifnode_Dispensation_V1_MsgCreateUserClaim.with {
            $0.userClaimAddress = userClaimAddress
            $0.userClaimType = Sifnode_Dispensation_V1_DistributionType.liquidityMining
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/sifnode.dispensation.v1.MsgCreateUserClaim"
            $0.value = try! claimIncentiveMsg.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Sif Swap
    static func genSignedSifSwapMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ signer: String, _ inputDenom: String, _ inputAmount: String, _ outputDenom: String, _ outputAmount: String,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let sifSwapMsg = genSifSwapMsg(signer, inputDenom, inputAmount, outputDenom, outputAmount)
        return getGrpcSignedTx(auth, chainType, sifSwapMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSifSwapMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ signer: String, _ inputDenom: String, _ inputAmount: String, _ outputDenom: String, _ outputAmount: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let sifSwapMsg = genSifSwapMsg(signer, inputDenom, inputAmount, outputDenom, outputAmount)
        return getGrpcSimulateTx(auth, chainType, sifSwapMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSifSwapMsg(_ signer: String, _ inputDenom: String, _ inputAmount: String, _ outputDenom: String, _ outputAmount: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Sif Add LP
    static func genSignedSifAddLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ signer: String, _ nativeAmount: String, _ externalDenom: String, _ externalAmount: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let sifAddLpMsg = genSifAddLpMsg(signer, nativeAmount, externalDenom, externalAmount)
        return getGrpcSignedTx(auth, chainType, sifAddLpMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSifAddLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ signer: String, _ nativeAmount: String, _ externalDenom: String, _ externalAmount: String,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let sifAddLpMsg = genSifAddLpMsg(signer, nativeAmount, externalDenom, externalAmount)
        return getGrpcSimulateTx(auth, chainType, sifAddLpMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSifAddLpMsg(_ signer: String, _ nativeAmount: String, _ externalDenom: String, _ externalAmount: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Sif Remove LP
    static func genSignedSifRemoveLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ signer: String, _ externalDenom: String, _ w_basis_points: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let sifRemoveLpMsg = genSifRemoveLpMsg(signer, externalDenom, w_basis_points)
        return getGrpcSignedTx(auth, chainType, sifRemoveLpMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSifRemoveLpMsgTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ signer: String, _ externalDenom: String, _ w_basis_points: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let sifRemoveLpMsg = genSifRemoveLpMsg(signer, externalDenom, w_basis_points)
        return getGrpcSimulateTx(auth, chainType, sifRemoveLpMsg, privateKey, publicKey, fee, memo)
    }
    
    static func genSifRemoveLpMsg(_ signer: String, _ externalDenom: String, _ w_basis_points: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //for IRIS custom msgs
    //Tx for Iris Issue Nft
    static func genSignedIssueNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ signer: String, _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let irisIssueNft = genIrisIssueNft(signer, denom_id, denom_name, id, name, uri, data)
        return getGrpcSignedTx(auth, chainType, irisIssueNft, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateIssueNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                              _ signer: String, _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                              _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let irisIssueNft = genIrisIssueNft(signer, denom_id, denom_name, id, name, uri, data)
        return getGrpcSimulateTx(auth, chainType, irisIssueNft, privateKey, publicKey, fee, memo)
    }
    
    static func genIrisIssueNft(_ signer: String, _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String) -> [Google_Protobuf2_Any] {
        var anyMsgs = Array<Google_Protobuf2_Any>()
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
        anyMsgs.append(issueNftDenomMsg)
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
        anyMsgs.append(issueNftMsg)
        return anyMsgs
    }
    
    //Tx for Iris Send Nft
    static func genSignedSendNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ irisResponse: Irismod_Nft_QueryNFTResponse,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let irisSendNft = genIrisSendNft(signer, recipient, id, denom_id, irisResponse)
        return getGrpcSignedTx(auth, chainType, irisSendNft, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSendNftIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ irisResponse: Irismod_Nft_QueryNFTResponse,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let irisSendNft = genIrisSendNft(signer, recipient, id, denom_id, irisResponse)
        return getGrpcSimulateTx(auth, chainType, irisSendNft, privateKey, publicKey, fee, memo)
    }
    
    static func genIrisSendNft(_ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ irisResponse: Irismod_Nft_QueryNFTResponse) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Iris Issue Nft Denom
    static func genSignedIssueNftDenomIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                 _ signer: String,_ denom_id: String, _ denom_name: String,
                                                 _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let irisIssueNftDenom = genIrisIssueNftDenom(signer, denom_id, denom_name)
        return getGrpcSignedTx(auth, chainType, irisIssueNftDenom, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateIssueNftDenomIrisTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                   _ signer: String,_ denom_id: String, _ denom_name: String,
                                                   _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let irisIssueNftDenom = genIrisIssueNftDenom(signer, denom_id, denom_name)
        return getGrpcSimulateTx(auth, chainType, irisIssueNftDenom, privateKey, publicKey, fee, memo)
    }
    
    static func genIrisIssueNftDenom(_ signer: String,_ denom_id: String, _ denom_name: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //for CRO custom msgs
    //Tx for Cro Issue Nft
    static func genSignedIssueNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ signer: String, _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let croIssueNft = genCroIssueNft(signer, denom_id, denom_name, id, name, uri, data)
        return getGrpcSignedTx(auth, chainType, croIssueNft, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateIssueNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ signer: String, _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let croIssueNft = genCroIssueNft(signer, denom_id, denom_name, id, name, uri, data)
        return getGrpcSimulateTx(auth, chainType, croIssueNft, privateKey, publicKey, fee, memo)
    }
    
    static func genCroIssueNft(_ signer: String, _ denom_id: String, _ denom_name: String,  _ id: String, _ name: String, _ uri: String, _ data: String) -> [Google_Protobuf2_Any] {
        var anyMsgs = Array<Google_Protobuf2_Any>()
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
        anyMsgs.append(issueNftDenomMsg)
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
        anyMsgs.append(issueNftMsg)
        return anyMsgs
    }
    
    //Tx for Cro Send Nft
    static func genSignedSendNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ croResponse: Chainmain_Nft_V1_QueryNFTResponse,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let croSendNft = genCroSendNft(signer, recipient, id, denom_id, croResponse)
        return getGrpcSignedTx(auth, chainType, croSendNft, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSendNftCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ croResponse: Chainmain_Nft_V1_QueryNFTResponse,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let croSendNft = genCroSendNft(signer, recipient, id, denom_id, croResponse)
        return getGrpcSimulateTx(auth, chainType, croSendNft, privateKey, publicKey, fee, memo)
    }
    
    static func genCroSendNft(_ signer: String, _ recipient: String, _ id: String, _ denom_id: String, _ croResponse: Chainmain_Nft_V1_QueryNFTResponse) -> [Google_Protobuf2_Any] {
        let issueNft = Chainmain_Nft_V1_MsgTransferNFT.with {
            $0.sender = signer
            $0.recipient = recipient
            $0.id = id
            $0.denomID = denom_id
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/chainmain.nft.v1.MsgTransferNFT"
            $0.value = try! issueNft.serializedData()
        }
        return [anyMsg]
    }
    
    //Tx for Cro Issue Nft Denom
    static func genSignedIssueNftDenomCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ signer: String,_ denom_id: String, _ denom_name: String,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let croIssueNftDenom = genCroIssueNftDenom(signer, denom_id, denom_name)
        return getGrpcSignedTx(auth, chainType, croIssueNftDenom, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateIssueNftDenomCroTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ signer: String,_ denom_id: String, _ denom_name: String,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let croIssueNftDenom = genCroIssueNftDenom(signer, denom_id, denom_name)
        return getGrpcSimulateTx(auth, chainType, croIssueNftDenom, privateKey, publicKey, fee, memo)
    }
    
    static func genCroIssueNftDenom(_ signer: String,_ denom_id: String, _ denom_name: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //for Desmos custom msgs
    //Tx for Desmos Save Profile
    static func genSignedSaveProfileTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ creator: String,_ dtag: String, _ nickname: String, _ bio: String, _ profile_picture: String, _ cover_picture: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let saveProfile = genSaveProfile(creator, dtag, nickname, bio, profile_picture, cover_picture)
        return getGrpcSignedTx(auth, chainType, saveProfile, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateSaveProfileTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                             _ creator: String,_ dtag: String, _ nickname: String, _ bio: String, _ profile_picture: String, _ cover_picture: String,
                                             _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let saveProfile = genSaveProfile(creator, dtag, nickname, bio, profile_picture, cover_picture)
        return getGrpcSimulateTx(auth, chainType, saveProfile, privateKey, publicKey, fee, memo)
    }
    
    static func genSaveProfile(_ creator: String,_ dtag: String, _ nickname: String, _ bio: String, _ profile_picture: String, _ cover_picture: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Desmos Link Chain
    static func genSignedLinkChainTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ signer: String, _ tochain: ChainType, _ toAccount: Account, _ toPrivateKey: Data, _ toPublicKey: Data,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let linkChain = genLinkChain(signer, tochain, toAccount, toPrivateKey, toPublicKey)
        return getGrpcSignedTx(auth, chainType, linkChain, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateLinkChainTxgRPC(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ signer: String, _ tochain: ChainType, _ toAccount: Account, _ toPrivateKey: Data, _ toPublicKey: Data,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let linkChain = genLinkChain(signer, tochain, toAccount, toPrivateKey, toPublicKey)
        return getGrpcSimulateTx(auth, chainType, linkChain, privateKey, publicKey, fee, memo)
    }
    
    static func genLinkChain(_ signer: String, _ tochain: ChainType, _ toAccount: Account, _ toPrivateKey: Data, _ toPublicKey: Data) -> [Google_Protobuf2_Any] {
        let plainString = "Link Chain With Cosmostation"
        let sigbyte = getGrpcByteSingleSignatures(toPrivateKey, plainString.data(using: .utf8)!, nil)
        
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
        return [anyMsg]
    }
    
    
    //for kava sign
    //Tx for Kava CDP Create
    static func genSignedKavaCDPCreate(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                       _ sender: String, _ collateral: Coin, _ principal: Coin, _ collateral_type: String,
                                       _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let createCdp = genKavaCDPCreate(sender, collateral, principal, collateral_type)
        return getGrpcSignedTx(auth, chainType, createCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaCDPCreate(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ sender: String, _ collateral: Coin, _ principal: Coin, _ collateral_type: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let createCdp = genKavaCDPCreate(sender, collateral, principal, collateral_type)
        return getGrpcSimulateTx(auth, chainType, createCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaCDPCreate(_ sender: String, _ collateral: Coin, _ principal: Coin, _ collateral_type: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava CDP Deposit
    static func genSignedKavaCDPDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let depositCdp = genKavaCDPDeposit(owner, depositor, collateral, collateral_type)
        return getGrpcSignedTx(auth, chainType, depositCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaCDPDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let depositCdp = genKavaCDPDeposit(owner, depositor, collateral, collateral_type)
        return getGrpcSimulateTx(auth, chainType, depositCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaCDPDeposit(_ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava CDP Withdraw
    static func genSignedKavaCDPWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let withdrawCdp = genKavaCDPWithdraw(owner, depositor, collateral, collateral_type)
        return getGrpcSignedTx(auth, chainType, withdrawCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaCDPWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let withdrawCdp = genKavaCDPWithdraw(owner, depositor, collateral, collateral_type)
        return getGrpcSimulateTx(auth, chainType, withdrawCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaCDPWithdraw(_ owner: String, _ depositor: String, _ collateral: Coin, _ collateral_type: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava CDP Draw Debt
    static func genSignedKavaCDPDrawDebt(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ sender: String, _ principal: Coin, _ collateral_type: String,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let drawdebtCdp = genKavaCDPDrawDebt(sender, principal, collateral_type)
        return getGrpcSignedTx(auth, chainType, drawdebtCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaCDPDrawDebt(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ sender: String, _ principal: Coin, _ collateral_type: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let drawdebtCdp = genKavaCDPDrawDebt(sender, principal, collateral_type)
        return getGrpcSimulateTx(auth, chainType, drawdebtCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaCDPDrawDebt(_ sender: String, _ principal: Coin, _ collateral_type: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava CDP Repay
    static func genSignedKavaCDPRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                      _ sender: String, _ payment: Coin, _ collateral_type: String,
                                      _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let repayCdp = genKavaCDPRepay(sender, payment, collateral_type)
        return getGrpcSignedTx(auth, chainType, repayCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaCDPRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ sender: String, _ payment: Coin, _ collateral_type: String,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let repayCdp = genKavaCDPRepay(sender, payment, collateral_type)
        return getGrpcSimulateTx(auth, chainType, repayCdp, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaCDPRepay(_ sender: String, _ payment: Coin, _ collateral_type: String) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Hard Deposit
    static func genSignedKavaHardDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ depositor: String, _ toDepositCoins: Array<Coin>,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let depositHard = genKavaHardDeposit(depositor, toDepositCoins)
        return getGrpcSignedTx(auth, chainType, depositHard, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaHardDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ depositor: String, _ toDepositCoins: Array<Coin>,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let depositHard = genKavaHardDeposit(depositor, toDepositCoins)
        return getGrpcSimulateTx(auth, chainType, depositHard, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaHardDeposit(_ depositor: String, _ toDepositCoins: Array<Coin>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Hard Withdraw
    static func genSignedKavaHardWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ depositor: String, _ toWithdrawCoins: Array<Coin>,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let withdrawHard = genKavaHardWithdraw(depositor, toWithdrawCoins)
        return getGrpcSignedTx(auth, chainType, withdrawHard, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaHardWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ depositor: String, _ toWithdrawCoins: Array<Coin>,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let withdrawHard = genKavaHardWithdraw(depositor, toWithdrawCoins)
        return getGrpcSimulateTx(auth, chainType, withdrawHard, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaHardWithdraw(_ depositor: String, _ toWithdrawCoins: Array<Coin>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Hard Borrow
    static func genSignedKavaHardBorrow(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                        _ borrower: String, _ toBorrowCoins: Array<Coin>,
                                        _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let borrowHard = genKavaHardBorrow(borrower, toBorrowCoins)
        return getGrpcSignedTx(auth, chainType, borrowHard, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaHardBorrow(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ borrower: String, _ toBorrowCoins: Array<Coin>,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let borrowHard = genKavaHardBorrow(borrower, toBorrowCoins)
        return getGrpcSimulateTx(auth, chainType, borrowHard, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaHardBorrow(_ borrower: String, _ toBorrowCoins: Array<Coin>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Hard Repay
    static func genSignedKavaHardRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                       _ sender: String, _ owner: String, _ toRepayCoins: Array<Coin>,
                                       _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let repayHard = genKavaHardRepay(sender, owner, toRepayCoins)
        return getGrpcSignedTx(auth, chainType, repayHard, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaHardRepay(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ sender: String, _ owner: String, _ toRepayCoins: Array<Coin>,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let repayHard = genKavaHardRepay(sender, owner, toRepayCoins)
        return getGrpcSimulateTx(auth, chainType, repayHard, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaHardRepay(_ sender: String, _ owner: String, _ toRepayCoins: Array<Coin>) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Swap Deposit
    static func genSignedKavaSwapDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                         _ depositor: String, _ token_a: Coin, _ token_b: Coin, _ slippage: String, _ deadline: Int64,
                                         _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapDeposit = genKavaSwapDeposit(depositor, token_a, token_b, slippage, deadline)
        return getGrpcSignedTx(auth, chainType, swapDeposit, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaSwapDeposit(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ depositor: String, _ token_a: Coin, _ token_b: Coin, _ slippage: String, _ deadline: Int64,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapDeposit = genKavaSwapDeposit(depositor, token_a, token_b, slippage, deadline)
        return getGrpcSimulateTx(auth, chainType, swapDeposit, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaSwapDeposit(_ depositor: String, _ token_a: Coin, _ token_b: Coin, _ slippage: String, _ deadline: Int64) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Swap Withdraw
    static func genSignedKavaSwapWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ from: String, _ shares: String, _ min_token_a: Coin, _ min_token_b: Coin, _ deadline: Int64,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapWithdraw = genKavaSwapWithdraw(from, shares, min_token_a, min_token_b, deadline)
        return getGrpcSignedTx(auth, chainType, swapWithdraw, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaSwapWithdraw(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ from: String, _ shares: String, _ min_token_a: Coin, _ min_token_b: Coin, _ deadline: Int64,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapWithdraw = genKavaSwapWithdraw(from, shares, min_token_a, min_token_b, deadline)
        return getGrpcSimulateTx(auth, chainType, swapWithdraw, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaSwapWithdraw(_ from: String, _ shares: String, _ min_token_a: Coin, _ min_token_b: Coin, _ deadline: Int64) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Swap Exact For Tokens
    static func genSignedKavaSwapExactForTokens(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                _ requester: String, _ swapIn: Coin, _ swapOut: Coin, _ slippage: String, _ deadline: Int64,
                                                _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let swapExactForTokens = genKavaSwapExactForTokens(requester, swapIn, swapOut, slippage, deadline)
        return getGrpcSignedTx(auth, chainType, swapExactForTokens, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaSwapExactForTokens(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                                  _ requester: String, _ swapIn: Coin, _ swapOut: Coin, _ slippage: String, _ deadline: Int64,
                                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let swapExactForTokens = genKavaSwapExactForTokens(requester, swapIn, swapOut, slippage, deadline)
        return getGrpcSimulateTx(auth, chainType, swapExactForTokens, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaSwapExactForTokens(_ requester: String, _ swapIn: Coin, _ swapOut: Coin, _ slippage: String, _ deadline: Int64) -> [Google_Protobuf2_Any] {
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
        return [anyMsg]
    }
    
    //Tx for Kava Incentive All
    static func genSignedKavaIncentiveAll(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                          _ sender: String, _ multiplier_name: String,
                                          _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let kavaIncentive = genKavaIncentiveAll(sender, multiplier_name)
        return getGrpcSignedTx(auth, chainType, kavaIncentive, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateKavaIncentiveAll(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ sender: String, _ multiplier_name: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let kavaIncentive = genKavaIncentiveAll(sender, multiplier_name)
        return getGrpcSimulateTx(auth, chainType, kavaIncentive, privateKey, publicKey, fee, memo)
    }
    
    static func genKavaIncentiveAll(_ sender: String, _ multiplier_name: String) -> [Google_Protobuf2_Any] {
        var anyMsgs = Array<Google_Protobuf2_Any>()
        let incentiveRewards = BaseData.instance.mIncentiveRewards!
        if (incentiveRewards.getMintingRewardAmount().compare(NSDecimalNumber.zero).rawValue > 0) {
            anyMsgs.append(getKavaIncentiveUSDXMinting(sender, multiplier_name))
        }
        if (incentiveRewards.getHardRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentiveRewards.getHardRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = multiplier_name })
            }
            anyMsgs.append(getKavaIncentiveHard(sender, denoms_to_claims))
        }
        if (incentiveRewards.getDelegatorRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentiveRewards.getDelegatorRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = multiplier_name })
            }
            anyMsgs.append(getKavaIncentiveDelegator(sender, denoms_to_claims))
        }
        if (incentiveRewards.getSwapRewardDenoms().count > 0) {
            var denoms_to_claims = Array<Kava_Incentive_V1beta1_Selection>()
            for denom in incentiveRewards.getSwapRewardDenoms() {
                denoms_to_claims.append(Kava_Incentive_V1beta1_Selection.with { $0.denom = denom; $0.multiplierName = multiplier_name })
            }
            anyMsgs.append(getKavaIncentiveSwap(sender, denoms_to_claims))
        }
        return anyMsgs
    }
    
    static func getKavaIncentiveUSDXMinting(_ sender: String, _ multiplier_name: String) -> Google_Protobuf2_Any {
        let incentiveMint = Kava_Incentive_V1beta1_MsgClaimUSDXMintingReward.with {
            $0.sender = sender
            $0.multiplierName = multiplier_name
        }
        return Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.incentive.v1beta1.MsgClaimUSDXMintingReward"
            $0.value = try! incentiveMint.serializedData()
        }
    }
    
    static func getKavaIncentiveHard(_ sender: String, _ denoms_to_claims: Array<Kava_Incentive_V1beta1_Selection>) -> Google_Protobuf2_Any {
        let incentiveHard = Kava_Incentive_V1beta1_MsgClaimHardReward.with {
            $0.sender = sender
            $0.denomsToClaim = denoms_to_claims
        }
        return Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.incentive.v1beta1.MsgClaimHardReward"
            $0.value = try! incentiveHard.serializedData()
        }
    }
    
    static func getKavaIncentiveDelegator(_ sender: String, _ denoms_to_claims: Array<Kava_Incentive_V1beta1_Selection>) -> Google_Protobuf2_Any {
        let incentiveDelegator = Kava_Incentive_V1beta1_MsgClaimDelegatorReward.with {
            $0.sender = sender
            $0.denomsToClaim = denoms_to_claims
        }
        return Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.incentive.v1beta1.MsgClaimDelegatorReward"
            $0.value = try! incentiveDelegator.serializedData()
        }
    }
    
    static func getKavaIncentiveSwap(_ sender: String, _ denoms_to_claims: Array<Kava_Incentive_V1beta1_Selection>) -> Google_Protobuf2_Any {
        let incentiveSwap = Kava_Incentive_V1beta1_MsgClaimSwapReward.with {
            $0.sender = sender
            $0.denomsToClaim = denoms_to_claims
        }
        return Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.incentive.v1beta1.MsgClaimSwapReward"
            $0.value = try! incentiveSwap.serializedData()
        }
    }
    
    //Tx for Kava Create HTLC Swap
    static func genSignedKavaCreateHTLCSwap(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                            _ from: String, _ to: String, _ sendCoin: Array<Coin>, _ timeStamp: Int64, _ randomNumberHash: String,
                                            _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let createAtomicSwap = Kava_Bep3_V1beta1_MsgCreateAtomicSwap.with {
            $0.from = from
            $0.to = WUtils.getDuputyAdddress(sendCoin[0].denom).0
            $0.senderOtherChain = WUtils.getDuputyAdddress(sendCoin[0].denom).1
            $0.recipientOtherChain = to
            $0.randomNumberHash = randomNumberHash
            $0.timestamp = timeStamp
            $0.amount = [Cosmos_Base_V1beta1_Coin.with { $0.denom = sendCoin[0].denom; $0.amount = sendCoin[0].amount }]
            $0.heightSpan = 24686
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.bep3.v1beta1.MsgCreateAtomicSwap"
            $0.value = try! createAtomicSwap.serializedData()
        }
        return getGrpcSignedTx(auth, chainType, [anyMsg], privateKey, publicKey, fee, memo)
    }
    
    //Tx for Kava Claim HTLC Swap
    static func genSignedKavaClaimHTLCSwap(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                           _ from: String, _ swapID: String, _ randomNumber: String,
                                           _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let claimAtomicSwap = Kava_Bep3_V1beta1_MsgClaimAtomicSwap.with {
            $0.from = from
            $0.swapID = swapID
            $0.randomNumber = randomNumber
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/kava.bep3.v1beta1.MsgClaimAtomicSwap"
            $0.value = try! claimAtomicSwap.serializedData()
        }
        return getGrpcSignedTx2(auth, chainId, [anyMsg], privateKey, publicKey, fee, memo)
        
    }
    
    //for WASM custom msg
    //Tx for CW20 Transfer
    static func genSignedCw20Send(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                  _ fromAddress: String, _ toAddress: String, _ contractAddress: String, _ amount: Array<Coin>,
                                  _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let cw20Send = genCw20Send(fromAddress, toAddress, contractAddress, amount)
        return getGrpcSignedTx(auth, chainType, cw20Send, privateKey, publicKey, fee, memo)
    }
    
    static func genSimulateCw20Send(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse,
                                    _ fromAddress: String, _ toAddress: String, _ contractAddress: String, _ amount: Array<Coin>,
                                    _ fee: Fee, _ memo: String, _ privateKey: Data, _ publicKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let cw20Send = genCw20Send(fromAddress, toAddress, contractAddress, amount)
        return getGrpcSimulateTx(auth, chainType, cw20Send, privateKey, publicKey, fee, memo)
    }
    
    static func genCw20Send(_ fromAddress: String, _ toAddress: String, _ contractAddress: String, _ amount: Array<Coin>) -> [Google_Protobuf2_Any] {
        let exeContract = Cosmwasm_Wasm_V1_MsgExecuteContract.with {
            $0.sender = fromAddress
            $0.contract = contractAddress
            $0.msg  = Cw20TransferReq.init(toAddress, amount[0].amount).getEncode()
        }
        let anyMsg = Google_Protobuf2_Any.with {
            $0.typeURL = "/cosmwasm.wasm.v1.MsgExecuteContract"
            $0.value = try! exeContract.serializedData()
        }
        return [anyMsg]
    }
    
    
    
    
    
    static func getGrpcSignedTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ chainType: ChainType, _ msgAnys: Array<Google_Protobuf2_Any>, _ privateKey: Data, _ publicKey: Data, _ fee: Fee, _ memo: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let txBody = getGrpcTxBody(msgAnys, memo)
        let signerInfo = getGrpcSignerInfos(auth, publicKey, chainType)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTxs(auth, txBody, authInfo, privateKey, chainType)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func getGrpcSignedTx2(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ chainId: String, _ msgAnys: Array<Google_Protobuf2_Any>, _ privateKey: Data, _ publicKey: Data, _ fee: Fee, _ memo: String) -> Cosmos_Tx_V1beta1_BroadcastTxRequest {
        let txBody = getGrpcTxBody(msgAnys, memo)
        let signerInfo = getGrpcSignerInfos(auth, publicKey, nil)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let rawTx = getGrpcRawTxs2(auth, txBody, authInfo, privateKey, chainId)
        return Cosmos_Tx_V1beta1_BroadcastTxRequest.with {
            $0.mode = Cosmos_Tx_V1beta1_BroadcastMode.async
            $0.txBytes = try! rawTx.serializedData()
        }
    }
    
    static func getGrpcSimulateTx(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ chainType: ChainType, _ msgAnys: Array<Google_Protobuf2_Any>, _ privateKey: Data, _ publicKey: Data, _ fee: Fee, _ memo: String) -> Cosmos_Tx_V1beta1_SimulateRequest {
        let txBody = getGrpcTxBody(msgAnys, memo)
        let signerInfo = getGrpcSignerInfos(auth, publicKey, chainType)
        let authInfo = getGrpcAuthInfo(signerInfo, fee)
        let simulateTx = getGrpcSimulTxs(auth, txBody, authInfo, privateKey, chainType)
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
    
    static func getGrpcSignerInfos(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ publicKey: Data, _ chainType: ChainType?) -> Cosmos_Tx_V1beta1_SignerInfo {
        let single = Cosmos_Tx_V1beta1_ModeInfo.Single.with {
            $0.mode = Cosmos_Tx_Signing_V1beta1_SignMode.direct
        }
        let mode = Cosmos_Tx_V1beta1_ModeInfo.with {
            $0.single = single
        }
        var pubKey: Google_Protobuf2_Any?
        if (chainType == ChainType.INJECTIVE_MAIN) {
            let pub = Injective_Crypto_V1beta1_Ethsecp256k1_PubKey.with {
                $0.key = publicKey
            }
            pubKey = Google_Protobuf2_Any.with {
                $0.typeURL = "/injective.crypto.v1beta1.ethsecp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
            
        } else {
            let pub = Cosmos_Crypto_Secp256k1_PubKey.with {
                $0.key = publicKey
            }
            pubKey = Google_Protobuf2_Any.with {
                $0.typeURL = "/cosmos.crypto.secp256k1.PubKey"
                $0.value = try! pub.serializedData()
            }
        }
        return Cosmos_Tx_V1beta1_SignerInfo.with {
            $0.publicKey = pubKey!
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
    
    
    static func getGrpcRawTxs(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ txBody: Cosmos_Tx_V1beta1_TxBody, _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ privateKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_TxRaw {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = BaseData.instance.getChainId(chainType)
            $0.accountNumber = WUtils.onParseAuthGrpc(auth).1!
        }
        let sigbyte = getGrpcByteSingleSignatures(privateKey, try! signDoc.serializedData(), chainType)
        return Cosmos_Tx_V1beta1_TxRaw.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.signatures = [sigbyte]
        }
    }
    
    static func getGrpcRawTxs2(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ txBody: Cosmos_Tx_V1beta1_TxBody, _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ privateKey: Data, _ chainId: String) -> Cosmos_Tx_V1beta1_TxRaw {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = chainId
            $0.accountNumber = WUtils.onParseAuthGrpc(auth).1!
        }
        let sigbyte = getGrpcByteSingleSignatures(privateKey, try! signDoc.serializedData(), nil)
        return Cosmos_Tx_V1beta1_TxRaw.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.signatures = [sigbyte]
        }
    }
    
    static func getGrpcSimulTxs(_ auth: Cosmos_Auth_V1beta1_QueryAccountResponse, _ txBody: Cosmos_Tx_V1beta1_TxBody, _ authInfo: Cosmos_Tx_V1beta1_AuthInfo, _ privateKey: Data, _ chainType: ChainType) -> Cosmos_Tx_V1beta1_Tx {
        let signDoc = Cosmos_Tx_V1beta1_SignDoc.with {
            $0.bodyBytes = try! txBody.serializedData()
            $0.authInfoBytes = try! authInfo.serializedData()
            $0.chainID = BaseData.instance.getChainId(chainType)
            $0.accountNumber = WUtils.onParseAuthGrpc(auth).1!
        }
        let sigbyte = getGrpcByteSingleSignatures(privateKey, try! signDoc.serializedData(), chainType)
        return Cosmos_Tx_V1beta1_Tx.with {
            $0.authInfo = authInfo
            $0.body = txBody
            $0.signatures = [sigbyte]
        }
    }
    
    static func getGrpcByteSingleSignatures(_ privateKey: Data, _ toSignByte: Data, _ chainType: ChainType?) -> Data {
        var hash: Data?
        if (chainType == ChainType.INJECTIVE_MAIN) {
            hash = HDWalletKit.Crypto.sha3keccak256(data: toSignByte)
        } else {
            hash = toSignByte.sha256()
        }
        let signedData = try! ECDSA.compactsign(hash!, privateKey: privateKey)
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
