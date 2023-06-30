//
//  MainDappViewController.swift
//  Cosmostation
//
//  Created by y on 2022/07/27.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MainDappViewController: BaseViewController {
    @IBOutlet weak var searchTextField: UITextField!
    var mainTabVC: MainTabViewController!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var dapps: [NSDictionary] = []
    var filteredDapps: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.tableView.register(UINib(nibName: "DappCell", bundle: nil), forCellReuseIdentifier: "DappCell")
        loadDapp()
    }
    
    private func loadDapp() {
        let request = Alamofire.request("https://raw.githubusercontent.com/cosmostation/chainlist/master/dapp/dapps.json", method: .get, encoding: URLEncoding.default)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let result = res as? [NSDictionary] {
                    self.dapps = result
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func currentThemeParams() -> String {
        var themeParams = "dark"
        if (BaseData.instance.getThemeType() == .unspecified) {
            if (self.traitCollection.userInterfaceStyle != .dark) {
                themeParams = "light"
            }
        } else if (BaseData.instance.getThemeType() == .light) {
            themeParams = "light"
        }
        return themeParams
    }
    
    @IBAction func searchTextChange() {
        filteredDapps = []
        if let text = searchTextField.text {
            if !text.isEmpty {
                if text.starts(with: "http") {
                    filteredDapps.append(["title": "\"\(text)\" - Open in Browser", "url":text, "description":""])
                } else {
                    filteredDapps.append(["title": "\"\(text)\" - Search in Google", "url":"https://www.google.com/search?q=\(text)", "description":""])
                }
                filteredDapps += dapps.filter({ item in
                    var contain = false
                    if let title = item["title"] as? String {
                        contain = contain || title.lowercased().contains(text.lowercased())
                    }
                    if let title = item["description"] as? String {
                        contain = contain || title.lowercased().contains(text.lowercased())
                    }
                    if let title = item["url"] as? String {
                        contain = contain || title.lowercased().contains(text.lowercased())
                    }
                    return contain
                })
            }
        }
        
        if filteredDapps.isEmpty {
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.emptyView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    func openWeb(_ url: String) {
        let commonWcVC = CommonWCViewController(nibName: "CommonWCViewController", bundle: nil)
        commonWcVC.modalPresentationStyle = .fullScreen
        commonWcVC.dappURL = url
        commonWcVC.connectType = .INTERNAL_DAPP
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            self.present(commonWcVC, animated: false, completion: nil)
        })
        self.searchTextField.resignFirstResponder()
        self.searchTextField.text = ""
        self.tableView.isHidden = true
        self.emptyView.isHidden = false
    }
}

extension MainDappViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= filteredDapps.count {
            return UITableViewCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier:"DappCell") as? DappCell {
            let item = filteredDapps[indexPath.row]
            if let logo = item["logo"] as? String, let url = URL(string: logo) {
                cell.iconImg.af_setImage(withURL: url)
            } else {
                cell.iconImg.image = nil
            }
            cell.descriptionLabel.text = item["description"] as? String
            cell.titleLabel.text = item["title"] as? String
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredDapps[indexPath.row]
        openWeb(item["url"] as? String ?? "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDapps.count
    }
}

extension MainDappViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let urlString = textField.text {
            openWeb(urlString)
        }
        return true
    }
}
