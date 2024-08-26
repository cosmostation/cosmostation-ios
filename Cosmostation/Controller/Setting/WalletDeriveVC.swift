//
//  WalletDeriveVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class WalletDeriveVC: BaseVC, HdPathDelegate, CreateNameDelegate {
    
    @IBOutlet weak var hdPathTitle: UILabel!
    @IBOutlet weak var hdPathLayer: UIView!
    @IBOutlet weak var hdPathLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var mnemonic: String?
    var privateKeyString: String?
    var seed: Data?
    var toAddAccount: BaseAccount!
    var hdPath = 0
    
    var mainnetChains = [BaseChain]()
    var testnetChains = [BaseChain]()
    var selectedTags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "DeriveCell", bundle: nil), forCellReuseIdentifier: "DeriveCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        //add only cosmos for default
        selectedTags.append("cosmos118")
        if (mnemonic != nil) {
            Task {
                seed = KeyFac.getSeedFromWords(mnemonic!)
                DispatchQueue.main.async(execute: {
                    self.toAddAccount = BaseAccount("", .withMnemonic, String(self.hdPath))
                    self.toAddAccount.fetchForPreCreate(self.seed!, nil)
                    self.mainnetChains = self.toAddAccount.allChains.filter({ $0.isTestnet == false })
                    self.testnetChains = self.toAddAccount.allChains.filter({ $0.isTestnet == true })
                    self.onUpdateview()
                });
            }
            
            let hdPathTap = UITapGestureRecognizer(target: self, action: #selector(onHdPathSelect))
            hdPathTap.cancelsTouchesInView = false
            hdPathLayer.addGestureRecognizer(hdPathTap)
            
        } else if (privateKeyString != nil) {
            hdPathTitle.isHidden = true
            hdPathLayer.isHidden = true
            
            toAddAccount = BaseAccount("", .onlyPrivateKey, "-1")
            toAddAccount.fetchForPreCreate(nil, privateKeyString)
            mainnetChains = toAddAccount.allChains.filter({ $0.isTestnet == false })
            testnetChains = toAddAccount.allChains.filter({ $0.isTestnet == true })
            onUpdateview()
            
        } else {
            hdPathTitle.isHidden = true
            hdPathLayer.isHidden = true
        }
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_select_wallet", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_restore_wallets", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("fetchBalances"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("fetchBalances"), object: nil)
    }
    
    func onUpdateview() {
        if (mainnetChains.count > 0) {
            tableView.reloadData()
            tableView.isHidden = false
            loadingView.isHidden = true
            confirmBtn.isEnabled = true
            
            hdPathLabel.text = String(hdPath)
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        let tag = notification.object as! String
        for i in 0..<mainnetChains.count {
            if (mainnetChains[i].tag == tag) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
        for i in 0..<testnetChains.count {
            if (testnetChains[i].tag == tag) {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    @objc func onHdPathSelect() {
        let hdPathSheet = HdPathSheet(nibName: "HdPathSheet", bundle: nil)
        hdPathSheet.hdPath = hdPath
        hdPathSheet.hdPathDelegate = self
        guard let sheet = hdPathSheet.presentationController as? UISheetPresentationController else {
            return
        }
        sheet.largestUndimmedDetentIdentifier = .large
        sheet.prefersGrabberVisible = true
        present(hdPathSheet, animated: true)
    }

    
    func onSelectedHDPath(_ path: Int) {
        if (hdPath != path) {
            hdPath = path
            selectedTags.removeAll()
            selectedTags.append("cosmos118")
            
            toAddAccount = BaseAccount("", .withMnemonic, String(self.hdPath))
            toAddAccount.allChains.removeAll()
            toAddAccount.fetchForPreCreate(seed!, nil)
            mainnetChains = toAddAccount.allChains.filter({ $0.isTestnet == false })
            testnetChains = toAddAccount.allChains.filter({ $0.isTestnet == true })
            onUpdateview()
        }
    }
    
    @IBAction func onClickCreate(_ sender: UIButton) {
        let createNameSheet = CreateNameSheet(nibName: "CreateNameSheet", bundle: nil)
        createNameSheet.mnemonic = mnemonic
        createNameSheet.privateKeyString = privateKeyString
        createNameSheet.createNameDelegate = self
        onStartSheet(createNameSheet, 240, 0.6)
    }
    
    func onNameConfirmed(_ name: String, _ mnemonic: String?, _ privateKeyString: String?) {
        loadingView.isHidden = false
        
        DispatchQueue.global().async {
            let keychain = BaseData.instance.getKeyChain()
            if (self.toAddAccount.type == .withMnemonic) {
                let recoverAccount = BaseAccount(name, .withMnemonic, String(self.hdPath))
                let id = BaseData.instance.insertAccount(recoverAccount)
                let newData = mnemonic! + " : " + self.seed!.toHexString()
                try? keychain.set(newData, key: recoverAccount.uuid.sha1())
                BaseData.instance.setLastAccount(id)
                BaseData.instance.baseAccount = BaseData.instance.getLastAccount()
                BaseData.instance.setDisplayChainTags(id, self.selectedTags)
                
            } else if (self.toAddAccount.type == .onlyPrivateKey) {
                let recoverAccount = BaseAccount(name, .onlyPrivateKey, "0")
                let id = BaseData.instance.insertAccount(recoverAccount)
                try? keychain.set(privateKeyString!, key: recoverAccount.uuid.sha1())
                BaseData.instance.setLastAccount(id)
                BaseData.instance.baseAccount = BaseData.instance.getLastAccount()
                BaseData.instance.setDisplayChainTags(id, self.selectedTags)
            }
            
            DispatchQueue.main.async(execute: {
                self.loadingView.isHidden = true
                self.onStartMainTab()
            });
        }
    }
    
}



extension WalletDeriveVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && mainnetChains.count == 0) { return nil }
        if (section == 1 && testnetChains.count == 0) { return nil }
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == 0) {
            view.titleLabel.text = "Mainnet"
            view.cntLabel.text = String(mainnetChains.count)
        } else if (section == 1) {
            view.titleLabel.text = "Testnet"
            view.cntLabel.text = String(testnetChains.count)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return mainnetChains.count == 0 ? 0 : 40
        } else if (section == 1) {
            return testnetChains.count == 0 ? 0 : 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return mainnetChains.count
        } else if (section == 1) {
            return testnetChains.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeriveCell") as! DeriveCell
        if (indexPath.section == 0) {
            cell.bindDeriveChain(toAddAccount, mainnetChains[indexPath.row], selectedTags)
        } else if (indexPath.section == 1) {
            cell.bindDeriveChain(toAddAccount, testnetChains[indexPath.row], selectedTags)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var chain: BaseChain!
        if (indexPath.section == 0) {
            chain = mainnetChains[indexPath.row]
            if (chain.tag == "cosmos118") { return }
        } else if (indexPath.section == 1) {
            chain = testnetChains[indexPath.row]
        }
        
        if (selectedTags.contains(chain.tag)) {
            selectedTags.removeAll { $0 == chain.tag }
        } else {
            selectedTags.append(chain.tag)
        }
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }
    
}
