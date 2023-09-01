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
        sheetTableView.register(UINib(nibName: "NewAccountCell", bundle: nil), forCellReuseIdentifier: "NewAccountCell")
        sheetTableView.register(UINib(nibName: "SelectAccountCell", bundle: nil), forCellReuseIdentifier: "SelectAccountCell")
        sheetTableView.sectionHeaderTopPadding = 0
    }
    
    func updateTitle() {
        if (sheetType == .SelectNewAccount) {
            sheetTitle.text = NSLocalizedString("title_create_account", comment: "")
        }
    }

}


extension BaseSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sheetType == .SelectNewAccount) {
            return 3
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (sheetType == .SelectNewAccount) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NewAccountCell") as? NewAccountCell
            cell?.onBindView(indexPath.row)
            return cell!
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sheetDelegate?.onSelectSheet(sheetType, BaseSheetResult.init(indexPath.row, nil))
        dismiss(animated: true)
    }
    
}


protocol BaseSheetDelegate {
    func onSelectSheet(_ sheetType: SheetType?, _ result: BaseSheetResult)
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
    case SelectNewAccount = 0
}
