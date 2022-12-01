//
//  SelectContractTokenCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class SelectContractTokenCell: UITableViewCell {
    
    @IBOutlet weak var coinImg: UIImageView!
    @IBOutlet weak var coinTitle: UILabel!
    @IBOutlet weak var coinSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        coinSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func onBindToken(_ token: MintscanToken, _ selectedList: Array<String>) {
        if let assetImgeUrl = token.assetImg() {
            coinImg.af_setImage(withURL: assetImgeUrl)
            coinTitle.text = token.symbol
        }
        coinSwitch.isOn = selectedList.contains(token.address)
    }
}
