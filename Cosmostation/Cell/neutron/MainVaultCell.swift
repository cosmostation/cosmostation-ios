//
//  MainVaultCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainVaultCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var token0Img: UIImageView!
    @IBOutlet weak var token1Img: UIImageView!
    @IBOutlet weak var token2Img: UIImageView!
    @IBOutlet weak var totalPowerLabel: UILabel!
    @IBOutlet weak var lockTimeLabel: UILabel!
    @IBOutlet weak var myPowerLabel: UILabel!
    
    var actionDeposit: (() -> Void)? = nil
    var actionWithdraw: (() -> Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindView(_ chainConfig: ChainConfig, _ position: Int) {
        let vault = BaseData.instance.mNeutronVaults[0]
        titleLabel.text = vault.name?.uppercased()
        descriptionLabel.text = vault.description
        
        onFetchTotalVotingPower(chainConfig, vault.address!)
        
    }
    
    @IBAction func onClickDeposit(_ sender: UIButton) {
        actionDeposit?()
    }
    @IBAction func onClickWithdraw(_ sender: UIButton) {
        actionWithdraw?()
    }
    
    func onFetchTotalVotingPower(_ chainConfig: ChainConfig, _ contAddress: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(chainConfig)!
                let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                    $0.address = contAddress
                    $0.queryData = Data(base64Encoded: "ewogICAgInRvdGFsX3Bvd2VyX2F0X2hlaWdodCI6IHt9Cn0=")!
                }
                if let response = try? Cosmwasm_Wasm_V1_QueryClient(channel: channel).smartContractState(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    let vaultDeposit = try? JSONDecoder().decode(Cw20VaultDepositRes.self, from: response.data)
                    DispatchQueue.main.async(execute: {
                        self.totalPowerLabel.attributedText = WDP.dpAmount(vaultDeposit?.power, self.totalPowerLabel.font!, 6, 6)
                        self.myPowerLabel.attributedText = WDP.dpAmount(BaseData.instance.mNeutronVaultDeposit.stringValue, self.myPowerLabel.font!, 6, 6)
                    });
                }
                try channel.close().wait()

            } catch {
                print("onFetchTotalVotingPower failed: \(error)")
            }
        }
    }
}



