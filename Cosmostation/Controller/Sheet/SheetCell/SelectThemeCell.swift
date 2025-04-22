//
//  SelectThemeCell.swift
//  Cosmostation
//
//  Created by 차소민 on 4/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class SelectThemeCell: UITableViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var themeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        rootView.clipsToBounds = true
        rootView.layer.cornerRadius = 12
        rootView.layer.borderWidth = 1
        rootView.layer.borderColor = UIColor.color07.cgColor
        rootView.backgroundColor = .color08
    }
    
    override func prepareForReuse() {
        rootView.clipsToBounds = true
        rootView.layer.cornerRadius = 12
        rootView.layer.borderWidth = 1
        rootView.layer.borderColor = UIColor.color07.cgColor
        rootView.backgroundColor = .color08
    }

    func onBindTheme(_ position: Int) {
        if (position == 0) {
            titleLabel.text = "1. Dark Theme"
            descriptionLabel.text = "Softly, calmly. Dive deeper with Dark Theme"
            themeImageView.image = UIImage(named: "imgThemeDark")

        } else {
            titleLabel.text = "2. Cosmic Theme"
            descriptionLabel.text = "Like a scene from space — a new view every time"
            themeImageView.image = UIImage(named: "imgThemeCosmic")

        }
        
        if (position == BaseData.instance.getTheme()) {
            rootView.layer.borderColor = UIColor.white.cgColor
        } else {
            rootView.layer.borderColor = UIColor.color07.cgColor
        }
    }

}
