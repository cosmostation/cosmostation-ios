//
//  MnemonicListViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/04/28.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class MnemonicListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mnemonicListTableView: UITableView!
    
    var mMyMnemonics = Array<MWords>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mnemonicListTableView.delegate = self
        self.mnemonicListTableView.dataSource = self
        self.mnemonicListTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.mnemonicListTableView.register(UINib(nibName: "ManageMnemonicCell", bundle: nil), forCellReuseIdentifier: "ManageMnemonicCell")
        self.mnemonicListTableView.rowHeight = UITableView.automaticDimension
        self.mnemonicListTableView.estimatedRowHeight = UITableView.automaticDimension
        
        mMyMnemonics = BaseData.instance.selectAllMnemonics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_mnemonic_manage", comment: "");
        self.navigationItem.title = NSLocalizedString("title_mnemonic_manage", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
        print("didSelectRowAt ", indexPath.row)
        let mnemonicDetailVC = MnemonicDetailViewController(nibName: "MnemonicDetailViewController", bundle: nil)
        mnemonicDetailVC.mnemonicId = mMyMnemonics[indexPath.row].id
        self.navigationItem.title = ""
        self.navigationController?.pushViewController(mnemonicDetailVC, animated: true)
    }

    @IBAction func onClickCreate(_ sender: UIButton) {
        print("onClickCreate")
    }
}
