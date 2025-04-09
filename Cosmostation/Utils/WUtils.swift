//
//  WUtils.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import UIKit
import Web3Core
import BigInt

public class WUtils {
    
    static func timeStringToDate(_ input: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let result = dateFormatter.date(from: input) {
            return result
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let result = dateFormatter.date(from: input) {
            return result
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        if let result = dateFormatter.date(from: input) {
            return result
        }
        return nil
    }

    static func timeInt64ToDate(_ input: Int64) -> Date? {
        return Date.init(milliseconds: Int(input))
    }

    static func getGapTime(_ date: Date) -> String {
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        var gapTime = Int(Date().timeIntervalSince(date))
        if (gapTime > 0) {
            if gapTime < minute {
                return "\(gapTime) seconds ago"
            } else if gapTime < hour {
                return "\(gapTime / minute) minutes ago"
            } else if gapTime < day {
                return "\(gapTime / hour) hours ago"
            } else {
                return "\(gapTime / day) days ago"
            }

        } else {
            gapTime = gapTime * -1
            if gapTime < day {
                return "H-\(gapTime / hour)"
            } else {
                return "D-\(gapTime / day)"
            }
        }
    }
    
    static func getGapTime(_ seconds: Double) -> String {
        let date = Date(timeIntervalSince1970: seconds)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.string(from: date)
    }
    
    static func getRemainingTime(_ date: Date) -> String {
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        var gapTime = Int(Date().timeIntervalSince(date))
        gapTime = gapTime * -1
        
        if gapTime < minute {
            return "\(gapTime) seconds left"
        } else if gapTime < hour {
            return "\(gapTime / minute) minutes left"
        } else if gapTime < day {
            return "\(gapTime / hour) hours left"
        } else {
            return "\(gapTime / day) days left"
        }
    }
    
    //for okt ("0.1"  -> "0.10000000000000000")
    static func getFormattedNumber(_ amount: NSDecimalNumber, _ dpPoint:Int16) -> String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = Int(dpPoint)
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal

        let formatted = nf.string(from: amount)?.replacingOccurrences(of: ",", with: "" )
        return formatted!
    }
    
    
    static func assetValue(_ geckoId: String?, _ amount: String?, _ decimals: Int16) -> NSDecimalNumber {
        let price = BaseData.instance.getPrice(geckoId)
        let amount = NSDecimalNumber(string: amount)
        return price.multiplying(by: amount).multiplying(byPowerOf10: -decimals, withBehavior: handler3Down)
    }
    
    static func getNumberFormatter(_ divider: Int) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = divider
        nf.maximumFractionDigits = divider
        return nf
    }

    static func getDpAttributedString(_ dpString: String, _ divider: Int, _ font: UIFont?) -> NSMutableAttributedString? {
        if (font == nil) { return nil }
        let endIndex    = dpString.index(dpString.endIndex, offsetBy: -divider)
        let preString   = dpString[..<endIndex]
        let postString  = dpString[endIndex...]
        let preAttrs    = [NSAttributedString.Key.font : font]
        let postAttrs   = [NSAttributedString.Key.font : font!.withSize(CGFloat(Int(Double(font!.pointSize) * 0.85)))]

        let attributedString1 = NSMutableAttributedString(string:String(preString), attributes:preAttrs as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:String(postString), attributes:postAttrs as [NSAttributedString.Key : Any])
        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    
    static func checkIBCrecipientableChains(_ fromChain: BaseChain, _ toSendDenom: String) -> [BaseChain] {
        let allIbcChains = ALLCHAINS().filter({ $0.isTestnet == false })
        
        var result = [BaseChain]()
        result.append(fromChain)
        
        //IBC Coin should add backward path if wallet support fromchain
        if toSendDenom.starts(with: "ibc/"),
           let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.chain == fromChain.apiName && $0.denom == toSendDenom }).first,
           let sendable = allIbcChains.filter({ $0.apiName == msAsset.ibc_info?.counterparty?.chain }).first {
            if !result.contains(where: { $0.apiName == sendable.apiName }) {
                result.append(sendable)
            }
        }
        
