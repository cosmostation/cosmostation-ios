//
//  TwoLineButton.swift
//  Cosmostation
//
//  Created by albertopeam on 24/9/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

/// Two lines button
final class TwoLinesButton: UIButton {
    
    convenience init() {
        self.init(type: .system)
    }
    
    /**
     Sets the title in two row format using the respective colors
     
     - Parameter firstLineTitle: title for the first line
     - Parameter firstLineColor: color for the first line
     - Parameter secondLineText: title for the second line
     - Parameter secondLineColor: color for the second line
     - Parameter state: state where the title applies
     */
    func setTitle(firstLineTitle: String, firstLineColor: UIColor?,
                  secondLineText: String, secondLineColor: UIColor?,
                  state: UIControl.State) {
        titleLabel?.numberOfLines = 2
        
        let attributedString = NSMutableAttributedString()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let labelAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: firstLineColor ?? .white,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        attributedString.append(NSAttributedString(string: firstLineTitle, attributes: labelAttribute))
        
        let textAttribute = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: secondLineColor ?? .white,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        attributedString.append(NSAttributedString(string: "\n \(secondLineText)", attributes: textAttribute))
        
        setAttributedTitle(attributedString, for: state)
    }
}
