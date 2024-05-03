//
//  SwitchStyleCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/3/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class SwitchStyleCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var styleImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        rootView.layer.borderWidth = 1
        rootView.layer.borderColor = UIColor.color05.cgColor
    }
    
    override func prepareForReuse() {
        rootView.layer.borderWidth = 1
        rootView.layer.borderColor = UIColor.color05.cgColor
    }
    
    func onBindStyle(_ position: Int) {
        if (position == 0) {
            titleLabel.text = "1. " + NSLocalizedString("style_simple", comment: "")
            msgLabel.text = NSLocalizedString("style_simple_msg", comment: "")
            styleImg.image = UIImage(named: "imgStyleSimple")
            
        } else {
            titleLabel.text = "2. " + NSLocalizedString("style_pro", comment: "")
            msgLabel.text = NSLocalizedString("style_pro_msg", comment: "")
            styleImg.image = UIImage(named: "imgStylePro")
        }
        
        if (position == BaseData.instance.getStyle()) {
            rootView.layer.borderColor = UIColor.white.cgColor
        }
        
    }
    
}
