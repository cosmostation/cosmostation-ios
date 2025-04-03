//
//  OkAddShare.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/21.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie
import SwiftyJSON
import Alamofire
import SDWebImage

class OkAddShare: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleCntLabel: UILabel!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var memoCardView: FixCardView!
    @IBOutlet weak var memoTitle: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoHintLabel: UILabel!
    
    @IBOutlet weak var feeSelectImg: UIImageView!
    @IBOutlet weak var feeSelectLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var feeCurrencyLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!
    
    @IBOutlet weak var voteBtn: BaseButton!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    var selectedChain: ChainOktEVM!
    var oktFetcher: OktFetcher!
    var stakeDenom: String!
    var tokenInfo: JSON!
    var txMemo = ""
    var myValidators = [JSON]()
    
    var gasAmount = NSDecimalNumber(string: BASE_GAS_AMOUNT)
    var gasFee = NSDecimalNumber(string: OKT_BASE_FEE)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseAccount = BaseData.instance.baseAccount
        oktFetcher = selectedChain.getOktfetcher()
        stakeDenom = selectedChain.stakeDenom
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "OktValidatorCell", bundle: nil), forCellReuseIdentifier: "OktValidatorCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0.0
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickTable)))
        memoCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickMemo)))
        
        let allValidators = oktFetcher.oktValidators
        let myValidaorAddress = oktFetcher.oktDeposits["validator_address"].arrayValue.map { $0.stringValue }
        allValidators.forEach { validatorinfo in
            if (myValidaorAddress.contains(validatorinfo["operator_address"].stringValue)) {
                myValidators.append(validatorinfo)
            }
        }
        onUpdateFeeView()
    }
    
    override func setLocalizedString() {
        titleLabel.text = NSLocalizedString("str_select_validators", comment: "")
        memoHintLabel.text = NSLocalizedString("msg_tap_for_add_memo", comment: "")
        voteBtn.setTitle(NSLocalizedString("str_select_validators", comment: ""), for: .normal)
    }
    
    @objc func onClickTable() {
        let selectSheet = OktSelectValidatorSheet(nibName: "OktSelectValidatorSheet", bundle: nil)
        selectSheet.selectedChain = selectedChain
        selectSheet.oktFetcher = oktFetcher
        selectSheet.existSelected = myValidators
        selectSheet.oktSelectValidatorDelegate = self
        guard let sheet = selectSheet.presentationController as? UISheetPresentationController else {
            return
        }
        sheet.largestUndimmedDetentIdentifier = .large
        sheet.prefersGrabberVisible = true
        present(selectSheet, animated: true)
    }
    
    @objc func onClickMemo() {
        let memoSheet = TxMemoSheet(nibName: "TxMemoSheet", bundle: nil)
        memoSheet.existedMemo = txMemo
        memoSheet.memoDelegate = self
        onStartSheet(memoSheet, 260, 0.6)
    }
    
    func onUpdateMemoView(_ memo: String) {
        txMemo = memo
        if (txMemo.isEmpty) {
            memoLabel.isHidden = true
            memoHintLabel.isHidden = false
        } else {
            memoLabel.text = txMemo
            memoLabel.isHidden = false
            memoHintLabel.isHidden = true
        }
    }
    
    func onUpdateFeeView() {
        feeSelectImg.sd_setImage(with: selectedChain.assetImgUrl(stakeDenom), placeholderImage: UIImage(named: "tokenDefault"))
        feeSelectLabel.text = stakeDenom.uppercased()
        
        let existCnt = oktFetcher.oktDeposits["validator_address"].arrayValue.count
        let noCnt = myValidators.count
        let max = (existCnt >= noCnt) ? existCnt : noCnt
        
        gasAmount = NSDecimalNumber(string: BASE_GAS_AMOUNT)
        gasFee = NSDecimalNumber(string: OKT_BASE_FEE)
        if (max > 10) {
            gasFee = gasFee.multiplying(by: NSDecimalNumber(string: "3"))
            gasAmount = gasAmount.multiplying(by: NSDecimalNumber(string: "3"))
        } else if (max > 20) {
            gasFee = gasFee.multiplying(by: NSDecimalNumber(string: "4"))
            gasAmount = gasAmount.multiplying(by: NSDecimalNumber(string: "4"))
        }
        
        guard let msAsset = BaseData.instance.getAsset(selectedChain.apiName, selectedChain.stakeDenom ?? selectedChain.coinSymbol) else { return }
        let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId)
        let feeValue = msPrice.multiplying(by: gasFee, withBehavior: handler6)
        feeAmountLabel?.attributedText = WDP.dpAmount(gasFee.stringValue, feeAmountLabel!.font, 18)
        feeDenomLabel.text = stakeDenom.uppercased()
        WDP.dpValue(feeValue, feeCurrencyLabel, feeValueLabel)
    }
    
    
    @IBAction func onClickVote(_ sender: UIButton) {
        let pinVC = UIStoryboard.PincodeVC(self, .ForDataCheck)
        self.present(pinVC, animated: true)
    }
    
}

extension OkAddShare: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyView.isHidden = myValidators.count > 0
        titleCntLabel.text =  "(" + String(myValidators.count) + ")"
        return myValidators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"OktValidatorCell") as! OktValidatorCell
        cell.bindOktValidator(selectedChain, myValidators[indexPath.row])
        return cell
    }
}

extension OkAddShare: MemoDelegate, PinDelegate, OktSelectValidatorDelegate {
    
    func onOktSelected(_ selected: [JSON]) {
        myValidators = selected
        onUpdateFeeView()
        tableView.reloadData()
        
    }
    func onInputedMemo(_ memo: String) {
        onUpdateMemoView(memo)
    }
    
    func onPinResponse(_ request: LockType, _ result: UnLockResult) {
        if (result == .success) {
            view.isUserInteractionEnabled = false
            voteBtn.isEnabled = false
            loadingView.isHidden = false
            
            Task {
                if let response = try? await broadcastOktAddShareTx() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        print("response ", response)
                        self.loadingView.isHidden = true
                        
                        let txResult = CosmosTxResult(nibName: "CosmosTxResult", bundle: nil)
                        txResult.selectedChain = self.selectedChain
                        txResult.legacyResult = response
                        txResult.modalPresentationStyle = .fullScreen
                        self.present(txResult, animated: true)
                        
                    });
                }
            }
        }
    }
}

extension OkAddShare {
    
    func broadcastOktAddShareTx() async throws -> JSON? {
        let gasCoin = L_Coin(stakeDenom, WUtils.getFormattedNumber(gasFee, 18))
        let fee = L_Fee(gasAmount.stringValue, [gasCoin])
        
        let okMsg = L_Generator.oktAddShareMsg(selectedChain.bechAddress!, myValidators.map{ $0["operator_address"].stringValue })
        let postData = L_Generator.postData([okMsg], fee, txMemo, selectedChain)
        let param = try! JSONSerialization.jsonObject(with: postData, options: .allowFragments) as? [String: Any]
        
        let url = oktFetcher.getLcd() + "txs"
        return try? await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: [:]).serializingDecodable(JSON.self).value
    }
}
