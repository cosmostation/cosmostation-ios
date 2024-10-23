//
//  SelectDisplayTokenListSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class SelectDisplayTokenListSheet: BaseVC, UISearchBarDelegate{
    
    @IBOutlet weak var sheetTitle: UILabel!
    @IBOutlet weak var sheetTableView: UITableView!
    @IBOutlet weak var sheetSearchBar: UISearchBar!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var selectedChain: BaseChain!
    var allErc20Tokens = [MintscanToken]()
    var searchErc20Tokens = [MintscanToken]()
    var toDisplayErc20Tokens = [String]()
    var tokensListDelegate: SelectTokensListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        sheetSearchBar.backgroundImage = UIImage()
        sheetSearchBar.delegate = self
        
        searchErc20Tokens = allErc20Tokens
        
        sheetTableView.delegate = self
        sheetTableView.dataSource = self
        sheetTableView.separatorStyle = .none
        sheetTableView.register(UINib(nibName: "SelectDisplayTokenCell", bundle: nil), forCellReuseIdentifier: "SelectDisplayTokenCell")
        sheetTableView.rowHeight = UITableView.automaticDimension
        sheetTableView.sectionHeaderTopPadding = 0.0
    }
    
    override func setLocalizedString() {
        sheetTitle.text = NSLocalizedString("str_edit_token_list", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }

    @IBAction func onClickConfirm(_ sender: BaseButton) {
        BaseData.instance.setDisplayErc20s(baseAccount.id, selectedChain.tag, toDisplayErc20Tokens)
        tokensListDelegate?.onTokensSelected(toDisplayErc20Tokens)
        dismiss(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchErc20Tokens = searchText.isEmpty ? allErc20Tokens : allErc20Tokens.filter { token in
            return token.symbol!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        sheetTableView.reloadData()
    }
}



extension SelectDisplayTokenListSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchErc20Tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectDisplayTokenCell") as! SelectDisplayTokenCell
        cell.bindErc20Token(selectedChain, searchErc20Tokens[indexPath.row], toDisplayErc20Tokens)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toToggle = searchErc20Tokens[indexPath.row]
        if (toDisplayErc20Tokens.contains(toToggle.contract!)) {
            toDisplayErc20Tokens.removeAll { $0 == toToggle.contract! }
        } else {
            toDisplayErc20Tokens.append(toToggle.contract!)
        }
        DispatchQueue.main.async {
            self.sheetTableView.beginUpdates()
            self.sheetTableView.reloadRows(at: [indexPath], with: .none)
            self.sheetTableView.endUpdates()
        }
    }
}


protocol SelectTokensListDelegate {
    func onTokensSelected(_ result: [String])
}
