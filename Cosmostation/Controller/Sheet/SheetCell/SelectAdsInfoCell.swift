//
//  SelectAdsInfoCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 1/22/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import UIKit

class SelectAdsInfoCell: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var viewDetailLabel: UILabel!
    
    private let adsInfo: AdsInfo
    private let onViewAction: (AdsInfo) -> Void

    init(adInfo: AdsInfo, onViewAction: @escaping (AdsInfo) -> Void) {
        self.adsInfo = adInfo
        self.onViewAction = onViewAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        detailView.layer.cornerRadius = 4
        detailView.clipsToBounds = true
        detailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToDetail)))

        loadDataView()
    }

    private func loadDataView() {
        guard let image = adsInfo.images.mobile, let url = URL(string: image) else {
            imageView.image = UIImage(named: "popUpDrop")
            return
        }
        
        let viewDetail = adsInfo.view_detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let viewDetail, !viewDetail.isEmpty {
            viewDetailLabel.isHidden = false
            detailView.isHidden = false
            
            viewDetailLabel.text = viewDetail
            detailView.backgroundColor = UIColor(hex: adsInfo.color ?? "#000000") ?? .black
            
        } else {
            viewDetailLabel.isHidden = true
            detailView.isHidden = true
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = img
            }
        }.resume()
    }
    
    @objc func moveToDetail() {
        onViewAction(adsInfo)
    }
}
