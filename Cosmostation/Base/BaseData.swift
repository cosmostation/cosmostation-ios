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


final class BaseData : NSObject{
    
    static let instance = BaseData()
    
    var database: Connection!
    var copySalt: String?
    
    
    public override init() {
        super.init();
        if database == nil {
            self.initdb();
        }
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
    
    func setLastTab(_ index : Int) {
        UserDefaults.standard.set(index, forKey: KEY_LAST_TAB)
    }
    
    func getLastTab() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_LAST_TAB)
    }
    
    func setNeedRefresh(_ refresh : Bool) {
        UserDefaults.standard.set(refresh, forKey: KEY_ACCOUNT_REFRESH_ALL)
    }
    
    func getNeedRefresh() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_ACCOUNT_REFRESH_ALL)
    }
    
    func setTheme(_ theme : Int) {
        UserDefaults.standard.set(theme, forKey: KEY_THEME)
    }
    
    func getTheme() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_THEME)
    }
    
    func getThemeType() -> UIUserInterfaceStyle {
        if (getTheme() == 1) {
            return UIUserInterfaceStyle.light
        } else if (getTheme() == 2) {
            return UIUserInterfaceStyle.dark
        } else {
            return UIUserInterfaceStyle.unspecified
        }
    }
    
    func getThemeString() -> String {
        if (getTheme() == 1) {
            return NSLocalizedString("theme_light", comment: "")
        } else if (getTheme() == 2) {
            return NSLocalizedString("theme_dark", comment: "")
        }
        return NSLocalizedString("theme_system", comment: "")
    }
    
    enum Language: Int, CustomStringConvertible {
        case System = 0
        case English = 1
        case Korean = 2
        case Japanese = 3
        
        var description: String {
            switch self {
            case .System: return Locale.current.languageCode ?? ""
            case .English: return "en"
            case .Korean: return "ko"
            case .Japanese: return "ja"
            }
        }
    }
    
    func setLanguage(_ language : Int) {
        UserDefaults.standard.set(language, forKey: KEY_LANGUAGE)
    }
    
    func getLanguage() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_LANGUAGE)
    }
    
    func getLanguageType() -> String {
        let lang = getLanguage()
        if(lang == 1) {
            return "English(United States)"
        } else if(lang == 2) {
            return "한국어(대한민국)"
        } else if(lang == 3) {
            return "日本語(日本)"
        }
        return NSLocalizedString("theme_system", comment: "")
    }
    
    func setCurrency(_ currency : Int) {
        UserDefaults.standard.set(currency, forKey: KEY_CURRENCY)
    }
    
    func getCurrency() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_CURRENCY)
    }
    
    func getCurrencyString() -> String {
        if (getCurrency() == 0) {
            return NSLocalizedString("currency_usd", comment: "")
        } else if (getCurrency() == 1) {
            return NSLocalizedString("currency_eur", comment: "")
        } else if (getCurrency() == 2) {
            return NSLocalizedString("currency_krw", comment: "")
        } else if (getCurrency() == 3) {
            return NSLocalizedString("currency_jpy", comment: "")
        } else if (getCurrency() == 4) {
            return NSLocalizedString("currency_cny", comment: "")
        } else if (getCurrency() == 5) {
            return NSLocalizedString("currency_rub", comment: "")
        } else if (getCurrency() == 6) {
            return NSLocalizedString("currency_gbp", comment: "")
        } else if (getCurrency() == 7) {
            return NSLocalizedString("currency_inr", comment: "")
        } else if (getCurrency() == 8) {
            return NSLocalizedString("currency_brl", comment: "")
        } else if (getCurrency() == 9) {
            return NSLocalizedString("currency_idr", comment: "")
        } else if (getCurrency() == 10) {
            return NSLocalizedString("currency_dkk", comment: "")
        } else if (getCurrency() == 11) {
            return NSLocalizedString("currency_nok", comment: "")
        } else if (getCurrency() == 12) {
            return NSLocalizedString("currency_sek", comment: "")
        } else if (getCurrency() == 13) {
            return NSLocalizedString("currency_chf", comment: "")
        } else if (getCurrency() == 14) {
            return NSLocalizedString("currency_aud", comment: "")
        } else if (getCurrency() == 15) {
            return NSLocalizedString("currency_cad", comment: "")
        } else if (getCurrency() == 16) {
            return NSLocalizedString("currency_myr", comment: "")
        }
        return ""
    }
    
    func getCurrencySymbol() -> String {
        if (getCurrency() == 0) {
            return NSLocalizedString("currency_usd_symbol", comment: "")
        } else if (getCurrency() == 1) {
            return NSLocalizedString("currency_eur_symbol", comment: "")
        } else if (getCurrency() == 2) {
            return NSLocalizedString("currency_krw_symbol", comment: "")
        } else if (getCurrency() == 3) {
            return NSLocalizedString("currency_jpy_symbol", comment: "")
        } else if (getCurrency() == 4) {
            return NSLocalizedString("currency_cny_symbol", comment: "")
        } else if (getCurrency() == 5) {
            return NSLocalizedString("currency_rub_symbol", comment: "")
        } else if (getCurrency() == 6) {
            return NSLocalizedString("currency_gbp_symbol", comment: "")
        } else if (getCurrency() == 7) {
            return NSLocalizedString("currency_inr_symbol", comment: "")
        } else if (getCurrency() == 8) {
            return NSLocalizedString("currency_brl_symbol", comment: "")
        } else if (getCurrency() == 9) {
            return NSLocalizedString("currency_idr_symbol", comment: "")
        } else if (getCurrency() == 10) {
            return NSLocalizedString("currency_dkk_symbol", comment: "")
        } else if (getCurrency() == 11) {
            return NSLocalizedString("currency_nok_symbol", comment: "")
        } else if (getCurrency() == 12) {
            return NSLocalizedString("currency_sek_symbol", comment: "")
        } else if (getCurrency() == 13) {
            return NSLocalizedString("currency_chf_symbol", comment: "")
        } else if (getCurrency() == 14) {
            return NSLocalizedString("currency_aud_symbol", comment: "")
        } else if (getCurrency() == 15) {
            return NSLocalizedString("currency_cad_symbol", comment: "")
        } else if (getCurrency() == 16) {
            return NSLocalizedString("currency_myr_symbol", comment: "")
        }
        return ""
    }
    
    func setPriceChaingColor(_ value : Int) {
        UserDefaults.standard.set(value, forKey: KEY_PRICE_CHANGE_COLOR)
    }
    
    func getPriceChaingColor() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_PRICE_CHANGE_COLOR)
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
    
    func setAutoPass(_ mode : Int) {
        UserDefaults.standard.set(mode, forKey: KEY_AUTO_PASS)
    }
    
    func getAutoPass() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_AUTO_PASS)
    }
    
    func getAutoPassString() -> String {
        if (getAutoPass() == 1) {
            return NSLocalizedString("autopass_5min", comment: "")
        } else if (getAutoPass() == 2) {
            return NSLocalizedString("autopass_10min", comment: "")
        } else if (getAutoPass() == 3) {
            return NSLocalizedString("autopass_30min", comment: "")
        }
        return NSLocalizedString("autopass_none", comment: "")
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
    
    func setUsingEnginerMode(_ using : Bool) {
        UserDefaults.standard.set(using, forKey: KEY_ENGINER_MODE)
    }
    
    func getUsingEnginerMode() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_ENGINER_MODE)
    }
    
    
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
    
    func setDBVersion(_ version: Int) {
        UserDefaults.standard.set(version, forKey: KEY_DB_VERSION)
    }
    
    func getDBVersion() -> Int {
        return UserDefaults.standard.integer(forKey: KEY_DB_VERSION)
    }
    
    func getUserHiddenChains() -> Array<String>? {
        return UserDefaults.standard.stringArray(forKey: KEY_USER_HIDEN_CHAINS) ?? []
    }
    
