//
//  WalletDeriveViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/05/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class WalletDeriveViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mnemonicNameLabel: UILabel!
    @IBOutlet weak var walletCntLabel: UILabel!
    @IBOutlet weak var totalWalletCntLabel: UILabel!
    @IBOutlet weak var pathCardView: CardView!
    @IBOutlet weak var selectedHDPathLabel: UILabel!
    @IBOutlet weak var derivedWalletTableView: UITableView!
    
    var mWords: MWords!
    var mPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.derivedWalletTableView.delegate = self
        self.derivedWalletTableView.dataSource = self
        self.derivedWalletTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.derivedWalletTableView.register(UINib(nibName: "DeriveWalletCell", bundle: nil), forCellReuseIdentifier: "DeriveWalletCell")
        self.derivedWalletTableView.rowHeight = UITableView.automaticDimension
        self.derivedWalletTableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.mnemonicNameLabel.text = self.mWords.getName()
        self.walletCntLabel.text = "7"
        self.totalWalletCntLabel.text = "/ 50"
        self.selectedHDPathLabel.text = String(mPath)
        
        let tapPath = UITapGestureRecognizer(target: self, action: #selector(self.onClickPath))
        self.pathCardView.addGestureRecognizer(tapPath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChainFactory().getAllKeyType().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"DeriveWalletCell") as? DeriveWalletCell
        let baseChain = ChainFactory().getAllKeyType()[indexPath.row]
        cell?.onBindWallet(mWords, baseChain.0, baseChain.1, mPath)
        return cell!
    }
    
    @objc func onClickPath() {
        print("onClickPath")
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onClickDerive(_ sender: UIButton) {
    }
}
