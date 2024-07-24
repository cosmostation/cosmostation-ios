//
//  SearchBarWithTopPadding.swift
//  Cosmostation
//
//  Created by 차소민 on 7/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

final class SearchBarWithTopPadding: UIView {
    let searchBar = UISearchBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(searchBar)
        
        searchBar.frame = .init(x: 0, y: 10, width: frame.width, height: 44)
        
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = .white
        searchBar.barTintColor = .clear
        searchBar.searchTextField.textColor = .color01
        searchBar.searchTextField.font = .fontSize14Bold
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
