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


final class BaseData: NSObject{
    
    static let instance = BaseData()
    
    var database: Connection!
    var copySalt: String?
    
    var baseAccount: BaseAccount!
    var mintscanUSDPrices: [MintscanPrice]?
    var mintscanPrices: [MintscanPrice]?
    var mintscanAssets: [MintscanAsset]?
    
    
    public override init() {
        super.init();
        if database == nil {
            self.initdb();
        }
    }
    
    
    func getAsset(_ chainName: String, _ denom: String) -> MintscanAsset? {
        return mintscanAssets?.filter({ $0.chain == chainName && $0.denom?.lowercased() == denom.lowercased() }).first
    }
    
    func getPrice(_ geckoId: String?, _ usd: Bool? = false) -> NSDecimalNumber {
        if (usd == true) {
            if let price = mintscanUSDPrices?.filter({ $0.coinGeckoId == geckoId }).first {
                return NSDecimalNumber.init(value: price.current_price ?? 0).rounding(accordingToBehavior: getDivideHandler(12))
            }
            return NSDecimalNumber.zero.rounding(accordingToBehavior: getDivideHandler(12))
            
        } else {
            if let price = mintscanPrices?.filter({ $0.coinGeckoId == geckoId }).first {
                return NSDecimalNumber.init(value: price.current_price ?? 0).rounding(accordingToBehavior: getDivideHandler(12))
            }
            return NSDecimalNumber.zero.rounding(accordingToBehavior: getDivideHandler(12))
        }
    }
    
    func priceChange(_ geckoId: String?) -> NSDecimalNumber {
        if let price = mintscanPrices?.filter({ $0.coinGeckoId == geckoId }).first {
            return NSDecimalNumber.init(value: price.daily_price_change_in_percent ?? 0).rounding(accordingToBehavior: handler2Down)
        }
        return NSDecimalNumber.zero.rounding(accordingToBehavior: getDivideHandler(2))
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
    
    
    

    
    

    
    func setUsingBioAuth(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_USING_BIO_AUTH)
    }
    
    func getUsingBioAuth() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_USING_BIO_AUTH)
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
    

    
    
    func setFCMToken(_ token : String) {
        UserDefaults.standard.set(token, forKey: KEY_FCM_TOKEN)
    }
    
    func getFCMToken() -> String {
        return UserDefaults.standard.string(forKey: KEY_FCM_TOKEN) ?? ""
    }
    
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
            }
            try self.database.run(accountTable)
            
            let refAddressTable = TABLE_REFADDRESS.create(ifNotExists: true) { table in
                table.column(REFADDRESS_ID, primaryKey: true)
                table.column(REFADDRESS_ACCOUNT_ID)
                table.column(REFADDRESS_CHAIN_ID)
                table.column(REFADDRESS_DP_ADDRESS)
                table.column(REFADDRESS_LAST_AMOUNT)
                table.column(REFADDRESS_LAST_VALUE)
            }
            try self.database.run(refAddressTable)
            
        } catch { print(error) }
    }
    
    //V2 version baseAccount
    public func selectAccounts() -> Array<BaseAccount> {
        var result = Array<BaseAccount>()
        for row in try! database.prepare(TABLE_BASEACCOUNT) {
            result.append(BaseAccount(row[BASEACCOUNT_ID], row[BASEACCOUNT_UUID], row[BASEACCOUNT_NAME], row[BASEACCOUNT_TYPE], row[BASEACCOUNT_LAST_PATH]))
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
                                                BASEACCOUNT_LAST_PATH <- account.lastHDPath)
        return try! database.run(toInsert)
    }
    
    //V2 version refAddress
    public func selectRefAddresses(_ accountId: Int64) -> Array<RefAddress> {
        var result = Array<RefAddress>()
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == accountId)
        for rowInfo in try! database.prepare(query) {
            result.append(RefAddress(rowInfo[REFADDRESS_ID], rowInfo[REFADDRESS_ACCOUNT_ID], rowInfo[REFADDRESS_CHAIN_ID],
                                     rowInfo[REFADDRESS_DP_ADDRESS], rowInfo[REFADDRESS_LAST_AMOUNT], rowInfo[REFADDRESS_LAST_VALUE]))
        }
        return result
    }
    
    @discardableResult
    public func insertRefAddresses(_ refAddress: RefAddress) -> Int64 {
        let toInsert = TABLE_REFADDRESS.insert(REFADDRESS_ACCOUNT_ID <- refAddress.accountId,
                                               REFADDRESS_CHAIN_ID <- refAddress.chainId,
                                               REFADDRESS_DP_ADDRESS <- refAddress.dpAddress,
                                               REFADDRESS_LAST_AMOUNT <- refAddress.lastAmount,
                                               REFADDRESS_LAST_VALUE <- refAddress.lastValue)
        return try! database.run(toInsert)
    }
    
    @discardableResult
    public func updateRefAddresses(_ refAddress: RefAddress) -> Int? {
        let query = TABLE_REFADDRESS.filter(REFADDRESS_ACCOUNT_ID == refAddress.accountId &&
                                            REFADDRESS_CHAIN_ID == refAddress.chainId &&
                                            REFADDRESS_DP_ADDRESS == refAddress.dpAddress)
        if let address = try! database.pluck(query) {
            let target = TABLE_REFADDRESS.filter(REFADDRESS_ID == address[REFADDRESS_ID])
            return try? database.run(target.update(REFADDRESS_LAST_AMOUNT <- refAddress.lastAmount,
                                                   REFADDRESS_LAST_VALUE <- refAddress.lastValue))
            
        } else {
            return Int(insertRefAddresses(refAddress))
        }
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
    
    func setDisplayCosmosChainNames(_ baseAccount: BaseAccount, _ chainNames: [String])  {
        if let encoded = try? JSONEncoder().encode(chainNames) {
            UserDefaults.standard.setValue(encoded, forKey: String(baseAccount.id) + " " + KEY_DISPLAY_COSMOS_CHAINS)
        }
    }
    
    func getDisplayCosmosChainNames(_ baseAccount: BaseAccount) -> [String] {
        if let savedData = UserDefaults.standard.object(forKey: String(baseAccount.id) + " " + KEY_DISPLAY_COSMOS_CHAINS) as? Data {
            if let result = try? JSONDecoder().decode([String].self, from: savedData) {
                return result
            }
        }
        return DEFUAL_DISPALY_COSMOS
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
}
