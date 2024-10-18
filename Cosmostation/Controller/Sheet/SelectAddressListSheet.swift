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
    @IBOutlet weak var majorStyleTableView: UITableView!
    @IBOutlet weak var cosmosStyleTableView: UITableView!
    @IBOutlet weak var evmStyleTableView: UITableView!
    
    var fromChain: BaseChain!
    var toChain: BaseChain!
    var sendType: SendAssetType!
    
    var refMajorAddresses = Array<RefAddress>()
    var majorAddressBook = Array<AddressBook>()
    var refBechAddresses = Array<RefAddress>()
    var bechAddressBook = Array<AddressBook>()
    var refEvmAddresses = Array<RefAddress>()
    var evmAddressBook = Array<AddressBook>()
    
    var addressListSheetDelegate: SelectAddressListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        majorStyleTableView.delegate = self
        majorStyleTableView.dataSource = self
        majorStyleTableView.separatorStyle = .none
        majorStyleTableView.register(UINib(nibName: "SelectRefAddressCell", bundle: nil), forCellReuseIdentifier: "SelectRefAddressCell")
        majorStyleTableView.register(UINib(nibName: "SelectAddressBookCell", bundle: nil), forCellReuseIdentifier: "SelectAddressBookCell")
        majorStyleTableView.sectionHeaderTopPadding = 0
        
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
        
        let senderMajorAddress = fromChain.mainAddress
        let senderBechAddress = fromChain.bechAddress
        let senderEvmAddress = fromChain.evmAddress
        
        var tempRefBechAddresses = [RefAddress]()
        
        
        if (sendType == .SUI_COIN || sendType == .SUI_NFT) {
            //only support sui address style
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                if (refAddress.chainTag == toChain.tag && refAddress.bechAddress != senderMajorAddress) {
                    refMajorAddresses.append(refAddress)
                }
            }
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if (WUtils.isValidSuiAdderss(book.dpAddress) && book.dpAddress != senderMajorAddress) {
                    majorAddressBook.append(book)
                }
            }
            
            addressStyleSegment.isHidden = true
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            majorStyleTableView.isHidden = false
            cosmosStyleTableView.isHidden = true
            evmStyleTableView.isHidden = true
            
        } else if (sendType == .BTC_COIN) {
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                
                if toChain.isTestnet {
                    if (refAddress.chainTag.contains("bitcoin") && (refAddress.chainTag.contains("_T")) && refAddress.bechAddress != senderMajorAddress) {
                        refMajorAddresses.append(refAddress)
                    }

                } else {
                    if (refAddress.chainTag.contains("bitcoin") && !(refAddress.chainTag.contains("_T")) && refAddress.bechAddress != senderMajorAddress) {
                        refMajorAddresses.append(refAddress)
                    }
                }
            }
            
            
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if toChain.isTestnet {
                    if (book.chainName.lowercased().contains("bitcoin") && book.chainName.lowercased().contains("testnet") && book.dpAddress != senderMajorAddress) {
                        majorAddressBook.append(book)
                    }

                } else {
                    if (book.chainName.lowercased().contains("bitcoin") && !book.chainName.lowercased().contains("testnet") && book.dpAddress != senderMajorAddress) {
                        majorAddressBook.append(book)
                    }
                }
            }
            
            addressStyleSegment.isHidden = true
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            majorStyleTableView.isHidden = false
            cosmosStyleTableView.isHidden = true
            evmStyleTableView.isHidden = true

            
        } else if (sendType == .EVM_COIN || sendType == .EVM_ERC20) {
            //only support EVM address style
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                if (refAddress.chainTag == toChain.tag && refAddress.evmAddress != senderEvmAddress) {
                    refEvmAddresses.append(refAddress)
                }
            }
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if (WUtils.isValidEvmAddress(book.dpAddress) && book.dpAddress != senderEvmAddress) {
                    evmAddressBook.append(book)
                }
            }
            addressStyleSegment.isHidden = true
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            majorStyleTableView.isHidden = true
            cosmosStyleTableView.isHidden = true
            evmStyleTableView.isHidden = false
            
        } else if (sendType == .COSMOS_COIN || sendType == .COSMOS_WASM) {
            //only support cosmos address style
            BaseData.instance.selectAllRefAddresses().filter {
                $0.bechAddress.starts(with: toChain.bechAccountPrefix! + "1") &&
                $0.bechAddress != senderBechAddress }.forEach { refAddress in
                    if (tempRefBechAddresses.filter { $0.bechAddress == refAddress.bechAddress && $0.accountId == refAddress.accountId }.count == 0) {
                        tempRefBechAddresses.append(refAddress)
                    }
                }
            
            BaseData.instance.selectAllAddressBooks().forEach { book in
                if (book.chainName == toChain.name && !book.dpAddress.starts(with: "0x") && book.dpAddress != senderBechAddress) {
                    bechAddressBook.append(book)
                }
            }
            addressStyleSegment.isHidden = true
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            majorStyleTableView.isHidden = true
            cosmosStyleTableView.isHidden = false
            evmStyleTableView.isHidden = true
            
        } else if (sendType == .COSMOS_EVM_MAIN_COIN) {
            //support both address style
            BaseData.instance.selectAllRefAddresses().filter {
                $0.bechAddress.starts(with: toChain.bechAccountPrefix! + "1") &&
                $0.bechAddress != senderBechAddress }.forEach { refAddress in
                    if (tempRefBechAddresses.filter { $0.bechAddress == refAddress.bechAddress && $0.accountId == refAddress.accountId }.count == 0) {
                        tempRefBechAddresses.append(refAddress)
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
                    if (WUtils.isValidEvmAddress(book.dpAddress) && book.dpAddress != senderEvmAddress) {
                        evmAddressBook.append(book)
                    }
                }
            }
            addressStyleSegment.isHidden = false
            sheetTitle.isHidden = true
            majorStyleTableView.isHidden = true
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
        
        let allBaseChain = ALLCHAINS()
        let hideLegacy = BaseData.instance.getHideLegacy()
        if (hideLegacy) {
            tempRefBechAddresses.forEach { refAddress in
                if (allBaseChain.filter { $0.tag == refAddress.chainTag && $0.isDefault == true }.count > 0) {
                    refBechAddresses.append(refAddress)
                }
            }
        } else {
            refBechAddresses = tempRefBechAddresses
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
        if (tableView == majorStyleTableView) {
            if (section == 0) {
                view.titleLabel.text = "My Account"
                view.cntLabel.text = String(refMajorAddresses.count)
            } else if (section == 1) {
                view.titleLabel.text = "Address Book"
                view.cntLabel.text = String(majorAddressBook.count)
            }
            
        } else if (tableView == cosmosStyleTableView) {
            if (section == 0) {
                view.titleLabel.text = "My Account"
                view.cntLabel.text = String(refBechAddresses.count)
            } else if (section == 1) {
                view.titleLabel.text = "Address Book"
                view.cntLabel.text = String(bechAddressBook.count)
            }
            
        } else if (tableView == evmStyleTableView) {
            if (section == 0) {
               view.titleLabel.text = "My Account"
               view.cntLabel.text = String(refEvmAddresses.count)
            } else if (section == 1) {
               view.titleLabel.text = "Address Book"
               view.cntLabel.text = String(evmAddressBook.count)
           }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView == majorStyleTableView) {
            if (section == 0) {
                return (refMajorAddresses.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (majorAddressBook.count > 0) ? 40 : 0
            }
            
        } else if (tableView == cosmosStyleTableView) {
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
        if (tableView == majorStyleTableView) {
            if (section == 0) {
                return refMajorAddresses.count
            } else if (section == 1) {
                return majorAddressBook.count
            }
            
        } else if (tableView == cosmosStyleTableView) {
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
        if (tableView == majorStyleTableView) {
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"SelectRefAddressCell") as? SelectRefAddressCell
                cell?.onBindMajorRefAddress(toChain, refMajorAddresses[indexPath.row])
                return cell!
                
            } else if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"SelectAddressBookCell") as? SelectAddressBookCell
                cell?.onBindMajorAddressBook(toChain, majorAddressBook[indexPath.row])
                return cell!
            }
            
        } else if (tableView == cosmosStyleTableView) {
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
        if (tableView == majorStyleTableView) {
            if (indexPath.section == 0) {
                let result: [String : Any] = ["address" : refMajorAddresses[indexPath.row].bechAddress]
                addressListSheetDelegate?.onAddressSelected(result)
                
            } else if (indexPath.section == 1) {
                let result: [String : Any] = ["address" : majorAddressBook[indexPath.row].dpAddress, "memo" : majorAddressBook[indexPath.row].memo]
                addressListSheetDelegate?.onAddressSelected(result)
            }
        } else if (tableView == cosmosStyleTableView) {
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
