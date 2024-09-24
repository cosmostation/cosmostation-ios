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
        tableView.register(UINib(nibName: "NoticeTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeTableViewCell")
        
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
    
    
    @objc func titleTap(sender: UITapGestureRecognizer) {
        print(#function)
        let section = sender.view!.tag
        if shownSections.contains(section) {
            shownSections.remove(section)
            tableView.reloadSections(IndexSet.init(integer: section), with: .fade)

        } else {
            shownSections.insert(section)
            tableView.reloadSections(IndexSet.init(integer: section), with: .fade)
            tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: UITableView.ScrollPosition.top, animated: true)
        }
    }
    

}

extension NoticeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shownSections.contains(section) {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"NoticeTableViewCell") as! NoticeTableViewCell
        
        cell.setNoticeContent("### Chain Support\r\n- Support SUI Mainnet\r\n- Support MANTRA Testnet\r\n### Additional\r\n- Support Drop-money\r\n- Support End-point initialization\r\n" + "### Changes\r\n- Support Drop-money\r\n- Support End-point initialization")

        return cell
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NoticeHeaderView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleTap(sender:)))
        header.tag = section
        header.addGestureRecognizer(tapGesture)
        header.setHeaderView(notices: notices, section: section, shownSections: shownSections)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return notices.count
    }
}




// MARK: HEADER
class NoticeHeaderView: UITableViewHeaderFooterView {
    
    let rootView = CardViewCell()
    let createdDateLabel = UILabel()
    let typeTag = RoundedPaddingLabel()
    let titleLabel = UILabel()
    let image = UIImageView()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
        backgroundColor = .color07
        
        addSubview(rootView)
        rootView.addSubview(createdDateLabel)
        rootView.addSubview(titleLabel)
        rootView.addSubview(image)
        

        rootView.translatesAutoresizingMaskIntoConstraints = false
        createdDateLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: topAnchor),
            rootView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootView.rightAnchor.constraint(equalTo: rightAnchor),
            rootView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, constant: 25)
        ])
        
        NSLayoutConstraint.activate([
            createdDateLabel.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 0),
            createdDateLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20),
            createdDateLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5)
        ])
        
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: rootView.centerYAnchor),
            //            image.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            image.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20),
            image.widthAnchor.constraint(equalToConstant: 20),
            image.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: createdDateLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(greaterThanOrEqualTo: rootView.bottomAnchor, constant: -5),
            titleLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -10)
        ])
        
        
        image.contentMode = .scaleAspectFit
        image.setContentCompressionResistancePriority(.required, for: .horizontal)
        image.tintColor = .color02
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHeaderView(notices: [JSON], section: Int, shownSections: Set<Int>) {
        createdDateLabel.text = WDP.dpDate(notices[section]["created_at"].stringValue)
        createdDateLabel.font = .fontSize10Bold
                
        let titleString = " \(notices[section]["type"].stringValue)  \(notices[section]["title"].stringValue)"
        let attributedString = NSMutableAttributedString(string: titleString)
        let range = (titleString as NSString).range(of: " \(notices[section]["type"].stringValue) ")

        attributedString.addAttribute(NSAttributedString.Key.backgroundColor,
                                      value: UIColor.color04,
                                      range: range)
        
        attributedString.addAttribute(NSAttributedString.Key.font,
                                      value: UIFont.fontSize10Bold,
                                      range: range)
        

        titleLabel.font = UIFont.fontSize14Bold
        titleLabel.attributedText = attributedString
        titleLabel.numberOfLines = 0

        if shownSections.contains(section) {
            image.image = UIImage(systemName: "chevron.up")
        } else {
            image.image = UIImage(systemName: "chevron.down")
        }
    }
}