//    func setUserHiddenChains(_ hidedChains: Array<ChainType>) {
//        var toHideChain = Array<String>()
//        hidedChains.forEach { chainType in
//            toHideChain.append(WUtils.getChainDBName(chainType))
//        }
//        UserDefaults.standard.set(toHideChain, forKey: KEY_USER_HIDEN_CHAINS)
//    }
//
//    func getUserSortedChainS() -> Array<String>? {
//        return UserDefaults.standard.stringArray(forKey: KEY_USER_SORTED_CHAINS) ?? []
//    }
//
//    func setUserSortedChains(_ displayedChains: Array<ChainType>) {
//        var toDisplayChain = Array<String>()
//        displayedChains.forEach { chainType in
//            toDisplayChain.append(WUtils.getChainDBName(chainType))
//        }
//        UserDefaults.standard.set(toDisplayChain, forKey: KEY_USER_SORTED_CHAINS)
//    }
    
    
    func initdb() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var fileUrl = documentDirectory.appendingPathComponent("cosmostation").appendingPathExtension("sqlite3")
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try fileUrl.setResourceValues(resourceValues)
                
            } catch { print("failed to set resource value") }
            
            let database = try Connection(fileUrl.path)
            self.database = database
            
//            let createAccountTable = DB_ACCOUNT.create(ifNotExists: true) { (table) in
//                table.column(DB_ACCOUNT_ID, primaryKey: true)
//                table.column(DB_ACCOUNT_UUID)
//                table.column(DB_ACCOUNT_NICKNAME)
//                table.column(DB_ACCOUNT_FAVO)
//                table.column(DB_ACCOUNT_ADDRESS)
//                table.column(DB_ACCOUNT_BASECHAIN)
//                table.column(DB_ACCOUNT_HAS_PRIVATE)
//                table.column(DB_ACCOUNT_RESOURCE)
//                table.column(DB_ACCOUNT_FROM_MNEMONIC)
//                table.column(DB_ACCOUNT_PATH)
//                table.column(DB_ACCOUNT_IS_VALIDATOR)
//                table.column(DB_ACCOUNT_SEQUENCE_NUMBER)
//                table.column(DB_ACCOUNT_ACCOUNT_NUMBER)
//                table.column(DB_ACCOUNT_FETCH_TIME)
//                table.column(DB_ACCOUNT_M_SIZE)
//                table.column(DB_ACCOUNT_IMPORT_TIME)
//            }
//            try self.database.run(createAccountTable)
//            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_LAST_TOTAL, defaultValue: ""))
//            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_SORT_ORDER, defaultValue: 0))
//            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_PUSHALARM, defaultValue: false))
//            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_NEW_BIP, defaultValue: false))
//            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_CUSTOM_PATH, defaultValue: 0))
//            _ = try? self.database.run(DB_ACCOUNT.addColumn(DB_ACCOUNT_MNEMONIC_ID, defaultValue: -1))
//            
//            let createBalanceTable = DB_BALANCE.create(ifNotExists: true) { (table) in
//                table.column(DB_BALANCE_ID, primaryKey: true)
//                table.column(DB_BALANCE_ACCOUNT_ID)
//                table.column(DB_BALANCE_DENOM)
//                table.column(DB_BALANCE_AMOUNT)
//                table.column(DB_BALANCE_FETCH_TIME)
//                table.column(DB_BALANCE_FROZEN)
//                table.column(DB_BALANCE_LOCKED)
//            }
//            try self.database.run(createBalanceTable)
//            _ = try? self.database.run(DB_BALANCE.addColumn(DB_BALANCE_FROZEN, defaultValue: ""))
//            _ = try? self.database.run(DB_BALANCE.addColumn(DB_BALANCE_LOCKED, defaultValue: ""))
//            
//            let createMnemonicTable = DB_MNEMONIC.create(ifNotExists: true) { (table) in
//                table.column(DB_MNEMONIC_ID, primaryKey: true)
//                table.column(DB_MNEMONIC_UUID)
//                table.column(DB_MNEMONIC_NICKNAME)
//                table.column(DB_MNEMONIC_CNT)
//                table.column(DB_MNEMONIC_FAVO)
//                table.column(DB_MNEMONIC_IMPORT_TIME)
//            }
//            try self.database.run(createMnemonicTable)
//            _ = try? self.database.run(DB_MNEMONIC.addColumn(DB_MNEMONIC_IMPORT_TIME, defaultValue: -1))
//            
//            //delete LCD used old table
//            try self.database.run(DB_BONDING.drop(ifExists: true))
//            try self.database.run(DB_UNBONDING.drop(ifExists: true))
            
        } catch {
            print(error)
        }
    }
    
    
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
    
    /*
    public func selectMnemonicById(_ id: Int64) -> MWords? {
        return selectAllMnemonics().filter { $0.id == id }.first
    }
    
    public func insertMnemonics(_ mwords: MWords) -> Int64 {
        let toInsert = DB_MNEMONIC.insert(DB_MNEMONIC_UUID <- mwords.uuid,
                                          DB_MNEMONIC_NICKNAME <- mwords.nickName,
                                          DB_MNEMONIC_CNT <- mwords.wordsCnt,
                                          DB_MNEMONIC_FAVO <- mwords.isFavo,
                                          DB_MNEMONIC_IMPORT_TIME <- mwords.importTime)
        do {
            return try database.run(toInsert)
        } catch {
            return -1
        }
    }
    
    public func updateMnemonic(_ mwords: MWords) -> Int64 {
        let target = DB_MNEMONIC.filter(DB_MNEMONIC_ID == mwords.id)
        do {
            return try Int64(database.run(target.update(DB_MNEMONIC_NICKNAME <- mwords.nickName,
                                                        DB_MNEMONIC_FAVO <- mwords.isFavo)))
        } catch {
            return -1
        }
    }
    
    public func deleteMnemonic(_ mwords: MWords) -> Int {
        let query = DB_MNEMONIC.filter(DB_MNEMONIC_ID == mwords.id)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    */
    
    
    
    
