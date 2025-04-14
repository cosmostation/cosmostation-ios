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
    static let shared = BtcJS()
    
    private var btcJScontext = JSContext()
    
    fileprivate var jsValue: JSValue!
    
    private init() {
        
        // Retrieve the content of bitcoin.js
        let btcJSpath = Bundle.main.path(forResource: "bitcoin", ofType: "js")
        
        if let btcJSpath {
            do {
                let btcJS = try String(contentsOfFile: btcJSpath, encoding: String.Encoding.utf8)
                print("Loaded bitcoin.js")
                
                let textEncoderDecoderPolyfill = """
                class TextEncoder {
                    encode(input) {
                        const encoder = new Uint8Array([...unescape(encodeURIComponent(input))].map(c => c.charCodeAt(0)));
                        return encoder;
                    }
                }
                
                class TextDecoder {
                    decode(input) {
                        return decodeURIComponent(escape(String.fromCharCode(...input)));
                    }
                }
                
                globalThis.TextEncoder = TextEncoder;
                globalThis.btoa = TextEncoder;
                globalThis.TextDecoder = TextDecoder;
                """
                
                btcJScontext?.evaluateScript(textEncoderDecoderPolyfill)
                
                let cryptoPolyfill =
                """
                var globalScope = typeof globalThis !== "undefined" ? globalThis : this;
                
                if (!globalScope.crypto) {
                    Object.defineProperty(globalScope, "crypto", {
                        value: {
                            getRandomValues: function(buffer) {
                                if (!(buffer instanceof Uint8Array)) {
                                    throw new TypeError("Expected Uint8Array");
                                }
                                for (let i = 0; i < buffer.length; i++) {
                                    buffer[i] = Math.floor(Math.random() * 256);
                                }
                                return buffer;
                            },
                            subtle: {
                                digest: async function(algorithm, data) {
                                    if (algorithm.name !== "SHA-256") {
                                        throw new Error("Only SHA-256 is supported in this polyfill.");
                                    }
                                    let buffer = new Uint8Array(data);
                                    let hash = 0;
                                    for (let i = 0; i < buffer.length; i++) {
                                        hash = (hash * 31 + buffer[i]) % 4294967296;
                                    }
                                    return new Uint8Array([hash & 0xFF, (hash >> 8) & 0xFF, (hash >> 16) & 0xFF, (hash >> 24) & 0xFF]).buffer;
                                },
                
                                importKey: async function(format, keyData, algorithm, extractable, keyUsages) {
                                    if (format !== "raw") {
                                        throw new Error("Only raw format is supported in this polyfill.");
                                    }
                                    if (algorithm.name !== "HMAC" || algorithm.hash.name !== "SHA-256") {
                                        throw new Error("Only HMAC-SHA256 is supported in this polyfill.");
                                    }
                                    return { key: keyData, algorithm: algorithm };
                                },
                
                                sign: async function(algorithm, key, data) {
                                    if (algorithm.name !== "HMAC" || algorithm.hash.name !== "SHA-256") {
                                        throw new Error("Only HMAC-SHA256 is supported in this polyfill.");
                                    }
                                    let buffer = new Uint8Array(data);
                                    let keyBuffer = new Uint8Array(key.key);
                                    let hash = 0;
                                    for (let i = 0; i < buffer.length; i++) {
                                        hash = (hash * 37 + buffer[i] * keyBuffer[i % keyBuffer.length]) % 4294967296;
                                    }
                                    return new Uint8Array([hash & 0xFF, (hash >> 8) & 0xFF, (hash >> 16) & 0xFF, (hash >> 24) & 0xFF]).buffer;
                                }
                            }
                        },
                        writable: false,
                        enumerable: false,
                        configurable: false
                    });
                }
                """
                
                btcJScontext?.evaluateScript(cryptoPolyfill)
                
                
                // Evaluate bitcoin.js
                _ = btcJScontext?.evaluateScript(btcJS)
                
            }
            catch {
                print("Unable to load bitcoin.js")
            }
            
        } else {
            print("Unable to find bitcoin.js")
        }
        
    }
    
    func getTxHex(_ txString: String) -> String {
        btcJScontext?.evaluateScript(txString)
        return "\(btcJScontext!.objectForKeyedSubscript("result").call(withArguments: nil)!)"
    }
    
    func callJSValue(key: String = "", param: [Any?]? = nil) -> String {
        jsValue = btcJScontext?.objectForKeyedSubscript(key)
        return "\(jsValue.call(withArguments: param)!)"
    }
    
    func callJSValueToBool(key: String = "", param: [Any?]? = nil) -> Bool {
        jsValue = btcJScontext?.objectForKeyedSubscript(key)
        return jsValue.call(withArguments: param)!.toBool()
    }

}


public enum BtcTxType: String {
    
    case p2wpkh
    case p2pkh
    case p2sh
    case p2tr
    
    var vbyte: Vbytes {
        switch self {
        case .p2wpkh:
            Vbytes(overhead: 11, inputs: 68, output: 31)
            
        case .p2pkh:
            Vbytes(overhead: 10, inputs: 148, output: 34)

        case .p2sh:
            Vbytes(overhead: 10, inputs: 297, output: 32)
            
        case .p2tr:
            Vbytes(overhead: 11, inputs: 58, output: 43)
        }
    }

    struct Vbytes {
        var overhead: Int
        var inputs: Int
        var output: Int
    }

}
