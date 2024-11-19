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
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!

    var selectedChain: BaseChain!
    var allTokens = [MintscanToken]()
    var searchTokens = [MintscanToken]()
    var toDisplayTokens = [String]()
    var tokensListDelegate: SelectTokensListDelegate?
    
    private let tokenType = ["cw20", "erc20"]
    
    static var tokenWithAmount: [MintscanToken] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        sheetSearchBar.backgroundImage = UIImage()
        sheetSearchBar.delegate = self
        
        searchTokens = allTokens
        
        sheetTableView.delegate = self
        sheetTableView.dataSource = self
        sheetTableView.separatorStyle = .none
        sheetTableView.register(UINib(nibName: "SelectDisplayTokenCell", bundle: nil), forCellReuseIdentifier: "SelectDisplayTokenCell")
        sheetTableView.rowHeight = UITableView.automaticDimension
        sheetTableView.sectionHeaderTopPadding = 0.0
        
        setTokensAmount()
        setSegment()
        
    }
    
    override func setLocalizedString() {
        sheetTitle.text = NSLocalizedString("str_edit_token_list", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }

    @IBAction func onClickConfirm(_ sender: BaseButton) {
        if selectedChain.isSupportCw20() && selectedChain.isSupportErc20() {
            let toDisplayCw20Tokens = toDisplayTokens.filter { allTokens.filter({ $0.type == "cw20" }).map({ $0.contract }).contains($0) }
            let toDisplayErc20Tokens = toDisplayTokens.filter { allTokens.filter({ $0.type == "erc20" }).map({ $0.contract }).contains($0) }

            BaseData.instance.setDisplayCw20s(baseAccount.id, selectedChain.tag, toDisplayCw20Tokens)
            BaseData.instance.setDisplayErc20s(baseAccount.id, selectedChain.tag, toDisplayErc20Tokens)

        } else if selectedChain.isSupportCw20() {
            BaseData.instance.setDisplayCw20s(baseAccount.id, selectedChain.tag, toDisplayTokens)
            
        } else {
            BaseData.instance.setDisplayErc20s(baseAccount.id, selectedChain.tag, toDisplayTokens)
            
        }
        tokensListDelegate?.onTokensSelected(toDisplayTokens)
        dismiss(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if selectedChain.isSupportCw20() && selectedChain.isSupportErc20() {
            searchTokens = searchText.isEmpty ? allTokens.filter { $0.type == tokenType[segment.selectedSegmentIndex] } : allTokens.filter({ $0.type == tokenType[segment.selectedSegmentIndex] }).filter { token in
                return token.symbol!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil || token.contract?.range(of: searchText, options: .caseInsensitive) != nil
            }
        } else {
            searchTokens = searchText.isEmpty ? allTokens : allTokens.filter { token in
                return token.symbol!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil || token.contract?.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        sheetTableView.reloadData()
    }
    
    private func setTokensAmount() {
        for token in allTokens {
            if let _ = token.amount {
                Self.tokenWithAmount.append(token)
            }
        }
    }
    
    private func setSegment() {
        if selectedChain.isSupportCw20() && selectedChain.isSupportErc20() {
            segmentView.isHidden = false
            segment.selectedSegmentIndex = 0
            segment.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
            didChangeValue(segment)
            
        } else {
            segmentView.isHidden = true
        }
    }
    
    @objc func didChangeValue(_ segment: UISegmentedControl) {
        searchTokens = allTokens.filter { $0.type == tokenType[segment.selectedSegmentIndex] }
        
        sheetTableView.reloadData()
        sheetSearchBar.text = ""
    }
}



extension SelectDisplayTokenListSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectDisplayTokenCell") as! SelectDisplayTokenCell
        cell.bindToken(selectedChain, searchTokens[indexPath.row], toDisplayTokens)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toToggle = searchTokens[indexPath.row]
        if (toDisplayTokens.contains(toToggle.contract!)) {
            toDisplayTokens.removeAll { $0 == toToggle.contract! }
        } else {
            toDisplayTokens.append(toToggle.contract!)
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
