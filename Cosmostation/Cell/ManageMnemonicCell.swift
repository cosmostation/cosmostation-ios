//
//  ManageMnemonicCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/04/29.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class ManageMnemonicCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var walletsCntLabel: UILabel!
    @IBOutlet weak var wordsCntLabel: UILabel!
    @IBOutlet weak var importedDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ word: MWords) {
        nameLabel.text = word.getName()
        walletsCntLabel.text = String(word.getLinkedWalletCnt())
        wordsCntLabel.text = String(word.getWordsCnt())
        importedDataLabel.text = word.getImportDate()
    }
    
}
