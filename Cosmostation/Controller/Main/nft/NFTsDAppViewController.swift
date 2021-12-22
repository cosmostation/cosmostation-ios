//
//  NFTsDAppViewController.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class NFTsDAppViewController: BaseViewController {
    
    @IBOutlet weak var dAppsSegment: UISegmentedControl!
    @IBOutlet weak var myNFTsView: UIView!
    @IBOutlet weak var topNFTsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        myNFTsView.alpha = 1
        topNFTsView.alpha = 0
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        if #available(iOS 13.0, *) {
            dAppsSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            dAppsSegment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            dAppsSegment.selectedSegmentTintColor =  WUtils.getChainDarkColor(self.chainType)
        } else {
            dAppsSegment.tintColor = WUtils.getChainColor(self.chainType)
        }
    }
    
    @IBAction func switchView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            myNFTsView.alpha = 1
            topNFTsView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            myNFTsView.alpha = 0
            topNFTsView.alpha = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("title_nft", comment: "");
        self.navigationItem.title = NSLocalizedString("title_nft", comment: "");
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}

struct NFTCollectionId {
    var denom_id: String?
    var token_ids:String?
    
    init(_ denom_id: String?, _ token_ids: String?) {
        self.denom_id = denom_id
        self.token_ids = token_ids
    }
}


extension WUtils {
    static func getNftDescription(_ text: String?) -> String {
        if let data = text?.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                
                if let description = json?.object(forKey: "description") as? String {
                    return description
                }
                if let description = json?.value(forKeyPath: "body.description") as? String {
                    return description
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
    static func getNftIssuer(_ text: String?) -> String {
        if let data = text?.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                
                if let issuerAddr = json?.object(forKey: "issuerAddr") as? String {
                    return issuerAddr
                }
                if let issuerAddr = json?.value(forKeyPath: "body.issuerAddr") as? String {
                    return issuerAddr
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
    
}

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .allowFragments),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}
