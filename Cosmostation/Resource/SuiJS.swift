//
//  SuiJS.swift
//  Cosmostation
//
//  Created by 권혁준 on 4/1/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation
import JavaScriptCore
import SwiftyJSON

open class SuiJS {
    static let shared = SuiJS()
    
    private var suiJScontext = JSContext()
    
    fileprivate var jsValue: JSValue!
    
    private init() {
        
        let suiJSpath = Bundle.main.path(forResource: "sui", ofType: "js")
        
        if let suiJSpath {
            do {
                let suiJS = try String(contentsOfFile: suiJSpath, encoding: String.Encoding.utf8)
                print("Loaded sui.js")
                
                _ = suiJScontext?.evaluateScript(suiJS)
                
            } catch {
                print("Unable to load sui.js")
            }
            
        } else {
            print("Unable to find sui.js")
        }
    }
    
    func callJSValue(key: String, param: [Any]? = nil) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            callJSValueAsync(key: key, param: param) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    func callJSValueAsync(
        key: String,
        param: [Any]? = nil,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard let result = suiJScontext?.objectForKeyedSubscript(key).call(withArguments: param ?? [])
        else {
            completion(nil, NSError(domain: "JSCore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to call JS function"]))
            return
        }
        
        let onFulfilled: @convention(block) (JSValue?) -> Void = {
            completion($0?.toString(), nil)
        }
        
        let onRejected: @convention(block) (JSValue?) -> Void = {
            completion(nil, NSError(
                domain: "JSCore",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: $0?.toString() ?? "JS Promise rejected"]
            ))
        }
        
        result.invokeMethod("then", withArguments: [
            JSValue(object: onFulfilled, in: suiJScontext) as Any,
            JSValue(object: onRejected, in: suiJScontext) as Any
        ])
    }
}
