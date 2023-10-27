//
//  ServiceVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ServiceVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ServiceCell", bundle: nil), forCellReuseIdentifier: "ServiceCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        initView()
    }
    
    func initView() {
        baseAccount = BaseData.instance.baseAccount
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.name)
    }
    
    func onOpenMoonpay() {
        var query = "?apiKey=" + MOON_PAY_PUBLICK
        let param = ["api_key" : query] as [String : Any]
        AF.request(CSS_MOON_PAY, method: .post, parameters: param, encoding: JSONEncoding.default).responseDecodable(of: JSON.self)  { response in
            switch response.result {
            case .success(let res):
                if let signauture = res["signature"].string {
                    let signauture2 = signauture.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                        let urlMoonpay = URL(string: MOON_PAY_URL + query + "&signature=" + signauture2!)
                        if (UIApplication.shared.canOpenURL(urlMoonpay!)) {
                            UIApplication.shared.open(urlMoonpay!, options: [:], completionHandler: nil)
                        }
                    });
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                        self.onShowToast(NSLocalizedString("error_network_msg", comment: ""))
                    });
                }
                
            case .failure(let error):
                self.onShowToast("\(error)")
            }
        }
    }
    
    func onOpenKado() {
        let query = "?apiKey=" + KADO_PAY_PUBLICK
        let urlKadoMoney = URL(string: KADO_PAY_URL + query)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if (UIApplication.shared.canOpenURL(urlKadoMoney!)) {
                UIApplication.shared.open(urlKadoMoney!, options: [:], completionHandler: nil)
            }
        });
    }
    
    func onOpenBinance() {
        let binanceUrl = URL(string: BINANCE_BUY_URL)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if (UIApplication.shared.canOpenURL(binanceUrl!)) {
                UIApplication.shared.open(binanceUrl!, options: [:], completionHandler: nil)
            }
        });
    }
}

extension ServiceVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.titleLabel.text = "Service List"
        view.cntLabel.text = ""
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1 && BaseData.instance.reviewMode) {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ServiceCell") as! ServiceCell
        cell.onBindService(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let swapStartVC = SwapStartVC(nibName: "SwapStartVC", bundle: nil)
            swapStartVC.modalTransitionStyle = .coverVertical
            self.present(swapStartVC, animated: true)
            
        } else if (indexPath.row == 1) {
            let dappStartVC = DappStartVC(nibName: "DappStartVC", bundle: nil)
            dappStartVC.modalTransitionStyle = .coverVertical
            self.present(dappStartVC, animated: true)
            
        } else {
            let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            baseSheet.sheetDelegate = self
            baseSheet.sheetType = .SelectBuyCrypto
            onStartSheet(baseSheet)
        }
    }
}


extension ServiceVC: BaseSheetDelegate {
    
    func leftBarButton(_ name: String?, _ imge: UIImage? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "naviCon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        button.setTitle(name == nil ? "Account" : name, for: .normal)
        button.titleLabel?.font = .fontSize16Bold
        button.sizeToFit()
        button.addTarget(self, action: #selector(onClickSwitchAccount(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    @objc func onClickSwitchAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SwitchAccount
        onStartSheet(baseSheet)
    }

    public func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SwitchAccount) {
            if let toAddcountId = Int64(result.param!) {
                if (BaseData.instance.baseAccount?.id != toAddcountId) {
                    showWait()
                    DispatchQueue.global().async {
                        let toAccount = BaseData.instance.selectAccount(toAddcountId)
                        BaseData.instance.setLastAccount(toAccount!.id)
                        BaseData.instance.baseAccount = toAccount
                        
                        DispatchQueue.main.async(execute: {
                            self.hideWait()
                            self.onStartMainTab()
                        });
                    }
                }
            }
            
        } else if (sheetType == .SelectBuyCrypto) {
            if (result.position == 0) {
                onOpenMoonpay()
            } else if (result.position == 1) {
                onOpenKado()
            } else if (result.position == 2) {
                onOpenBinance()
            }
            
        }
    }
}
