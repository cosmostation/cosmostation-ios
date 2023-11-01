//
//  AddressBookCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AddressBookCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        logoImg1.image = UIImage.init(named: "chainDefault")
    }
    
    func bindAddressBook(_ book: AddressBook) {
        if let chain = ALLCOSMOSCLASS().filter({ $0.name == book.chainName }).first {
            logoImg1.image = UIImage.init(named: chain.logo1)
        }
        nameLabel.text = book.bookName
        memoLabel.text = book.memo
        addressLabel.text = book.dpAddress
        addressLabel.adjustsFontSizeToFitWidth = true
    }
    
}
