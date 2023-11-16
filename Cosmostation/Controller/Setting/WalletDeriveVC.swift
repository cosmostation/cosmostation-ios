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
    
    var allCosmosChains = [CosmosClass]()
    var selectedCosmosTags = [String]()

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
        
        //add cosmos as default
        selectedCosmosTags.append("cosmos118")
        
        if (mnemonic != nil) {
            DispatchQueue.global().async {
                self.seed = KeyFac.getSeedFromWords(self.mnemonic!)
                DispatchQueue.main.async(execute: {
                    self.toAddAccount = BaseAccount("", .withMnemonic, String(self.hdPath))
                    self.toAddAccount.fetchForPreCreate(self.seed!, nil)
                    self.allCosmosChains = self.toAddAccount.allCosmosClassChains
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
            
            allCosmosChains = toAddAccount.allCosmosClassChains
            onUpdateview()
            
        } else {
            hdPathTitle.isHidden = true
            hdPathLayer.isHidden = true
            
        }
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("title_restore", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_restore_wallets", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("FetchPreCreate"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FetchPreCreate"), object: nil)
    }
    
    func onUpdateview() {
        if (allCosmosChains.count > 0) {
            tableView.reloadData()
            tableView.isHidden = false
            loadingView.isHidden = true
            confirmBtn.isEnabled = true
            
            hdPathLabel.text = String(hdPath)
        }
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
            selectedCosmosTags.removeAll()
            selectedCosmosTags.append("cosmos118")
            
            toAddAccount = BaseAccount("", .withMnemonic, String(self.hdPath))
            toAddAccount.allCosmosClassChains.removeAll()
            toAddAccount.fetchForPreCreate(seed!, nil)
            allCosmosChains = toAddAccount.allCosmosClassChains
            onUpdateview()
        }
    }
    
    @IBAction func onClickCreate(_ sender: UIButton) {
        let createNameSheet = CreateNameSheet(nibName: "CreateNameSheet", bundle: nil)
        createNameSheet.mnemonic = mnemonic
        createNameSheet.privateKeyString = privateKeyString
        createNameSheet.createNameDelegate = self
        onStartSheet(createNameSheet, 240)
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
                BaseData.instance.setDisplayCosmosChainTags(id, self.selectedCosmosTags)
                
            } else if (self.toAddAccount.type == .onlyPrivateKey) {
                let recoverAccount = BaseAccount(name, .onlyPrivateKey, "0")
                let id = BaseData.instance.insertAccount(recoverAccount)
                try? keychain.set(privateKeyString!, key: recoverAccount.uuid.sha1())
                BaseData.instance.setLastAccount(id)
                BaseData.instance.baseAccount = BaseData.instance.getLastAccount()
                BaseData.instance.setDisplayCosmosChainTags(id, self.selectedCosmosTags)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = "Cosmos Class"
        view.cntLabel.text = String(allCosmosChains.count)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCosmosChains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeriveCell") as! DeriveCell
        cell.bindCosmosClassChain(toAddAccount, allCosmosChains[indexPath.row], selectedCosmosTags)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chain = allCosmosChains[indexPath.row]
        if (chain.tag == "cosmos118") { return }
        if (selectedCosmosTags.contains(chain.tag)) {
            selectedCosmosTags.removeAll { $0 == chain.tag }
        } else {
            selectedCosmosTags.append(chain.tag)
        }
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }
    
}
