//
//  NoticeVC.swift
//  Cosmostation
//
//  Created by 차소민 on 9/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class NoticeVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var notices: [JSON] = []
    var shownSections: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
        navigationItem.title = NSLocalizedString("str_notice", comment: "")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NoticeTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeTitleTableViewCell")
        tableView.register(UINib(nibName: "NoticeContentTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeContentTableViewCell")

        view.isUserInteractionEnabled = false
        
        loadingView.isHidden = false
        loadingView.animation = LottieAnimation.named("loading")
        loadingView.contentMode = .scaleAspectFit
        loadingView.loopMode = .loop
        loadingView.animationSpeed = 1.3
        loadingView.play()

        Task {
            notices = await fetchNotice()
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.view.isUserInteractionEnabled = true
                self.tableView.reloadData()
            }
        }
    }
    
    
    func fetchNotice() async -> [JSON] {
        let url = "https://front.api.mintscan.io/v10/notice?include_content=true&flatform=MOBILE"
        do {
            let noticeList = try await AF.request(url).serializingDecodable(JSON.self).value
            return noticeList["list"].arrayValue
            
        } catch {
            onShowToast("Error: \(error)")
            return []
        }
    }
}

extension NoticeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shownSections.contains(indexPath.section) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"NoticeContentTableViewCell") as! NoticeContentTableViewCell
            cell.setNoticeContent(notices[indexPath.section])
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTitleTableViewCell") as! NoticeTitleTableViewCell
            cell.setNoticeTitle(notices[indexPath.section])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if shownSections.contains(section) {
            shownSections.remove(section)
            tableView.reloadSections(IndexSet.init(integer: section), with: .fade)

        } else {
            shownSections.insert(section)
            tableView.reloadSections(IndexSet.init(integer: section), with: .fade)
            tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: UITableView.ScrollPosition.top, animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return notices.count
    }
}
