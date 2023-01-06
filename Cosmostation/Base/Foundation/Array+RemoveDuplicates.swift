//
//  Array+RemoveDuplicates.swift
//  Cosmostation
//
//  Created by albertopeam on 5/1/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation


extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var elements: [Element] = .init()
        forEach { element in
            if (!elements.contains(element)) {
                elements.append(element)
            }
        }
        return elements
    }
}
