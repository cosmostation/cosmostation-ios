//
//  MnemonicListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/04/28.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class MnemonicListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, PasswordViewDelegate {
    
    @IBOutlet weak var mnemonicListTableView: UITableView!
    
    var mMyMnemonics = Array<MWords>()
    var mSelected: Int64?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mnemonicListTableView.delegate = self
        self.mnemonicListTableView.dataSource = self
        self.mnemonicListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.mnemonicListTableView.register(UINib(nibName: "ManageMnemonicCell", bundle: nil), forCellReuseIdentifier: "ManageMnemonicCell")
        self.mnemonicListTableView.rowHeight = UITableView.automaticDimension
        self.mnemonicListTableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_mnemonic_manage", comment: "")
        self.navigationItem.title = NSLocalizedString("title_mnemonic_manage", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.mMyMnemonics = BaseData.instance.selectAllMnemonics()
        self.mnemonicListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mMyMnemonics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ManageMnemonicCell") as? ManageMnemonicCell
        cell?.onBindView(mMyMnemonics[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mSelected = mMyMnemonics[indexPath.row].id
        self.onCheckPassword()
    }

    @IBAction func onClickCreate(_ sender: UIButton) {
        let mnemonicCreateVC = MnemonicCreateViewController(nibName: "MnemonicCreateViewController", bundle: nil)
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(mnemonicCreateVC, animated: true)
    }
    
    @IBAction func onClickimport(_ sender: UIButton) {
        let mnemonicImportVC = MnemonicRestoreViewController(nibName: "MnemonicRestoreViewController", bundle: nil)
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(mnemonicImportVC, animated: true)
    }
    
    func onCheckPassword() {
        if (!BaseData.instance.hasPassword()) {
            let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
            self.navigationItem.title = ""
            self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
            passwordVC.resultDelegate = self
            passwordVC.mTarget = PASSWORD_ACTION_INIT
            self.navigationController?.pushViewController(passwordVC, animated: false)
            
        } else {
            if (BaseData.instance.isAutoPass()) {
                self.onStartMenmonicDetail()
                
            } else {
                let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                self.navigationItem.title = ""
                self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
                passwordVC.resultDelegate = self
                passwordVC.mTarget = PASSWORD_ACTION_SIMPLE_CHECK
                self.navigationController?.pushViewController(passwordVC, animated: false)
                
            }
        }
    }
    
    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.onStartMenmonicDetail()
            });
        }
    }
    
    func onStartMenmonicDetail() {
        let mnemonicDetailVC = MnemonicDetailViewController(nibName: "MnemonicDetailViewController", bundle: nil)
        mnemonicDetailVC.mnemonicId = self.mSelected!
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(mnemonicDetailVC, animated: true)
    }
}
