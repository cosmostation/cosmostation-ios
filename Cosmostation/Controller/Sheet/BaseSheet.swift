//
//  BaseSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseSheet: BaseVC {
    
    @IBOutlet weak var sheetTitle: UILabel!
    @IBOutlet weak var sheetTableView: UITableView!
    
    var sheetType: SheetType?
    var sheetDelegate: BaseSheetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        
        sheetTableView.delegate = self
        sheetTableView.dataSource = self
        sheetTableView.separatorStyle = .none
        sheetTableView.register(UINib(nibName: "BaseSheetCell", bundle: nil), forCellReuseIdentifier: "BaseSheetCell")
        sheetTableView.register(UINib(nibName: "NewAccountCell", bundle: nil), forCellReuseIdentifier: "NewAccountCell")
        sheetTableView.register(UINib(nibName: "SwitchAccountCell", bundle: nil), forCellReuseIdentifier: "SwitchAccountCell")
        sheetTableView.register(UINib(nibName: "SwitchCurrencyCell", bundle: nil), forCellReuseIdentifier: "SwitchCurrencyCell")
        sheetTableView.register(UINib(nibName: "SwitchPriceDisplayCell", bundle: nil), forCellReuseIdentifier: "SwitchPriceDisplayCell")
        sheetTableView.sectionHeaderTopPadding = 0
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
        }
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
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sheetType == .SwitchAccount) {
            let result = BaseSheetResult.init(indexPath.row, String(BaseData.instance.selectAccounts()[indexPath.row].id))
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
}
