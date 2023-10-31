//
//  BaseSheet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/30.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseSheet: BaseVC, UISearchBarDelegate {
    
    @IBOutlet weak var sheetTitle: UILabel!
    @IBOutlet weak var sheetSearchBar: UISearchBar!
    @IBOutlet weak var sheetTableView: UITableView!
    
    var sheetType: SheetType?
    var sheetDelegate: BaseSheetDelegate?
    
    var targetChain: CosmosClass!
    var swapChains = Array<CosmosClass>()
    var swapChainsSearch = Array<CosmosClass>()
    var swapAssets = Array<JSON>()
    var swapAssetsSearch = Array<JSON>()
    var swapBalance = Array<Cosmos_Base_V1beta1_Coin>()
    
    var feeDatas = Array<FeeData>()
    var validators = Array<Cosmos_Staking_V1beta1_Validator>()
    var validatorsSearch = Array<Cosmos_Staking_V1beta1_Validator>()
    var delegations = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    var delegation: Cosmos_Staking_V1beta1_DelegationResponse!
    var cosmosChainList = Array<CosmosClass>()
    var nameservices = Array<NameService>()
    
    var senderAddress: String!
    var refAddresses = Array<RefAddress>()
    var addressBook = Array<String>()
    
    var hardMarketDenom: String?
    var swpName: String?
    var cdpType: String?
    
    var selectChains = Array<CosmosClass>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        
        sheetSearchBar.backgroundImage = UIImage()
        sheetSearchBar.delegate = self
        
        sheetTableView.delegate = self
        sheetTableView.dataSource = self
        sheetTableView.separatorStyle = .none
        sheetTableView.register(UINib(nibName: "BaseSheetCell", bundle: nil), forCellReuseIdentifier: "BaseSheetCell")
        sheetTableView.register(UINib(nibName: "BaseMsgSheetCell", bundle: nil), forCellReuseIdentifier: "BaseMsgSheetCell")
        sheetTableView.register(UINib(nibName: "BaseImgSheetCell", bundle: nil), forCellReuseIdentifier: "BaseImgSheetCell")
        sheetTableView.register(UINib(nibName: "SwitchAccountCell", bundle: nil), forCellReuseIdentifier: "SwitchAccountCell")
        sheetTableView.register(UINib(nibName: "SwitchCurrencyCell", bundle: nil), forCellReuseIdentifier: "SwitchCurrencyCell")
        sheetTableView.register(UINib(nibName: "SwitchPriceDisplayCell", bundle: nil), forCellReuseIdentifier: "SwitchPriceDisplayCell")
        sheetTableView.register(UINib(nibName: "SelectSwapChainCell", bundle: nil), forCellReuseIdentifier: "SelectSwapChainCell")
        sheetTableView.register(UINib(nibName: "SelectSwapAssetCell", bundle: nil), forCellReuseIdentifier: "SelectSwapAssetCell")
        sheetTableView.register(UINib(nibName: "SelectAccountCell", bundle: nil), forCellReuseIdentifier: "SelectAccountCell")
        sheetTableView.register(UINib(nibName: "SelectEndpointCell", bundle: nil), forCellReuseIdentifier: "SelectEndpointCell")
        
        sheetTableView.register(UINib(nibName: "SelectFeeCoinCell", bundle: nil), forCellReuseIdentifier: "SelectFeeCoinCell")
        sheetTableView.register(UINib(nibName: "SelectValidatorCell", bundle: nil), forCellReuseIdentifier: "SelectValidatorCell")
        sheetTableView.register(UINib(nibName: "SelectNameServiceCell", bundle: nil), forCellReuseIdentifier: "SelectNameServiceCell")
        sheetTableView.register(UINib(nibName: "SelectRefAddressCell", bundle: nil), forCellReuseIdentifier: "SelectRefAddressCell")
        sheetTableView.register(UINib(nibName: "SelectBepRecipientCell", bundle: nil), forCellReuseIdentifier: "SelectBepRecipientCell")
        sheetTableView.sectionHeaderTopPadding = 0
        
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
        
