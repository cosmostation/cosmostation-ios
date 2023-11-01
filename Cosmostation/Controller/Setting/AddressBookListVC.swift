//
//  AddressBookListVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class AddressBookListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: BaseButton!
    @IBOutlet weak var emptyView: UIView!
    
    var addressBookLsit = [AddressBook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AddressBookCell", bundle: nil), forCellReuseIdentifier: "AddressBookCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        addressBookLsit = BaseData.instance.selectAllAddressBooks()
        if (addressBookLsit.count > 0) {
            tableView.isHidden = false
        } else {
            emptyView.isHidden = false
        }
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("str_address_book_list", comment: "")
        addBtn.setTitle(NSLocalizedString("str_address_book_add", comment: ""), for: .normal)
    }
    
    @IBAction func onClickAdd(_ sender: UIButton) {
        let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
        addressBookSheet.bookDelegate = self
        self.onStartSheet(addressBookSheet, 420)
    }

}

extension AddressBookListVC: UITableViewDelegate, UITableViewDataSource, AddressBookDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBookLsit.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AddressBookCell") as! AddressBookCell
        cell.bindAddressBook(addressBookLsit[indexPath.row])
        return cell
    }
    
    func onAddressBookUpdated(_ result: Int?) {
        print("onAddressBookUpdated ", result)
    }
}
