//
//  BundleExtension.swift
//  Cosmostation
//
//  Created by y on 2022/11/25.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

extension Bundle {
    var WALLET_CONNECT_API_KEY: String {
        guard let file = self.path(forResource: "ApiKey", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        return resource["WALLET_CONNECT_API_KEY"] as? String ?? ""
    }
    
    
    var SKIP_V2_IOS: String {
        guard let file = self.path(forResource: "ApiKey", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        return resource["SKIP_V2_IOS"] as? String ?? ""
    }
    
    class func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
