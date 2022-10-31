//
//  MsgGenerator.swift
//  Cosmostation
//
//  Created by yongjoo on 09/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import CryptoSwift
import HDWalletKit

class MsgGenerator {
    
    static func genGetSendMsg(_ fromAddress: String, _ toAddress: String, _ amount: Array<Coin>, _ chain: ChainType) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        if (chain == ChainType.OKEX_MAIN) {
            value.from_address = WKey.convertEvmToBech32(fromAddress, "ex")
            value.to_address = WKey.convertEvmToBech32(toAddress, "ex")
            let data = try? JSONEncoder().encode(amount)
            do {
                value.amount = try JSONDecoder().decode(AmountType.self, from:data!)
            } catch {
                print(error)
            }
            
            msg.type = "okexchain/token/MsgTransfer"
            msg.value = value
            
        } else {
            value.from_address = fromAddress
            value.to_address = toAddress
            let data = try? JSONEncoder().encode(amount)
            do {
                value.amount = try JSONDecoder().decode(AmountType.self, from:data!)
            } catch {
                print(error)
            }
            
            msg.type = "cosmos-sdk/MsgSend"
            msg.value = value
        }
        return msg
    }
    
    
    static func genBnbCreateHTLCSwapMsg(_ fromChain: ChainType, _ toChain: ChainType, _ fromAccount: Account, _ toAccount: Account,
                                        _ sendCoin: Array<Coin>, _ timeStamp: Int64, _ randomNumberHash: String, _ pkey: PrivateKey) -> BinanceMessage {
        let sendAmount = NSDecimalNumber.init(string: sendCoin[0].amount).multiplying(byPowerOf10: 8)
        if (fromChain == ChainType.BINANCE_MAIN) {
            var bnb_duputy = ""
            var kava_duputy = ""
            if (sendCoin[0].denom == TOKEN_HTLC_BINANCE_BNB) {
                bnb_duputy = BINANCE_MAIN_BNB_DEPUTY
                kava_duputy = KAVA_MAIN_BNB_DEPUTY
            } else if (sendCoin[0].denom  == TOKEN_HTLC_BINANCE_BTCB) {
                bnb_duputy = BINANCE_MAIN_BTCB_DEPUTY
                kava_duputy = KAVA_MAIN_BTCB_DEPUTY
            } else if (sendCoin[0].denom  == TOKEN_HTLC_BINANCE_XRPB) {
                bnb_duputy = BINANCE_MAIN_XRPB_DEPUTY
                kava_duputy = KAVA_MAIN_XRPB_DEPUTY
            } else if (sendCoin[0].denom  == TOKEN_HTLC_BINANCE_BUSD) {
                bnb_duputy = BINANCE_MAIN_BUSD_DEPUTY
                kava_duputy = KAVA_MAIN_BUSD_DEPUTY
            }
            return BinanceMessage.createHtlc(toAddress: bnb_duputy,
                                              otherFrom: kava_duputy,
                                              otherTo: toAccount.account_address,
                                              timestamp: timeStamp,
                                              randomNumberHash: randomNumberHash,
                                              sendAmount: sendAmount.int64Value,
                                              sendDenom: sendCoin[0].denom,
                                              expectedIncom: sendAmount.stringValue + ":" + sendCoin[0].denom,
                                              heightSpan: 407547,
                                              crossChain: true,
                                              memo: SWAP_MEMO_CREATE,
                                              privateKey: pkey,
                                              signerAddress: fromAccount.account_address,
                                              sequence: Int(fromAccount.account_sequence_number),
                                              accountNumber: Int(fromAccount.account_account_numner),
                                              chainId: BaseData.instance.getChainId(fromChain))
            
        } else {
            var bnb_duputy = ""
            var kava_duputy = ""
            if (sendCoin[0].denom == TOKEN_HTLC_BINANCE_TEST_BNB) {
                bnb_duputy = BINANCE_TEST_BNB_DEPUTY
                kava_duputy = KAVA_TEST_BNB_DEPUTY
            } else if (sendCoin[0].denom  == TOKEN_HTLC_BINANCE_TEST_BTC) {
                bnb_duputy = BINANCE_TEST_BTC_DEPUTY
                kava_duputy = KAVA_TEST_BTC_DEPUTY
            }
            return BinanceMessage.createHtlc(toAddress: bnb_duputy,
                                             otherFrom: kava_duputy,
                                             otherTo: toAccount.account_address,
                                             timestamp: timeStamp,
                                             randomNumberHash: randomNumberHash,
                                             sendAmount: sendAmount.int64Value,
                                             sendDenom: sendCoin[0].denom,
                                             expectedIncom: sendAmount.stringValue + ":" + sendCoin[0].denom,
                                             heightSpan: 407547,
                                             crossChain: true,
                                             memo: SWAP_MEMO_CREATE,
                                             privateKey: pkey,
                                             signerAddress: fromAccount.account_address,
                                             sequence: Int(fromAccount.account_sequence_number),
                                             accountNumber: Int(fromAccount.account_account_numner),
                                             chainId: BaseData.instance.getChainId(fromChain))
        }
    }
    
    static func genBnbClaimHTLCSwapMsg(_ claimer: Account, _ randomNumber: String, _ swapId: String, _ pkey: PrivateKey, _ chainId: String) -> BinanceMessage {
        return BinanceMessage.claimHtlc(randomNumber: randomNumber,
                                        swapId: swapId,
                                        memo: SWAP_MEMO_CLAIM,
                                        privateKey: pkey,
                                        signerAddress: claimer.account_address,
                                        sequence: Int(claimer.account_sequence_number),
                                        accountNumber: Int(claimer.account_account_numner),
                                        chainId: chainId)
        
    }
    
    
    static func genOkDepositMsg(_ delegator: String, _ coin: Coin) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.delegator_address = WKey.convertEvmToBech32(delegator, "ex")
        value.quantity = coin;
        msg.type = "okexchain/staking/MsgDeposit";
        msg.value = value;
        return msg
    }
    
    static func genOkWithdarwMsg(_ delegator: String, _ coin: Coin) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.delegator_address = WKey.convertEvmToBech32(delegator, "ex")
        value.quantity = coin;
        msg.type = "okexchain/staking/MsgWithdraw";
        msg.value = value;
        return msg
    }
    
    static func genOkVote(_ delegator: String, _ toVals: Array<String>) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.delegator_address = WKey.convertEvmToBech32(delegator, "ex")
        value.validator_addresses = toVals;
        msg.type = "okexchain/staking/MsgAddShares";
        msg.value = value;
        return msg
    }

    
    static func genSignedTx(_ msgs: Array<Msg>, _ fee: Fee, _ memo: String, _ signatures: Array<Signature>) -> StdTx {
        let stdTx = StdTx.init()
        let value = StdTx.Value.init()
        
        value.msg = msgs
        value.fee = fee
        value.signatures = signatures
        value.memo = memo
        
        stdTx.type = COSMOS_AUTH_TYPE_STDTX
        stdTx.value = value
        
        return stdTx
    }
    
    static func genTrustSignedTx(_ msgs: Array<Msg>, _ fee: Fee, _ memo: String, _ signatures: Array<TrustSignature>) -> TrustStdTx {
        let stdTx = TrustStdTx.init()
        let value = TrustStdTx.Value.init()
        
        value.msg = msgs
        value.fee = fee
        value.signatures = signatures
        value.memo = memo
        
        stdTx.type = COSMOS_AUTH_TYPE_STDTX
        stdTx.value = value
        
        return stdTx
    }
    
    static func getToSignMsg(_ chain: String, _ accountNum: String, _ sequenceNum: String, _ msgs: Array<Msg>, _ fee: Fee, _ memo: String) -> StdSignMsg {
        var stdSignedMsg = StdSignMsg.init()
        
        stdSignedMsg.chain_id = chain
        stdSignedMsg.account_number = accountNum
        stdSignedMsg.sequence = sequenceNum
        stdSignedMsg.msgs = msgs
        stdSignedMsg.fee = fee
        stdSignedMsg.memo = memo
        
        return stdSignedMsg
    }
    
    static func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    static func bytesConvertToHexstring(byte : [UInt8]) -> String {
        var string = ""

        for val in byte {
            //getBytes(&byte, range: NSMakeRange(i, 1))
            string = string + String(format: "%02X", val)
        }

        return string
    }
    
}


//protocol UIntToBytesConvertable {
//    var toBytes: [Byte] { get }
//}
//
//extension UIntToBytesConvertable {
//    func toByteArr<T: Integer>(endian: T, count: Int) -> [Byte] {
//        var _endian = endian
//        let bytePtr = withUnsafePointer(to: &_endian) {
//            $0.withMemoryRebound(to: Byte.self, capacity: count) {
//                UnsafeBufferPointer(start: $0, count: count)
//            }
//        }
//        return [Byte](bytePtr)
//    }
//}
//
//extension UInt16: UIntToBytesConvertable {
//    var toBytes: [Byte] {
//        return toByteArr(endian: self.littleEndian,
//                         count: MemoryLayout<UInt16>.size)
//    }
//}
//
//extension UInt32: UIntToBytesConvertable {
//    var toBytes: [Byte] {
//        return toByteArr(endian: self.littleEndian,
//                         count: MemoryLayout<UInt32>.size)
//    }
//}
//
//extension UInt64: UIntToBytesConvertable {
//    var toBytes: [Byte] {
//        return toByteArr(endian: self.littleEndian,
//                         count: MemoryLayout<UInt64>.size)
//    }
//}
