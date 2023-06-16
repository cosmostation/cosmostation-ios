//
//  TxDetailgRPCViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/17.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit
import GRPC
import NIO
import web3swift
import Alamofire

class TxDetailgRPCViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var txTableView: UITableView!
    @IBOutlet weak var controlLayer: UIStackView!
    @IBOutlet weak var errorLayer: CardView!
    @IBOutlet weak var errorCode: UILabel!
    @IBOutlet weak var loadingImg: LoadingImageView!
    @IBOutlet weak var txDetailTitle: UILabel!
    @IBOutlet weak var btnshare: UIButton!
    @IBOutlet weak var btnexplorer: UIButton!
    @IBOutlet weak var btnDone: UIButton!

    
    var mIsGen: Bool = true
    var mTxHash: String?
    var mBroadCaseResult: Cosmos_Tx_V1beta1_BroadcastTxResponse?
    var mFetchCnt = 10
    var mTxRespose: Cosmos_Tx_V1beta1_GetTxResponse?
    
    var mEthResultHash: String?
    var mEthTx: TransactionDetails?
    var mEthRecipient: TransactionReceipt?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = ChainFactory.getChainType(account!.account_base_chain)
        self.chainConfig = ChainFactory.getChainConfig(chainType)
        self.loadingImg.onStartAnimation()
        
        self.txDetailTitle.text = NSLocalizedString("str_tx_detail", comment: "")
        self.btnshare.setTitle(NSLocalizedString("str_share", comment: ""), for: .normal)
        self.btnexplorer.setTitle(NSLocalizedString("str_explorer", comment: ""), for: .normal)
        self.btnDone.setTitle(NSLocalizedString("str_done", comment: ""), for: .normal)

        self.txTableView.delegate = self
        self.txTableView.dataSource = self
        self.txTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.txTableView.rowHeight = UITableView.automaticDimension
        self.txTableView.estimatedRowHeight = UITableView.automaticDimension
        self.txTableView.register(UINib(nibName: "TxCommonCell", bundle: nil), forCellReuseIdentifier: "TxCommonCell")
        self.txTableView.register(UINib(nibName: "TxTransferCell", bundle: nil), forCellReuseIdentifier: "TxTransferCell")
        self.txTableView.register(UINib(nibName: "TxDelegateCell", bundle: nil), forCellReuseIdentifier: "TxDelegateCell")
        self.txTableView.register(UINib(nibName: "TxUndelegateCell", bundle: nil), forCellReuseIdentifier: "TxUndelegateCell")
        self.txTableView.register(UINib(nibName: "TxRedelegateCell", bundle: nil), forCellReuseIdentifier: "TxRedelegateCell")
        self.txTableView.register(UINib(nibName: "TxRewardCell", bundle: nil), forCellReuseIdentifier: "TxRewardCell")
        self.txTableView.register(UINib(nibName: "TxCommissionCell", bundle: nil), forCellReuseIdentifier: "TxCommissionCell")
        self.txTableView.register(UINib(nibName: "TxEditRewardAddressCell", bundle: nil), forCellReuseIdentifier: "TxEditRewardAddressCell")
        self.txTableView.register(UINib(nibName: "TxVoteCell", bundle: nil), forCellReuseIdentifier: "TxVoteCell")
        //for starname msg type
        self.txTableView.register(UINib(nibName: "TxRegisterDomainCell", bundle: nil), forCellReuseIdentifier: "TxRegisterDomainCell")
        self.txTableView.register(UINib(nibName: "TxRegisterAccountCell", bundle: nil), forCellReuseIdentifier: "TxRegisterAccountCell")
        self.txTableView.register(UINib(nibName: "TxDeleteDomainCell", bundle: nil), forCellReuseIdentifier: "TxDeleteDomainCell")
        self.txTableView.register(UINib(nibName: "TxDeleteAccountCell", bundle: nil), forCellReuseIdentifier: "TxDeleteAccountCell")
        self.txTableView.register(UINib(nibName: "TxReplaceResourceCell", bundle: nil), forCellReuseIdentifier: "TxReplaceResourceCell")
        self.txTableView.register(UINib(nibName: "TxRenewStarnameCell", bundle: nil), forCellReuseIdentifier: "TxRenewStarnameCell")
        //for osmosis msg type
        self.txTableView.register(UINib(nibName: "TxCreatePoolCell", bundle: nil), forCellReuseIdentifier: "TxCreatePoolCell")
        self.txTableView.register(UINib(nibName: "TxJoinPoolCell", bundle: nil), forCellReuseIdentifier: "TxJoinPoolCell")
        self.txTableView.register(UINib(nibName: "TxExitPoolCell", bundle: nil), forCellReuseIdentifier: "TxExitPoolCell")
        self.txTableView.register(UINib(nibName: "TxTokenSwapCell", bundle: nil), forCellReuseIdentifier: "TxTokenSwapCell")
        self.txTableView.register(UINib(nibName: "TxLockTokenCell", bundle: nil), forCellReuseIdentifier: "TxLockTokenCell")
        self.txTableView.register(UINib(nibName: "TxBeginUnlockTokenCell", bundle: nil), forCellReuseIdentifier: "TxBeginUnlockTokenCell")
        self.txTableView.register(UINib(nibName: "TxBeginUnlockAllTokensCell", bundle: nil), forCellReuseIdentifier: "TxBeginUnlockAllTokensCell")
        
        //for ibc msg type
        self.txTableView.register(UINib(nibName: "TxIbcSendCell", bundle: nil), forCellReuseIdentifier: "TxIbcSendCell")
        self.txTableView.register(UINib(nibName: "TxIbcReceiveCell", bundle: nil), forCellReuseIdentifier: "TxIbcReceiveCell")
        self.txTableView.register(UINib(nibName: "TxIbcUpdateClientCell", bundle: nil), forCellReuseIdentifier: "TxIbcUpdateClientCell")
        self.txTableView.register(UINib(nibName: "TxIbcAcknowledgeCell", bundle: nil), forCellReuseIdentifier: "TxIbcAcknowledgeCell")
        
        //for rizon
        self.txTableView.register(UINib(nibName: "TxRizonEventHorizonCell", bundle: nil), forCellReuseIdentifier: "TxRizonEventHorizonCell")
        
        //for NFT msg type
        self.txTableView.register(UINib(nibName: "TxIssueNFTDenomCell", bundle: nil), forCellReuseIdentifier: "TxIssueNFTDenomCell")
        self.txTableView.register(UINib(nibName: "TxIssueNFTCell", bundle: nil), forCellReuseIdentifier: "TxIssueNFTCell")
        self.txTableView.register(UINib(nibName: "TxSendNFTCell", bundle: nil), forCellReuseIdentifier: "TxSendNFTCell")
        
        //for Desmos msg type
        self.txTableView.register(UINib(nibName: "TxSaveProfileCell", bundle: nil), forCellReuseIdentifier: "TxSaveProfileCell")
        self.txTableView.register(UINib(nibName: "TxLinkAccountCell", bundle: nil), forCellReuseIdentifier: "TxLinkAccountCell")
        
        //for Kava msg type
        self.txTableView.register(UINib(nibName: "TxCdpCreateCell", bundle: nil), forCellReuseIdentifier: "TxCdpCreateCell")
        self.txTableView.register(UINib(nibName: "TxCdpDepositCell", bundle: nil), forCellReuseIdentifier: "TxCdpDepositCell")
        self.txTableView.register(UINib(nibName: "TxCdpWithdrawCell", bundle: nil), forCellReuseIdentifier: "TxCdpWithdrawCell")
        self.txTableView.register(UINib(nibName: "TxCdpBorrowCell", bundle: nil), forCellReuseIdentifier: "TxCdpBorrowCell")
        self.txTableView.register(UINib(nibName: "TxCdpRepayCell", bundle: nil), forCellReuseIdentifier: "TxCdpRepayCell")
        self.txTableView.register(UINib(nibName: "TxCdpLiquidateCell", bundle: nil), forCellReuseIdentifier: "TxCdpLiquidateCell")
        self.txTableView.register(UINib(nibName: "TxHardDepositCell", bundle: nil), forCellReuseIdentifier: "TxHardDepositCell")
        self.txTableView.register(UINib(nibName: "TxHardWithdrawCell", bundle: nil), forCellReuseIdentifier: "TxHardWithdrawCell")
        self.txTableView.register(UINib(nibName: "TxHardBorrowCell", bundle: nil), forCellReuseIdentifier: "TxHardBorrowCell")
        self.txTableView.register(UINib(nibName: "TxHardRepayCell", bundle: nil), forCellReuseIdentifier: "TxHardRepayCell")
        self.txTableView.register(UINib(nibName: "TxHardLiquidateCell", bundle: nil), forCellReuseIdentifier: "TxHardLiquidateCell")
        self.txTableView.register(UINib(nibName: "TxSwapDepositCell", bundle: nil), forCellReuseIdentifier: "TxSwapDepositCell")
        self.txTableView.register(UINib(nibName: "TxSwapWithdrawCell", bundle: nil), forCellReuseIdentifier: "TxSwapWithdrawCell")
        self.txTableView.register(UINib(nibName: "TxSwapTokenCell", bundle: nil), forCellReuseIdentifier: "TxSwapTokenCell")
        self.txTableView.register(UINib(nibName: "TxIncentiveMintingCell", bundle: nil), forCellReuseIdentifier: "TxIncentiveMintingCell")
        self.txTableView.register(UINib(nibName: "TxIncentiveHardCell", bundle: nil), forCellReuseIdentifier: "TxIncentiveHardCell")
        self.txTableView.register(UINib(nibName: "TxIncentiveSwapCell", bundle: nil), forCellReuseIdentifier: "TxIncentiveSwapCell")
        self.txTableView.register(UINib(nibName: "TxIncentiveDelegatorCell", bundle: nil), forCellReuseIdentifier: "TxIncentiveDelegatorCell")
        self.txTableView.register(UINib(nibName: "TxIncentiveEarnCell", bundle: nil), forCellReuseIdentifier: "TxIncentiveEarnCell")
        self.txTableView.register(UINib(nibName: "TxEarnCell", bundle: nil), forCellReuseIdentifier: "TxEarnCell")
        
        //for wasm msg type
        self.txTableView.register(UINib(nibName: "TxStoreContractCell", bundle: nil), forCellReuseIdentifier: "TxStoreContractCell")
        self.txTableView.register(UINib(nibName: "TxInstantContractCell", bundle: nil), forCellReuseIdentifier: "TxInstantContractCell")
        self.txTableView.register(UINib(nibName: "TxExeContractCell", bundle: nil), forCellReuseIdentifier: "TxExeContractCell")
        
        //for authz execute msg type
        self.txTableView.register(UINib(nibName: "TxAuthzExecCell", bundle: nil), forCellReuseIdentifier: "TxAuthzExecCell")
        
        //for EVM tx
        self.txTableView.register(UINib(nibName: "TxEvmCell", bundle: nil), forCellReuseIdentifier: "TxEvmCell")
        
        //for Liquid Staking
        self.txTableView.register(UINib(nibName: "TxLiquidStakeCell", bundle: nil), forCellReuseIdentifier: "TxLiquidStakeCell")
        
        //for Persistence Liquid Staking
        self.txTableView.register(UINib(nibName: "TxPersisLiquidStakeCell", bundle: nil), forCellReuseIdentifier: "TxPersisLiquidStakeCell")
        
        //for unknown msg type
        self.txTableView.register(UINib(nibName: "TxUnknownCell", bundle: nil), forCellReuseIdentifier: "TxUnknownCell")
        
        if (mIsGen) {
            if (mEthResultHash != nil) {
                self.onFetchEvmTx(mEthResultHash!)
                
            } else if (mBroadCaseResult?.txResponse.code != 0 || mBroadCaseResult?.txResponse.txhash == nil) {
                self.onShowError(mBroadCaseResult?.txResponse.code, mBroadCaseResult?.txResponse.rawLog)
                
            } else {
                mTxHash = mBroadCaseResult?.txResponse.txhash
                self.onFetchgRPCTx(mTxHash!)
                
            }
            
        } else {
            //TODO temp added
//            self.onFetchgRPCTx(mTxHash!)
//            self.onFetchEvmTx(mEthResultHash!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func onUpdateView() {
        self.loadingImg.isHidden = true
        self.controlLayer.isHidden = false
        self.txTableView.isHidden = false
        self.txTableView.reloadData()
    }
    
    func onShowError(_ code: UInt32?, _ msg: String?) {
        let dpCode = code ?? 8000
        let dpMsg = msg ?? "unKnown"
        
        self.loadingImg.isHidden = true
        self.errorCode.text = "error code : " + String(dpCode) + "\n" + dpMsg
        self.errorLayer.isHidden = false
        self.controlLayer.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mEthResultHash != nil) {
            return 1
            
        } else {
            if (mTxRespose == nil || mTxRespose!.tx.body.messages.count <= 0) { return 0 }
            return mTxRespose!.tx.body.messages.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chainConfig = chainConfig else {
            return UITableViewCell()
        }
        if (mEthResultHash != nil) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"TxEvmCell") as? TxEvmCell
            cell?.onBindEvm(chainConfig, mEthTx, mEthRecipient)
            return cell!
            
        } else {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier:"TxCommonCell") as? TxCommonCell
                cell?.onBind(chainConfig, mTxRespose!)
                return cell!
                
            } else {
                let msg = mTxRespose!.tx.body.messages[indexPath.row - 1]
                if (msg.typeURL.contains(Cosmos_Bank_V1beta1_MsgSend.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxTransferCell") as? TxTransferCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1, account!.account_address)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Staking_V1beta1_MsgDelegate.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxDelegateCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Staking_V1beta1_MsgUndelegate.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxUndelegateCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Staking_V1beta1_MsgBeginRedelegate.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxRedelegateCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Distribution_V1beta1_MsgWithdrawDelegatorReward.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxRewardCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Distribution_V1beta1_MsgWithdrawValidatorCommission.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCommissionCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Distribution_V1beta1_MsgSetWithdrawAddress.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxEditRewardAddressCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmos_Gov_V1beta1_MsgVote.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxVoteCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Ibc_Applications_Transfer_V1_MsgTransfer.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIbcSendCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Ibc_Core_Channel_V1_MsgRecvPacket.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIbcReceiveCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Ibc_Core_Client_V1_MsgUpdateClient.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIbcUpdateClientCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Ibc_Core_Channel_V1_MsgAcknowledgement.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIbcAcknowledgeCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                }
                
                else if (msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgRegisterDomain.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxRegisterDomainCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgRegisterAccount.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxRegisterAccountCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgDeleteDomain.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxDeleteDomainCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgDeleteAccount.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxDeleteAccountCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgRenewDomain.protoMessageName) || msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgRenewAccount.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxRenewStarnameCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Starnamed_X_Starname_V1beta1_MsgReplaceAccountResources.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxReplaceResourceCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Osmosis_Gamm_V1beta1_MsgSwapExactAmountIn.protoMessageName) || msg.typeURL.contains(Osmosis_Gamm_V1beta1_MsgSwapExactAmountOut.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxTokenSwapCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Irismod_Nft_MsgIssueDenom.protoMessageName) || msg.typeURL.contains(Chainmain_Nft_V1_MsgIssueDenom.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIssueNFTDenomCell") as? TxIssueNFTDenomCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Irismod_Nft_MsgMintNFT.protoMessageName) || msg.typeURL.contains(Chainmain_Nft_V1_MsgMintNFT.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIssueNFTCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Irismod_Nft_MsgTransferNFT.protoMessageName) || msg.typeURL.contains(Chainmain_Nft_V1_MsgTransferNFT.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxSendNFTCell") as? TxSendNFTCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1, account!.account_address)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Desmos_Profiles_V1beta1_MsgSaveProfile.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxSaveProfileCell") as? TxSaveProfileCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Desmos_Profiles_V1beta1_MsgLinkChainAccount.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxLinkAccountCell") as? TxLinkAccountCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Kava_Cdp_V1beta1_MsgCreateCDP.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCdpCreateCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Cdp_V1beta1_MsgDeposit.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCdpDepositCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Cdp_V1beta1_MsgWithdraw.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCdpWithdrawCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Cdp_V1beta1_MsgDrawDebt.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCdpBorrowCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Cdp_V1beta1_MsgRepayDebt.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCdpRepayCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Cdp_V1beta1_MsgLiquidate.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxCdpLiquidateCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Hard_V1beta1_MsgDeposit.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxHardDepositCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Hard_V1beta1_MsgWithdraw.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxHardWithdrawCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Hard_V1beta1_MsgBorrow.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxHardBorrowCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Hard_V1beta1_MsgRepay.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxHardRepayCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Hard_V1beta1_MsgLiquidate.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxHardLiquidateCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Swap_V1beta1_MsgDeposit.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxSwapDepositCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Swap_V1beta1_MsgWithdraw.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxSwapWithdrawCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Swap_V1beta1_MsgSwapExactForTokens.protoMessageName) || msg.typeURL.contains(Kava_Swap_V1beta1_MsgSwapExactForTokensResponse.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxSwapTokenCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Incentive_V1beta1_MsgClaimUSDXMintingReward.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIncentiveMintingCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Incentive_V1beta1_MsgClaimHardReward.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIncentiveHardCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Incentive_V1beta1_MsgClaimDelegatorReward.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIncentiveDelegatorCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Incentive_V1beta1_MsgClaimSwapReward.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIncentiveSwapCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Incentive_V1beta1_MsgClaimEarnReward.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxIncentiveEarnCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Kava_Router_V1beta1_MsgDelegateMintDeposit.protoMessageName) ||
                           msg.typeURL.contains(Kava_Router_V1beta1_MsgWithdrawBurn.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxEarnCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Cosmwasm_Wasm_V1_MsgStoreCode.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxStoreContractCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmwasm_Wasm_V1_MsgInstantiateContract.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxInstantContractCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                } else if (msg.typeURL.contains(Cosmwasm_Wasm_V1_MsgExecuteContract.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxExeContractCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Cosmos_Authz_V1beta1_MsgExec.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxAuthzExecCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Stride_Stakeibc_MsgLiquidStake.protoMessageName) ||
                         msg.typeURL.contains(Stride_Stakeibc_MsgRedeemStake.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxLiquidStakeCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                    
                }
                
                else if (msg.typeURL.contains(Pstake_Lscosmos_V1beta1_MsgLiquidStake.protoMessageName) ||
                         msg.typeURL.contains(Pstake_Lscosmos_V1beta1_MsgRedeem.protoMessageName)) {
                    let cell = tableView.dequeueReusableCell(withIdentifier:"TxPersisLiquidStakeCell") as? TxCell
                    cell?.onBindMsg(chainConfig, mTxRespose!, indexPath.row - 1)
                    return cell!
                }
                
            }
            let cell:TxUnknownCell? = tableView.dequeueReusableCell(withIdentifier:"TxUnknownCell") as? TxUnknownCell
            cell?.onBind(chainConfig, mTxRespose!)
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    
    func onFetchgRPCTx(_ txHash: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.chainConfig)!
                let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = txHash }
                let response = try Cosmos_Tx_V1beta1_ServiceClient(channel: channel).getTx(req).response.wait()
                self.mTxRespose = response
                DispatchQueue.main.async(execute: { self.onUpdateView() });
                
            } catch {
                print("onFetchgRPCTx failed: \(error)")
                if (self.mIsGen) {
                    self.mFetchCnt = self.mFetchCnt - 1
                    if (self.mFetchCnt > 0) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                            self.onFetchgRPCTx(self.mTxHash!)
                        })
                    } else {
                        DispatchQueue.main.async(execute: { self.onShowMoreWait() });
                    }
                } else {
                    DispatchQueue.main.async(execute: { self.onShowError(nil, nil) });
                }
            }
        }
    }
    
    func onShowMoreWait() {
        let noticeAlert = UIAlertController(title: NSLocalizedString("more_wait_title", comment: ""), message: NSLocalizedString("more_wait_msg", comment: ""), preferredStyle: .alert)
        noticeAlert.overrideUserInterfaceStyle = BaseData.instance.getThemeType()
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.onStartMainTab()
        }))
        noticeAlert.addAction(UIAlertAction(title: NSLocalizedString("wait", comment: ""), style: .default, handler: { _ in
            self.mFetchCnt = 10
            self.onFetchgRPCTx(self.mTxHash!)
        }))
        self.present(noticeAlert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            noticeAlert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func onFetchEvmTx(_ ethHash: String) {
        guard let chainConfig = chainConfig else {
            return
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if let url = URL(string: chainConfig.rpcUrl), let web3 = try? Web3.new(url) {
                let resultTx = try? web3.eth.getTransactionDetails(ethHash)
                if (resultTx == nil) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.onFetchEvmTx(ethHash)
                    })
                    
                } else {
                    self.mEthTx = resultTx
                    self.onFetchEvmRecipient(ethHash)
                }
            }
        })
    }
    
    func onFetchEvmRecipient(_ ethHash: String) {
        guard let chainConfig = chainConfig else {
            return
        }
        DispatchQueue.global().async {
            if let url = URL(string: chainConfig.rpcUrl), let web3 = try? Web3.new(url) {
                let receiptTx = try? web3.eth.getTransactionReceipt(ethHash)
                if (receiptTx == nil) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(6000), execute: {
                        self.onFetchEvmRecipient(ethHash)
                    })
                    
                } else {
                    self.mEthRecipient = receiptTx
                    DispatchQueue.main.async(execute: { self.onUpdateView() });
                }
            }
        }
    }
    
    func onFetchEvmTxcheck(_ ethHash: String, completion: @escaping (String?) -> Void) {
        guard let chainConfig = chainConfig else {
            return
        }
        let request = Alamofire.request(BaseNetWork.mintscanEvmTxcheck(chainConfig.chainAPIName, ethHash), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary,
                      let txHash = responseData.object(forKey: "txHash") as? String else {
                    completion(nil)
                    return
                }
                completion(txHash)
                
            case .failure:
                completion(nil)
            }
        }
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        if (mEthResultHash != nil) {
            //check with mintscan api
            self.onFetchEvmTxcheck(self.mEthResultHash!) { txHash in
                if (txHash != nil) {
                    let link = WUtils.getTxExplorer(self.chainConfig, txHash!)
                    let textToShare = [ link ]
                    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
            
            
        } else {
            let link = WUtils.getTxExplorer(chainConfig, self.mTxHash!)
            let textToShare = [ link ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        if (mEthResultHash != nil) {
            //check with mintscan api
            self.onFetchEvmTxcheck(self.mEthResultHash!) { txHash in
                if (txHash != nil) {
                    let link = WUtils.getTxExplorer(self.chainConfig, txHash!)
                    guard let url = URL(string: link) else { return }
                    self.onShowSafariWeb(url)
                }
            }
            
        } else {
            let link = WUtils.getTxExplorer(chainConfig, self.mTxHash!)
            guard let url = URL(string: link) else { return }
            self.onShowSafariWeb(url)
        }
    }
    
    @IBAction func onClickDismiss(_ sender: UIButton) {
        self.mFetchCnt = -1
        if (mIsGen){
            self.onStartMainTab()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
