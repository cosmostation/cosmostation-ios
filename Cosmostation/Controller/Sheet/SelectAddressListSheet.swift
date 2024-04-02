//
//  SelectAddressListSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/19/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class SelectAddressListSheet: BaseVC {
    
    @IBOutlet weak var sheetTitle: UILabel!
    @IBOutlet weak var addressStyleSegment: UISegmentedControl!
    @IBOutlet weak var cosmosStyleTableView: UITableView!
    @IBOutlet weak var evmStyleTableView: UITableView!
    
    var fromChain: BaseChain!
    var toChain: BaseChain!
    var sendType: SendAssetType!
    var senderBechAddress: String!
    var senderEvmAddress: String!
    
    var refBechAddresses = Array<RefAddress>()
    var bechAddressBook = Array<AddressBook>()
    var refEvmAddresses = Array<RefAddress>()
    var evmAddressBook = Array<AddressBook>()
    
    var addressListSheetDelegate: SelectAddressListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cosmosStyleTableView.delegate = self
        cosmosStyleTableView.dataSource = self
        cosmosStyleTableView.separatorStyle = .none
        cosmosStyleTableView.register(UINib(nibName: "SelectRefAddressCell", bundle: nil), forCellReuseIdentifier: "SelectRefAddressCell")
        cosmosStyleTableView.register(UINib(nibName: "SelectAddressBookCell", bundle: nil), forCellReuseIdentifier: "SelectAddressBookCell")
        cosmosStyleTableView.sectionHeaderTopPadding = 0
        
        evmStyleTableView.delegate = self
        evmStyleTableView.dataSource = self
        evmStyleTableView.separatorStyle = .none
        evmStyleTableView.register(UINib(nibName: "SelectRefAddressCell", bundle: nil), forCellReuseIdentifier: "SelectRefAddressCell")
        evmStyleTableView.register(UINib(nibName: "SelectAddressBookCell", bundle: nil), forCellReuseIdentifier: "SelectAddressBookCell")
        evmStyleTableView.sectionHeaderTopPadding = 0
        
//        print("sendType ", sendType)
        
        if (sendType == .Only_EVM_Coin || sendType == .Only_EVM_ERC20) {
            //only support EVM address style
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                if (refAddress.chainTag == toChain.tag && refAddress.evmAddress != senderEvmAddress) {
                    refEvmAddresses.append(refAddress)
                }
            }
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if (book.dpAddress.starts(with: "0x") && book.dpAddress != senderEvmAddress) {
                    evmAddressBook.append(book)
                }
            }
            addressStyleSegment.isHidden = true
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            cosmosStyleTableView.isHidden = true
            evmStyleTableView.isHidden = false
            
        } else if (sendType == .Only_Cosmos_Coin || sendType == .Only_Cosmos_CW20) {
            //only support cosmos address style
            BaseData.instance.selectAllRefAddresses().filter {
                $0.bechAddress.starts(with: (toChain as! CosmosClass).bechAccountPrefix! + "1") &&
                $0.bechAddress != senderBechAddress }.forEach { refAddress in
                    if (refBechAddresses.filter { $0.bechAddress == refAddress.bechAddress && $0.accountId == refAddress.accountId }.count == 0) {
                        refBechAddresses.append(refAddress)
                    }
                }
            
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if (book.chainName == toChain.name && !book.dpAddress.starts(with: "0x") && book.dpAddress != senderBechAddress) {
                    bechAddressBook.append(book)
                }
            }
            addressStyleSegment.isHidden = true
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            cosmosStyleTableView.isHidden = false
            evmStyleTableView.isHidden = true
            
        } else if (sendType == .CosmosEVM_Coin) {
            //only support both address style
            BaseData.instance.selectAllRefAddresses().filter {
                $0.bechAddress.starts(with: (toChain as! CosmosClass).bechAccountPrefix! + "1") &&
                $0.bechAddress != senderBechAddress }.forEach { refAddress in
                    if (refBechAddresses.filter { $0.bechAddress == refAddress.bechAddress && $0.accountId == refAddress.accountId }.count == 0) {
                        refBechAddresses.append(refAddress)
                    }
                }
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if (book.chainName == toChain.name && !book.dpAddress.starts(with: "0x") && book.dpAddress != senderBechAddress) {
                    bechAddressBook.append(book)
                }
            }
            
            if (fromChain.tag == toChain.tag) {
                //ibc case not support EVM address style
                BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                    if (refAddress.chainTag == toChain.tag && refAddress.evmAddress != senderEvmAddress) {
                        refEvmAddresses.append(refAddress)
                    }
                }
                BaseData.instance.selectAllAddressBooks().forEach { book in
                    if (book.dpAddress.starts(with: "0x") && book.dpAddress != senderEvmAddress) {
                        evmAddressBook.append(book)
                    }
                }
            }
            addressStyleSegment.isHidden = false
            sheetTitle.isHidden = true
            cosmosStyleTableView.isHidden = false
            evmStyleTableView.isHidden = true
        }
        refEvmAddresses.sort {
            if let account0 = BaseData.instance.selectAccount($0.accountId),
               let account1 = BaseData.instance.selectAccount($1.accountId) {
                return account0.order < account1.order
            }
            return false
        }
        
        refBechAddresses.sort {
            if let account0 = BaseData.instance.selectAccount($0.accountId),
               let account1 = BaseData.instance.selectAccount($1.accountId) {
                return account0.order < account1.order
            }
            return false
        }
        
    }
    
    @IBAction func onClickSegment(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            cosmosStyleTableView.isHidden = false
            evmStyleTableView.isHidden = true
        } else {
            cosmosStyleTableView.isHidden = true
            evmStyleTableView.isHidden = false
        }
    }
}

