//
//  DeleteAccountSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/17.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class DeleteAccountSheet: BaseVC {
    
    @IBOutlet weak var deleteBtn: BaseRedButton!
    @IBOutlet weak var deleteTitleLabel: UILabel!
    @IBOutlet weak var deleteMsgLabel: UILabel!
    
    var toDeleteAccount: BaseAccount!
    var deleteDelegate: DeleteDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setLocalizedString() {
        deleteTitleLabel.text = String(format: NSLocalizedString("str_delete_account_title", comment: ""), toDeleteAccount.name)
        deleteMsgLabel.text = NSLocalizedString("str_delete_account_msg", comment: "")
        deleteBtn.setTitle(NSLocalizedString("str_delete_account", comment: ""), for: .normal)
    }

    @IBAction func onClickDelete(_ sender: UIButton) {
        deleteDelegate?.onDeleted()
        dismiss(animated: true)
    }
}

protocol DeleteDelegate {
    func onDeleted()
}
