//
//  Threading.swift
//  Cosmostation
//
//  Created by albertopeam on 26/12/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

//TODO: Task vs DispatchQueue
//TODO: doc
func runOnBackground<T>(background: @escaping () throws -> T, runOnMain: @escaping (T) -> Void) throws {
    Task {
        let result = try background()
        await MainActor.run { runOnMain(result) }
    }
}
