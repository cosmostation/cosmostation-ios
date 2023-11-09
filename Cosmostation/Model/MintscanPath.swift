//
//  MintscanPath.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/02.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public class MintscanPath {
    var channel: String?
    var port: String?
    
    init(_ channel: String, _ port: String) {
        self.channel = channel
        self.port = port
    }
    
    func getIBCContract() -> String {
        return self.port!.replacingOccurrences(of: "wasm.", with: "")
    }
}
