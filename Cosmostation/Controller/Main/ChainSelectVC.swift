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
    
    @IBOutlet weak var loadingView: LottieAnimationView!
    @IBOutlet weak var loadingMsgLabel: UILabel!
    @IBOutlet weak var loadingCntLabel: UILabel!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var toDisplayCosmoses = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg2")!)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg2")
        backgroundImage.contentMode =  .scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        tableView.isHidden = true
        confirmBtn.isHidden = true
        loadingMsgLabel.isHidden = false
        loadingCntLabel.isHidden = false
        powerLabel.isHidden = false
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading2")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SelectChainCell", bundle: nil), forCellReuseIdentifier: "SelectChainCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        baseAccount = BaseData.instance.baseAccount
        toDisplayCosmoses = BaseData.instance.getDisplayCosmosChainNames(baseAccount)
        loadingCntLabel.text = "0 / " + String(baseAccount.allCosmosClassChains.count)
        baseAccount.initAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchData"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchData"), object: nil)
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let fetchedCnt = baseAccount.allCosmosClassChains.filter { $0.fetched == true }.count
        DispatchQueue.main.async {
            self.loadingCntLabel.text = String(fetchedCnt) + " / " + String(self.baseAccount.allCosmosClassChains.count)
        }
        
        
        if (baseAccount.allCosmosClassChains.filter { $0.fetched == false }.count == 0) {
            baseAccount.allCosmosClassChains.forEach { chain in
                let address = RefAddress(baseAccount.id, chain.id, chain.address!,chain.allStakingDenomAmount().stringValue, chain.allValue(true).stringValue)
                BaseData.instance.updateRefAddresses(address)
            }
            baseAccount.sortCosmosChain()
            loadingView.stop()
            loadingView.isHidden = true
            loadingMsgLabel.isHidden = true
            loadingCntLabel.isHidden = true
            powerLabel.isHidden = true
            
            confirmBtn.isHidden = false
            tableView.reloadData()
            tableView.isHidden = false
        }

    }

    @IBAction func onClickConfirm(_ sender: BaseButton) {
        var toSaveCosmos = [String]()
        baseAccount.allCosmosClassChains.sort {
            if ($0.id == "cosmos118" && $1.id != "cosmos118") { return true }
            return $0.allValue().compare($1.allValue()).rawValue > 0 ? true : false
        }
        baseAccount.allCosmosClassChains.forEach { chain in
            if (toDisplayCosmoses.contains(chain.id)) {
                toSaveCosmos.append(chain.id)
            }
        }
        
        BaseData.instance.setDisplayCosmosChainNames(baseAccount, toSaveCosmos)
        let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabVC") as! MainTabVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainTabVC
        self.present(mainTabVC, animated: true, completion: nil)
    }
}


extension ChainSelectVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = "Cosmos Class"
        view.cntLabel.text = String(baseAccount.allCosmosClassChains.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseAccount.allCosmosClassChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"SelectChainCell") as! SelectChainCell
        let toBindChain = baseAccount.allCosmosClassChains[indexPath.row]
        cell.bindCosmosClassChain(baseAccount, toBindChain, toDisplayCosmoses)
        cell.actionToggle = { result in
            if (result) {
                if (!self.toDisplayCosmoses.contains(toBindChain.id)) {
                    self.toDisplayCosmoses.append(toBindChain.id)
                }
            } else {
                self.toDisplayCosmoses.removeAll { $0 == toBindChain.id }
            }
        }
        return cell
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
