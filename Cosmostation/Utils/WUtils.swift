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
    
    static func getMintscanPath(_ fromChain: BaseChain, _ toChain: BaseChain, _ denom: String) -> MintscanPath? {
        let msAsset = BaseData.instance.mintscanAssets?.filter({ $0.denom?.lowercased() == denom.lowercased() }).first
        var msToken: MintscanToken?
        if let tokenInfo = fromChain.getGrpcfetcher()?.mintscanCw20Tokens.filter({ $0.address == denom }).first {
            msToken = tokenInfo
        }
        var result: MintscanPath?
        BaseData.instance.mintscanAssets?.forEach { asset in
            if (msAsset != nil) {
                if (asset.chain == fromChain.apiName &&
                    asset.beforeChain(fromChain.apiName) == toChain.apiName &&
                    asset.denom?.lowercased() == denom.lowercased()) {
                    result = MintscanPath.init(asset.channel!, asset.port!)
                    return
                }
                if (asset.chain == toChain.apiName &&
                    asset.beforeChain(toChain.apiName) == fromChain.apiName &&
                    asset.counter_party?.denom?.lowercased() == denom.lowercased()) {
                    result = MintscanPath.init(asset.counter_party!.channel!, asset.counter_party!.port!)
                    return
                }

            } else if (msToken != nil) {
                if (asset.chain == toChain.apiName &&
                    asset.beforeChain(toChain.apiName) == fromChain.apiName &&
                    asset.counter_party?.denom?.lowercased() == msToken?.address!.lowercased()) {
                    result = MintscanPath.init(asset.counter_party!.channel!, asset.counter_party!.port!)
                    return
                }
            }
        }
        return result
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
}
