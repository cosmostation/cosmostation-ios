//
//  WalletDeriveViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import GRPC
import NIO
import SwiftKeychainWrapper

class WalletDeriveViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mnemonicNameLabel: UILabel!
    @IBOutlet weak var mnemonicTitleLeadingLayout: NSLayoutConstraint?
    @IBOutlet weak var pathTitle: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var pathCardView: CardView!
    @IBOutlet weak var searchLabel: UITextField!
    @IBOutlet weak var selectedHDPathLabel: UILabel!
    @IBOutlet weak var noResultImg: UIImageView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var derivedWalletTableView: UITableView!
    @IBOutlet weak var btnAddWallet: UIButton!
    
    var mPrivateKeyMode = false
    var mBackable = true
    var mWords: MWords!
    var mPrivateKey: Data!
    var mSeed: Data!
    var mPath = 0
    var mDerives = Array<Derive>()
    var mSearchRes = Array<Derive>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchLabel.placeholder = NSLocalizedString("msg_search_chain", comment: "")
        self.derivedWalletTableView.delegate = self
        self.derivedWalletTableView.dataSource = self
        self.derivedWalletTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.derivedWalletTableView.register(UINib(nibName: "DeriveWalletCell", bundle: nil), forCellReuseIdentifier: "DeriveWalletCell")
        self.derivedWalletTableView.rowHeight = UITableView.automaticDimension
        self.derivedWalletTableView.estimatedRowHeight = UITableView.automaticDimension
        
        if (!mBackable) {
            self.backBtn.isHidden = true
            self.mnemonicTitleLeadingLayout?.isActive = false
        }
        
        if (mPrivateKeyMode) {
            self.mnemonicNameLabel.text = NSLocalizedString("title_restore_privatekey", comment: "")
            self.pathLabel.isHidden = true
            self.pathCardView.isHidden = true
            self.onGetAllKeyTypes()
            
        } else {
            self.mnemonicNameLabel.text = self.mWords.getName()
            self.selectedHDPathLabel.text = String(mPath)
            let tapPath = UITapGestureRecognizer(target: self, action: #selector(self.onClickPath))
            self.pathCardView.addGestureRecognizer(tapPath)
            self.getSeedFormWords()
        }
        
        pathTitle.text = NSLocalizedString("str_path", comment: "")
        btnAddWallet.setTitle(NSLocalizedString("str_add_wallet", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSearchRes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let derive = mSearchRes[indexPath.row]
        guard let chainConfig = ChainFactory.getChainConfig(derive.chaintype) else { return }
        if (derive.status == 2) { return }
        self.mSearchRes[indexPath.row].selected = !derive.selected
        if let filterIndex = self.mDerives.firstIndex(where: { $0.dpAddress == derive.dpAddress }) {
            self.mDerives[filterIndex].selected = !derive.selected
        }
        self.derivedWalletTableView.reloadRows(at: [indexPath], with: .none)
        
        if (!derive.selected) {
            if (chainConfig.supportHdPaths().count > 1 && derive.fullPath != chainConfig.defaultPath.replacingOccurrences(of: "X", with: String(mPath))) {
                let alert = UIAlertController(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("select_to_default_path_warning", comment: ""), preferredStyle: .alert)
                alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in
                    self.mSearchRes[indexPath.row].selected = false
                    self.derivedWalletTableView.reloadRows(at: [indexPath], with: .none)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeriveWalletCell") as? DeriveWalletCell
        cell?.onBindWallet(mSearchRes[indexPath.row], mPrivateKeyMode)
        return cell!
    }
    
    var tempPath = 0
    @objc func onClickPath() {
        let alert = UIAlertController(title: NSLocalizedString("select_hd_path", comment: ""), message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        alert.view.addSubview(pickerFrame)
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        pickerFrame.selectRow(self.mPath, inComponent: 0, animated: false)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { (UIAlertAction) in
            self.showWaittingAlert()
            self.selectedHDPathLabel.text = String(self.mPath)
            self.mDerives.removeAll()
            self.mSearchRes.removeAll()
            self.searchLabel.text = ""
            self.derivedWalletTableView.reloadData()
            DispatchQueue.main.async(execute: {
                self.onGetAllKeyTypes()
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.mPath = row
    }
    
    @IBAction func searchChainView(_ sender: Any) {
        filterDerives()
    }
    
    private func filterDerives() {
        let trimmedString = self.searchLabel?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedString.isEmpty {
            mSearchRes = mDerives
        } else {
            mSearchRes = mDerives.filter({ derive in
                if let chainConfig = ChainFactory.getChainConfig(derive.chaintype) {
                    return [chainConfig.chainAPIName, chainConfig.chainKoreanName, chainConfig.stakeSymbol].filter { str in
                        str.localizedStandardContains(trimmedString.lowercased())
                    }.count > 0
                } else {
                    return false
                }
            })
        }
        
        DispatchQueue.main.async(execute: {
            if (self.mSearchRes.isEmpty) {
                self.noResultImg.isHidden = false
                self.noResultLabel.isHidden = false
                self.noResultLabel.text = NSLocalizedString("str_no_result", comment: "")
            } else {
                self.noResultImg.isHidden = true
                self.noResultLabel.isHidden = true
            }
            self.derivedWalletTableView.reloadData()
        })
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickDerive(_ sender: UIButton) {
        let selectedCnt = mDerives.filter { $0.selected == true }.count
        if (selectedCnt > 0) {
            let msg = String(format: NSLocalizedString("import_account_msg", comment: ""), String(selectedCnt))
            let addingAlert = UIAlertController (title: NSLocalizedString("import_account_title", comment: "") , message: msg, preferredStyle: .alert)
            addingAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
            addingAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil))
            addingAlert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { (UIAlertAction) in
                self.onSaveAccount()
            }))
            self.present(addingAlert, animated: true, completion: nil)
            
        } else {
            self.onShowToast(NSLocalizedString("error_not_selected_to_import", comment: ""))
        }
    }
    
    func getSeedFormWords() {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            self.mSeed = WKey.getSeedFromWords(self.mWords)
            self.onGetAllKeyTypes()
        }
    }
    
    func onGetAllKeyTypes() {
        if (mPrivateKeyMode) {
            ChainFactory.getAllKeyType().forEach { keyTypes in
                let chainConfig = ChainFactory.getChainConfig(keyTypes.0)!
                let fullPath = chainConfig.getHdPath(keyTypes.1, self.mPath)
                let pKey = self.mPrivateKey
                let dpAddress = WKey.getDpAddress(chainConfig, pKey!, keyTypes.1)
                var status = -1
                if let checkAddress = BaseData.instance.selectExistAccount(dpAddress, chainConfig.chainType) {
                    if (checkAddress.account_has_private) { status = 2 }
                    else { status = 1 }
                } else {
                    status = 0
                }
                let derive = Derive.init(chainConfig.chainType, keyTypes.1, self.mPath, fullPath, dpAddress, pKey!, status)
                if (!self.mDerives.contains(where: { $0.dpAddress == derive.dpAddress })) {
                    self.mDerives.append(derive)
                }
            }
        } else {
            ChainFactory.getAllKeyType().forEach { keyTypes in
                let chainConfig = ChainFactory.getChainConfig(keyTypes.0)!
                let fullPath = chainConfig.getHdPath(keyTypes.1, self.mPath)
                let pKey = KeyFac.getPrivateKeyDataFromSeed(self.mSeed, fullPath)
                let dpAddress = WKey.getDpAddress(chainConfig, pKey, keyTypes.1)
                var status = -1
                if let checkAddress = BaseData.instance.selectExistAccount(dpAddress, chainConfig.chainType) {
                    if (checkAddress.account_has_private) { status = 2 }
                    else { status = 1 }
                } else {
                    status = 0
                }
                let derive = Derive.init(chainConfig.chainType, keyTypes.1, self.mPath, fullPath, dpAddress, pKey, status)
                if (!self.mDerives.contains(where: { $0.dpAddress == derive.dpAddress })) {
                    self.mDerives.append(derive)
                }
            }
        }
        
        DispatchQueue.main.async(execute: {
            self.derivedWalletTableView.reloadData()
            self.filterDerives()
            
            for i in 0 ..< self.mSearchRes.count {
                self.onFetchBalance(i)
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
            self.hideWaittingAlert()
        })
    }
    
    func onFetchBalance(_ position: Int) {
        let derive = self.mDerives[position]
        guard let chainConfig = ChainFactory.getChainConfig(derive.chaintype) else { return }
        
        var tempCoin = Coin.init(chainConfig.stakeDenom, "0")
        if (chainConfig.isGrpc) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(chainConfig)!
                    let req = Cosmos_Bank_V1beta1_QueryBalanceRequest.with { $0.address = derive.dpAddress; $0.denom = chainConfig.stakeDenom }
                    if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).balance(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        tempCoin = Coin.init(response.balance.denom, response.balance.amount)                        
                    }
                    try channel.close().wait()
                } catch { }
                DispatchQueue.main.async(execute: {
                    self.onTableViewLoadData(position, tempCoin)
                });
            }
            
        } else {
            let request = Alamofire.request(BaseNetWork.accountInfoUrl(chainConfig.chainType, derive.dpAddress), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    if (chainConfig.chainType == .BINANCE_MAIN) {
                        if let responseData = res as? NSDictionary {
                            if let balances = responseData.object(forKey: "balances") as? Array<NSDictionary> {
                                balances.forEach { balance in
                                    if (balance.object(forKey: "symbol") as! String == chainConfig.stakeDenom) {
                                        tempCoin = Coin.init(balance.object(forKey: "symbol") as! String, balance.object(forKey: "free") as! String)
                                    }
                                }
                            }
                        }
                        
                    } else if (chainConfig.chainType == .OKEX_MAIN) {
                        if let responseData = res as? NSDictionary {
                            if let coins = responseData.value(forKeyPath: "value.coins") as? Array<NSDictionary> {
                                coins.forEach { coin in
                                    if (coin.object(forKey: "denom") as! String == chainConfig.stakeDenom) {
                                        tempCoin = Coin.init(coin.object(forKey: "denom") as! String, coin.object(forKey: "amount") as! String)
                                    }
                                }
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
                self.onTableViewLoadData(position, tempCoin)
            }
        }
    }
    
    private func onTableViewLoadData(_ position: Int, _ tempCoin: Coin) {
        self.mDerives[position].coin = tempCoin
        if let firstIndex = self.mSearchRes.firstIndex(where: { derive in
            derive.chaintype == self.mDerives[position].chaintype && derive.dpAddress == self.mDerives[position].dpAddress}) {
            self.mSearchRes[firstIndex].coin = tempCoin
            self.derivedWalletTableView.beginUpdates()
            self.derivedWalletTableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .none)
            self.derivedWalletTableView.endUpdates()
        }
    }
    
    func onSaveAccount() {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            self.mDerives.forEach { derive in
                if (derive.selected == true) {
                    if (derive.status == 1) {
                        self.onOverideAccount(derive)
                    } else {
                        self.onCreateAccount(derive)
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                let initDerive = self.mDerives.filter { $0.selected == true }.first!
                let initAccount = BaseData.instance.selectExistAccount(initDerive.dpAddress, initDerive.chaintype)!
                BaseData.instance.setLastTab(0)
                BaseData.instance.setRecentAccountId(initAccount.account_id)
                BaseData.instance.setRecentChain(initDerive.chaintype)
                
                self.onStartMainTab()
            });
        }
    }
    
    func onOverideAccount(_ derive: Derive) {
        let existedAccount = BaseData.instance.selectExistAccount(derive.dpAddress, derive.chaintype)!
        existedAccount.account_path = String(derive.path)
        existedAccount.account_pubkey_type = Int64(derive.hdpathtype)
        existedAccount.account_has_private = true
        
        if (mPrivateKeyMode) {
            existedAccount.account_from_mnemonic = false
            if (BaseData.instance.overrideAccount(existedAccount) > 0 ) {
                KeychainWrapper.standard.set(mPrivateKey.hexEncodedString(), forKey: existedAccount.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            }
            
        } else {
            existedAccount.account_from_mnemonic = true
            existedAccount.account_m_size = Int64(self.mWords.getWordsCnt())
            existedAccount.account_mnemonic_id = self.mWords.id
            if (BaseData.instance.overrideAccount(existedAccount) > 0 ) {
                KeychainWrapper.standard.set(self.mWords.getWords(), forKey: existedAccount.account_uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
                KeychainWrapper.standard.set(derive.pKey.hexEncodedString(), forKey: existedAccount.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            }
        }
        var hiddenChains = BaseData.instance.userHideChains()
        if (hiddenChains.contains(derive.chaintype)) {
            if let position = hiddenChains.firstIndex(where: { $0 == derive.chaintype }) {
                hiddenChains.remove(at: position)
            }
            BaseData.instance.setUserHiddenChains(hiddenChains)
        }
    }
    
    func onCreateAccount(_ derive: Derive) {
        let newAccount = Account.init(isNew: true)
        newAccount.account_path = String(derive.path)
        newAccount.account_pubkey_type = Int64(derive.hdpathtype)
        newAccount.account_address = derive.dpAddress
        newAccount.account_base_chain = WUtils.getChainDBName(derive.chaintype)
        newAccount.account_has_private = true
        newAccount.account_import_time = Date().millisecondsSince1970
        newAccount.account_sort_order = 9999
        
        if (mPrivateKeyMode) {
            newAccount.account_from_mnemonic = false
            if (BaseData.instance.insertAccount(newAccount) > 0) {
                KeychainWrapper.standard.set(mPrivateKey.hexEncodedString(), forKey: newAccount.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            }
        } else {
            newAccount.account_from_mnemonic = true
            newAccount.account_m_size = Int64(self.mWords.getWordsCnt())
            newAccount.account_mnemonic_id = self.mWords.id
            newAccount.account_nick_name = self.mWords.getName()
            if (BaseData.instance.insertAccount(newAccount) > 0) {
                KeychainWrapper.standard.set(self.mWords.getWords(), forKey: newAccount.account_uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
                KeychainWrapper.standard.set(derive.pKey.hexEncodedString(), forKey: newAccount.getPrivateKeySha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            }
        }
        PushUtils.shared.sync()
        var hiddenChains = BaseData.instance.userHideChains()
        if (hiddenChains.contains(derive.chaintype)) {
            if let position = hiddenChains.firstIndex(where: { $0 == derive.chaintype }) {
                hiddenChains.remove(at: position)
            }
            BaseData.instance.setUserHiddenChains(hiddenChains)
        }
    }
}

struct Derive {
    var chaintype: ChainType
    var hdpathtype: Int
    var path: Int
    var fullPath: String
    var dpAddress: String
    var pKey: Data
    var status = -1    // 0 == ready, 1 == overide, 2 == already imported
    var coin: Coin?
    var selected = false
    
    init(_ chaintype: ChainType, _ hdpathtype: Int, _ path: Int, _ fullPath: String, _ address: String, _ pKey: Data, _ status: Int) {
        self.chaintype = chaintype
        self.hdpathtype = hdpathtype
        self.path = path
        self.fullPath = fullPath
        self.dpAddress = address
        self.pKey = pKey
        self.status = status
    }
}