//        print("senderAddress ", senderAddress)
//        print("targetChain ", targetChain.accountPrefix)
//        
//        let ref = BaseData.instance.selectAllRefAddresses()
//        print("ref ", ref.count)
//        
//        ref.forEach { refAddress in
//            print("refAddress ", refAddress.chainTag, "  ", refAddress.dpAddress)
//        }
        
 
    }
    
    func updateTitle() {
        if (sheetType == .SelectCreateAccount) {
            sheetTitle.text = NSLocalizedString("title_create_account", comment: "")
            
        } else if (sheetType == .SwitchAccount) {
            sheetTitle.text = NSLocalizedString("title_select_account", comment: "")
            
        } else if (sheetType == .SwitchLanguage) {
            sheetTitle.text = NSLocalizedString("title_select_language", comment: "")
            
        } else if (sheetType == .SwitchCurrency) {
            sheetTitle.text = NSLocalizedString("title_select_currency", comment: "")
            
        } else if (sheetType == .SwitchPriceColor) {
            sheetTitle.text = NSLocalizedString("str_price_change_color", comment: "")
            
        } else if (sheetType == .SwitchAutoPass) {
            sheetTitle.text = NSLocalizedString("str_autopass", comment: "")
            
        } else if (sheetType == .SwitchEndpoint) {
            sheetTitle.text = NSLocalizedString("title_select_end_point", comment: "")
            
        } else if (sheetType == .SelectSwapInputChain) {
            sheetTitle.text = NSLocalizedString("title_select_input_chain", comment: "")
            sheetSearchBar.isHidden = false
            swapChains.sort {
                if ($0.tag == "cosmos118") { return true }
                if ($1.tag == "cosmos118") { return false }
                return $0.name < $1.name
            }
            swapChainsSearch = swapChains
            
        } else if (sheetType == .SelectSwapOutputChain) {
            sheetTitle.text = NSLocalizedString("title_select_output_chain", comment: "")
            sheetSearchBar.isHidden = false
            swapChains.sort {
                if ($0.tag == "cosmos118") { return true }
                if ($1.tag == "cosmos118") { return false }
                return $0.name < $1.name
            }
            swapChainsSearch = swapChains
            
        } else if (sheetType == .SelectSwapInputAsset) {
            sheetTitle.text = NSLocalizedString("title_select_input_asset", comment: "")
            sheetSearchBar.isHidden = false
            swapAssets.sort {
                if ($0["symbol"] == "ATOM") { return true }
                if ($1["symbol"] == "ATOM") { return false }
                return $0["symbol"].stringValue < $1["symbol"].stringValue
            }
            swapAssetsSearch = swapAssets
            
        } else if (sheetType == .SelectSwapOutputAsset) {
            sheetTitle.text = NSLocalizedString("title_select_output_asset", comment: "")
            sheetSearchBar.isHidden = false
            swapAssets.sort {
                if ($0["symbol"] == "ATOM") { return true }
                if ($1["symbol"] == "ATOM") { return false }
                return $0["symbol"].stringValue < $1["symbol"].stringValue
            }
            swapAssetsSearch = swapAssets
            
        } else if (sheetType == .SelectSwapSlippage) {
            sheetTitle.text = NSLocalizedString("title_select_slippage", comment: "")
            
        } else if (sheetType == .SelectDelegatedAction || sheetType == .SelectUnbondingAction) {
            sheetTitle.text = NSLocalizedString("title_select_options", comment: "")
            
        } else if (sheetType == .SelectFeeCoin) {
            sheetTitle.text = NSLocalizedString("str_select_coin_for_fee", comment: "")
            
        } else if (sheetType == .SelectValidator) {
            sheetTitle.text = NSLocalizedString("str_select_validators", comment: "")
            sheetSearchBar.isHidden = false
            validatorsSearch = validators
            
        } else if (sheetType == .SelectUnStakeValidator) {
            sheetTitle.text = NSLocalizedString("str_select_validators", comment: "")
            delegations = targetChain.cosmosDelegations
            delegations.forEach { delegation in
                if let validator = targetChain.cosmosValidators.filter({ $0.operatorAddress == delegation.delegation.validatorAddress }).first {
                    validators.append(validator)
                }
            }
            
        } else if (sheetType == .SelectRecipientChain) {
            sheetTitle.text = NSLocalizedString("title_select_recipient_chain", comment: "")
            
        } else if (sheetType == .SelectRecipientAddress) {
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                if (refAddress.dpAddress.starts(with: targetChain.accountPrefix!) &&
                    refAddress.dpAddress != senderAddress) {
                    refAddresses.append(refAddress)
                }
            }
            refAddresses.sort {
                if let account0 = BaseData.instance.selectAccount($0.accountId),
                   let account1 = BaseData.instance.selectAccount($1.accountId) {
                    return account0.name < account1.name
                }
                return false
            }
            
        } else if (sheetType == .SelectRecipientEvmAddress) {
            sheetTitle.text = NSLocalizedString("str_address_book_list", comment: "")
            BaseData.instance.selectAllRefAddresses().forEach { refAddress in
                if (refAddress.chainTag == targetChain.tag && refAddress.dpAddress != senderAddress) {
                    refAddresses.append(refAddress)
                }
            }
            refAddresses.sort {
                if let account0 = BaseData.instance.selectAccount($0.accountId),
                   let account1 = BaseData.instance.selectAccount($1.accountId) {
                    return account0.name < account1.name
                }
                return false
            }
            
        } else if (sheetType == .SelectNameServiceAddress) {
            sheetTitle.text = String(format: NSLocalizedString("title_select_nameservice", comment: ""), nameservices[0].name ?? "")
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            sheetTitle.text = NSLocalizedString("str_recipient_address", comment: "")
            
        } else if (sheetType == .SelectNeutronVault) {
            sheetTitle.text = NSLocalizedString("title_select_vaults", comment: "")
            
        } else if (sheetType == .SelectHardAction) {
            sheetTitle.text = NSLocalizedString("title_select_hardpool_action", comment: "")
            
        } else if (sheetType == .SelectSwpAction) {
            sheetTitle.text = NSLocalizedString("title_select_swappool_action", comment: "")
            
        } else if (sheetType == .SelectMintAction) {
            sheetTitle.text = NSLocalizedString("title_select_mint_action", comment: "")
            
        } else if (sheetType == .SelectAccount) {
            sheetTitle.text = NSLocalizedString("title_select_wallet", comment: "")
            
        } else if (sheetType == .SelectBuyCrypto) {
            sheetTitle.text = NSLocalizedString("title_buy_crypto", comment: "")
            
        }
    }
    
    @objc func dismissKeyboard() {
        sheetSearchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            swapChainsSearch = searchText.isEmpty ? swapChains : swapChains.filter { chain in
                return chain.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset) {
            swapAssetsSearch = searchText.isEmpty ? swapAssets : swapAssets.filter { json in
                return json["symbol"].stringValue.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        } else if (sheetType == .SelectValidator) {
            validatorsSearch = searchText.isEmpty ? validators : validators.filter { validator in
                return validator.description_p.moniker.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        sheetTableView.reloadData()
    }
}


extension BaseSheet: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (sheetType == .SelectRecipientAddress || sheetType == .SelectRecipientEvmAddress) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BaseSheetHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (sheetType == .SelectRecipientAddress || sheetType == .SelectRecipientEvmAddress) {
            if (section == 0) {
                view.titleLabel.text = "My Account"
                view.cntLabel.text = String(refAddresses.count)
            } else {
                view.titleLabel.text = "Address Book"
                view.cntLabel.text = String(addressBook.count)
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (sheetType == .SelectRecipientAddress || sheetType == .SelectRecipientEvmAddress) {
            if (section == 0) {
                return (refAddresses.count > 0) ? 40 : 0
            } else if (section == 1) {
                return (addressBook.count > 0) ? 40 : 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sheetType == .SelectCreateAccount) {
            return 3
            
        } else if (sheetType == .SwitchAccount) {
            return BaseData.instance.selectAccounts().count
            
        } else if (sheetType == .SwitchLanguage) {
            return Language.getLanguages().count
            
        } else if (sheetType == .SwitchCurrency) {
            return Currency.getCurrencys().count
            
        } else if (sheetType == .SwitchPriceColor) {
            return 2
            
        } else if (sheetType == .SwitchAutoPass) {
            return AutoPass.getAutoPasses().count
            
        } else if (sheetType == .SwitchEndpoint) {
            return targetChain.getChainParam()["grpc_endpoint"].arrayValue.count
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            return swapChainsSearch.count
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset) {
            return swapAssetsSearch.count
            
        } else if (sheetType == .SelectSwapSlippage) {
            return 3
            
        } else if (sheetType == .SelectDelegatedAction) {
            return 4
            
        } else if (sheetType == .SelectUnbondingAction) {
            return 1
            
        } else if (sheetType == .SelectFeeCoin) {
            return feeDatas.count
            
        } else if (sheetType == .SelectValidator) {
            return validatorsSearch.count
            
        } else if (sheetType == .SelectUnStakeValidator) {
            return validators.count
            
        } else if (sheetType == .SelectRecipientChain) {
            return cosmosChainList.count
            
        } else if (sheetType == .SelectRecipientAddress || sheetType == .SelectRecipientEvmAddress) {
            if (section == 0) {
                return refAddresses.count
            } else {
                return addressBook.count
            }
            
        } else if (sheetType == .SelectNameServiceAddress) {
            return nameservices.count
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            return cosmosChainList.count
            
        } else if (sheetType == .SelectNeutronVault) {
            return 2
            
        } else if (sheetType == .SelectHardAction) {
            return 4
            
        } else if (sheetType == .SelectSwpAction) {
            return 2
            
        } else if (sheetType == .SelectMintAction) {
            return 4
            
        } else if (sheetType == .SelectAccount) {
            return selectChains.count
            
        } else if (sheetType == .SelectBuyCrypto) {
            return 3
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (sheetType == .SelectCreateAccount) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseMsgSheetCell") as? BaseMsgSheetCell
            cell?.onBindCreate(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchAccount) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchAccountCell") as? SwitchAccountCell
            cell?.onBindAccount(BaseData.instance.selectAccounts()[indexPath.row])
            return cell!
            
        } else if (sheetType == .SwitchLanguage) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindLanguage(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchCurrency) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchCurrencyCell") as? SwitchCurrencyCell
            cell?.onBindCurrency(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchPriceColor) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SwitchPriceDisplayCell") as? SwitchPriceDisplayCell
            cell?.onBindPriceDisplay(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchAutoPass) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindAutoPass(indexPath.row)
            return cell!
            
        } else if (sheetType == .SwitchEndpoint) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectEndpointCell") as? SelectEndpointCell
            cell?.onBindEndpoint(indexPath.row, targetChain)
            return cell!
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectSwapChainCell") as? SelectSwapChainCell
            cell?.onBindCosmosChain(swapChainsSearch[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset)  {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectSwapAssetCell") as? SelectSwapAssetCell
            cell?.onBindAsset(targetChain, swapAssetsSearch[indexPath.row], swapBalance)
            return cell!
            
        } else if (sheetType == .SelectSwapSlippage) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onSkipSwapSlippage(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectDelegatedAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseMsgSheetCell") as? BaseMsgSheetCell
            cell?.onBindDelegate(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectUnbondingAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseMsgSheetCell") as? BaseMsgSheetCell
            cell?.onBindUndelegate(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectFeeCoin) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectFeeCoinCell") as? SelectFeeCoinCell
            cell?.onBindFeeCoin(targetChain, feeDatas[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectValidator) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectValidatorCell") as? SelectValidatorCell
            cell?.onBindValidator(targetChain, validatorsSearch[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectUnStakeValidator) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectValidatorCell") as? SelectValidatorCell
            cell?.onBindUnstakeValidator(targetChain, validators[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectRecipientChain) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectSwapChainCell") as? SelectSwapChainCell
            cell?.onBindCosmosChain(cosmosChainList[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectRecipientAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectRefAddressCell") as? SelectRefAddressCell
            if (indexPath.section == 0) {
                cell?.onBindRefAddress(refAddresses[indexPath.row])
            } else {
                
            }
            return cell!
            
        } else if (sheetType == .SelectRecipientEvmAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectRefAddressCell") as? SelectRefAddressCell
            if (indexPath.section == 0) {
                cell?.onBindEvmRefAddress(refAddresses[indexPath.row])
            } else {
                
            }
            return cell!
            
        } else if (sheetType == .SelectNameServiceAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectNameServiceCell") as? SelectNameServiceCell
            cell?.onBindNameservice(nameservices[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectBepRecipientCell") as? SelectBepRecipientCell
            cell?.onBindBepRecipient(cosmosChainList[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectNeutronVault) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindVault(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectHardAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindHard(indexPath.row, hardMarketDenom)
            return cell!
            
        } else if (sheetType == .SelectSwpAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindSwp(indexPath.row)
            return cell!
            
        } else if (sheetType == .SelectMintAction) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseSheetCell") as? BaseSheetCell
            cell?.onBindMint(indexPath.row, cdpType!)
            return cell!
            
        } else if (sheetType == .SelectAccount) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"SelectAccountCell") as? SelectAccountCell
            cell?.onBindChains(selectChains[indexPath.row])
            return cell!
            
        } else if (sheetType == .SelectBuyCrypto) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"BaseImgSheetCell") as? BaseImgSheetCell
            cell?.onBindBuyCrypto(indexPath.row)

            return cell!
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sheetType == .SwitchAccount) {
            let result = BaseSheetResult.init(indexPath.row, String(BaseData.instance.selectAccounts()[indexPath.row].id))
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SwitchEndpoint) {
            let cell = sheetTableView.cellForRow(at: indexPath) as? SelectEndpointCell
            if (cell?.gapTime != nil) {
                let result = BaseSheetResult.init(indexPath.row, targetChain.name)
                sheetDelegate?.onSelectedSheet(sheetType, result)
                
            } else {
                onShowToast(NSLocalizedString("error_useless_end_point", comment: ""))
                return
            }
            
        } else if (sheetType == .SelectDelegatedAction) {
            let result = BaseSheetResult.init(indexPath.row, delegation.delegation.validatorAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwapInputChain || sheetType == .SelectSwapOutputChain) {
            let result = BaseSheetResult.init(indexPath.row, swapChainsSearch[indexPath.row].chainId)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwapInputAsset || sheetType == .SelectSwapOutputAsset)  {
            let result = BaseSheetResult.init(indexPath.row, swapAssetsSearch[indexPath.row]["denom"].stringValue)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectValidator) {
            let result = BaseSheetResult.init(indexPath.row, validatorsSearch[indexPath.row].operatorAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectUnStakeValidator) {
            let result = BaseSheetResult.init(indexPath.row, validators[indexPath.row].operatorAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectRecipientChain) {
            let result = BaseSheetResult.init(indexPath.row, cosmosChainList[indexPath.row].chainId)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectRecipientAddress || sheetType == .SelectRecipientEvmAddress) {
            let result = BaseSheetResult.init(indexPath.row, refAddresses[indexPath.row].dpAddress)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectBepRecipientAddress) {
            let chain = cosmosChainList[indexPath.row]
            if let bnbChain = chain as? ChainBinanceBeacon {
                let availableAmount = bnbChain.lcdBalanceAmount(bnbChain.stakeDenom)
                let fee = NSDecimalNumber(string: BNB_BEACON_BASE_FEE)
                if (availableAmount.compare(fee).rawValue < 0) {
                    onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                    dismiss(animated: true)
                }
                
            } else {
                let availableAmount = chain.balanceAmount(chain.stakeDenom)
                let fee = NSDecimalNumber(string: KAVA_BASE_FEE)
                if (availableAmount.compare(fee).rawValue < 0) {
                    onShowToast(NSLocalizedString("error_not_enough_fee", comment: ""))
                    dismiss(animated: true)
                }
            }
            let result = BaseSheetResult.init(indexPath.row, chain.address)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectHardAction) {
            let result = BaseSheetResult.init(indexPath.row, hardMarketDenom)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectSwpAction) {
            let result = BaseSheetResult.init(indexPath.row, swpName)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectMintAction) {
            let result = BaseSheetResult.init(indexPath.row, cdpType)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else if (sheetType == .SelectAccount) {
            let result = BaseSheetResult.init(indexPath.row, selectChains[indexPath.row].address)
            sheetDelegate?.onSelectedSheet(sheetType, result)
            
        } else {
            sheetDelegate?.onSelectedSheet(sheetType, BaseSheetResult.init(indexPath.row, nil))
        }
        dismiss(animated: true)
    }
    
}


protocol BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: BaseSheetResult)
}

public struct BaseSheetResult {
    var position: Int?
    var param: String?
    
    init(_ position: Int? = nil, _ param: String? = nil) {
        self.position = position
        self.param = param
    }
}

public enum SheetType: Int {
    case SelectCreateAccount = 0
    
    case SwitchAccount = 1
    case SwitchLanguage = 2
    case SwitchCurrency = 3
    case SwitchPriceColor = 4
    case SwitchAutoPass = 5
    case SwitchEndpoint = 6
    
    case SelectSwapInputChain = 21
    case SelectSwapOutputChain = 22
    case SelectSwapInputAsset = 23
    case SelectSwapOutputAsset = 24
    case SelectSwapSlippage = 25
    
    case SelectDelegatedAction = 31
    case SelectUnbondingAction = 32
    
    case SelectFeeCoin = 41
    case SelectValidator = 42
    case SelectUnStakeValidator = 43
    case SelectRecipientChain = 44
    case SelectRecipientAddress = 45
    case SelectRecipientEvmAddress = 46
    case SelectNameServiceAddress = 47
    case SelectBepRecipientAddress = 48
    
    case SelectNeutronVault = 51
    
    case SelectHardAction = 61
    case SelectSwpAction = 62
    case SelectMintAction = 63
    case SelectBuyCrypto = 64
    
    case SelectAccount = 71
}
