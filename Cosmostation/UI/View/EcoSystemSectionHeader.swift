//
//  EcoSystemSectionHeader.swift
//  Cosmostation
//
//  Created by 차소민 on 12/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class EcoSystemSectionHeader: UICollectionReusableView {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .color01
        label.font = UIFont.fontSize12Bold
        label.sizeToFit()
        return label
    }()
    var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .color02
        label.font = UIFont.fontSize12Bold
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(countLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 18).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        
        countLabel.topAnchor.constraint(equalTo: self.titleLabel.topAnchor).isActive = true
        countLabel.leftAnchor.constraint(equalTo: self.titleLabel.rightAnchor, constant: 4).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
