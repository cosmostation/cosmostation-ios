//
//  RoundedPaddingLabel.swift
//  Cosmostation
//
//  Created by 차소민 on 7/10/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

final class RoundedPaddingLabel: PaddingLabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
