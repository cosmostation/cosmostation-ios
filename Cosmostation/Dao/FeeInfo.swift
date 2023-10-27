//
//  FeeInfo.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct FeeInfo {
    var title = ""
    var msg = ""
    var FeeDatas = Array<FeeData>()
    
    init(_ data: String?) {
        if (data == nil) { return }
        for rawData in data!.split(separator: ",") {
            self.FeeDatas.append(FeeData.init(String(rawData).trimmingCharacters(in: .whitespaces)))
        }
    }
}

public struct FeeData {
    var denom: String?
    var gasRate: NSDecimalNumber?
    
    init(_ data: String?) {
        if let range = data?.range(of: "[0-9]*\\.?[0-9]*", options: .regularExpression) {
            let rawGasRate = String(data![range])
            let denomIndex = data!.index(data!.startIndex, offsetBy: rawGasRate.count)
            
            self.denom = String(data![denomIndex...])
            self.gasRate = NSDecimalNumber.init(string: rawGasRate)
        }
    }
}
