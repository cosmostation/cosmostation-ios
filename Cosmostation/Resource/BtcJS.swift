//
//  BtcJS.swift
//  Cosmostation
//
//  Created by 차소민 on 9/6/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import JavaScriptCore
import SwiftyJSON

open class BtcJS {
    private var btcJScontext = JSContext()
    
    fileprivate var key: String!
    fileprivate var jsValue: JSValue!
    var test: String!
    
    
    init(_ key: String = "") {
        
        self.key = key
        
        // Retrieve the content of bitcoin.js
        let btcJSpath = Bundle.main.path(forResource: "bitcoin", ofType: "js")
        
        if let btcJSpath {
            do {
                let btcJS = try String(contentsOfFile: btcJSpath, encoding: String.Encoding.utf8)
                print("Loaded bitcoin.js")
                
                // Evaluate bitcoin.js
                _ = btcJScontext?.evaluateScript(btcJS)
                                
                // Reference functions
                jsValue = btcJScontext?.objectForKeyedSubscript(key)
            }
            catch {
                print("Unable to load bitcoin.js")
            }
            
        } else {
            print("Unable to find bitcoin.js")
        }
        
    }
    
    open func getTxHex(_ txString: String) -> String {
        btcJScontext?.evaluateScript(txString)
        return "\(btcJScontext!.objectForKeyedSubscript("result").call(withArguments: nil)!)"
    }
    
    open func callJSValue(param: [Any?]? = nil) -> String {
        return "\(jsValue.call(withArguments: param)!)"
    }
    
    open func callJSValueToBool(param: [Any?]? = nil) -> Bool {
        return jsValue.call(withArguments: param)!.toBool()
    }

}


public enum BtcTxType: String {
    
    case p2wpkh
    case p2pkh
    case p2sh
    
    var vbyte: Vbytes {
        switch self {
        case .p2wpkh:
            Vbytes(overhead: 11, inputs: 68, output: 31)
            
        case .p2pkh:
            Vbytes(overhead: 10, inputs: 148, output: 34)

        case .p2sh:
            Vbytes(overhead: 10, inputs: 297, output: 32)
        }
    }

    struct Vbytes {
        var overhead: Int
        var inputs: Int
        var output: Int
    }

}
