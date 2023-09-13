//
//  BaseSheetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseSheetCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkedImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindLanguage(_ position: Int) {
        titleLabel.text = Language.getLanguages()[position].description
        if (BaseData.instance.getLanguage() == position) {
            checkedImg.isHidden = false
        } else {
            checkedImg.isHidden = true
        }
    }
    
    func onBindAutoPass(_ position: Int) {
        titleLabel.text = AutoPass.getAutoPasses()[position].description
        if (BaseData.instance.getAutoPass() == position) {
            checkedImg.isHidden = false
        } else {
            checkedImg.isHidden = true
        }
    }
    
}
