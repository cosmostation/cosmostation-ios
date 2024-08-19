//
//  SelectAddressBookCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/06.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SelectAddressBookCell: UITableViewCell {
    
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookNameLabel.text = ""
        memoLabel.text = ""
        addressLabel.text = ""
    }
    
    func onBindMajorAddressBook(_ toChain: BaseChain, _ book: AddressBook) {
        bookNameLabel.text = book.bookName
        addressLabel.text = book.dpAddress
        memoLabel.text = ""
    }
    
    func onBindBechAddressBook(_ toChain: BaseChain, _ book: AddressBook) {
        bookNameLabel.text = book.bookName
        addressLabel.text = book.dpAddress
        memoLabel.text = book.memo
    }
    
    func onBindEvmAddressBook(_ toChain: BaseChain, _ book: AddressBook) {
        bookNameLabel.text = book.bookName
        addressLabel.text = book.dpAddress
        memoLabel.text = ""
    }
    
}
