//
//  BaseData.swift
//  Cosmostation
//
//  Created by yongjoo on 07/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import SQLite
import SwiftKeychainWrapper
import SwiftProtobuf
import KeychainAccess
import SwiftyJSON


final class BaseData: NSObject{
    
    static let instance = BaseData()
    
    var database: Connection!
    var copySalt: String?
    
    var reviewMode = true
    var mintscanChainParams: JSON?
    var mintscanUSDPrices: [MintscanPrice]?
    var mintscanPrices: [MintscanPrice]?
    var mintscanAssets: [MintscanAsset]?
    var baseAccount: BaseAccount?
    
    
    var appUserInfo: [AnyHashable : Any]?
    var appSchemeUrl: URL?
    
    public override init() {
        super.init();
        if database == nil {
            self.initdb();
        }
    }
    
    func getAsset(_ chainApiName: String, _ denom: String) -> MintscanAsset? {
        return mintscanAssets?.filter({ $0.chain == chainApiName && $0.denom?.lowercased() == denom.lowercased() }).first
    }
    
    func getPrice(_ geckoId: String?, _ usd: Bool? = false) -> NSDecimalNumber {
        if (geckoId == nil) { return NSDecimalNumber.zero }
        if (usd == true) {
            if let price = mintscanUSDPrices?.filter({ $0.coinGeckoId == geckoId }).first {
                return NSDecimalNumber.init(value: price.current_price ?? 0).rounding(accordingToBehavior: handler12Down)
            }
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler12Down)
            
        } else {
            if let price = mintscanPrices?.filter({ $0.coinGeckoId == geckoId }).first {
                return NSDecimalNumber.init(value: price.current_price ?? 0).rounding(accordingToBehavior: handler12Down)
            }
            return NSDecimalNumber.zero.rounding(accordingToBehavior: handler12Down)
        }
    }
    
    func priceChange(_ geckoId: String?) -> NSDecimalNumber {
        if (geckoId == nil) { return NSDecimalNumber.zero.rounding(accordingToBehavior: handler2Down) }
        if let price = mintscanPrices?.filter({ $0.coinGeckoId == geckoId }).first {
            return NSDecimalNumber.init(value: price.daily_price_change_in_percent ?? 0).rounding(accordingToBehavior: handler2Down)
        }
        return NSDecimalNumber.zero.rounding(accordingToBehavior: handler2Down)
    }
    
    
    func setAllValidatorSort(_ sort : Int64) {
        UserDefaults.standard.set(sort, forKey: KEY_ALL_VAL_SORT)
    }
    
    func getAllValidatorSort() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: KEY_ALL_VAL_SORT))
    }
    
    func setMyValidatorSort(_ sort : Int64) {
        UserDefaults.standard.set(sort, forKey: KEY_MY_VAL_SORT)
    }
    
    func getMyValidatorSort() -> Int64 {
        return Int64(UserDefaults.standard.integer(forKey: KEY_MY_VAL_SORT))
    }
    
    func setNeedRefresh(_ refresh : Bool) {
        UserDefaults.standard.set(refresh, forKey: KEY_ACCOUNT_REFRESH_ALL)
    }
    
    func getNeedRefresh() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_ACCOUNT_REFRESH_ALL)
    }
    
    func showEvenReview() -> Bool {
        return (!reviewMode || checkInstallTime())
    }
    

    
    

    

    
    
    
