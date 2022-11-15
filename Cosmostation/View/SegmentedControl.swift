//
//  SegmentedControl.swift
//  Cosmostation
//
//  Created by albertopeam on 14/11/22.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

final class SegmentedControl: UISegmentedControl {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        setTitleTextAttributes([.foregroundColor: UIColor.font04], for: .normal)
    }
}