//    public func selectAllAccounts() -> Array<Account> {
//        var result = Array<Account>()
//        do {
//            for accountBD in try database.prepare(DB_ACCOUNT) {
//                let account = Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
//                                      accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
//                                      accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
//                                      accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
//                                      accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
//                                      accountBD[DB_ACCOUNT_MNEMONIC_ID]);
//                account.setBalances(selectBalanceById(accountId: account.account_id))
//                result.append(account);
//            }
//        } catch {
//            print(error)
//        }
//        return result;
//    }
//
//    public func selectAccountsByMnemonic(_ id: Int64) -> Array<Account> {
//        var result = Array<Account>()
//        let allAccounts = selectAllAccounts()
//        for account in allAccounts {
//            if (account.account_mnemonic_id == id) {
//                result.append(account)
//            }
//        }
//        return result;
//    }
//
//    public func selectAccountByAddress(address: String) -> Account? {
//        do {
//            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ADDRESS == address)
//            if let accountBD = try database.pluck(query) {
//                return Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
//                               accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
//                               accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
//                               accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
//                               accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
//                               accountBD[DB_ACCOUNT_MNEMONIC_ID])
//            }
//            return nil
//        } catch {
//            print(error)
//        }
//        return nil
//    }
//
//    public func selectExistAccount(_ address: String, _ chainType: ChainType?) -> Account? {
//        do {
//            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ADDRESS == address && DB_ACCOUNT_BASECHAIN == WUtils.getChainDBName(chainType))
//            if let accountBD = try database.pluck(query) {
//                return Account(accountBD[DB_ACCOUNT_ID], accountBD[DB_ACCOUNT_UUID], accountBD[DB_ACCOUNT_NICKNAME], accountBD[DB_ACCOUNT_FAVO], accountBD[DB_ACCOUNT_ADDRESS],
//                               accountBD[DB_ACCOUNT_BASECHAIN], accountBD[DB_ACCOUNT_HAS_PRIVATE],  accountBD[DB_ACCOUNT_RESOURCE], accountBD[DB_ACCOUNT_FROM_MNEMONIC],
//                               accountBD[DB_ACCOUNT_PATH], accountBD[DB_ACCOUNT_IS_VALIDATOR], accountBD[DB_ACCOUNT_SEQUENCE_NUMBER], accountBD[DB_ACCOUNT_ACCOUNT_NUMBER],
//                               accountBD[DB_ACCOUNT_FETCH_TIME], accountBD[DB_ACCOUNT_M_SIZE], accountBD[DB_ACCOUNT_IMPORT_TIME], accountBD[DB_ACCOUNT_LAST_TOTAL],
//                               accountBD[DB_ACCOUNT_SORT_ORDER], accountBD[DB_ACCOUNT_PUSHALARM], accountBD[DB_ACCOUNT_NEW_BIP], accountBD[DB_ACCOUNT_CUSTOM_PATH],
//                               accountBD[DB_ACCOUNT_MNEMONIC_ID])
//            }
//            return nil
//        } catch {
//            print(error)
//        }
//        return nil
//    }
    
    public func isDupleAccount(_ address: String, _ chain: String) -> Bool {
        do {
            let query = DB_ACCOUNT.filter(DB_ACCOUNT_ADDRESS == address && DB_ACCOUNT_BASECHAIN == chain)
            if (try database.pluck(query)) != nil {
                return true
            } else {
                return false
            }
            
        } catch {
            print(error)
        }
        return true;
    }
    
    public func insertAccount(_ account: Account) -> Int64 {
        let insertAccount = DB_ACCOUNT.insert(DB_ACCOUNT_UUID <- account.account_uuid,
                                              DB_ACCOUNT_NICKNAME <- account.account_nick_name,
                                              DB_ACCOUNT_FAVO <- account.account_favo,
                                              DB_ACCOUNT_ADDRESS <- account.account_address,
                                              DB_ACCOUNT_BASECHAIN <- account.account_base_chain,
                                              DB_ACCOUNT_HAS_PRIVATE <- account.account_has_private,
                                              DB_ACCOUNT_RESOURCE <- account.account_resource,
                                              DB_ACCOUNT_FROM_MNEMONIC <- account.account_from_mnemonic,
                                              DB_ACCOUNT_PATH <- account.account_path,
                                              DB_ACCOUNT_IS_VALIDATOR <- account.account_is_validator,
                                              DB_ACCOUNT_SEQUENCE_NUMBER <- account.account_sequence_number,
                                              DB_ACCOUNT_ACCOUNT_NUMBER <- account.account_account_numner,
                                              DB_ACCOUNT_FETCH_TIME <- account.account_fetch_time,
                                              DB_ACCOUNT_M_SIZE <- account.account_m_size,
                                              DB_ACCOUNT_IMPORT_TIME <- account.account_import_time,
                                              DB_ACCOUNT_LAST_TOTAL <- account.account_last_total,
                                              DB_ACCOUNT_SORT_ORDER <- account.account_sort_order,
                                              DB_ACCOUNT_PUSHALARM <- account.account_push_alarm,
                                              DB_ACCOUNT_NEW_BIP <- account.account_new_bip44,
                                              DB_ACCOUNT_CUSTOM_PATH <- account.account_pubkey_type,
                                              DB_ACCOUNT_MNEMONIC_ID <- account.account_mnemonic_id)
        do {
            return try database.run(insertAccount)
        } catch {
            print(error)
            return -1
        }
    }
    
    public func updateAccount(_ account: Account) -> Int64 {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            return try Int64(database.run(target.update(DB_ACCOUNT_NICKNAME <- account.account_nick_name,
                                                        DB_ACCOUNT_FAVO <- account.account_favo,
                                                        DB_ACCOUNT_BASECHAIN <- account.account_base_chain,
                                                        DB_ACCOUNT_SEQUENCE_NUMBER <- account.account_sequence_number,
                                                        DB_ACCOUNT_ACCOUNT_NUMBER <- account.account_account_numner,
                                                        DB_ACCOUNT_RESOURCE <- account.account_resource,
                                                        DB_ACCOUNT_FETCH_TIME <- account.account_fetch_time)))
        } catch {
            print(error)
            return -1
        }
    }
    
    public func overrideAccount(_ account: Account) -> Int64 {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            return try Int64(database.run(target.update(DB_ACCOUNT_HAS_PRIVATE <- account.account_has_private,
                                                        DB_ACCOUNT_FROM_MNEMONIC <- account.account_from_mnemonic,
                                                        DB_ACCOUNT_PATH <- account.account_path,
                                                        DB_ACCOUNT_M_SIZE <- account.account_m_size,
                                                        DB_ACCOUNT_NEW_BIP <- account.account_new_bip44,
                                                        DB_ACCOUNT_CUSTOM_PATH <- account.account_pubkey_type,
                                                        DB_ACCOUNT_MNEMONIC_ID <- account.account_mnemonic_id)))
        } catch {
            print(error)
            return -1
        }
    }
    
    
    //for okchain display address
    public func updateAccountAddress(_ account: Account) {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_ADDRESS <- account.account_address))
        } catch {
            print(error)
        }
    }
    
    //for okchain key custom_path 0 -> tendermint(996), 1 -> ethermint(996), 2 -> etherium(60)
    public func updateAccountPathType(_ account: Account) {
        if (account.account_import_time > 1643986800000) { return  }
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_CUSTOM_PATH <- account.account_pubkey_type))
        } catch {
            print(error)
        }
    }
    
    