//    func setLastPassTime() {
//        let now = Date().millisecondsSince1970
//        UserDefaults.standard.set(String(now), forKey: KEY_LAST_PASS_TIME)
//    }
//
//    func getLastPassTime() -> Int64 {
//        let last = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")!
//        return last
//    }
//
//    func setLastPriceTime() {
//        let now = Date().millisecondsSince1970
//        UserDefaults.standard.set(String(now), forKey: KEY_LAST_PRICE_TIME)
//    }
//
//    func isAutoPass() -> Bool {
//        let now = Date().millisecondsSince1970
//        let min: Int64 = 60000
//        if (getAutoPass() == 1) {
//            let passTime = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")! + (min * 5)
//            return passTime > now ? true : false
//
//        } else if (getAutoPass() == 2) {
//            let passTime = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")! + (min * 10)
//            return passTime > now ? true : false
//
//        } else if (getAutoPass() == 3) {
//            let passTime = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PASS_TIME) ?? "0")! + (min * 30)
//            return passTime > now ? true : false
//        }
//        return false
//    }
    

    
    

    
//    func setKavaWarn() {
//        let remindTime = Calendar.current.date(byAdding: .day, value: 3, to: Date())?.millisecondsSince1970
//        UserDefaults.standard.set(String(remindTime!), forKey: KEY_KAVA_TESTNET_WARN)
//    }
//
//    func getKavaWarn() ->Bool {
//        let reminTime = Int64(UserDefaults.standard.string(forKey: KEY_KAVA_TESTNET_WARN) ?? "0")
//        if (Date().millisecondsSince1970 > reminTime!) {
//            return true
//        }
//        return false
//    }
//
//    func setEventTime() {
//        let remindTime = Calendar.current.date(byAdding: .day, value: 1, to: Date())?.millisecondsSince1970
//        UserDefaults.standard.set(String(remindTime!), forKey: KEY_PRE_EVENT_HIDE)
//    }
//
//    func getEventTime() -> Bool {
//        let reminTime = Int64(UserDefaults.standard.string(forKey: KEY_PRE_EVENT_HIDE) ?? "0")
//        if (Date().millisecondsSince1970 > reminTime!) {
//            return true
//        }
//        return false
//    }
    
    func setCustomIcon(_ type: String) {
        UserDefaults.standard.set(type, forKey: KEY_CUSTOM_ICON)
    }
    
    func getCustomIcon() -> String {
        return UserDefaults.standard.string(forKey: KEY_PRE_EVENT_HIDE) ?? ICON_DEFAULT
    }
    
    func getUserHiddenChains() -> Array<String>? {
        return UserDefaults.standard.stringArray(forKey: KEY_USER_HIDEN_CHAINS) ?? []
    }
    
    public func hasPassword() -> Bool{
        if (KeychainWrapper.standard.hasValue(forKey: "password")) {
            return true;
        } else {
            return false;
        }
    }
    
    /// checks if app lock is active and exists a password. If both are met returns true, false otherwise
    func isRequiredUnlock() -> Bool {
        getUsingAppLock() && hasPassword()
    }
}


extension BaseData {
    
