//
//  SolanaJS.swift
//  Cosmostation
//
//  Created by 권혁준 on 8/25/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import JavaScriptCore
import SwiftyJSON

open class SolanaJS {
    static let shared = SolanaJS()
    
    private var solanaJScontext = JSContext()
    
    fileprivate var jsValue: JSValue!
    
    private init() {
        
        let solanaJSpath = Bundle.main.path(forResource: "solana", ofType: "js")
        
        if let solanaJSpath {
            do {
                let solanaJS = try String(contentsOfFile: solanaJSpath, encoding: String.Encoding.utf8)
                print("Loaded solana.js")
                
                _ = solanaJScontext?.evaluateScript(solanaJS)
                
            } catch {
                print("Unable to load solana.js")
            }
            
        } else {
            print("Unable to find solana.js")
        }
    }
    
    func overwriteProgramTx(_ overwriteProgramTxHex: String) -> String {
        solanaJScontext?.evaluateScript(overwriteProgramTxHex)
        return "\(solanaJScontext!.objectForKeyedSubscript("overwriteComputeBudgetProgramFunction").call(withArguments: nil)!)"
    }
    
    func callJSValue(key: String = "", param: [Any?]? = nil) -> String {
        jsValue = solanaJScontext?.objectForKeyedSubscript(key)
        return "\(jsValue.call(withArguments: param)!)"
    }
    
    func callJSValueToBool(key: String = "", param: [Any?]? = nil) -> Bool {
        jsValue = solanaJScontext?.objectForKeyedSubscript(key)
        return jsValue.call(withArguments: param)!.toBool()
    }
}

