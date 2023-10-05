//
//  ChainSelectVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class ChainSelectVC: BaseVC {
    
    @IBOutlet weak var loadingLayer: UIView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var loadingMsgLabel: UILabel!
    @IBOutlet weak var loadingCntLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var orderBtn: UIButton!
    @IBOutlet weak var reloadBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var toDisplayCosmosTags = [String]()
    var allCosmosChains = [CosmosClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadingView.animation = LottieAnimation.named("loading")
//        loadingView.contentMode = .scaleAspectFit
//        loadingView.loopMode = .loop
//        loadingView.animationSpeed = 1.3
//        loadingView.play()
        confirmBtn.isHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SelectChainCell", bundle: nil), forCellReuseIdentifier: "SelectChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        baseAccount = BaseData.instance.baseAccount
        baseAccount.fetchAllCosmosChains()
        allCosmosChains = baseAccount.allCosmosClassChains
        
        toDisplayCosmosTags = BaseData.instance.getDisplayCosmosChainTags(baseAccount.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    override func setLocalizedString() {
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        for i in 0..<allCosmosChains.count {
            if (allCosmosChains[i].tag == tag) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        if (baseAccount.allCosmosClassChains.filter { $0.fetched == false }.count == 0) {
            print("ALL Loaded!!")
        }
    }
    
    @IBAction func onClickOrder(_ sender: UIButton) {
        print("onClickOrder")
        
        
    }
    @IBAction func onClickReload(_ sender: UIButton) {
        print("onClickReload")
        
//        baseAccount.sortCosmosChains()
//        allCosmosChains = baseAccount.allCosmosClassChains
//        tableView.reloadData()
    }
    

    @IBAction func onClickConfirm(_ sender: BaseButton) {
//        var toSaveCosmosTag = [String]()
//        baseAccount.allCosmosClassChains.sort {
//            if ($0.tag == "cosmos118") { return true }
//            if ($1.tag == "cosmos118") { return false }
//            return $0.allValue().compare($1.allValue()).rawValue > 0 ? true : false
//        }
//        baseAccount.allCosmosClassChains.forEach { chain in
//            if (toDisplayCosmosTags.contains(chain.tag)) {
//                toSaveCosmosTag.append(chain.tag)
//            }
//        }
//        BaseData.instance.setDisplayCosmosChainTags(baseAccount, toSaveCosmosTag)
//        let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.window?.rootViewController = mainTabVC
//        self.present(mainTabVC, animated: true, completion: nil)
    }
}


extension ChainSelectVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.rootView.backgroundColor = UIColor.colorBg
        view.titleLabel.text = "Cosmos Class"
        view.cntLabel.text = String(baseAccount.allCosmosClassChains.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCosmosChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectChainCell") as! SelectChainCell
        let toBindChain = allCosmosChains[indexPath.row]
        cell.bindCosmosClassChain(baseAccount, toBindChain, toDisplayCosmosTags)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chain = allCosmosChains[indexPath.row]
        if (toDisplayCosmosTags.contains(chain.tag)) {
            toDisplayCosmosTags.removeAll { $0 == chain.tag }
        } else {
            toDisplayCosmosTags.append(chain.tag)
        }
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        for cell in tableView.visibleCells {
//            let hiddenFrameHeight = scrollView.contentOffset.y + (navigationController?.navigationBar.frame.size.height ?? 44) - cell.frame.origin.y
//            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
//                maskCell(cell: cell, margin: Float(hiddenFrameHeight))
//            }
//        }
//    }
//
//    func maskCell(cell: UITableViewCell, margin: Float) {
//        cell.layer.mask = visibilityMaskForCell(cell: cell, location: (margin / Float(cell.frame.size.height) ))
//        cell.layer.masksToBounds = true
//    }
//
//    func visibilityMaskForCell(cell: UITableViewCell, location: Float) -> CAGradientLayer {
//        let mask = CAGradientLayer()
//        mask.frame = cell.bounds
//        mask.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 1).cgColor]
//        mask.locations = [NSNumber(value: location), NSNumber(value: location)]
//        return mask;
//    }
    
}
