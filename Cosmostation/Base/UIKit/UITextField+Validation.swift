//
//  UITextField+Validation.swift
//  Cosmostation
//
//  Created by albertopeam on 28/11/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

extension UITextField {
    /**
     Checks that the text won't contain: `.` or `,` at the begining; duplicated `.` or `,` ;  simultaneous `.` and `,`;  more than `displayDecimal` decimals.
     - Parameter range: The range of characters to be replaced
     - Parameter replacementString: The replacement string for the specified range.
     - Parameter displayDecimal: Max number of decimals supported.
     - Returns: A bool that determines if the replacementString should be applied or not
     */
    func shouldChange(charactersIn range: NSRange, replacementString string: String, displayDecimal: Int16 = 6) -> Bool {
        guard let text = text else {
            return true
        }
        if (text.contains(".") || text.contains(",")) && string.contains(".") && range.length == 0 {
            return false
        }
        if text.count == 0 && string.starts(with: ".") {
            return false
        }
        if (text.contains(",") || text.contains(".")) && string.contains(",") && range.length == 0 {
            return false
        }
        if text.count == 0 && string.starts(with: ",") {
            return false
        }
        if let index = text.range(of: ".")?.upperBound {
            if (text.substring(from: index).count > (displayDecimal - 1) && range.length == 0) {
                return false
            }
        }
        if let index = text.range(of: ",")?.upperBound {
            if (text.substring(from: index).count > (displayDecimal - 1) && range.length == 0) {
                return false
            }
        }
        return true
    }
}
