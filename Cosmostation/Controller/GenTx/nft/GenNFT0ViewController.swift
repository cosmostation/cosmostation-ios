//
//  GenNFT0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/23.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import Photos
import Ipfs

class GenNFT0ViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editRootView: UIView!
    @IBOutlet weak var nftImageView: UIImageView!
    @IBOutlet weak var nftAddBtn: UIButton!
    @IBOutlet weak var nftDeleteBtn: UIButton!
    @IBOutlet weak var nftNameTextView: UITextView!
    @IBOutlet weak var nftDescriptionTextView: UITextView!
    @IBOutlet weak var nftDenomIdLabel: UITextView!
    @IBOutlet weak var nftDenomNameLabel: UITextView!
    
    var pageHolderVC: StepGenTxViewController!
    var object: ObjectModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.nftNameTextView.delegate = self
        self.nftDescriptionTextView.delegate = self
        self.loadingImg.startAnimating()
        
        Ipfs.shared().setBase(address: "https://ipfs.infura.io", port: 5001, apiVersionPath: "/api/v0")
        Ipfs.swarm.peers { (result) in
            self.loadingImg.stopAnimating()
            self.loadingImg.isHidden = true
            switch result {
            case .success:
                self.inInitView()
            case .failure:
                self.onIPFSNetworkError()
            }
        }
        self.editRootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:))))
    }
    
    func inInitView() {
        nftAddBtn.alignTextBelow()
        nftNameTextView.layer.borderWidth = 1.0
        nftNameTextView.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        nftNameTextView.layer.cornerRadius = 8
        nftDescriptionTextView.layer.borderWidth = 1.0
        nftDescriptionTextView.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        nftDescriptionTextView.layer.cornerRadius = 8
        nftDenomIdLabel.layer.borderWidth = 1.0
        nftDenomIdLabel.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        nftDenomIdLabel.layer.cornerRadius = 8
        nftDenomNameLabel.layer.borderWidth = 1.0
        nftDenomNameLabel.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        nftDenomNameLabel.layer.cornerRadius = 8
        
        let randomUUID = STATION_NFT_DENOM + UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        nftDenomIdLabel.text = randomUUID
        nftDenomNameLabel.text = randomUUID
        print("randomUUID ", randomUUID)
        
        onUpdateImgView(nil)
        editRootView.isHidden = false
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if (textView == nftNameTextView) {
            DispatchQueue.main.async {
                let offset = CGPoint(x: 0, y: 100)
                self.scrollView.setContentOffset(offset, animated: true)
            }
        } else if (textView == nftDescriptionTextView) {
            DispatchQueue.main.async {
                let offset = CGPoint(x: 0, y: 200)
                self.scrollView.setContentOffset(offset, animated: true)
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n" && textView == nftNameTextView) {
            nftDescriptionTextView.becomeFirstResponder()
            return false
        }
        return true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func onUpdateImgView(_ hash: String?) {
        if (hash != nil) {
            nftImageView.af_setImage(withURL: URL(string: NFT_INFURA + hash!)!)
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
            dashBorder.strokeColor = UIColor.init(named: "_font05")!.cgColor
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
        picker.dismiss(animated: true) {
            self.showWaittingAlert()
            self.imageUpload(newImage!) { (success) in
                if success {
                    self.onUpdateImgView(self.object?.hash)
                } else {
                    self.onShowToast(NSLocalizedString("error_fail_upload_img", comment: ""))
                }
                self.hideWaittingAlert()
            }
        }
    }
    
    func imageUpload(_ imag: UIImage, _ handler: @escaping (Bool)->()) {
        guard let data = imag.fixOrientation().pngData() else { return }
        Ipfs.files.add(data: data) { (result) in
            switch result {
            case let .success(moyaResponse):
                let object = try? moyaResponse.map(ObjectModel.self)
                self.object = object
                handler(object != nil)
                break
            case let .failure(error):
                print("failure: \(error.localizedDescription)")
                handler(false)
                break
            }
        }
    }
    

    @IBAction func onClickImgAdd(_ sender: UIButton) {
        authCheck()
    }
    
    @IBAction func onClickImgDele(_ sender: UIButton) {
        object = nil
        onUpdateImgView(nil)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (object == nil) {
            self.onShowToast(NSLocalizedString("error_no_nft_image", comment: ""))
            return
        }
        if (nftNameTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == true) {
            self.onShowToast(NSLocalizedString("error_no_nft_title", comment: ""))
            return
        }
        if (nftDescriptionTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == true) {
            self.onShowToast(NSLocalizedString("error_no_nft_dexcription", comment: ""))
            return
        }
        
        self.pageHolderVC.mNFTHash = object?.hash!
        self.pageHolderVC.mNFTName = nftNameTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.pageHolderVC.mNFTDescription = nftDescriptionTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.pageHolderVC.mNFTDenomId = nftDenomIdLabel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.pageHolderVC.mNFTDenomName = nftDenomNameLabel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
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
        if #available(iOS 13.0, *) { settingsAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
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
    
    func onIPFSNetworkError() {
        let title = NSLocalizedString("str_ipfs_connect_fail_title", comment: "")
        let msg = NSLocalizedString("str_ipfs_connect_fail_msg", comment: "")
        let noticeAlert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if #available(iOS 13.0, *) { noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType() }
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { _ in
            self.pageHolderVC.onBeforePage()
        }))
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