extension SelectAddressListSheet: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseSheetHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (tableView == cosmosStyleTableView) {
            if (section == 0) {
                view.titleLabel.text = "My Account"
                view.cntLabel.text = String(refBechAddresses.count)
            } else if (section == 1) {
                view.titleLabel.text = "Address Book"
                view.cntLabel.text = String(bechAddressBook.count)
            }
            
        } else if (tableView == evmStyleTableView) {
            if (section == 1) {
               view.titleLabel.text = "My Account"
               view.cntLabel.text = String(refEvmAddresses.count)
           }  else {
               view.titleLabel.text = "Address Book"
               view.cntLabel.text = String(evmAddressBook.count)
           }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == cosmosStyleTableView) {
            if (section == 0) {
                return (refBechAddresses.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (bechAddressBook.count > 0) ? 40 : 0
            }
            
        } else if (tableView == evmStyleTableView) {
            if (section == 0) {
                return (refEvmAddresses.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (evmAddressBook.count > 0) ? 40 : 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == cosmosStyleTableView) {
            if (section == 0) {
                return refBechAddresses.count
            } else if (section == 1) {
                return bechAddressBook.count
            }
        } else if (tableView == evmStyleTableView) {
            if (section == 0) {
                return refEvmAddresses.count
            } else if (section == 1) {
                return evmAddressBook.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == cosmosStyleTableView) {
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"SelectRefAddressCell") as? SelectRefAddressCell
                cell?.onBindBechRefAddress(toChain, refBechAddresses[indexPath.row])
                return cell!
                
            } else if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"SelectAddressBookCell") as? SelectAddressBookCell
                cell?.onBindBechAddressBook(toChain, bechAddressBook[indexPath.row])
                return cell!
            }
            
        } else if (tableView == evmStyleTableView) {
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"SelectRefAddressCell") as? SelectRefAddressCell
                cell?.onBindEvmRefAddress(toChain, refEvmAddresses[indexPath.row])
                return cell!
                
            } else if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"SelectAddressBookCell") as? SelectAddressBookCell
                cell?.onBindEvmAddressBook(toChain, evmAddressBook[indexPath.row])
                return cell!
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == cosmosStyleTableView) {
            if (indexPath.section == 0) {
                let result: [String : Any] = ["address" : refBechAddresses[indexPath.row].bechAddress]
                addressListSheetDelegate?.onAddressSelected(result)
                
            } else if (indexPath.section == 1) {
                let result: [String : Any] = ["address" : bechAddressBook[indexPath.row].dpAddress, "memo" : bechAddressBook[indexPath.row].memo]
                addressListSheetDelegate?.onAddressSelected(result)
            }
        } else if (tableView == evmStyleTableView) {
            if (indexPath.section == 0) {
                let result: [String : Any] = ["address" : refEvmAddresses[indexPath.row].evmAddress]
                addressListSheetDelegate?.onAddressSelected(result)
                
            } else if (indexPath.section == 1) {
                let result: [String : Any] = ["address" : evmAddressBook[indexPath.row].dpAddress, "memo" : evmAddressBook[indexPath.row].memo]
                addressListSheetDelegate?.onAddressSelected(result)
            }
        }
        dismiss(animated: true)
    }
}

protocol SelectAddressListDelegate {
    func onAddressSelected(_ result: Dictionary<String, Any>)
}
