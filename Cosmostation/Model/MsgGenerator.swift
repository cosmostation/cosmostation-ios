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
            value.from_address = WKey.convertAddressEthToCosmos(fromAddress, "ex")
            value.to_address = WKey.convertAddressEthToCosmos(toAddress, "ex")
            let data = try? JSONEncoder().encode(amount)
            do {
                value.amount = try JSONDecoder().decode(AmountType.self, from:data!)
            } catch {
                print(error)
            }
            
            msg.type = OK_MSG_TYPE_TRANSFER
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
            
            msg.type = COSMOS_MSG_TYPE_TRANSFER2
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
    
    
    static func genRefundAtomicSwap(_ from: String, _ swapId: String) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.from = from
        value.swap_id = swapId.uppercased()
        msg.type = KAVA_MSG_TYPE_HTLC_REFUND_SWAP
        msg.value = value
        return msg
    }
    
    
    static func genOkDepositMsg(_ delegator: String, _ coin: Coin) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.delegator_address = delegator;
        value.quantity = coin;
        msg.type = OK_MSG_TYPE_DEPOSIT;
        msg.value = value;
        return msg
    }
    
    static func genOkWithdarwMsg(_ delegator: String, _ coin: Coin) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.delegator_address = delegator;
        value.quantity = coin;
        msg.type = OK_MSG_TYPE_WITHDRAW;
        msg.value = value;
        return msg
    }
    
    static func genOkVote(_ delegator: String, _ toVals: Array<String>) -> Msg {
        var msg = Msg.init()
        var value = Msg.Value.init()
        value.delegator_address = delegator;
        value.validator_addresses = toVals;
        msg.type = OK_MSG_TYPE_DIRECT_VOTE;
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
    
    static func getIrisToSignMsg(_ chain: String, _ accountNum: String, _ sequenceNum: String, _ msgs: Array<Msg>, _ fee: Fee, _ memo: String) -> IrisStdSignMsg {
        var stdSignedMsg = IrisStdSignMsg.init()
        
        stdSignedMsg.chain_id = chain
        stdSignedMsg.account_number = accountNum
        stdSignedMsg.sequence = sequenceNum
        var msgValues: Array<Msg.Value> = Array<Msg.Value>()
        for msg in msgs {
            msgValues.append(msg.value)
        }
        stdSignedMsg.msgs = msgValues
        stdSignedMsg.fee = fee
        stdSignedMsg.memo = memo
        
        return stdSignedMsg
    }
    
    /*
    static func genIovSendTx(_ nonce:Int64, _ fromAddr:String, _ toAddr:String, _ sendCoins: Array<Coin>, _ fee:Fee,  _ memo:String, _ key:WKey.Ed25519Key) -> String {
        let sendAmount = NSDecimalNumber.init(string: sendCoins[0].amount).multiplying(byPowerOf10: -9)
        let interPart = WUtils.getQuotient(sendAmount.stringValue)
        let decimalPart = WUtils.getRemainder(sendAmount.stringValue).multiplying(byPowerOf10: 9)
        
        //Set send coin
        var sendCoin = Coin_Coin.init()
        if (interPart != NSDecimalNumber.zero) {
            sendCoin.whole = interPart.int64Value
        }
        if (decimalPart != NSDecimalNumber.zero) {
            sendCoin.fractional = decimalPart.int64Value
        }
        sendCoin.ticker = IOV_MAIN_DENOM
        
        //Set fee
        var sendFee = Coin_Coin.init()
        sendFee.fractional = WUtils.getRemainder(GAS_FEE_IOV_TRANSFER).multiplying(byPowerOf10: 9).int64Value
        sendFee.ticker = IOV_MAIN_DENOM
        
        //Set FeeInfo
        var feeInfo = Cash_FeeInfo.init()
        feeInfo.payer = WKey.getDatafromDpAddress(fromAddr)!
        feeInfo.fees = sendFee
        
        //Set MetaData
        var metaData = Weave_Metadata.init()
        metaData.schema = 1
        
        var sendMsg = Cash_SendMsg.init()
        sendMsg.source = WKey.getDatafromDpAddress(fromAddr)!
        sendMsg.destination = WKey.getDatafromDpAddress(toAddr)!
        sendMsg.amount = sendCoin
        sendMsg.metadata = metaData
        sendMsg.memo = memo
        
        print("sendMsg \n", sendMsg)
        
        var sendTx = Bnsd_Tx.init()
        sendTx.cashSendMsg = sendMsg
        sendTx.fees = feeInfo
        
        print("sendTx \n", sendTx)
        
        let inSig = getIovInSig(sendTx, nonce)
        print("inSig ", bytesConvertToHexstring(byte: inSig))
        let midSig = Digest.sha512(inSig)
        print("midSig ", bytesConvertToHexstring(byte: midSig))
        let genSig = Ed25519.sign(message: midSig, secretKey: key.key)
        print("genSig ", bytesConvertToHexstring(byte: genSig))
        
        var pubKey = Crypto_PublicKey.init()
        pubKey.ed25519 = Data(bytes: Ed25519.calcPublicKey(secretKey: key.key))
        
        var signature = Crypto_Signature.init()
        signature.ed25519 = Data(genSig)
        
        var std_signature = Sigs_StdSignature.init()
        std_signature.pubkey = pubKey
        std_signature.signature = signature
        std_signature.sequence = nonce
        
        sendTx.signatures = [std_signature]
        
        let sendTxSerial = try? sendTx.serializedData()
        
//        return sendTxSerial!.base64EncodedData()
        
        return sendTxSerial!.base64EncodedString()
//        let result = "0x" + bytesConvertToHexstring(byte: sendTxSerial!.bytes)
//        let result = bytesConvertToHexstring(byte: sendTxSerial!.bytes)
//
//        print("result ", result)
//
//        return result
    }
    
    static func getIovInSig(_ tx:Bnsd_Tx, _ nonce:Int64) -> [UInt8] {
        let chainB: [UInt8] = Array("iov-mainnet".utf8)
        let versionB : [UInt8] = [0, 0xCA, 0xFE, 0]
        let nonceB = byteArray(from: nonce)
        let chainSize:UInt8 = UInt8(chainB.count)
        let chainLenB = byteArray(from: chainSize)
        let txB = try? tx.serializedData().bytes
        
        print("txB ", bytesConvertToHexstring(byte: txB!))
        
        return versionB + chainLenB + chainB + nonceB + txB!
    }
     */
    
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
