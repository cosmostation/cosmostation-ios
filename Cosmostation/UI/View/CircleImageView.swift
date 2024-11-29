//
//  CircleImageView.swift
//  Cosmostation
//
//  Created by 차소민 on 11/29/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

final class CircleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
