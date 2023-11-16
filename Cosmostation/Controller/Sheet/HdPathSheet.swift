//
//  HdPathSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/16.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class HdPathSheet: BaseVC {
    
    @IBOutlet weak var hdPathTitle: UILabel!
    @IBOutlet weak var hdPathMsgLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cosmosPathLabel: UILabel!
    @IBOutlet weak var ethereumPathLabel: UILabel!
    @IBOutlet weak var kavaPathLabel: UILabel!
    @IBOutlet weak var confirmBtn: BaseButton!
    
    var hdPathDelegate: HdPathDelegate?
    var hdPath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(hdPath, inComponent: 0, animated: false)
        
        onUpdateHdPathView()
    }
    
    override func setLocalizedString() {
        hdPathTitle.text = NSLocalizedString("str_select_hd_path", comment: "")
        hdPathMsgLabel.text = NSLocalizedString("msg_create_another_msg", comment: "")
        confirmBtn.setTitle(NSLocalizedString("str_confirm", comment: ""), for: .normal)
    }
    
    
    @IBAction func onClickConfirm(_ sender: UIButton) {
        hdPathDelegate?.onSelectedHDPath(hdPath)
        dismiss(animated: true)
    }
    
    func onUpdateHdPathView() {
        let cosmosPath = "m/44'/118'/0'/0/X"
        let dpCosmosPath = cosmosPath.replacingOccurrences(of: "X", with: String(hdPath))
        let cosmosRange = (cosmosPath as NSString).range(of: "X")
        let cosmosAttributedString = NSMutableAttributedString(string: dpCosmosPath)
        cosmosAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color01 , range: cosmosRange)
        cosmosPathLabel.attributedText = cosmosAttributedString

        let ethPath = "m/44'/60'/0'/0/X"
        let dpEthPath = ethPath.replacingOccurrences(of: "X", with: String(hdPath))
        let ethRange = (ethPath as NSString).range(of: "X")
        let ethAttributedString = NSMutableAttributedString(string: dpEthPath)
        ethAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color01 , range: ethRange)
        ethereumPathLabel.attributedText = ethAttributedString

        let kavaPath = "m/44'/459'/0'/0/X"
        let dpKavaPath = kavaPath.replacingOccurrences(of: "X", with: String(hdPath))
        let kavaRange = (kavaPath as NSString).range(of: "X")
        let kavaAttributedString = NSMutableAttributedString(string: dpKavaPath)
        kavaAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.color01 , range: kavaRange)
        kavaPathLabel.attributedText = kavaAttributedString
    }
}


extension HdPathSheet: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.hdPath = row
        onUpdateHdPathView()
    }
    
}

protocol HdPathDelegate {
    func onSelectedHDPath(_ path: Int)
}
