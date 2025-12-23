//
//  AptosJS.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import JavaScriptCore
import SwiftyJSON

open class AptosJS {
    static let shared = AptosJS()
    
    private var aptosJScontext = JSContext()
    
    fileprivate var jsValue: JSValue!
    
    private init() {
        
        let aptosJSpath = Bundle.main.path(forResource: "aptos", ofType: "js")
        
        if let aptosJSpath {
            do {
                let aptosJS = try String(contentsOfFile: aptosJSpath, encoding: String.Encoding.utf8)
                print("Loaded aptos.js")
                
                _ = aptosJScontext?.evaluateScript(aptosJS)
                
            } catch {
                print("Unable to load aptos.js")
            }
            
        } else {
            print("Unable to find aptos.js")
        }
    }
    
    func callJSValue(key: String = "", param: [Any?]? = nil) -> String {
        jsValue = aptosJScontext?.objectForKeyedSubscript(key)
        return "\(jsValue.call(withArguments: param)!)"
    }
    
    func callJSValueAsync(
        key: String,
        param: [Any]? = nil,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard
            let context = aptosJScontext,
            let fn = context.objectForKeyedSubscript(key)
        else {
            completion(nil, NSError(domain: "JSCore", code: -1, userInfo: [NSLocalizedDescriptionKey: "JS function not found"]))
            return
        }

        guard let result = fn.call(withArguments: param ?? []) else {
            completion(nil, NSError(domain: "JSCore", code: -2, userInfo: [NSLocalizedDescriptionKey: "JS returned nil"]))
            return
        }

        let onFulfilledBlock: @convention(block) (JSValue?) -> Void = { value in
            completion(value?.toString(), nil)
        }

        let onRejectedBlock: @convention(block) (JSValue?) -> Void = { errorValue in
            let message = errorValue?.toString() ?? "JS Promise rejected"
            let error = NSError(domain: "JSCore", code: -3, userInfo: [NSLocalizedDescriptionKey: message])
            completion(nil, error)
        }

        guard
            let fulfilled = JSValue(object: onFulfilledBlock, in: context),
            let rejected = JSValue(object: onRejectedBlock, in: context)
        else {
            completion(nil, NSError(domain: "JSCore", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to create JS callbacks"]))
            return
        }

        result.invokeMethod("then", withArguments: [fulfilled, rejected])
    }
}
