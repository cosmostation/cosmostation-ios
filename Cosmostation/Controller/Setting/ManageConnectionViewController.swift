//
//  WalletDetailViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 03/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class ManageConnectionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var items = WalletConnectManager.shared.getWhitelist()
    
    private func reloadItems() {
        items = WalletConnectManager.shared.getWhitelist()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionLabel.text = NSLocalizedString("wc_manage_description", comment: "")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.register(UINib(nibName: "ManageConnectionCell", bundle: nil), forCellReuseIdentifier: "ManageConnectionCell")
        reloadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("wc_manage_title", comment: "")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:"ManageConnectionCell") as? ManageConnectionCell {
            let url = self.items[indexPath.row]
            cell.url.text = url
            cell.action = {
                let title = NSLocalizedString("wc_manage_disconnect_alert_message", comment: "")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
                    WalletConnectManager.shared.removeWhitelist(url: url)
                    self.reloadItems()
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default))
                self.present(alert, animated: true)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