        //IBC & Eureka_IBC
        //Native & IBC & Cw20 & Erc20 check forward path if wallet support tochain
        BaseData.instance.mintscanAssets?.forEach { msAsset in
            if msAsset.ibc_info?.counterparty?.chain == fromChain.apiName,
               msAsset.ibc_info?.counterparty?.getDenom == toSendDenom,
               let sendable = allIbcChains.filter({ $0.apiName == msAsset.chain }).first {
                if !result.contains(where: { $0.apiName == sendable.apiName }) {
                    result.append(sendable)
                }
            }
        }
        
        //Eureka_IBC
        //Erc20 token shoud check backward path if possible
        //ex: Atom(Erc20) on ethereum should back to cosmos
        if toSendDenom.starts(with: "0x"),
           let msToken = BaseData.instance.mintscanErc20Tokens?.filter({ $0.chainName == fromChain.apiName && $0.address == toSendDenom }).first,
           let sendable = allIbcChains.filter({ $0.apiName == msToken.ibc_info?.counterparty?.chain }).first {
            if !result.contains(where: { $0.apiName == sendable.apiName }) {
                result.append(sendable)
            }
        }
        
        //Eureka_IBC
        //Native & IBC Coin check forward path to Ethereum chains
        //ex: Atom on Cosmos can go etheruem
        BaseData.instance.mintscanErc20Tokens?.forEach { msToken in
            if msToken.ibc_info?.counterparty?.chain == fromChain.apiName,
               msToken.ibc_info?.counterparty?.getDenom == toSendDenom,
               let sendable = allIbcChains.filter({ $0.apiName == msToken.chainName }).first {
                if !result.contains(where: { $0.apiName == sendable.apiName }) {
                    result.append(sendable)
                }
            }
        }
        
        result.sort {
            if ($0.name == fromChain.name) { return true }
            if ($1.name == fromChain.name) { return false }
            if ($0.name == "Cosmos") { return true }
            if ($1.name == "Cosmos") { return false }
            if ($0.name == "Ethereum") { return true }
            if ($1.name == "Ethereum") { return false }
            if ($0.name == "Osmosis") { return true }
            if ($1.name == "Osmosis") { return false }
            return false
        }
        return result
    }
    
    static func getMintscanPath(_ fromChain: BaseChain, _ toChain: BaseChain, _ toSendDenom: String) -> MintscanPath? {
//        var result: MintscanPath?
        
        //Check IBC Coin backward case
        if let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.chain == fromChain.apiName && $0.denom == toSendDenom }).first,
           msAsset.ibc_info?.counterparty?.chain == toChain.apiName {
            print("BACKWRAD ", msAsset.ibc_info)
            return MintscanPath.init(.BACKWRAD, msAsset.ibc_info)
        }
        
        //IBC & Eureka_IBC
        //Check Native & IBC & Cw20 & Erc20 Coin forward case
        if let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.chain == toChain.apiName &&
            $0.ibc_info?.counterparty?.chain == fromChain.apiName &&
            $0.ibc_info?.counterparty?.getDenom == toSendDenom }).first {
            print("FORWARD ", msAsset.ibc_info)
            return MintscanPath.init(.FORWARD, msAsset.ibc_info)
        }
        
        //IBC Eureka
        //Check Erc20 token backward case
        //ex: Atom(Erc20) on ethereum should back to cosmos
        if let msToken = BaseData.instance.mintscanErc20Tokens?.filter({ $0.chainName == fromChain.apiName &&
            $0.address == toSendDenom &&
            $0.ibc_info?.counterparty?.chain == toChain.apiName }).first {
            print("EUREKA BACKWRAD ", msToken.ibc_info)
            return MintscanPath.init(.BACKWRAD, msToken.ibc_info)
        }
        
        //IBC Eureka
        //Check Native & IBC Coin forward case
        //ex: Atom on Cosmos can go etheruem
        if let msToken = BaseData.instance.mintscanErc20Tokens?.filter({ $0.chainName == toChain.apiName &&
            $0.ibc_info?.counterparty?.chain == fromChain.apiName &&
            $0.ibc_info?.counterparty?.getDenom == toSendDenom }).first {
            print("EUREKA FORWARD ", msToken.ibc_info)
            return MintscanPath.init(.FORWARD, msToken.ibc_info)
        }
        return nil
    }
    
    
    static func isValidBechAddress(_ chain: BaseChain, _ address: String?) -> Bool {
        if (address?.isEmpty == true) {
            return false
        }
        if (address!.starts(with: "0x")) {
            //TODO
            return false
        }
        guard let _ = try? Bech32().decode(address!) else {
            return false
        }
        
        if (!address!.starts(with: chain.bechAccountPrefix! + "1")) {
            return false
        }
        return true
        
    }
    
    static func isValidEvmAddress(_ address: String?) -> Bool {
        if (address?.isEmpty == true) {
            return false
        }
        if let evmAddess = EthereumAddress.init(address!) {
            return true
        }
        return false
    }
    
    static func isValidSuiAdderss(_ address: String?) -> Bool {
        let suiPattern = "^(0x)[A-Fa-f0-9]{64}$"
        return address?.range(of: suiPattern, options: .regularExpression ) != nil
    }
    
    static func generateQrCode(_ content: String)  -> CIImage? {
        let data = content.data(using: String.Encoding.ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let scaleUp = CGAffineTransform(scaleX: 8, y: 8)
        if let qrCodeImage = (filter?.outputImage?.transformed(by: scaleUp)) {
            return qrCodeImage
        }
        return nil
    }
}

