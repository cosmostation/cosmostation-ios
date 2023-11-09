//
//  QrScanVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AVFoundation

class QrScanVC: UIViewController {
    
    var scanDelegate: QrScanDelegate?
    
    @IBOutlet weak var guideImg: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            
            view.bringSubviewToFront(guideImg)
            view.bringSubviewToFront(cancelBtn)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print(error)
            let alert = UIAlertController(title: NSLocalizedString("error_access_camera_title", comment: ""), message: NSLocalizedString("error_access_camera_msg", comment: ""), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
            let settingAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (action) in
                guard let appSettingURl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(appSettingURl) {
                    UIApplication.shared.open(appSettingURl, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(settingAction)
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "QR Scan";
        self.navigationItem.title = "QR Scan";
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    @IBAction func onClickCancel(_ sender: BaseButton) {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getStringData(_ stringData: String) {
        if presentedViewController != nil {
            return
        }
        if (self.navigationController != nil) {
            scanDelegate?.onScanned(stringData)
            self.navigationController?.popViewController(animated: false)
            return
            
        } else {
            self.dismiss(animated: true) {
                self.scanDelegate?.onScanned(stringData)
                return
            }
            return
            
        }
    }
}

extension QrScanVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                getStringData(metadataObj.stringValue!)
            }
        }
    }
    
}

protocol QrScanDelegate{
    func onScanned(_ result: String)
}
