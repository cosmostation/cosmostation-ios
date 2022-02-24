//
//  RestorePathViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 28/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import GRPC
import NIO

class RestorePathViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var userChain: ChainType?
    var userInputWords: [String]?
    var customPath = 0;
    @IBOutlet weak var restoreTableView: UITableView!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoreTableView.delegate = self
        self.restoreTableView.dataSource = self
        self.restoreTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.restoreTableView.register(UINib(nibName: "RestorePathCell", bundle: nil), forCellReuseIdentifier: "RestorePathCell")
        self.loadingImg.onStartAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_path", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MAX_WALLET_PER_CHAIN
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RestorePathCell? = tableView.dequeueReusableCell(withIdentifier:"RestorePathCell") as? RestorePathCell
        cell?.rootCardView.backgroundColor = WUtils.getChainBg(userChain!)
        WUtils.setDenomTitle(userChain!, cell!.denomTitle)
        
        if (userChain == ChainType.BINANCE_MAIN) {
            cell?.pathLabel.text = BNB_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.IOV_MAIN) {
            cell?.pathLabel.text = IOV_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.BAND_MAIN) {
            cell?.pathLabel.text = BAND_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.KAVA_MAIN) {
            if (self.customPath == 0) { cell?.pathLabel.text = BASE_PATH.appending(String(indexPath.row)) }
            else { cell?.pathLabel.text = KAVA_BASE_PATH.appending(String(indexPath.row)) }
            
        } else if (userChain == ChainType.SECRET_MAIN) {
            if (self.customPath == 0) { cell?.pathLabel.text = BASE_PATH.appending(String(indexPath.row)) }
            else { cell?.pathLabel.text = SECRET_BASE_PATH.appending(String(indexPath.row)) }
            
        } else if (userChain == ChainType.OKEX_MAIN) {
            if (self.customPath == 0) {
                cell?.pathLabel.text = OK_BASE_PATH.appending(String(indexPath.row)) + " (Tendermint Type)"
            } else if (self.customPath == 1) {
                cell?.pathLabel.text = OK_BASE_PATH.appending(String(indexPath.row)) + " (Ethermint Type)"
            } else {
                cell?.pathLabel.text = ETH_NON_LEDGER_PATH.appending(String(indexPath.row)) + " (Ethereum Type)"
            }
            
        } else if (userChain == ChainType.PERSIS_MAIN) {
            cell?.pathLabel.text = PERSIS_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.CRYPTO_MAIN) {
            cell?.pathLabel.text = CRYPTO_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.FETCH_MAIN) {
            if (self.customPath == 0) { cell?.pathLabel.text = BASE_PATH.appending(String(indexPath.row)) }
            else if (self.customPath == 1) { cell?.pathLabel.text = ETH_NON_LEDGER_PATH.appending(String(indexPath.row)) }
            else if (self.customPath == 2) { cell?.pathLabel.text = ETH_LEDGER_LIVE_PATH_1.appending(String(indexPath.row)) + ETH_LEDGER_LIVE_PATH_2 }
            else { cell?.pathLabel.text = ETH_LEDGER_LEGACY_PATH.appending(String(indexPath.row)) }
            
        } else if (userChain == ChainType.MEDI_MAIN) {
            cell?.pathLabel.text = MEDI_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.INJECTIVE_MAIN || userChain == ChainType.EVMOS_MAIN) {
            cell?.pathLabel.text = ETH_NON_LEDGER_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.BITSONG_MAIN) {
            cell?.pathLabel.text = BITSONG_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.DESMOS_MAIN) {
            cell?.pathLabel.text = DESMOS_BASE_PATH.appending(String(indexPath.row))
            
        } else if (userChain == ChainType.LUM_MAIN) {
            if (self.customPath == 0) { cell?.pathLabel.text = BASE_PATH.appending(String(indexPath.row)) }
            else { cell?.pathLabel.text = LUM_BASE_PATH.appending(String(indexPath.row)) }
            
        } else if (userChain == ChainType.PROVENANCE_MAIN) {
            cell?.pathLabel.text = PROVENANCE_BASE_PATH.appending(String(indexPath.row))
            
        } else {
            cell?.pathLabel.text = BASE_PATH.appending(String(indexPath.row))
        }
        
        DispatchQueue.global().async {
            let address = KeyFac.getDpAddressPath(self.userInputWords!, indexPath.row, self.userChain!, self.customPath)
            DispatchQueue.main.async(execute: {
                cell?.addressLabel.text = address
                let tempAccount = BaseData.instance.selectExistAccount(address, self.userChain)
                if (tempAccount == nil) {
                    cell?.stateLabel.text = NSLocalizedString("ready", comment: "")
                    cell?.stateLabel.textColor = UIColor.white
                } else {
                    if (tempAccount!.account_has_private) {
                        cell?.stateLabel.text = NSLocalizedString("imported", comment: "")
                        cell?.stateLabel.textColor = UIColor.init(hexString: "7A7f88")
                        cell?.rootCardView.backgroundColor = UIColor.init(hexString: "2E2E2E", alpha: 0.4)
                    } else {
                        cell?.stateLabel.text = NSLocalizedString("override", comment: "")
                        cell?.stateLabel.textColor = UIColor.white
                    }
                }
                if (WUtils.isGRPC(self.userChain!)) {
                    DispatchQueue.global().async {
                        var amount = "0"
                        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
                        defer { try! group.syncShutdownGracefully() }
                        
                        let channel = BaseNetWork.getConnection(self.userChain!, group)!
                        defer { try! channel.close().wait() }
                        
                        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with {
                            $0.address = address
                        }
                        do {
                            let response = try Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req).response.wait()
                            response.balances.forEach { balance in
                                if (balance.denom == WUtils.getMainDenom(self.userChain)) {
                                    amount = balance.amount
                                }
                            }
                        } catch { }
                        DispatchQueue.main.async(execute: {
                            cell?.denomAmount.attributedText = WUtils.displayAmount2(amount, cell!.denomAmount.font!, WUtils.mainDivideDecimal(self.userChain), WUtils.mainDisplayDecimal(self.userChain))
                            self.dispalyTableView()
                        });
                    }
                }
                
                else {
                    cell?.denomAmount.attributedText = WUtils.displayAmount2(NSDecimalNumber.zero.stringValue, cell!.denomAmount.font!, WUtils.mainDivideDecimal(self.userChain), WUtils.mainDisplayDecimal(self.userChain))
                    let request = Alamofire.request(BaseNetWork.accountInfoUrl(self.userChain, address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
                    request.responseJSON { (response) in
                        switch response.result {
                        case .success(let res):
                            self.dispalyTableView()
                            if (self.userChain == ChainType.BINANCE_MAIN) {
                                if let responseData = res as? NSDictionary {
                                    let bnbAccountInfo = BnbAccountInfo.init(responseData)
                                    if let coin = bnbAccountInfo.balances.filter({$0.symbol == WUtils.getMainDenom(self.userChain)}).first {
                                        cell?.denomAmount.attributedText = WUtils.displayAmount2(coin.free , cell!.denomAmount.font!, WUtils.mainDivideDecimal(self.userChain), WUtils.mainDisplayDecimal(self.userChain))
                                    }
                                }
                                
                            } else if (self.userChain == ChainType.OKEX_MAIN) {
                                if let responseData = res as? NSDictionary {
                                    let okAccountInfo = OkAccountInfo.init(responseData)
                                    if let coin = okAccountInfo.value?.coins.filter({$0.denom == WUtils.getMainDenom(self.userChain)}).first {
                                        cell?.denomAmount.attributedText = WUtils.displayAmount2(coin.amount , cell!.denomAmount.font!, WUtils.mainDivideDecimal(self.userChain), WUtils.mainDisplayDecimal(self.userChain))
                                    }
                                }
                                
                            } else {
                                if let responseData = res as? NSDictionary, let info = responseData.object(forKey: "result") as? NSDictionary {
                                    let accountInfo = AccountInfo.init(info)
                                    if (accountInfo.type == COSMOS_AUTH_TYPE_ACCOUNT && accountInfo.value.coins.count > 0) {
                                        if let coin = accountInfo.value.coins.filter({$0.denom == WUtils.getMainDenom(self.userChain)}).first {
                                            cell?.denomAmount.attributedText = WUtils.displayAmount2(coin.amount , cell!.denomAmount.font!, WUtils.mainDivideDecimal(self.userChain), WUtils.mainDisplayDecimal(self.userChain))
                                        }
                                    }
                                }
                            }
                        
                        
                        case .failure(let error):
                            print("onFetchAccountInfo ", error)
                        }
                    }
                    
                }

            });
        }
        return cell!
    }
    
    func dispalyTableView() {
        self.loadingImg.onStopAnimation()
        self.loadingImg.isHidden = true
        self.restoreTableView.isHidden = false
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:RestorePathCell? = tableView.cellForRow(at: indexPath) as? RestorePathCell
        if (cell?.stateLabel.text == NSLocalizedString("imported", comment: "")) {
            return
        } else if (cell?.stateLabel.text == NSLocalizedString("ready", comment: "")) {
            BaseData.instance.setLastTab(0)
            self.onGenAccount(self.userInputWords!, self.userChain!, indexPath.row, self.customPath)

        } else {
            BaseData.instance.setLastTab(0)
            self.onOverrideAccount(self.userInputWords!, self.userChain!, indexPath.row, self.customPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86;
    }
    
    func onGenAccount(_ mnemonic: [String], _ chain: ChainType, _ path: Int, _ customBipPath: Int) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            
            let newAccount = Account.init(isNew: true)
            newAccount.account_path = String(path)
            newAccount.account_address = KeyFac.getDpAddressPath(mnemonic, path, chain, customBipPath)
            newAccount.account_base_chain = WUtils.getChainDBName(chain)
            
            var resource: String = ""
            for word in self.userInputWords! {
                resource = resource + " " + word
            }
            let mnemonoicResult = KeychainWrapper.standard.set(resource, forKey: newAccount.account_uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            
            var insertResult :Int64 = -1
            if (mnemonoicResult) {
                newAccount.account_has_private = true
                newAccount.account_from_mnemonic = true
                newAccount.account_path = String(path)
                newAccount.account_m_size = Int64(self.userInputWords!.count)
                newAccount.account_import_time = Date().millisecondsSince1970
                newAccount.account_custom_path = Int64(customBipPath)
                newAccount.account_sort_order = 9999
                insertResult = BaseData.instance.insertAccount(newAccount)
                
                if(insertResult < 0) {
                    KeychainWrapper.standard.removeObject(forKey: newAccount.account_uuid.sha1())
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                if (mnemonoicResult && insertResult > 0) {
                    var hiddenChains = BaseData.instance.userHideChains()
                    if (hiddenChains.contains(chain)) {
                        if let position = hiddenChains.firstIndex { $0 == chain } {
                            hiddenChains.remove(at: position)
                        }
                        BaseData.instance.setUserHiddenChains(hiddenChains)
                    }
                    BaseData.instance.setLastTab(0)
                    BaseData.instance.setRecentAccountId(insertResult)
                    BaseData.instance.setRecentChain(chain)
                    self.onStartMainTab()
                }
            });
        }
    }
    
    
    func onOverrideAccount(_ mnemonic: [String], _ chain:ChainType, _ path:Int, _ customBipPath: Int) {
        self.showWaittingAlert()
        DispatchQueue.global().async {
            var resource: String = ""
            for word in self.userInputWords! {
                resource = resource + " " + word
            }
            let dpAddress = KeyFac.getDpAddressPath(mnemonic, path, chain, customBipPath)
            let existedAccount = BaseData.instance.selectExistAccount(dpAddress, chain)
            let keyResult = KeychainWrapper.standard.set(resource, forKey: existedAccount!.account_uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)
            var updateResult :Int64 = -1
            if(keyResult) {
                existedAccount!.account_has_private = true
                existedAccount!.account_from_mnemonic = true
                existedAccount!.account_path = String(path)
                existedAccount!.account_m_size = Int64(self.userInputWords!.count)
                existedAccount!.account_custom_path = Int64(customBipPath)
                updateResult = BaseData.instance.overrideAccount(existedAccount!)
                
                if(updateResult < 0) {
                    KeychainWrapper.standard.removeObject(forKey: existedAccount!.account_uuid.sha1())
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.hideWaittingAlert()
                if(keyResult && updateResult > 0) {
                    var hiddenChains = BaseData.instance.userHideChains()
                    if (hiddenChains.contains(chain)) {
                        if let position = hiddenChains.firstIndex { $0 == chain } {
                            hiddenChains.remove(at: position)
                        }
                        BaseData.instance.setUserHiddenChains(hiddenChains)
                    }
                    BaseData.instance.setLastTab(0)
                    BaseData.instance.setRecentAccountId(existedAccount!.account_id)
                    BaseData.instance.setRecentChain(chain)
                    self.onStartMainTab()
                }
            });
        }
    }
}
