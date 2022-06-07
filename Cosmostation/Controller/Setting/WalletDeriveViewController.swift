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

class WalletDeriveViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var mnemonicNameLabel: UILabel!
    @IBOutlet weak var walletCntLabel: UILabel!
    @IBOutlet weak var totalWalletCntLabel: UILabel!
    @IBOutlet weak var pathCardView: CardView!
    @IBOutlet weak var selectedHDPathLabel: UILabel!
    @IBOutlet weak var derivedWalletTableView: UITableView!
    
    var mWords: MWords!
    var mSeed: Data!
    var mPath = 0
    var mDerives = Array<Derive>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.derivedWalletTableView.delegate = self
        self.derivedWalletTableView.dataSource = self
        self.derivedWalletTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.derivedWalletTableView.register(UINib(nibName: "DeriveWalletCell", bundle: nil), forCellReuseIdentifier: "DeriveWalletCell")
        self.derivedWalletTableView.rowHeight = UITableView.automaticDimension
        self.derivedWalletTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.mnemonicNameLabel.text = self.mWords.getName()
        self.walletCntLabel.text = ""
        self.totalWalletCntLabel.text = ""
        self.selectedHDPathLabel.text = String(mPath)
        
        let tapPath = UITapGestureRecognizer(target: self, action: #selector(self.onClickPath))
        self.pathCardView.addGestureRecognizer(tapPath)
        
        self.getSeedFormWords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDerives.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let derive = mDerives[indexPath.row]
        if (derive.status == 2) { return }
        self.mDerives[indexPath.row].selected = !derive.selected
        self.derivedWalletTableView.reloadRows(at: [indexPath], with: .none)
        self.onUpdateCnt()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeriveWalletCell") as? DeriveWalletCell
        let derive = mDerives[indexPath.row]
        let chainConfig = ChainFactory().getChainConfig(derive.chaintype)
        cell?.chainImgView.image = chainConfig.chainImg
        cell?.pathLabel.text = chainConfig.getHdPath(derive.hdpathtype, derive.path)
        
        if let address = derive.address {
            cell!.addressLabel.text = address
        } else {
            cell!.addressLabel.text = "loading..."
        }
        
        if let coin = derive.coin {
            WUtils.showCoinDp(coin, cell!.denomLabel, cell!.amountLabel, derive.chaintype)
        } else {
            cell!.amountLabel.text = ""
            cell!.denomLabel.text = ""
        }
        
        if (derive.status == -1) {
            cell!.statusLabel.text = ""
            cell?.dimCardView.isHidden = true
            cell?.rootCardView.borderWidth = 0.5
            cell?.rootCardView.borderColor = UIColor(hexString: "#4b4f54")
            
        } else if (derive.status == 0) {
            cell!.statusLabel.text = ""
            cell?.dimCardView.isHidden = true
            cell?.rootCardView.borderWidth = 0.5
            cell?.rootCardView.borderColor = UIColor(hexString: "#4b4f54")
            
        } else if (derive.status == 1) {
            cell!.statusLabel.text = ""
            cell?.dimCardView.isHidden = true
            cell?.rootCardView.borderWidth = 0.5
            cell?.rootCardView.borderColor = UIColor(hexString: "#4b4f54")
            
        } else if (derive.status == 2) {
            cell!.statusLabel.text = "Imported"
            cell?.dimCardView.isHidden = false
            cell?.rootCardView.borderWidth = 0.0
        }
        
        if (derive.selected == true) {
            cell?.rootCardView.borderWidth = 1.2
            cell?.rootCardView.borderColor = .white
        }
        return cell!
    }
    
    
    @objc func onClickPath() {
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
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickDerive(_ sender: UIButton) {
    }
    
    func onUpdateCnt() {
        let allKeyCnt = self.mDerives.count
        let alreadyCnt = self.mDerives.filter { $0.status == 2 }.count
        let selectedCnt = self.mDerives.filter { $0.selected == true }.count
        
        if (selectedCnt == 0) {
            self.walletCntLabel.text = String(alreadyCnt)
            self.walletCntLabel.textColor = UIColor(hexString: "#7a7f88")
            self.totalWalletCntLabel.text = "/ " + String(allKeyCnt)
            
        } else {
            self.walletCntLabel.text = String(alreadyCnt + selectedCnt)
            self.walletCntLabel.textColor = UIColor(hexString: "#05D2DD")
            self.totalWalletCntLabel.text = "/ " + String(allKeyCnt)
            
        }
        
    }
    
    func getSeedFormWords() {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            self.mSeed = WKey.getSeedFromWords(self.mWords)
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                self.onGetAllKeyTypes()
            });
        }
    }
    
    func onGetAllKeyTypes() {
        ChainFactory().getAllKeyType().forEach { keyTypes in
            let chainConfig = ChainFactory().getChainConfig(keyTypes.0)
            self.mDerives.append(Derive.init(chainConfig.chainType, keyTypes.1, self.mPath))
        }
        self.derivedWalletTableView.reloadData()
        self.onDeriveAddress()
    }
    
    func onDeriveAddress() {
        print("onDeriveAddress", ChainFactory().getAllSupportPaths(mPath).count)
        print("onDeriveAddress", ChainFactory().getAllSupportPaths(mPath))
        
        let allSupportPaths = ChainFactory().getAllSupportPaths(mPath)
        DispatchQueue(label: "key Que", attributes: .concurrent).async {
            allSupportPaths.forEach { fullPath in
                let pKey = WKey.getPrivateKeyDataFromSeed(self.mSeed, fullPath)
                print(fullPath, "  ", pKey.hexEncodedString())
            }
        }
    }
    
    func onFetchBalance(_ position: Int) {
        let derive = self.mDerives[position]
        let chainConfig = ChainFactory().getChainConfig(derive.chaintype)
        
        if (chainConfig.isGrpc) {
            DispatchQueue.global(qos: .background).async {
                do {
                    let channel = BaseNetWork.getConnection(chainConfig.chainType, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = derive.address! }
                    let response = try Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req).response.wait()
                    self.mDerives[position].coin = Coin.init(chainConfig.stakeDenom, "0")
                    response.balances.forEach { balance in
                        if (balance.denom == chainConfig.stakeDenom) {
                            self.mDerives[position].coin = Coin.init(balance.denom, balance.amount)
                        }
                    }
                    
                } catch { }
                DispatchQueue.main.async(execute: {
                    self.derivedWalletTableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .none)
                });
            }
            
        } else {
            let request = Alamofire.request(BaseNetWork.accountInfoUrl(chainConfig.chainType, derive.address!), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
            request.responseJSON { (response) in
                switch response.result {
                case .success(let res):
                    var tempCoin = Coin.init(chainConfig.stakeDenom, "0")
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
                    DispatchQueue.main.async(execute: {
                        self.mDerives[position].coin = tempCoin
                        self.derivedWalletTableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .none)
                    });
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

struct Derive {
    var chaintype: ChainType
    var hdpathtype: Int
    var path: Int
    var address: String?
    var coin: Coin?
    var status = -1    // 0 == ready, 1 == overide, 2 == already imported
    var selected = false
    
    init(_ chaintype: ChainType, _ hdpathtype: Int, _ path: Int) {
        self.chaintype = chaintype
        self.hdpathtype = hdpathtype
        self.path = path
    }
}

struct HdKey {
    var hdfullpath: String
    var privateKey: Data?
    
    init(_ path: String, _ key: Data?) {
        self.hdfullpath = path
        self.privateKey = key
    }
}
