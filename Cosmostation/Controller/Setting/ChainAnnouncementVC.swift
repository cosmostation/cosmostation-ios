//
//  ChainAnnouncementVC.swift
//  Cosmostation
//
//  Created by 권혁준 on 2/9/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import UIKit

class ChainAnnouncementVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var announcementList = [AdsInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ChainAnnouncementCell", bundle: nil), forCellReuseIdentifier: "ChainAnnouncementCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        announcementList = BaseData.instance.adsInfos?.sorted {
            let o1 = $0.dateStringToLong(date: $0.startAt)
            let o2 = $1.dateStringToLong(date: $1.startAt)
            return o1 > o2
        } ?? []
        
        let hasData = !announcementList.isEmpty
        tableView.isHidden = !hasData
        emptyView.isHidden = hasData
    }
    
    override func setLocalizedString() {
        navigationItem.title = NSLocalizedString("str_chain_announcement", comment: "")
    }
    
    func onShowAnnounceDetail(_ announcement: AdsInfo) {
        let announcementPopUpView = AnnouncementPopUpSheet(nibName: "AnnouncementPopUpSheet", bundle: nil)
        announcementPopUpView.announcement = announcement
        announcementPopUpView.sheetDelegate = self
        announcementPopUpView.modalPresentationStyle = .overFullScreen
        self.present(announcementPopUpView, animated: true)
    }
}

extension ChainAnnouncementVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcementList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ChainAnnouncementCell") as! ChainAnnouncementCell
        let announcement = announcementList[indexPath.row]
        cell.bindAnnouncement(announcement)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = announcementList[indexPath.row]
        onShowAnnounceDetail(announcement)
    }
}

extension ChainAnnouncementVC: BaseSheetDelegate {
    
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if let urlStr = result["url"] as? String {
            guard let url = URL(string: urlStr) else { return }
            self.onShowSafariWeb(url)
        }
    }
}