    func initdb() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var fileUrl = documentDirectory.appendingPathComponent("cosmostation").appendingPathExtension("sqlite3")
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try fileUrl.setResourceValues(resourceValues)
                
            } catch { print(error) }
            
            let database = try Connection(fileUrl.path)
            self.database = database
            
            //V2 version
            let accountTable = TABLE_BASEACCOUNT.create(ifNotExists: true) { table in
                table.column(BASEACCOUNT_ID, primaryKey: true)
                table.column(BASEACCOUNT_UUID)
                table.column(BASEACCOUNT_NAME)
                table.column(BASEACCOUNT_TYPE)
                table.column(BASEACCOUNT_LAST_PATH)
                table.column(BASEACCOUNT_ORDER)
            }
            try self.database.run(accountTable)
            _ = try? self.database.run(TABLE_BASEACCOUNT.addColumn(BASEACCOUNT_ORDER, defaultValue: 999))
            
            let refAddressTable = TABLE_REFADDRESS.create(ifNotExists: true) { table in
                table.column(REFADDRESS_ID, primaryKey: true)
                table.column(REFADDRESS_ACCOUNT_ID)
                table.column(REFADDRESS_CHAIN_TAG)
                table.column(REFADDRESS_DP_ADDRESS)
                table.column(REFADDRESS_EVM_ADDRESS)
                table.column(REFADDRESS_MAIN_AMOUNT)
                table.column(REFADDRESS_MAIN_VALUE)
                table.column(REFADDRESS_TOKEN_VALUE)
                table.column(REFADDRESS_COIN_CNT)
            }
            try self.database.run(refAddressTable)
            
            let addressBookTable = TABLE_ADDRESSBOOK.create(ifNotExists: true) { table in
                table.column(ADDRESSBOOK_ID, primaryKey: true)
                table.column(ADDRESSBOOK_NAME)
                table.column(ADDRESSBOOK_CHAIN_NAME)
                table.column(ADDRESSBOOK_ADDRESS)
                table.column(ADDRESSBOOK_MEMO)
                table.column(ADDRESSBOOK_TIME)
            }
            try self.database.run(addressBookTable)
            
            
            
        } catch { print(error) }
    }
    
    //V2 version baseAccount
    public func selectAccounts() -> [BaseAccount] {
        var result = [BaseAccount]()
        result += selectAccounts(.withMnemonic)
        result += selectAccounts(.onlyPrivateKey)
        return result
    }
    
    public func selectAccounts(_ type: BaseAccountType) -> [BaseAccount] {
        var result = [BaseAccount]()
        for row in try! database.prepare(TABLE_BASEACCOUNT) {
            if (row[BASEACCOUNT_TYPE] == type.rawValue) {
                result.append(BaseAccount(row[BASEACCOUNT_ID], row[BASEACCOUNT_UUID], row[BASEACCOUNT_NAME], row[BASEACCOUNT_TYPE], row[BASEACCOUNT_LAST_PATH], row[BASEACCOUNT_ORDER]))
            }
        }
        result.sort {
            return $0.order < $1.order
        }
        return result
    }
    
    public func selectAccount(_ id: Int64) -> BaseAccount? {
        return selectAccounts().filter { $0.id == id }.first
    }
    
    @discardableResult
    public func insertAccount(_ account: BaseAccount) -> Int64 {
        let toInsert = TABLE_BASEACCOUNT.insert(BASEACCOUNT_UUID <- account.uuid,
                                                BASEACCOUNT_NAME <- account.name,
                                                BASEACCOUNT_TYPE <- account.type.rawValue,
                                                BASEACCOUNT_LAST_PATH <- account.lastHDPath,
                                                BASEACCOUNT_ORDER <- account.order)
        return try! database.run(toInsert)
    }
    
    @discardableResult
    public func updateAccount(_ account: BaseAccount) -> Int64 {
        let target = TABLE_BASEACCOUNT.filter(BASEACCOUNT_ID == account.id)
        return try! Int64(database.run(target.update(BASEACCOUNT_NAME <- account.name,
                                                     BASEACCOUNT_ORDER <- account.order)))
    }
    
    @discardableResult
    public func deleteAccount(_ account: BaseAccount) -> Int? {
        try? getKeyChain().remove(account.uuid.sha1())
                                  
        deleteRefAddresses(account.id)
        deleteDisplayCosmosChainTags(account.id)
        
        let query = TABLE_BASEACCOUNT.filter(BASEACCOUNT_ID == account.id)
        return try? database.run(query.delete())
    }
    
    
    
    //V2 version refAddress
    public func selectAllRefAddresses() -> Array<RefAddress> {
        var result = Array<RefAddress>()
        for rowInfo in try! database.prepare(TABLE_REFADDRESS) {
            result.append(RefAddress(rowInfo[REFADDRESS_ID], rowInfo[REFADDRESS_ACCOUNT_ID], rowInfo[REFADDRESS_CHAIN_TAG],
                                     rowInfo[REFADDRESS_DP_ADDRESS], rowInfo[REFADDRESS_EVM_ADDRESS], rowInfo[REFADDRESS_MAIN_AMOUNT], 
                                     rowInfo[REFADDRESS_MAIN_VALUE], rowInfo[REFADDRESS_TOKEN_VALUE], rowInfo[REFADDRESS_COIN_CNT]))
        }
        return result
    }
    
    public func selectRefAddresses(_ accountId: Int64) -> Array<RefAddress> {
        var result = Array<RefAddress>()
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == accountId)
        for rowInfo in try! database.prepare(query) {
            result.append(RefAddress(rowInfo[REFADDRESS_ID], rowInfo[REFADDRESS_ACCOUNT_ID], rowInfo[REFADDRESS_CHAIN_TAG],
                                     rowInfo[REFADDRESS_DP_ADDRESS], rowInfo[REFADDRESS_EVM_ADDRESS], rowInfo[REFADDRESS_MAIN_AMOUNT], 
                                     rowInfo[REFADDRESS_MAIN_VALUE], rowInfo[REFADDRESS_TOKEN_VALUE], rowInfo[REFADDRESS_COIN_CNT]))
        }
        return result
    }
    
    public func selectRefAddress(_ accountId: Int64, _ chainTag: String) -> RefAddress? {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == accountId &&
                                            REFADDRESS_CHAIN_TAG == chainTag)
        if let rowInfo = try! database.pluck(query) {
            return RefAddress(rowInfo[REFADDRESS_ID], rowInfo[REFADDRESS_ACCOUNT_ID], rowInfo[REFADDRESS_CHAIN_TAG],
                              rowInfo[REFADDRESS_DP_ADDRESS], rowInfo[REFADDRESS_EVM_ADDRESS], rowInfo[REFADDRESS_MAIN_AMOUNT], 
                              rowInfo[REFADDRESS_MAIN_VALUE], rowInfo[REFADDRESS_TOKEN_VALUE], rowInfo[REFADDRESS_COIN_CNT])
        }
        return nil
    }
    
    @discardableResult
    public func insertRefAddresses(_ refAddress: RefAddress) -> Int64 {
        let toInsert = TABLE_REFADDRESS.insert(REFADDRESS_ACCOUNT_ID <- refAddress.accountId,
                                               REFADDRESS_CHAIN_TAG <- refAddress.chainTag,
                                               REFADDRESS_DP_ADDRESS <- refAddress.bechAddress,
                                               REFADDRESS_EVM_ADDRESS <- refAddress.evmAddress,
                                               REFADDRESS_MAIN_AMOUNT <- refAddress.lastMainAmount,
                                               REFADDRESS_MAIN_VALUE <- refAddress.lastMainValue,
                                               REFADDRESS_TOKEN_VALUE <- refAddress.lastTokenValue,
                                               REFADDRESS_COIN_CNT <- refAddress.lastCoinCnt)
        return try! database.run(toInsert)
    }
    
    @discardableResult
    public func updateRefAddressesAllValue(_ refAddress: RefAddress) -> Int? {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == refAddress.accountId &&
                                            REFADDRESS_CHAIN_TAG == refAddress.chainTag)
        if let address = try! database.pluck(query) {
            let target = TABLE_REFADDRESS.filter(REFADDRESS_ID == address[REFADDRESS_ID])
            return try? database.run(target.update(REFADDRESS_MAIN_AMOUNT <- refAddress.lastMainAmount,
                                                   REFADDRESS_MAIN_VALUE <- refAddress.lastMainValue,
                                                   REFADDRESS_TOKEN_VALUE <- refAddress.lastTokenValue,
                                                   REFADDRESS_COIN_CNT <- refAddress.lastCoinCnt))
        } else {
            return Int(insertRefAddresses(refAddress))
        }
    }
    
    @discardableResult
    public func updateRefAddressesValue(_ refAddress: RefAddress) -> Int? {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == refAddress.accountId &&
                                            REFADDRESS_CHAIN_TAG == refAddress.chainTag)
        if let address = try! database.pluck(query) {
            let target = TABLE_REFADDRESS.filter(REFADDRESS_ID == address[REFADDRESS_ID])
            return try? database.run(target.update(REFADDRESS_MAIN_AMOUNT <- refAddress.lastMainAmount,
                                                   REFADDRESS_MAIN_VALUE <- refAddress.lastMainValue,
                                                   REFADDRESS_COIN_CNT <- refAddress.lastCoinCnt,
                                                   REFADDRESS_TOKEN_VALUE <- refAddress.lastTokenValue))
        } else {
            return Int(insertRefAddresses(refAddress))
        }
    }
    
    @discardableResult
    public func updateRefAddressesCoinValue(_ refAddress: RefAddress) -> Int? {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == refAddress.accountId &&
                                            REFADDRESS_CHAIN_TAG == refAddress.chainTag)
        if let address = try! database.pluck(query) {
            let target = TABLE_REFADDRESS.filter(REFADDRESS_ID == address[REFADDRESS_ID])
            return try? database.run(target.update(REFADDRESS_MAIN_AMOUNT <- refAddress.lastMainAmount,
                                                   REFADDRESS_MAIN_VALUE <- refAddress.lastMainValue,
                                                   REFADDRESS_COIN_CNT <- refAddress.lastCoinCnt))
        } else {
            return Int(insertRefAddresses(refAddress))
        }
    }
    
    @discardableResult
    public func updateRefAddressesTokenValue(_ refAddress: RefAddress) -> Int? {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == refAddress.accountId &&
                                            REFADDRESS_CHAIN_TAG == refAddress.chainTag)
        if let address = try! database.pluck(query) {
            let target = TABLE_REFADDRESS.filter(REFADDRESS_ID == address[REFADDRESS_ID])
            return try? database.run(target.update(REFADDRESS_TOKEN_VALUE <- refAddress.lastTokenValue))
            
        } else {
            return Int(insertRefAddresses(refAddress))
        }
    }
    
    @discardableResult
    public func deleteRefAddresses(_ accountId: Int64) -> Int?  {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == accountId)
        return try? database.run(query.delete())
    }
    
    
    //V2 version addressBook
    public func selectAllAddressBooks() -> [AddressBook] {
        var result = [AddressBook]()
        for rowInfo in try! database.prepare(TABLE_ADDRESSBOOK) {
            result.append(
                AddressBook(rowInfo[ADDRESSBOOK_ID], rowInfo[ADDRESSBOOK_NAME], rowInfo[ADDRESSBOOK_CHAIN_NAME],
                            rowInfo[ADDRESSBOOK_ADDRESS], rowInfo[ADDRESSBOOK_MEMO], rowInfo[ADDRESSBOOK_TIME]))
        }
        return result
    }
    
    public func selectAddressBooks(_ id: Int64) -> AddressBook? {
        let query = TABLE_ADDRESSBOOK.filter(ADDRESSBOOK_ID == id)
        if let rowInfo = try! database.pluck(query) {
            return AddressBook(rowInfo[ADDRESSBOOK_ID], rowInfo[ADDRESSBOOK_NAME], rowInfo[ADDRESSBOOK_CHAIN_NAME],
                               rowInfo[ADDRESSBOOK_ADDRESS], rowInfo[ADDRESSBOOK_MEMO], rowInfo[ADDRESSBOOK_TIME])
        }
        return nil
    }
    
    @discardableResult
    public func updateAddressBook(_ addressBook: AddressBook) -> Int? {
        if (selectAddressBooks(addressBook.id) != nil) {
            let target = TABLE_ADDRESSBOOK.filter(ADDRESSBOOK_ID == addressBook.id)
            return try? database.run(target.update(ADDRESSBOOK_NAME <- addressBook.bookName,
                                                  ADDRESSBOOK_MEMO <- addressBook.memo,
                                                  ADDRESSBOOK_TIME <- addressBook.lastTime))
        } else {
            return Int(insertAddressBook(addressBook))
        }
    }
    
    @discardableResult
    public func insertAddressBook(_ addressBook: AddressBook) -> Int64 {
        let toInsert = TABLE_ADDRESSBOOK.insert(ADDRESSBOOK_NAME <- addressBook.bookName,
                                                ADDRESSBOOK_CHAIN_NAME <- addressBook.chainName,
                                                ADDRESSBOOK_ADDRESS <- addressBook.dpAddress,
                                                ADDRESSBOOK_MEMO <- addressBook.memo,
                                                ADDRESSBOOK_TIME <- addressBook.lastTime)
        return try! database.run(toInsert)
    }
    
    @discardableResult
    public func deleteAddressBook(_ addressBookId: Int64) -> Int?  {
        let query = TABLE_ADDRESSBOOK.filter(ADDRESSBOOK_ID == addressBookId)
        return try? database.run(query.delete())
    }
    
    
    //legacy
    public func legacySelectAllMnemonics() -> Array<MWords> {
        var result = Array<MWords>()
        do {
            for mnemonicBD in try database.prepare(DB_MNEMONIC) {
                let mWords = MWords(mnemonicBD[DB_MNEMONIC_ID], mnemonicBD[DB_MNEMONIC_UUID], mnemonicBD[DB_MNEMONIC_NICKNAME],
                                    mnemonicBD[DB_MNEMONIC_CNT], mnemonicBD[DB_MNEMONIC_FAVO], mnemonicBD[DB_MNEMONIC_IMPORT_TIME]);
                result.append(mWords);
            }
        } catch { print(error) }
        return result
    }
    
    public func legacySelectAllAccounts() -> Array<Account> {
        var result = Array<Account>()
        do {
            for accountBD in try database.prepare(DB_ACCOUNT) {
                let account = Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
                                      accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
                                      accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
                                      accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
                                      accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
                                      accountBD[DB_ACCOUNT_MNEMONIC_ID]);
                result.append(account);
            }
        } catch {
            print(error)
        }
        return result;
    }
    
    public func legacySelectAccountsByPrivateKey() -> Array<Account> {
        var result = Array<Account>()
        for account in legacySelectAllAccounts() {
            if (account.account_from_mnemonic == false && account.account_has_private == true) {
                result.append(account)
            }
        }
        return result
    }
    
    public func getKeyChain() -> Keychain{
        return Keychain(service: "io.cosmostation")
            .synchronizable(false)
            .accessibility(.afterFirstUnlockThisDeviceOnly)
    }
}


