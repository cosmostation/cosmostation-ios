//
//  BaseSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseSheet: BaseVC, UISearchBarDelegate {
    
    @IBOutlet weak var sheetTitle: UILabel!
    @IBOutlet weak var sheetSearchBar: UISearchBar!
    @IBOutlet weak var sheetTableView: UITableView!
    
    var sheetType: SheetType?
    var sheetDelegate: BaseSheetDelegate?
    
    var targetChain: CosmosClass!
    var swapChains = Array<JSON>()
    var swapAssets = Array<JSON>()
    var searchList = Array<JSON>()
    var swapBalance = Array<Cosmos_Base_V1beta1_Coin>()
    
    var feeDatas = Array<FeeData>()
    var validators = Array<Cosmos_Staking_V1beta1_Validator>()
    var searchValidators = Array<Cosmos_Staking_V1beta1_Validator>()
    var delegations = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var delegation: Cosmos_Staking_V1beta1_DelegationResponse!
    var cosmosChainList = Array<CosmosClass>()
    var nameservices = Array<NameService>()
    
    var senderAddress: String!
    var refAddresses = Array<RefAddress>()
    var addressBook = Array<String>()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        
        sheetSearchBar.backgroundImage = UIImage()
        sheetSearchBar.delegate = self
        
        sheetTableView.delegate = self
        sheetTableView.dataSource = self
        sheetTableView.separatorStyle = .none
        sheetTableView.register(UINib(nibName: "BaseSheetCell", bundle: nil), forCellReuseIdentifier: "BaseSheetCell")
        sheetTableView.register(UINib(nibName: "BaseMsgSheetCell", bundle: nil), forCellReuseIdentifier: "BaseMsgSheetCell")
        sheetTableView.register(UINib(nibName: "SwitchAccountCell", bundle: nil), forCellReuseIdentifier: "SwitchAccountCell")
        sheetTableView.register(UINib(nibName: "SwitchCurrencyCell", bundle: nil), forCellReuseIdentifier: "SwitchCurrencyCell")
        sheetTableView.register(UINib(nibName: "SwitchPriceDisplayCell", bundle: nil), forCellReuseIdentifier: "SwitchPriceDisplayCell")
        sheetTableView.register(UINib(nibName: "SelectSwapChainCell", bundle: nil), forCellReuseIdentifier: "SelectSwapChainCell")
        sheetTableView.register(UINib(nibName: "SelectSwapAssetCell", bundle: nil), forCellReuseIdentifier: "SelectSwapAssetCell")
        
        sheetTableView.register(UINib(nibName: "SelectFeeCoinCell", bundle: nil), forCellReuseIdentifier: "SelectFeeCoinCell")
        sheetTableView.register(UINib(nibName: "SelectValidatorCell", bundle: nil), forCellReuseIdentifier: "SelectValidatorCell")
        sheetTableView.register(UINib(nibName: "SelectNameServiceCell", bundle: nil), forCellReuseIdentifier: "SelectNameServiceCell")
        sheetTableView.register(UINib(nibName: "SelectRefAddressCell", bundle: nil), forCellReuseIdentifier: "SelectRefAddressCell")
        sheetTableView.register(UINib(nibName: "SelectBepRecipientCell", bundle: nil), forCellReuseIdentifier: "SelectBepRecipientCell")
        sheetTableView.sectionHeaderTopPadding = 0
        
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
//        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapDismiss.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapDismiss)
        
