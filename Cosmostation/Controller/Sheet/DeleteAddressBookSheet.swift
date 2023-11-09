//
//  DeleteAddressBookSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class DeleteAddressBookSheet: BaseVC {
    
    @IBOutlet weak var deleteBtn: BaseRedButton!
    @IBOutlet weak var deleteTitleLabel: UILabel!
    @IBOutlet weak var deleteNameLabel: UILabel!
    @IBOutlet weak var deleteAddressLabel: UILabel!
    
    var addressBook: AddressBook!
    var deleteDelegate: AddressBookDeleteDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteNameLabel.text = addressBook.bookName
        deleteAddressLabel.text = addressBook.dpAddress
        deleteAddressLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func setLocalizedString() {
        deleteTitleLabel.text = NSLocalizedString("str_delete_address_book", comment: "")
        deleteBtn.setTitle(NSLocalizedString("str_delete", comment: ""), for: .normal)
    }
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        deleteDelegate?.onDeleted(addressBook)
        dismiss(animated: true)
    }

}

protocol AddressBookDeleteDelegate {
    func onDeleted(_ book: AddressBook)
}

