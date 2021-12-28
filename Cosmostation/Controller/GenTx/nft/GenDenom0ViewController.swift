//
//  GenDenom0ViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/28.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import SwiftProtobuf

class GenDenom0ViewController: BaseViewController {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var denomIdInput: AddressInputTextField!
    @IBOutlet weak var denomNameInput: AddressInputTextField!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        self.pageHolderVC = self.parent as? StepGenTxViewController
        
        self.denomIdInput.placeholder = "Insert Unique Denom ID"
        self.denomNameInput.placeholder = "Insert Denom Name"
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    @IBAction func onClickBack(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        self.pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        let inputDenom = self.denomIdInput.text?.trimmingCharacters(in: .whitespaces)
        if (!WUtils.checkNftDenomId(inputDenom!)) {
            self.onShowToast(NSLocalizedString("error_nft_denom_count", comment: ""))
            return;
        }
        self.onCheckUniqueDenom(inputDenom!)
    }
    
    func onNextPage() {
        self.pageHolderVC.mNFTDenomId = self.denomIdInput.text?.trimmingCharacters(in: .whitespaces).lowercased()
        self.pageHolderVC.mNFTDenomName = self.denomNameInput.text?.trimmingCharacters(in: .whitespaces)
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        self.pageHolderVC.onNextPage()
    }

    func onCheckUniqueDenom(_ denomId: String) {
        print("onCheckUniqueDenom ", denomId)
        if (chainType == ChainType.IRIS_MAIN) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    let req = Irismod_Nft_QueryDenomRequest.with { $0.denomID = denomId }
                    if let response = try? Irismod_Nft_QueryClient(channel: channel).denom(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        DispatchQueue.main.async(execute: {
                            self.onShowToast(NSLocalizedString("error_nft_denom_exist", comment: ""))
                            return
                        });
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.onNextPage()
                        });
                    }
                    try channel.close().wait()
                } catch {
                    print("IRIS QueryDenomRequest failed: \(error)")
                }
            }
            
        } else if (chainType == ChainType.CRYPTO_MAIN) {
            DispatchQueue.global().async {
                do {
                    let channel = BaseNetWork.getConnection(self.chainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                    let req = Chainmain_Nft_V1_QueryDenomRequest.with { $0.denomID = denomId }
                    if let response = try? Chainmain_Nft_V1_QueryClient(channel: channel).denom(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                        DispatchQueue.main.async(execute: {
                            self.onShowToast(NSLocalizedString("error_nft_denom_exist", comment: ""))
                            return
                        });
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.onNextPage()
                        });
                    }
                    try channel.close().wait()
                } catch {
                    print("CRO QueryDenomRequest failed: \(error)")
                }
            }
            
        }
    }
}
