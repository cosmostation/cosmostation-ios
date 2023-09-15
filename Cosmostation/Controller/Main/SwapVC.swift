//
//  SwapVC.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SwapVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let swapStartVC = SwapStartVC(nibName: "SwapStartVC", bundle: nil)
//        swapStartVC.modalTransitionStyle = .coverVertical
//        self.present(swapStartVC, animated: true)
    }
    
    func initView() {
        baseAccount = BaseData.instance.baseAccount
        navigationItem.leftBarButtonItem = leftBarButton(baseAccount?.name)
    }
    
    @IBAction func onClickTest(_ sender: UIButton) {
        let swapStartVC = SwapStartVC(nibName: "SwapStartVC", bundle: nil)
        swapStartVC.modalTransitionStyle = .coverVertical
        self.present(swapStartVC, animated: true)
    }

}


extension SwapVC: BaseSheetDelegate {
    
    func leftBarButton(_ name: String?, _ imge: UIImage? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "naviCon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        button.setTitle(name == nil ? "Account" : name, for: .normal)
        button.titleLabel?.font = .fontSize16Bold
        button.sizeToFit()
        button.addTarget(self, action: #selector(onClickSwitchAccount(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

    @objc func onClickSwitchAccount(_ sender: UIButton) {
        let baseSheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        baseSheet.sheetDelegate = self
        baseSheet.sheetType = .SwitchAccount
        onStartSheet(baseSheet)
    }

    public func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult) {
        if (sheetType == .SwitchAccount) {
            if let toAddcountId = Int64(result.param!) {
                if (BaseData.instance.baseAccount?.id != toAddcountId) {
                    showWait()
                    DispatchQueue.global().async {
                        let toAccount = BaseData.instance.selectAccount(toAddcountId)
                        BaseData.instance.setLastAccount(toAccount!.id)
                        BaseData.instance.baseAccount = toAccount
                        
                        DispatchQueue.main.async(execute: {
                            self.hideWait()
                            self.onStartMainTab()
                        });
                    }
                }
            }
        }
    }
}
