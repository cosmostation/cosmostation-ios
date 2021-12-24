//
//  GenNFT0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/23.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class GenNFT0ViewController: UIViewController {

    @IBOutlet weak var nftImageView: UIImageView!
    @IBOutlet weak var nftAddBtn: UIButton!
    @IBOutlet weak var nftDeleteBtn: UIButton!
    
    @IBOutlet weak var nftNameTextView: UITextView!
    @IBOutlet weak var nftDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        nftAddBtn.alignTextBelow()
        
        nftNameTextView.layer.borderWidth = 1.0
        nftNameTextView.layer.borderColor = UIColor(hexString: "#7A7F88").cgColor
        nftNameTextView.layer.cornerRadius = 8
        
        nftDescriptionTextView.layer.borderWidth = 1.0
        nftDescriptionTextView.layer.borderColor = UIColor(hexString: "#7A7F88").cgColor
        nftDescriptionTextView.layer.cornerRadius = 8
        
        onUpdateImgView(nil)
    }
    
    
    
    func onUpdateImgView(_ hash: String?) {
        if (hash != nil) {
            nftImageView.image = nil
            nftAddBtn.isHidden = true
            nftDeleteBtn.isHidden = false
            nftImageView.layer.sublayers = nil
            
        } else {
            nftImageView.image = nil
            nftAddBtn.isHidden = false
            nftDeleteBtn.isHidden = true
            
            nftImageView.clipsToBounds = true
            nftImageView.layer.cornerRadius = 8
            let dashBorder = CAShapeLayer()
            dashBorder.strokeColor = UIColor(hexString: "#7A7F88").cgColor
            dashBorder.lineWidth = 1
            dashBorder.lineDashPattern = [2, 4]
            dashBorder.fillColor = nil
            dashBorder.frame = nftImageView.bounds
            dashBorder.path = UIBezierPath(roundedRect: nftImageView.bounds, cornerRadius: 8).cgPath
            nftImageView.layer.addSublayer(dashBorder)
        }
    }
    

    @IBAction func onClickImgAdd(_ sender: UIButton) {
    }
    @IBAction func onClickImgDele(_ sender: UIButton) {
    }
}


extension UIButton {
    func alignTextBelow(spacing: CGFloat = 8.0) {
        guard let image = self.imageView?.image else {
            return
        }
        
        guard let titleLabel = self.titleLabel else {
            return
        }
        
        guard let titleText = titleLabel.text else {
            return
        }
        
        let titleSize = titleText.size(withAttributes: [
            NSAttributedString.Key.font: titleLabel.font as Any
        ])
        
        titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
    }
}
