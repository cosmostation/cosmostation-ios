//
//  GenProfile0ViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2022/01/07.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit
import Photos
import Ipfs
import GRPC
import NIO

class GenProfile0ViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editRootView: UIView!
    @IBOutlet weak var dTagTextView: UITextView!
    @IBOutlet weak var nickNameTextView: UITextView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addCoverBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!
    var coverObject: ObjectModel?
    var profileObject: ObjectModel?
    var isCover = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        self.loadingImg.isHidden = true
        self.dTagTextView.delegate = self
        self.nickNameTextView.delegate = self
        self.bioTextView.delegate = self
        
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor(named: "_font05")!.cgColor
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
        
        Ipfs.shared().setBase(address: "https://ipfs.infura.io", port: 5001, apiVersionPath: "/api/v0")
        Ipfs.swarm.peers { (result) in
            self.loadingImg.stopAnimating()
            self.loadingImg.isHidden = true
            switch result {
            case let .success(response):
                self.inInitView()
                break
            case let .failure(error):
                self.onIPFSNetworkError()
                break
            }
        }
        self.editRootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:))))
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onProfileimg (_:))))
        self.profileImageView.isUserInteractionEnabled = true
    }
    
    func inInitView() {
        addCoverBtn.alignTextBelow()
        dTagTextView.layer.borderWidth = 1.0
        dTagTextView.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        dTagTextView.layer.cornerRadius = 8
        nickNameTextView.layer.borderWidth = 1.0
        nickNameTextView.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        nickNameTextView.layer.cornerRadius = 8
        bioTextView.layer.borderWidth = 1.0
        bioTextView.layer.borderColor = UIColor.init(named: "_font05")!.cgColor
        bioTextView.layer.cornerRadius = 8
        
        onUpdateCoverImgView(nil)
        onUpdateProfileImgView(nil)
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if (textView == dTagTextView) {
            DispatchQueue.main.async {
                let offset = CGPoint(x: 0, y: 140)
                self.scrollView.setContentOffset(offset, animated: true)
            }
        } else if (textView == nickNameTextView) {
            DispatchQueue.main.async {
                let offset = CGPoint(x: 0, y: 220)
                self.scrollView.setContentOffset(offset, animated: true)
            }
        } else if (textView == bioTextView) {
            DispatchQueue.main.async {
                let offset = CGPoint(x: 0, y: 340)
                self.scrollView.setContentOffset(offset, animated: true)
            }
        }
        return true
    }
    
    func onUpdateCoverImgView(_ hash: String?) {
        if (hash != nil) {
            coverImageView.af_setImage(withURL: URL(string: NFT_INFURA + hash!)!)
            addCoverBtn.isHidden = true
            coverImageView.layer.sublayers = nil
        } else {
            coverImageView.image = nil
            addCoverBtn.isHidden = false
            
            coverImageView.clipsToBounds = true
            coverImageView.layer.cornerRadius = 8
            let dashBorder = CAShapeLayer()
            dashBorder.strokeColor = UIColor.init(named: "_font05")!.cgColor
            dashBorder.lineWidth = 1
            dashBorder.lineDashPattern = [2, 4]
            dashBorder.fillColor = nil
            dashBorder.frame = coverImageView.bounds
            dashBorder.path = UIBezierPath(roundedRect: coverImageView.bounds, cornerRadius: 8).cgPath
            coverImageView.layer.addSublayer(dashBorder)
        }
    }
    
    func onUpdateProfileImgView(_ hash: String?) {
        if (hash != nil) {
            profileImageView.af_setImage(withURL: URL(string: NFT_INFURA + hash!)!)
        } else {
            profileImageView.image = UIImage(named: "profileimgNone")
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
                    if (self.isCover) {
                        self.onUpdateCoverImgView(self.coverObject?.hash)
                    } else {
                        self.onUpdateProfileImgView(self.profileObject?.hash)
                    }
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
                if (self.isCover) {
                    let object = try? moyaResponse.map(ObjectModel.self)
                    self.coverObject = object
                    handler(object != nil)
                } else {
                    let object = try? moyaResponse.map(ObjectModel.self)
                    self.profileObject = object
                    handler(object != nil)
                }
                break
            case let .failure(error):
                print("failure: \(error.localizedDescription)")
                handler(false)
                break
            }
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let dtag = self.dTagTextView.text?.trimmingCharacters(in: .whitespaces)
        if (dtag?.isEmpty == true) {
            self.onShowToast(NSLocalizedString("error_insert_dtag", comment: ""))
            return
        }
        self.view.endEditing(true)
        self.onFetchgRPCDtag(dtag!)
    }
    
    @IBAction func onClickCoverimg(_ sender: UIButton) {
        self.isCover = true
        self.authCheck()
    }
    
    @objc func onProfileimg (_ sender: UITapGestureRecognizer) {
        print("onProfileimg")
        self.isCover = false
        self.authCheck()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
        settingsAlert.addAction(cancelAction)
        settingsAlert.addAction(settingsAction)
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
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: { _ in
            self.pageHolderVC.onBeforePage()
        }))
    }
    
    //check for already exist domain
    func onFetchgRPCDtag(_ dtag: String) {
        DispatchQueue.global().async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            defer { try! group.syncShutdownGracefully() }
            
            let channel = BaseNetWork.getConnection(self.chainType!, group)!
            defer { try! channel.close().wait() }
            
            do {
                let req = Desmos_Profiles_V1beta1_QueryProfileRequest.with { $0.user = dtag }
                let response = try Desmos_Profiles_V1beta1_QueryClient(channel: channel).profile(req, callOptions:BaseNetWork.getCallOptions()).response.wait()
                print("onFetchgRPCDtag ", response)
                DispatchQueue.main.async(execute: {
                    self.onShowToast(NSLocalizedString("error_already_registered_domain", comment: ""))
                    return
                });
                
            } catch {
                print("onFetchgRPCDomainInfo failed: \(error)")
                DispatchQueue.main.async(execute: {
                    self.onGoNextPage()
                });
            }
        }
    }
    
    func onGoNextPage() {
        pageHolderVC.mDesmosDtag = self.dTagTextView.text?.trimmingCharacters(in: .whitespaces)
        pageHolderVC.mDesmosNickName = self.nickNameTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        pageHolderVC.mDesmosBio = self.bioTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        pageHolderVC.mDesmosCoverHash = coverObject?.hash ?? ""
        pageHolderVC.mDesmosProfileHash = profileObject?.hash ?? ""
        btnCancel.isUserInteractionEnabled = false
        btnNext.isUserInteractionEnabled = false
        pageHolderVC.onNextPage()
    }
}
