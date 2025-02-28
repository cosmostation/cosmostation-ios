//
//  EcosystemPopUpSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 2/27/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit

class EcosystemPopUpSheet: BaseVC {
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ecosystemButton: UIView!
    @IBOutlet weak var ecosystemBtnLabel: UILabel!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var selectedChain: BaseChain!
    var tag: Int!
    
    var sheetDelegate: BaseSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 12
        popUpView.layer.borderWidth = 1
        popUpView.layer.borderColor = UIColor.colorBg.cgColor
        popUpView.clipsToBounds = true
        
        ecosystemButton.layer.cornerRadius = 4
        
        hideButton.configuration?.contentInsets = .zero
        
        //TODO: hideButton localization
        
        onBindEcosystemImage(tag)
    }
    
    private func onBindEcosystemImage(_ tag: Int) {
        if tag == SheetType.MoveDropDetail.rawValue {
            imageView.image = UIImage(named: "popUpDrop")
            ecosystemButton.backgroundColor = .colorDrop

        } else if tag == SheetType.MoveDydx.rawValue {
            imageView.image = UIImage(named: "popUpDydx")
            ecosystemButton.backgroundColor = .colorDydx

        } else if tag == SheetType.MoveBabylonDappDetail.rawValue {
            imageView.image = UIImage(named: "popUpBabylon")
            ecosystemButton.backgroundColor = .colorBabylon
        }
        ecosystemButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToDapp)))
    }
    
    @objc func moveToDapp() {
        dismiss(animated: true)
        sheetDelegate?.onSelectedSheet(SheetType(rawValue: tag), [:])
    }
    
    @IBAction func closePopUpView(_ sender: Any) {
        dismiss(animated: true)
    }
}
