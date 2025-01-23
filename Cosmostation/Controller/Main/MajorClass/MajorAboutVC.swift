//
//  MajorAboutVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class MajorAboutVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedChain: BaseChain!
    var chainParam: JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "AboutDescriptionCell", bundle: nil), forCellReuseIdentifier: "AboutDescriptionCell")
        tableView.register(UINib(nibName: "AboutChainInfoCell", bundle: nil), forCellReuseIdentifier: "AboutChainInfoCell")
        tableView.register(UINib(nibName: "AboutStakingCell", bundle: nil), forCellReuseIdentifier: "AboutStakingCell")
        tableView.register(UINib(nibName: "AboutSocialsCell", bundle: nil), forCellReuseIdentifier: "AboutSocialsCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        chainParam = selectedChain.getChainParam()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone), name: Notification.Name("FetchParam"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchParam"), object: nil)
    }

    @objc func onFetchDone() {
        chainParam = selectedChain.getChainParam()
        tableView.reloadData()
    }
}

extension MajorAboutVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = NSLocalizedString("str_chain_introduce", comment: "")
            view.cntLabel.text = ""
            
        } else if (section == 1) {
            view.titleLabel.text = NSLocalizedString("str_chain_info", comment: "")
            view.cntLabel.text = ""
            
        } else if (section == 2) {
            view.titleLabel.text = NSLocalizedString("str_staking_info", comment: "")
            view.cntLabel.text = ""
            
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 3) { return 0 }
        
        if selectedChain is ChainBitCoin86 && section == 2 {
            return 0
        }

        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedChain is ChainBitCoin86 && section == 2 {
            return 0
        }

        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutDescriptionCell") as! AboutDescriptionCell
            let description = chainParam["params"]["chainlist_params"]["description"]
            cell.onBindDescription(selectedChain, description)
            return cell
            
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutChainInfoCell") as! AboutChainInfoCell
            cell.onBindChainInfo(selectedChain, chainParam)
            return cell
            
        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutStakingCell") as! AboutStakingCell
            cell.onBindMajorInfo(selectedChain, chainParam)
            return cell
            
        } else if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AboutSocialsCell") as! AboutSocialsCell
            cell.vc = self
            cell.onBindSocial(chainParam)
            return cell
        }
        return UITableViewCell()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
            }
        }
    }

    func maskCell(cell: UITableViewCell, margin: Float) {
        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
        cell.layer.masksToBounds = true
    }

    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = cell.bounds
        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
        return mask;
    }
}