//        print("senderAddress ", senderAddress)
//        print("targetChain ", targetChain.accountPrefix)
//        
//        let ref = BaseData.instance.selectAllRefAddresses()
//        print("ref ", ref.count)
//        
//        ref.forEach { refAddress in
//            print("refAddress ", refAddress.chainTag, "  ", refAddress.dpAddress)
//        }
        
 
    }
    
    func updateTitle() {
        if (sheetType == .SelectCreateAccount) {
            sheetTitle.text = NSLocalizedString("title_create_account", comment: "")
            
        } else if (sheetType == .SwitchAccount) {
            sheetTitle.text = NSLocalizedString("title_select_account", comment: "")
            
        } else if (sheetType == .SwitchLanguage) {
            sheetTitle.text = NSLocalizedString("title_select_language", comment: "")
            
        } else if (sheetType == .SwitchCurrency) {
            sheetTitle.text = NSLocalizedString("title_select_currency", comment: "")
            
        } else if (sheetType == .SwitchPriceColor) {
            sheetTitle.text = NSLocalizedString("str_price_change_color", comment: "")
            
        } else if (sheetType == .SwitchAutoPass) {
            sheetTitle.text = NSLocalizedString("str_autopass", comment: "")
            
        } else if (sheetType == .SelectSwapInputChain) {
            sheetTitle.text = NSLocalizedString("title_select_input_chain", comment: "")
            sheetSearchBar.isHidden = false
            searchList = swapChains
            
        } else if (sheetType == .SelectSwapOutputChain) {
            sheetTitle.text = NSLocalizedString("title_select_output_chain", comment: "")
            sheetSearchBar.isHidden = false
            searchList = swapChains
            
        } else if (sheetType == .SelectSwapInputAsset) {
            sheetTitle.text = NSLocalizedString("title_select_input_asset", comment: "")
            sheetSearchBar.isHidden = false
            searchList = swapAssets
            
        } else if (sheetType == .SelectSwapOutputAsset) {
            sheetTitle.text = NSLocalizedString("title_select_output_asset", comment: "")
            sheetSearchBar.isHidden = false
            searchList = swapAssets
            
        } else if (sheetType == .SelectSwapSlippage) {
            sheetTitle.text = NSLocalizedString("title_select_slippage", comment: "")
            
        } else if (sheetType == .SelectDelegatedAction || sheetType == .SelectUnbondingAction) {
            sheetTitle.text = NSLocalizedString("title_select_options", comment: "")
            
        } else if (sheetType == .SelectFeeCoin) {
            sheetTitle.text = NSLocalizedString("str_select_coin_for_fee", comment: "")
            
        } else if (sheetType == .SelectValidator) {
            sheetTitle.text = NSLocalizedString("str_select_validators", comment: "")
            sheetSearchBar.isHidden = false
            searchValidators = validators
            
        } else if (sheetType == .SelectUnStakeValidator) {
            sheetTitle.text = NSLocalizedString("str_select_validators", comment: "")
            delegations = targetChain.cosmosDelegations
            delegations.forEach { delegation in
                if let validator = targetChain.cosmosValidators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                    validators.append(validator)
                }
            }
            
        } else if (sheetType == .SelectRecipientChain) {
            sheetTitle.text = NSLocalizedString("title_select_recipient_chain", comment: "")
            
        } else if (sheetType == .SelectRecipientAddress) {
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                if (refAddress.dpAddress.starts(with: targetChain.accountPrefix!) &&
                    refAddress.dpAddress != senderAddress) {
                    refAddresses.append(refAddress)
                }
            }
        } else if (sheetType == .SelectNameServiceAddress) {
            sheetTitle.text = String(format: NSLocalizedString("title_select_nameservice", comment: ""), nameservices[0].name ?? "")
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            sheetTitle.text = NSLocalizedString("str_recipient_address", comment: "")
        }
        
    }
    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sheetSearchBar.text = ""
        sheetSearchBar.endEditing(true)
        if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            searchList = swapChains
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset) {
            searchList = swapAssets
        } else if (sheetType == .SelectValidator) {
            searchValidators = validators
        }
        sheetTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            searchList = searchText.isEmpty ? swapChains : swapChains.filter { json in
                return json["chain_name"].stringValue.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset) {
            searchList = searchText.isEmpty ? swapAssets : swapAssets.filter { json in
                return json["symbol"].stringValue.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        } else if (sheetType == .SelectValidator) {
            searchValidators = searchText.isEmpty ? validators : validators.filter { validator in
                return validator.description_p.moniker.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        sheetTableView.reloadData()
    }
}


extension BaseSheet: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (sheetType == .SelectRecipientAddress) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseSheetHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (sheetType == .SelectRecipientAddress) {
            if (section == 0) {
                view.titleLabel.text = "My Account"
                view.cntLabel.text = String(refAddresses.count)
            } else {
                view.titleLabel.text = "Address Book"
                view.cntLabel.text = String(addressBook.count)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (sheetType == .SelectRecipientAddress) {
            if (section == 0) {
                return (refAddresses.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (addressBook.count > 0) ? 40 : 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sheetType == .SelectCreateAccount) {
            return 3
            
        } else if (sheetType == .SwitchAccount) {
            return BaseData.instance.selectAccounts().count
            
        } else if (sheetType == .SwitchLanguage) {
            return Language.getLanguages().count
            
        } else if (sheetType == .SwitchCurrency) {
            return Currency.getCurrencys().count
            
        } else if (sheetType == .SwitchPriceColor) {
            return 2
            
        } else if (sheetType == .SwitchAutoPass) {
            return AutoPass.getAutoPasses().count
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            return searchList.count
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset) {
            return searchList.count
            
        } else if (sheetType == .SelectSwapSlippage) {
            
        } else if (sheetType == .SelectDelegatedAction) {
            return 4
            
        } else if (sheetType == .SelectUnbondingAction) {
            return 1
            
        } else if (sheetType == .SelectFeeCoin) {
            return feeDatas.count
            
        } else if (sheetType == .SelectValidator) {
            return searchValidators.count
            
        } else if (sheetType == .SelectUnStakeValidator) {
            return validators.count
            
        } else if (sheetType == .SelectRecipientChain) {
            return cosmosChainList.count
            
        } else if (sheetType == .SelectRecipientAddress) {
            if (section == 0) {
                return refAddresses.count
            } else {
                return addressBook.count
            }
            
        } else if (sheetType == .SelectNameServiceAddress) {
            return nameservices.count
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            return cosmosChainList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (sheetType == .SelectCreateAccount) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseMsgSheetCell") as? BaseMsgSheetCell
            cell?.onBindCreate(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchAccount) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchAccountCell") as? SwitchAccountCell
            cell?.onBindAccount(BaseData.instance.selectAccounts()[indexPath.row])
            return cell!
            
        } else if (sheetType == .SwitchLanguage) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindLanguage(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchCurrency) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCurrencyCell") as? SwitchCurrencyCell
            cell?.onBindCurrency(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchPriceColor) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchPriceDisplayCell") as? SwitchPriceDisplayCell
            cell?.onBindPriceDisplay(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchAutoPass) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindAutoPass(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectSwapChainCell") as? SelectSwapChainCell
            cell?.onBindChain(searchList[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset)  {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectSwapAssetCell") as? SelectSwapAssetCell
            cell?.onBindAsset(targetChain, searchList[indexPath.row], swapBalance)
            return cell!
            
        } else if (sheetType == .SelectSwapSlippage) {
            
        } else if (sheetType == .SelectDelegatedAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseMsgSheetCell") as? BaseMsgSheetCell
            cell?.onBindDelegate(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectUnbondingAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseMsgSheetCell") as? BaseMsgSheetCell
            cell?.onBindUndelegate(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectFeeCoin) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectFeeCoinCell") as? SelectFeeCoinCell
            cell?.onBindFeeCoin(targetChain, feeDatas[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectValidator) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectValidatorCell") as? SelectValidatorCell
            cell?.onBindValidator(targetChain, searchValidators[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectUnStakeValidator) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectValidatorCell") as? SelectValidatorCell
            cell?.onBindUnstakeValidator(targetChain, validators[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectRecipientChain) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectSwapChainCell") as? SelectSwapChainCell
            cell?.onBindCosmosChain(cosmosChainList[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectRecipientAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectRefAddressCell") as? SelectRefAddressCell
            if (indexPath.section == 0) {
                cell?.onBindRefAddress(refAddresses[indexPath.row])
            } else {
                
            }
            return cell!
            
        } else if (sheetType == .SelectNameServiceAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectNameServiceCell") as? SelectNameServiceCell
            cell?.onBindNameservice(nameservices[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectBepRecipientCell") as? SelectBepRecipientCell
            cell?.onBindBepRecipient(cosmosChainList[indexPath.row])
            return cell!
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sheetType == .SwitchAccount) {
            let result = BaseSheetResult.init(indexPath.row, String(BaseData.instance.selectAccounts()[indexPath.row].id))
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectDelegatedAction) {
            let result = BaseSheetResult.init(indexPath.row, delegation.delegation.validatorAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            let result = BaseSheetResult.init(indexPath.row, searchList[indexPath.row]["chain_id"].stringValue)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset)  {
            let result = BaseSheetResult.init(indexPath.row, searchList[indexPath.row]["denom"].stringValue)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectValidator) {
            let result = BaseSheetResult.init(indexPath.row, searchValidators[indexPath.row].operatorAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectUnStakeValidator) {
            let result = BaseSheetResult.init(indexPath.row, validators[indexPath.row].operatorAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectRecipientChain) {
            let result = BaseSheetResult.init(indexPath.row, cosmosChainList[indexPath.row].chainId)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectRecipientAddress) {
            let result = BaseSheetResult.init(indexPath.row, refAddresses[indexPath.row].dpAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            print("SelectBepRecipientAddress ", indexPath.row)
            let chain = cosmosChainList[indexPath.row]
            if (chain is ChainBinanceBeacon) {
                let availableAmount = chain.lcdBalanceAmount(chain.stakeDenom)
                let fee = NSDecimalNumber(string: BNB_BEACON_BASE_FEE)
                if (availableAmount.compare(fee).rawValue < 0) {
                    onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                    dismiss(animated: true)
                }
                
            } else {
                let availableAmount = chain.balanceAmount(chain.stakeDenom)
                let fee = NSDecimalNumber(string: KAVA_BASE_FEE)
                if (availableAmount.compare(fee).rawValue < 0) {
                    onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                    dismiss(animated: true)
                }
            }
            let result = BaseSheetResult.init(indexPath.row, chain.address)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else {
            sheetDelegate?.onSelectedSheet(sheetType, BaseSheetResult.init(indexPath.row, nil))
        }
        dismiss(animated: true)
    }
    
}


protocol BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult)
}

public struct BaseSheetResult {
    var position: Int?
    var param: String?
    
    init(_ position: Int? = nil, _ param: String? = nil) {
        self.position = position
        self.param = param
    }
}

public enum SheetType: Int {
    case SelectCreateAccount = 0
    
    case SwitchAccount = 1
    case SwitchLanguage = 2
    case SwitchCurrency = 3
    case SwitchPriceColor = 4
    case SwitchAutoPass = 5
    
    case SelectSwapInputChain = 6
    case SelectSwapOutputChain = 7
    case SelectSwapInputAsset = 8
    case SelectSwapOutputAsset = 9
    case SelectSwapSlippage = 10
    
    case SelectDelegatedAction = 11
    case SelectUnbondingAction = 12
    
    case SelectFeeCoin = 13
    case SelectValidator = 14
    case SelectUnStakeValidator = 15
    case SelectRecipientChain = 16
    case SelectRecipientAddress = 17
    case SelectNameServiceAddress = 18
    case SelectBepRecipientAddress = 19
}
