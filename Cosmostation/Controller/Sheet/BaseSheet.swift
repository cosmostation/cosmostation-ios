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
    
    var swapChains = Array<JSON>()
    var swapAssets = Array<JSON>()
    var searchList = Array<JSON>()
    var swapBalance = Array<Cosmos_Base_V1beta1_Coin>()
    var swapBalanceChain: CosmosClass!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        
        sheetSearchBar.backgroundImage = UIImage()
        sheetSearchBar.delegate = self
        
        sheetTableView.delegate = self
        sheetTableView.dataSource = self
        sheetTableView.separatorStyle = .none
        sheetTableView.register(UINib(nibName: "BaseSheetCell", bundle: nil), forCellReuseIdentifier: "BaseSheetCell")
        sheetTableView.register(UINib(nibName: "NewAccountCell", bundle: nil), forCellReuseIdentifier: "NewAccountCell")
        sheetTableView.register(UINib(nibName: "SwitchAccountCell", bundle: nil), forCellReuseIdentifier: "SwitchAccountCell")
        sheetTableView.register(UINib(nibName: "SwitchCurrencyCell", bundle: nil), forCellReuseIdentifier: "SwitchCurrencyCell")
        sheetTableView.register(UINib(nibName: "SwitchPriceDisplayCell", bundle: nil), forCellReuseIdentifier: "SwitchPriceDisplayCell")
        sheetTableView.register(UINib(nibName: "SelectSwapChainCell", bundle: nil), forCellReuseIdentifier: "SelectSwapChainCell")
        sheetTableView.register(UINib(nibName: "SelectSwapAssetCell", bundle: nil), forCellReuseIdentifier: "SelectSwapAssetCell")
        sheetTableView.sectionHeaderTopPadding = 0
        
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
//        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapDismiss.cancelsTouchesInView = false
//        view.addGestureRecognizer(tapDismiss)
    }
    
    func updateTitle() {
        if (sheetType == .NewAccountType) {
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
        }
        sheetTableView.reloadData()
    }
}


extension BaseSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sheetType == .NewAccountType) {
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
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (sheetType == .NewAccountType) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewAccountCell") as? NewAccountCell
            cell?.onBindView(indexPath.row)
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
            cell?.onBindAsset(swapBalanceChain, searchList[indexPath.row], swapBalance)
            return cell!
            
        } else if (sheetType == .SelectSwapSlippage) {
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sheetType == .SwitchAccount) {
            let result = BaseSheetResult.init(indexPath.row, String(BaseData.instance.selectAccounts()[indexPath.row].id))
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            let result = BaseSheetResult.init(indexPath.row, searchList[indexPath.row]["chain_id"].stringValue)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset)  {
            let result = BaseSheetResult.init(indexPath.row, searchList[indexPath.row]["denom"].stringValue)
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
    case NewAccountType = 0
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
}
