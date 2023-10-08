//
//  Account.swift
//  Cosmostation
//
//  Created by yongjoo on 20/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import Foundation
import MobileCoreServices

public class Account {
    
    var account_id: Int64 = -1;
    var account_uuid: String = "";
    var account_nick_name: String = "";
    var account_favo: Bool = false;
    var account_address: String = "";
    
    var account_base_chain: String = "";
    var account_has_private: Bool = false;
    var account_resource:String = "";
    var account_from_mnemonic:Bool = false;
    var account_path:String = "";
    
    var account_is_validator: Bool = false;
    var account_sequence_number: Int64 = -1;
    var account_account_numner: Int64 = -1;
    var account_fetch_time:Int64 = -1;
    var account_m_size:Int64 = -1;
    
    var account_import_time:Int64 = -1;
    var account_last_total:String = "";
    var account_sort_order:Int64 = 0;
    var account_push_alarm: Bool = false;
    var account_new_bip44: Bool = false;
    
    var account_pubkey_type: Int64 = 0;                //this is using how to sign type
    var account_mnemonic_id: Int64 = 0;
    
    
    enum CodingKeys: String, CodingKey {
        case account_id
        case account_uuid
        case account_nick_name
        case account_favo
        case account_address
        case account_base_chain
        case account_has_private
        case account_resource
        case account_from_mnemonic
        case account_path
        case account_is_validator
        case account_sequence_number
        case account_account_numner
        case account_fetch_time
        case account_m_size
        case account_import_time
        case account_last_total
        case account_sort_order
        case account_push_alarm
        case account_new_bip44
        case account_pubkey_type
        case account_mnemonic_id
    }
    
    init(isNew: Bool) {
        account_uuid = UUID().uuidString
    }
    
    init(_ id:Int64, _ uuid:String, _ nickName:String, _ favo:Bool, _ address:String,
         _ baseChain:String, _ hasPrivate:Bool, _ resource:String, _ fromMnemonic:Bool, _ path:String,
         _ isValidator:Bool, _ sequenceNumber:Int64, _ accountNumber:Int64, _ fetchTime:Int64, _ mSize:Int64,
         _ importTime:Int64, _ lastTotal:String, _ sortOrder:Int64, _ pushAlarm:Bool, _ newbip:Bool, _ customPath:Int64,
         _ mnemonicId: Int64) {
        
        self.account_id = id;
        self.account_uuid = uuid;
        self.account_nick_name = nickName;
        self.account_favo = favo;
        self.account_address = address;
        
        self.account_base_chain = baseChain;
        self.account_has_private = hasPrivate;
        self.account_resource = resource;
        self.account_from_mnemonic = fromMnemonic;
        self.account_path = path;
        
        self.account_is_validator = isValidator;
        self.account_sequence_number = sequenceNumber;
        self.account_account_numner = accountNumber;
        self.account_fetch_time = fetchTime;
        self.account_m_size = mSize;
        
        self.account_import_time = importTime;
        self.account_last_total = lastTotal
        self.account_sort_order = sortOrder;
        self.account_push_alarm = pushAlarm;
        self.account_new_bip44 = newbip;
        
        self.account_pubkey_type = customPath;
        self.account_mnemonic_id = mnemonicId;
        
    }
    
//    var account_balances = Array<Balance>()
//
    func getPrivateKeySha1() -> String {
        return (account_uuid + "privateKey").sha1()
    }
}
