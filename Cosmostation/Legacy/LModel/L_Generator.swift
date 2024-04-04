//
//  L_Generator.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/08.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import CryptoSwift
import HDWalletKit


class L_Generator {
    
    static func oktSendMsg(_ fromAddress: String, _ toAddress: String, _ amounts: [L_Coin]) -> L_Msg {
        var value = L_Value.init()
        value.from_address = fromAddress
        value.to_address = toAddress
        value.amount = amounts
        
        var result = L_Msg.init()
        result.type = "okexchain/token/MsgTransfer"
        result.value = value
        return result
    }
    
    static func oktDepositMsg(_ delegator: String, _ amount: L_Coin) -> L_Msg {
        var value = L_Value.init()
        value.delegator_address = delegator
        value.quantity = amount
        
        var result = L_Msg.init()
        result.type = "okexchain/staking/MsgDeposit"
        result.value = value
        return result
    }
    
    static func oktWithdrawMsg(_ delegator: String, _ amount: L_Coin) -> L_Msg {
        var value = L_Value.init()
        value.delegator_address = delegator
        value.quantity = amount
        
        var result = L_Msg.init()
        result.type = "okexchain/staking/MsgWithdraw"
        result.value = value
        return result
    }
    
    static func oktAddShareMsg(_ delegator: String, _ toVals: Array<String>) -> L_Msg {
        var value = L_Value.init()
        value.delegator_address = delegator
        value.validator_addresses = toVals
        
        var result = L_Msg.init()
        result.type = "okexchain/staking/MsgAddShares"
        result.value = value
        return result
    }
    
    
    static func postData(_ msgs: [L_Msg], _ fee: L_Fee, _ memo: String, _ baseChain: CosmosClass) -> Data {
        guard let oktChain = baseChain as? ChainOkt996Keccak else {
            return Data()
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        
        let chainId = oktChain.chainIdCosmos!
        let accNum = oktChain.lcdAccountInfo["value","account_number"].uInt64Value
        let seqNum = oktChain.lcdAccountInfo["value","sequence"].uInt64Value
        
        let stdMsg = getToSignMsg(chainId, String(accNum), String(seqNum), msgs, fee, memo)
        let toSignData = try! encoder.encode(stdMsg)
        let signatures = genSignatures(toSignData, String(accNum), String(seqNum), baseChain)
        let stdTx = genSignedTx(msgs, fee, memo, signatures!)
        let postTx = L_PostTx.init("sync", stdTx.value)
        return try! encoder.encode(postTx)
    }
    
    
    static func getToSignMsg(_ chainid: String, _ accountNum: String, _ sequenceNum: String, _ msgs: [L_Msg], _ fee: L_Fee, _ memo: String) -> StdSignMsg {
        var stdSignedMsg = StdSignMsg.init()
        stdSignedMsg.chain_id = chainid
        stdSignedMsg.account_number = accountNum
        stdSignedMsg.sequence = sequenceNum
        stdSignedMsg.msgs = msgs
        stdSignedMsg.fee = fee
        stdSignedMsg.memo = memo
        return stdSignedMsg
    }
    
    static func genSignatures(_ toSignData: Data, _ accNum: String, _ seqNum: String, _ baseChain: CosmosClass) -> [L_Signature]? {
        if (baseChain.accountKeyType.pubkeyType == .COSMOS_Secp256k1) {
            let signedData = try! ECDSA.compactsign(toSignData.sha256(), privateKey: baseChain.privateKey!)
            let publicKey = L_PublicKey.init(COSMOS_KEY_TYPE_PUBLIC, baseChain.publicKey!.base64EncodedString())
            let signature = L_Signature.init(publicKey, signedData.base64EncodedString(), accNum, seqNum)
            return [signature]
            
        }  else if (baseChain.accountKeyType.pubkeyType == .ETH_Keccak256) {
            let signedData = try! ECDSA.compactsign(HDWalletKit.Crypto.sha3keccak256(data: toSignData), privateKey: baseChain.privateKey!)
            let publicKey = L_PublicKey.init(ETHERMINT_KEY_TYPE_PUBLIC, baseChain.publicKey!.base64EncodedString())
            let signature = L_Signature.init(publicKey, signedData.base64EncodedString(), accNum, seqNum)
            return [signature]
        }
        return nil
    }
    
    static func genSignedTx(_ msgs: [L_Msg], _ fee: L_Fee, _ memo: String, _ signatures: [L_Signature]) -> L_StdTx {
        let value = L_StdTx.L_Value.init(msgs, fee, signatures, memo)
        return L_StdTx.init(COSMOS_AUTH_TYPE_STDTX, value)
    }
}




public struct StdSignMsg: Codable{
    var chain_id: String?
    var account_number: String?
    var sequence: String?
    var fee: L_Fee?
    var msgs: [L_Msg]?
    var memo: String?
    
    init(chain_id: String? = nil, _ account_number: String? = nil, _ sequence: String? = nil,
         _ fee: L_Fee? = nil, _ msgs: [L_Msg]? = nil, _ memo: String? = nil) {
        self.chain_id = chain_id
        self.account_number = account_number
        self.sequence = sequence
        self.fee = fee
        self.msgs = msgs
        self.memo = memo
    }
}
