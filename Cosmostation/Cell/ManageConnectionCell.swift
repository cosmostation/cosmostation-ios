//
//  ManageConnectionCell.swift
//  Cosmostation
//
//  Created by y on 2022/06/12.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit


class ManageConnectionCell: UITableViewCell {
    @IBOutlet weak var url: UILabel!
    
    var action: (() -> Void)? = nil
    @IBAction func onClick(_ sender: UIButton) {
        action?()
    }
}