extension BaseData {
    func setFCMToken(_ token : String) {
        UserDefaults.standard.set(token, forKey: KEY_FCM_TOKEN)
    }
    
    func getFCMToken() -> String {
        return UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) ?? ""
    }
    
    func setDBVersion(_ version: Int) {
        UserDefaults.standard.set(version, forKey: KEY_DB_VERSION)
    }
    
    func getDBVersion() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_DB_VERSION)
    }
    
    func setLastAccount(_ account: BaseAccount) {
        UserDefaults.standard.set(account.id, forKey: KEY_LAST_ACCOUNT)
    }
    
    func setLastAccount(_ id: Int64) {
        UserDefaults.standard.set(id, forKey: KEY_LAST_ACCOUNT)
    }
    
    func getLastAccount() -> BaseAccount? {
        let id = UserDefaults.standard.integer(forKey: KEY_LAST_ACCOUNT)
        if let account = selectAccount(Int64(id)) {
            return account
        }
        return selectAccounts().first
    }
    
    func setDisplayEvmChainTags(_ id: Int64, _ chainNames: [String])  {
        if let encoded = try? JSONEncoder().encode(chainNames) {
            UserDefaults.standard.setValue(encoded, forKey: String(id) + " " + KEY_DISPLAY_EVM_CHAINS)
        }
    }
    
    func getDisplayEvmChainTags(_ id: Int64) -> [String] {
        if let savedData = UserDefaults.standard.object(forKey: String(id) + " " + KEY_DISPLAY_EVM_CHAINS) as? Data {
            if let result = try? JSONDecoder().decode([String].self, from: savedData) {
                return result
            }
        }
        return DEFUAL_DISPALY_EVM
    }
    
    func deleteDisplayEvmChainTags(_ id: Int64)  {
        UserDefaults.standard.removeObject(forKey: String(id) + " " + KEY_DISPLAY_EVM_CHAINS)
    }
    
    func setDisplayErc20s(_ id: Int64, _ chainTag: String, _ contractAddress: [String])  {
        if let encoded = try? JSONEncoder().encode(contractAddress) {
            UserDefaults.standard.setValue(encoded, forKey: String(id) + " " + chainTag + " " + KEY_DISPLAY_ERC20_TOKENS)
        }
    }
    
    func getDisplayErc20s(_ id: Int64, _ chainTag: String) -> [String]? {
        if let savedData = UserDefaults.standard.object(forKey: String(id) + " " + chainTag + " " + KEY_DISPLAY_ERC20_TOKENS) as? Data {
            if let result = try? JSONDecoder().decode([String].self, from: savedData) {
                return result
            }
        }
        return nil
    }
    
    func deleteDisplayErc20s(_ id: Int64)  {
        ALLCHAINS().filter { $0.supportEvm == true }.forEach { evmChain in
            UserDefaults.standard.removeObject(forKey: String(id) + " " + evmChain.tag + " " + KEY_DISPLAY_ERC20_TOKENS)
        }
    }
    
    
    func setDisplayCosmosChainTags(_ id: Int64, _ chainNames: [String])  {
        if let encoded = try? JSONEncoder().encode(chainNames) {
            UserDefaults.standard.setValue(encoded, forKey: String(id) + " " + KEY_DISPLAY_COSMOS_CHAINS)
        }
    }
    
    func getDisplayCosmosChainTags(_ id: Int64) -> [String] {
        if let savedData = UserDefaults.standard.object(forKey: String(id) + " " + KEY_DISPLAY_COSMOS_CHAINS) as? Data {
            if let result = try? JSONDecoder().decode([String].self, from: savedData) {
                return result
            }
        }
        return DEFUAL_DISPALY_COSMOS
    }
    
    func deleteDisplayCosmosChainTags(_ id: Int64)  {
        UserDefaults.standard.removeObject(forKey: String(id) + " " + KEY_DISPLAY_COSMOS_CHAINS)
    }
    
    
    
    //Userdefault for Asset prices
    func setLastPriceTime() {
        let now = Date().millisecondsSince1970
        UserDefaults.standard.set(String(now), forKey: KEY_LAST_PRICE_TIME)
    }
    
    func needPriceUpdate() -> Bool {
        if (BaseData.instance.mintscanPrices == nil ) { return true }
        let now = Date().millisecondsSince1970
        let min: Int64 = 60000
        let last = Int64(UserDefaults.standard.string(forKey: KEY_LAST_PRICE_TIME) ?? "0")! + (min * 2)
        return last < now ? true : false
    }
    
    func setHideLegacy(_ hide : Bool) {
        UserDefaults.standard.set(hide, forKey: KEY_HIDE_LEGACY)
    }
    
    func getHideLegacy() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_HIDE_LEGACY)
    }
    
    func setCurrency(_ currency : Int) {
        UserDefaults.standard.set(currency, forKey: KEY_CURRENCY)
    }
    
    func getCurrency() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_CURRENCY)
    }
    
    func getCurrencyString() -> String {
        return Currency.getCurrencys()[getCurrency()].description
    }
    
    func getCurrencySymbol() -> String {
        return Currency.getCurrencys()[getCurrency()].symbol
    }
    
    func setPriceChaingColor(_ value : Int) {
        UserDefaults.standard.set(value, forKey: KEY_PRICE_CHANGE_COLOR)
    }
    
    func getPriceChaingColor() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_PRICE_CHANGE_COLOR)
    }
    
    func setLanguage(_ language: Int) {
        UserDefaults.standard.set(language, forKey: KEY_LANGUAGE)
    }
    
    func getLanguage() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_LANGUAGE)
    }
    
    func setStyle(_ style : Int) {
        UserDefaults.standard.set(style, forKey: KEY_STYLE)
    }
    
    func getStyle() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_STYLE)
    }
    
    func getStyleString() -> String {
        return ProtfolioStyle.getProtfolioStyles()[getStyle()].description
    }
    
    func setAutoPass(_ mode : Int) {
        UserDefaults.standard.set(mode, forKey: KEY_AUTO_PASS)
    }
    
    func getAutoPass() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_AUTO_PASS)
    }
    
    func getAutoPassString() -> String {
        return AutoPass.getAutoPasses()[getAutoPass()].description
    }
    
    func setUsingAppLock(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_USING_APP_LOCK)
    }
    
    func getUsingAppLock() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_USING_APP_LOCK)
    }
    
    func setUsingBioAuth(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_USING_BIO_AUTH)
    }
    
    func getUsingBioAuth() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_USING_BIO_AUTH)
    }
    
    func setUsingEnginerMode(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_ENGINER_MODE)
    }
    
    func getUsingEnginerMode() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_ENGINER_MODE)
    }
    
    func setLastTab(_ index : Int) {
        UserDefaults.standard.set(index, forKey: KEY_LAST_TAB)
    }
    
    func getLastTab() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_LAST_TAB)
    }
    
    func setGrpcEndpoint(_ chain : BaseChain, _ endpoint: String) {
        UserDefaults.standard.set(endpoint, forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + chain.name)
    }
    
    func setEvmRpcEndpoint(_ chain : BaseChain, _ endpoint: String) {
        UserDefaults.standard.set(endpoint, forKey: KEY_CHAIN_EVM_RPC_ENDPOINT +  " : " + chain.name)
    }
    
    //Skip swap info
    func setLastSwapInfoTime() {
        let now = Date().millisecondsSince1970
        UserDefaults.standard.set(String(now), forKey: KEY_SWAP_INFO_TIME)
    }
    
    func needSwapInfoUpdate() -> Bool {
        let now = Date().millisecondsSince1970
        let day: Int64 = 86400000
        let last = Int64(UserDefaults.standard.string(forKey: KEY_SWAP_INFO_TIME) ?? "0")! + (day * 3)
        return last < now ? true : false
    }
    
    func setSkipChainInfo(_ json: JSON?) {
        UserDefaults.standard.setValue(json.encoded, forKey: KEY_SKIP_CHAIN_INFO)
    }
    
    func getSkipChainInfo() -> JSON? {
        if let savedData = UserDefaults.standard.object(forKey: KEY_SKIP_CHAIN_INFO) as? Data {
            return try? JSON.init(data: savedData)
        }
        return nil
    }
    
    func setSkipAssetInfo(_ json: JSON?) {
        UserDefaults.standard.setValue(json.encoded, forKey: KEY_SKIP_ASSET_INFO)
    }
    
    func getSkipAssetInfo() -> JSON? {
        if let savedData = UserDefaults.standard.object(forKey: KEY_SKIP_ASSET_INFO) as? Data {
            return try? JSON.init(data: savedData)
        }
        return nil
    }
    
    func setSwapWarn() {
        var dayComponent = DateComponents()
        dayComponent.day = 7
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: Date())
        let nextTime = nextDate?.millisecondsSince1970 ?? 0
        UserDefaults.standard.set(String(nextTime), forKey: KEY_SWAP_WARN)
    }

    func getSwapWarn() -> Bool {
        let last = Int64(UserDefaults.standard.string(forKey: KEY_SWAP_WARN) ?? "0")!
        let now = Date().millisecondsSince1970
        return last < now
    }
    
    // set user last seleted swap ui for convenience
    // [fromChainTag, fromChainDenom, toChainTag, toChainDenom]
    func setLastSwapSet(_ swapSet: [String]) {
        if let encoded = try? JSONEncoder().encode(swapSet) {
            UserDefaults.standard.setValue(encoded, forKey: KEY_SWAP_USER_SET)
        }
    }
    
    func getLastSwapSet() -> [String] {
        if let savedData = UserDefaults.standard.object(forKey: KEY_SWAP_USER_SET) as? Data {
            if let result = try? JSONDecoder().decode([String].self, from: savedData) {
                return result
            }
        }
        return ["", "", "", ""]
    }
    
    
    
    func setInstallTime() {
        var dayComponent = DateComponents()
        dayComponent.day = 20
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: Date())
        let nextTime = nextDate?.millisecondsSince1970 ?? 0
        UserDefaults.standard.set(String(nextTime), forKey: KEY_INSTALL_TIME)
    }

    func getInstallTime() -> Int64 {
        return Int64(UserDefaults.standard.string(forKey: KEY_INSTALL_TIME) ?? "0")!
    }
    
    func checkInstallTime() -> Bool {
        let last = Int64(UserDefaults.standard.string(forKey: KEY_INSTALL_TIME) ?? "0")!
        let now = Date().millisecondsSince1970
        return last < now
    }
    
    func setHideValue(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_HIDE_VALUE)
    }
    
    func getHideValue() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_HIDE_VALUE)
    }
}
