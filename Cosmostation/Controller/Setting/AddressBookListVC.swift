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
    
    func onShowEditSheet(_ book: AddressBook) {
        let addressBookSheet = AddressBookSheet(nibName: "AddressBookSheet", bundle: nil)
        addressBookSheet.addressBook = book
        addressBookSheet.bookDelegate = self
        self.onStartSheet(addressBookSheet, 420)
    }
    
    func onDeleteBook(_ book: AddressBook) {
        let deleteAddressBookSheet = DeleteAddressBookSheet(nibName: "DeleteAddressBookSheet", bundle: nil)
        deleteAddressBookSheet.addressBook = book
        deleteAddressBookSheet.deleteDelegate = self
        self.onStartSheet(deleteAddressBookSheet)
    }
}

extension AddressBookListVC: UITableViewDelegate, UITableViewDataSource, AddressBookDelegate, AddressBookDeleteDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBookLsit.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"AddressBookCell") as! AddressBookCell
        let book = addressBookLsit[indexPath.row]
        cell.bindAddressBook(book)
        cell.actionEdit = {
            self.onShowEditSheet(book)
        }
        cell.actionDelete = {
            self.onDeleteBook(book)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = addressBookLsit[indexPath.row]
        onShowEditSheet(book)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let book = addressBookLsit[indexPath.row]
        let edit = UIAction(title: NSLocalizedString("str_edit", comment: ""), image: nil, handler: { _ in
            self.onShowEditSheet(book)
        })
        let delete = UIAction(title: NSLocalizedString("str_delete", comment: ""), image: nil, handler: { _ in
            self.onDeleteBook(book)
        })
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            UIMenu(title: "", children: [edit, delete])
        }
    }

    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? AddressBookCell else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    func onAddressBookUpdated(_ result: Int?) {
        addressBookLsit = BaseData.instance.selectAllAddressBooks()
        tableView.reloadData()
    }
    
    func onDeleted(_ book: AddressBook) {
        BaseData.instance.deleteAddressBook(book.id)
        addressBookLsit = BaseData.instance.selectAllAddressBooks()
        tableView.reloadData()
    }
    
}
