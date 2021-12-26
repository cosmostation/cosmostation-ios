//
//  GenNFT0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/23.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import Photos

class GenNFT0ViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var nftImageView: UIImageView!
    @IBOutlet weak var nftAddBtn: UIButton!
    @IBOutlet weak var nftDeleteBtn: UIButton!
    @IBOutlet weak var nftNameTextView: UITextView!
    @IBOutlet weak var nftDescriptionTextView: UITextView!
    
    var pageHolderVC: StepGenTxViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
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
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    
    
    func onUpdateImgView(_ hash: String?) {
        if (hash != nil) {
//            nftImageView.image = nil
            nftAddBtn.isHidden = true
            nftDeleteBtn.isHidden = false
            nftImageView.layer.sublayers = nil
            
        } else {
//            nftImageView.image = nil
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage? = nil
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = image
        } else if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = image
        }
//        nftImageView.image = newImage
        picker.dismiss(animated: true) {
            //TODO upload & get hash with ipfs
            
        }
    }
    

    @IBAction func onClickImgAdd(_ sender: UIButton) {
        authCheck()
    }
    
    @IBAction func onClickImgDele(_ sender: UIButton) {
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        nftImageView.image = UIImage(named: "kavamainImg")
    }
    
    
    func authCheck() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized) {
            self.openPhotoLibrary()
            
        } else if (status == .denied) {
            self.showAlertForSettings()
            
        } else if (status == .notDetermined) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == PHAuthorizationStatus.authorized {
                    self.openPhotoLibrary()
                    
                } else {
                    self.showAlertForSettings()
                }
            }
            
        } else if (status == .restricted) {
            self.showAlertForSettings()
        }
    }
    
    func showAlertForSettings() {
        let settingsAlert = UIAlertController (title: NSLocalizedString("permission_photo_title", comment: "") , message: nil, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        settingsAlert .addAction(cancelAction)
        settingsAlert .addAction(settingsAction)
        self.present(settingsAlert , animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        DispatchQueue.main.async(execute: {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
            
        });
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