//    public func upgradeMnemonicDB() {
//        //select old mnemonics for accounts
//        var alreadyWords = Array<String>()
//        selectAllAccounts().forEach { account in
//            if (account.account_from_mnemonic) {
//                if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
//                    if !alreadyWords.contains(words) {
//                        alreadyWords.append(words)
//                    }
//                }
//            }
//        }
//        
//        //insert keychain and db for mnemonic
//        var mnemonicWords = selectAllMnemonics()
//        alreadyWords.forEach { alreadyWord in
//            if (mnemonicWords.filter { $0.getWords() == alreadyWord }.first == nil) {
//                let tempMWords = MWords.init(isNew: true)
//                if (KeychainWrapper.standard.set(alreadyWord, forKey: tempMWords.uuid.sha1(), withAccessibility: .afterFirstUnlockThisDeviceOnly)) {
//                    tempMWords.wordsCnt = Int64(alreadyWord.count)
//                    _ = insertMnemonics(tempMWords)
//                }
//            }
//        }
//        
//        //link account and mnemonic id(fkey)
//        mnemonicWords = selectAllMnemonics()
//        selectAllAccounts().forEach { account in
//            if (account.account_from_mnemonic) {
//                if let words = KeychainWrapper.standard.string(forKey: account.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines) {
//                    mnemonicWords.forEach { mnemonicWord in
//                        if (mnemonicWord.getWords() == words) {
//                            account.account_mnemonic_id = mnemonicWord.id
//                            updateMnemonicId(account)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    public func updateLastTotal(_ account: Account?, _ amount: String) {
        if (account == nil) { return}
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account!.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_LAST_TOTAL <- amount))
        } catch {
            print(error)
        }
    }
    
    public func updateSortOrder(_ accounts: Array<Account>) {
        for account in accounts {
            let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
            do {
                try database.run(target.update(DB_ACCOUNT_SORT_ORDER <- account.account_sort_order))
            } catch {
                print(error)
            }
        }
    }
    
    public func updateMnemonicId(_ account: Account) {
        let target = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            try database.run(target.update(DB_ACCOUNT_MNEMONIC_ID <- account.account_mnemonic_id))
        } catch {
            print(error)
        }
    }
    
    public func deleteAccount(account: Account) -> Int {
        let query = DB_ACCOUNT.filter(DB_ACCOUNT_ID == account.account_id)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    public func hasPassword() -> Bool{
        if(KeychainWrapper.standard.hasValue(forKey: "password")) {
            return true;
        } else {
            return false;
        }
    }
    
    /// checks if app lock is active and exists a password. If both are met returns true, false otherwise
    func isRequiredUnlock() -> Bool {
        getUsingAppLock() && hasPassword()
    }
    
    
    
    
    
    public func selectAllBalances() -> Array<Balance> {
        var result = Array<Balance>()
        do {
            for balanceBD in try database.prepare(DB_BALANCE) {
                let balance = Balance(balanceBD[DB_BALANCE_ID], balanceBD[DB_BALANCE_ACCOUNT_ID],
                                      balanceBD[DB_BALANCE_DENOM], balanceBD[DB_BALANCE_AMOUNT],
                                      balanceBD[DB_BALANCE_FETCH_TIME], balanceBD[DB_BALANCE_FROZEN],
                                      balanceBD[DB_BALANCE_LOCKED])
                result.append(balance);
            }
        } catch {
            print(error)
        }
        return result;
    }
    
    public func selectBalanceById(accountId: Int64) -> Array<Balance> {
        var result = Array<Balance>()
        do {
            for balanceBD in try database.prepare(DB_BALANCE.filter(DB_BALANCE_ACCOUNT_ID == accountId)) {
                let balance = Balance(balanceBD[DB_BALANCE_ID], balanceBD[DB_BALANCE_ACCOUNT_ID],
                                      balanceBD[DB_BALANCE_DENOM], balanceBD[DB_BALANCE_AMOUNT],
                                      balanceBD[DB_BALANCE_FETCH_TIME], balanceBD[DB_BALANCE_FROZEN],
                                      balanceBD[DB_BALANCE_LOCKED])
                result.append(balance);
            }
        } catch {
            print(error)
        }
        return result
    }
    
    public func deleteBalance(account: Account) -> Int {
        let query = DB_BALANCE.filter(DB_BALANCE_ACCOUNT_ID == account.account_id)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    public func deleteBalanceById(accountId: Int64) -> Int {
        let query = DB_BALANCE.filter(DB_BALANCE_ACCOUNT_ID == accountId)
        do {
            return  try database.run(query.delete())
        } catch {
            print(error)
            return -1
        }
    }
    
    public func insertBalance(balance: Balance) -> Int64 {
        let insertBalance = DB_BALANCE.insert(DB_BALANCE_ACCOUNT_ID <- balance.balance_account_id,
                                              DB_BALANCE_DENOM <- balance.balance_denom,
                                              DB_BALANCE_AMOUNT <- balance.balance_amount,
                                              DB_BALANCE_FETCH_TIME <- balance.balance_fetch_time,
                                              DB_BALANCE_FROZEN <- balance.balance_frozen,
                                              DB_BALANCE_LOCKED <- balance.balance_locked)
        do {
            return try database.run(insertBalance)
        } catch {
            print(error)
            return -1
        }
    }
    
    public func updateBalances(_ accountId: Int64, _ newBalances: Array<Balance>) {
        if(newBalances.count == 0) {
            _ = deleteBalanceById(accountId: accountId)
            return
        }
        _ = deleteBalanceById(accountId: newBalances[0].balance_account_id)
        for balance in newBalances {
            _ = self.insertBalance(balance: balance)
        }
    }
}
