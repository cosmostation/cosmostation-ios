//
//  AnnouncementPopUpSheet.swift
//  Cosmostation
//
//  Created by 권혁준 on 2/9/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import UIKit

class AnnouncementPopUpSheet: BaseVC {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var webButton: UIView!
    @IBOutlet weak var viewDetailBtnLabel: UILabel!
    
    var announcement: AdsInfo!
    var sheetDelegate: BaseSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)

        popUpView.layer.cornerRadius = 12
        popUpView.layer.borderWidth = 1
        popUpView.layer.borderColor = UIColor.colorBg.cgColor
        popUpView.clipsToBounds = true
        
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        
        webButton.layer.cornerRadius = 4
        webButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToAnnouncement)))

        loadDataView()
    }
    
    private func loadDataView() {
        guard let image = announcement.images.mobile, let imageUrl = URL(string: image) else {
            imageView.image = UIImage(named: "popUpDrop")
            return
        }
        
        let viewDetail = announcement.view_detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let viewDetail, !viewDetail.isEmpty {
            viewDetailBtnLabel.isHidden = false
            webButton.isHidden = false
            
            viewDetailBtnLabel.text = viewDetail
            webButton.backgroundColor = UIColor(hex: announcement.color ?? "#000000") ?? .black
            
        } else {
            viewDetailBtnLabel.isHidden = true
            webButton.isHidden = true
        }

        URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = img
            }
        }.resume()
    }
    
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc func moveToAnnouncement() {
        guard let urlStr = announcement.linkUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !urlStr.isEmpty else { return }
        
        dismiss(animated: true) { [weak self] in
            self?.sheetDelegate?.onSelectedSheet(nil, ["url": urlStr])
        }
    }
}

extension AnnouncementPopUpSheet: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !touch.view!.isDescendant(of: popUpView)
    }
}