extension Date {
    
    var hourAfter6UInt64: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 21600).rounded())
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var StringmillisecondsSince1970:String {
        return String((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var Stringmilli3MonthAgo:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0) - TimeInterval(7776000000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension String {
    func hexToNSDecimal() -> NSDecimalNumber {
        if (self.isEmpty) { return NSDecimalNumber.zero }
        return NSDecimalNumber(string: String(BigUInt(self.stripHexPrefix(), radix: 16) ?? "0"))
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func hexToString() -> String? {
        if (self.isEmpty) { return "0" }
        return String(BigUInt(self.stripHexPrefix(), radix: 16) ?? "0")
    }
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else { return nil }
        return data
    }
    
    func removingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func addABIPrefix() -> String {
        return "0000000000000000000000000000000000000000000000000000000000000020" + self
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = "#".endIndex
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UILabel {
    func setLineSpacing(text: String, font: UIFont?, alignment: NSTextAlignment? = .left) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.alignment = alignment!
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? UIFont.systemFont(ofSize: 12),
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        self.attributedText = attributedText
    }
}

extension Encodable {
    public var encoded: Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try! encoder.encode(self)
    }
    public var encodedString: String {
        return String(data: encoded, encoding: .utf8)!
    }
}


extension Cosmos_Base_V1beta1_Coin {
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: amount)
    }
    
    init (_ denom: String, _ amount: String) {
        self.denom = denom
        self.amount = amount
    }
    
    init (_ denom: String, _ amount: NSDecimalNumber) {
        self.denom = denom
        self.amount = amount.stringValue
    }
}


extension Cosmos_Base_V1beta1_DecCoin {
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
    }
    
    func getdAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: amount).multiplying(byPowerOf10: -18, withBehavior: handler18Down)
    }
}

/// Use when HTTP Request is successful but receives an error message as a result
enum EmptyDataError: Error {
    case error(message: String)
}


extension UIImageView {
    func setMonikerImg(_ chain: BaseChain, _ opAddress: String) {
        if chain.getChainListParam()["reported_validators"].arrayValue.contains(where: { $0.stringValue == opAddress }) {
            self.image = UIImage(named: "iconFake")
        } else {
            self.sd_setImage(with: chain.monikerImg(opAddress), placeholderImage: UIImage(named: "validatorDefault"))
        }
    }
}
