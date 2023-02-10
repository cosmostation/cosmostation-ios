//
//  MultiSelectPopupViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class MultiSelectPopupViewController: BaseViewController, SBCardPopupContent, UITableViewDelegate, UITableViewDataSource {
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard =  true
    let allowsSwipeToDismissPopupCard =  false
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupTableview: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var type: Int?
    var contractTokens = Array<MintscanToken>()
    var selectedContractTokens = Array<String>()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        chainType = ChainFactory.getChainType(account!.account_base_chain)
        chainConfig = ChainFactory.getChainConfig(chainType)
        
        self.popupTableview.delegate = self
        self.popupTableview.dataSource = self
        self.popupTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.popupTableview.register(UINib(nibName: "SelectContractTokenCell", bundle: nil), forCellReuseIdentifier: "SelectContractTokenCell")
        self.popupTableview.rowHeight = UITableView.automaticDimension
        self.popupTableview.estimatedRowHeight = UITableView.automaticDimension
        
        if (type == SELECT_POPUP_CONTRACT_TOKEN_EDIT) {
            self.popupTitle.text = NSLocalizedString("str_select_contract_token", comment: "")
            BaseData.instance.mMintscanTokens.forEach { msToken in
                if (msToken.default_show == false) {
                    contractTokens.append(msToken)
                }
            }
            selectedContractTokens = BaseData.instance.getUserFavoTokens2(account!.account_address)
        }
        
        tableViewHeightConstraint.constant = CGFloat(min(contractTokens.count * 55 + 10, 250))
    }

//    override func viewDidLayoutSubviews() {
//        var esHeight: CGFloat = 420
//        if (type == SELECT_POPUP_CONTRACT_TOKEN_EDIT) {
//            esHeight = (CGFloat)((contractTokens.count * 55) + 105)
//        }
//        esHeight = (esHeight > 420) ? 420 : esHeight
//        cardView.frame = CGRect(x: cardView.frame.origin.x, y: cardView.frame.origin.y, width: cardView.frame.size.width, height: esHeight)
//        cardView.layoutIfNeeded()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (type == SELECT_POPUP_CONTRACT_TOKEN_EDIT) {
            return contractTokens.count;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (type == SELECT_POPUP_CONTRACT_TOKEN_EDIT) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectContractTokenCell") as? SelectContractTokenCell
            let msToken = contractTokens[indexPath.row]
            cell?.onBindToken(msToken, selectedContractTokens)
            cell?.actionToggle = { result in
                if (result) {
                    if (!self.selectedContractTokens.contains(msToken.address)) {
                        self.selectedContractTokens.append(msToken.address)
                    }
                } else {
                    self.selectedContractTokens.removeAll { $0 == msToken.address }
                }
            }
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectContractTokenCell") as? SelectContractTokenCell
        return cell!
    }

    @IBAction func onClickCencel(_ sender: UIButton) {
        popupViewController?.close()
    }
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        BaseData.instance.setUserFavoTokens(account!.account_address, selectedContractTokens)
        popupViewController?.resultDelegate?.SBCardPopupResponse(type: type!, result: 1)
        popupViewController?.close()
    }
}
