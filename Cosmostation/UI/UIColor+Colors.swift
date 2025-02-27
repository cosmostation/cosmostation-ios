//
//  UIColor+Colors.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

extension UIColor {
    static var colorPrimary: UIColor {
        UIColor(named: "_primary")!
    }
    static var color01: UIColor {
        UIColor(named: "_color01")!
    }
    static var color02: UIColor {
        UIColor(named: "_color02")!
    }
    static var color03: UIColor {
        UIColor(named: "_color03")!
    }
    static var color04: UIColor {
        UIColor(named: "_color04")!
    }
    static var color05: UIColor {
        UIColor(named: "_color05")!
    }
    static var color06: UIColor {
        UIColor(named: "_color06")!
    }
    static var color07: UIColor {
        UIColor(named: "_color07")!
    }
    static var color08: UIColor {
        UIColor(named: "_color08")!
    }
    static var colorRed: UIColor {
        UIColor(named: "_colorRed")!
    }
    static var colorGreen: UIColor {
        UIColor(named: "_colorGreen")!
    }
    static var colorBg: UIColor {
        UIColor(named: "_colorBg")!
    }
    static var colorNativeSegwit: UIColor {
        UIColor(named: "_btcNativeSegwit")!
    }
    static var colorBtcTaproot: UIColor {
        UIColor(named: "_btcTaproot")!
    }
    static var colorBabylon: UIColor {
        UIColor.init(hexString: "#FF7B17")
    }

    public convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255
                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        return nil
    }
}

