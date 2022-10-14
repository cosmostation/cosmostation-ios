//
//  String+Split.swift
//  Cosmostation
//
//  Created by albertopeam on 16/10/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

extension String {
    /// Splits the string using the separator "." and returns the last component or empty if not exists
    var splitByDotAndLast: String {
        self.split(separator: ".").last.map(String.init) ?? ""
    }
}
