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
    @IBOutlet weak var editBtn: UIButton!
    
    var actionEdit: (() -> Void)? = nil
    var actionDelete: (() -> Void)? = nil

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
        if (book.dpAddress.starts(with: "0x")) {
            memoLabel.isHidden = true
            
        } else {
            memoLabel.isHidden = false
            if let chain = All_IBC_Chains().filter({ $0.name == book.chainName }).first {
                logoImg1.image = UIImage.init(named: chain.logo1)
            }
        }
        nameLabel.text = book.bookName
        memoLabel.text = book.memo
        addressLabel.text = book.dpAddress
        addressLabel.adjustsFontSizeToFitWidth = true
        
        editBtn.showsMenuAsPrimaryAction = true
        let edit = UIAction(title: NSLocalizedString("str_edit", comment: ""), image: nil, handler: { _ in
            self.actionEdit?()
        })
        let delete = UIAction(title: NSLocalizedString("str_delete", comment: ""), image: nil, handler: { _ in
            self.actionDelete?()
        })
        editBtn.menu = UIMenu(title: "",
                              image: nil,
                              identifier: nil,
                              options: .displayInline,
                              children: [edit, delete])
    }
    
}
