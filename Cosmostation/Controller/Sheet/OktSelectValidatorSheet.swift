//
//  OktSelectValidatorSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class OktSelectValidatorSheet: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cntLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var selectedChain: BaseChain!
    var oktFetcher: OktFetcher!
    var oktSelectValidatorDelegate: OktSelectValidatorDelegate?
    var allValidators = [JSON]()
    var existSelected = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SelectOktValidatorCell", bundle: nil), forCellReuseIdentifier: "SelectOktValidatorCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        allValidators = oktFetcher.lcdOktValidators
    }


    @IBAction func onClickConfirm(_ sender: UIButton) {
        if (existSelected.count == 0) {
            self.onShowToast(NSLocalizedString("error_min_1_validator", comment: ""))
            return
            
        } else if (existSelected.count >= 30) {
            self.onShowToast(NSLocalizedString("error_max_30_validator", comment: ""))
            return
        }
        oktSelectValidatorDelegate?.onOktSelected(existSelected)
        dismiss(animated: true)
    }

}


extension OktSelectValidatorSheet: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cntLabel.text =  "(" + String(existSelected.count) + "/30)"
        return allValidators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectOktValidatorCell") as! SelectOktValidatorCell
        cell.onBindSelectValidator(selectedChain, allValidators[indexPath.row], existSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toToggle = allValidators[indexPath.row]
        if (existSelected.map { $0["operator_address"].stringValue }.contains(toToggle["operator_address"].stringValue)) {
            existSelected.removeAll { $0["operator_address"].stringValue == toToggle["operator_address"].stringValue }
        } else {
            existSelected.append(toToggle)
        }
        DispatchQueue.main.async {
            self.cntLabel.text =  "(" + String(self.existSelected.count) + "/30)"
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }
}

protocol OktSelectValidatorDelegate {
    func onOktSelected(_ selected: [JSON])
}

