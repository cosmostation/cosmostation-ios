//
//  Boards.swift
//  Cosmostation
//
//  Created by 권혁준 on 2022/05/27.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation


public class Board {
    var id: Int?
    var chain: String?
    var type: String?
    var title: String?
    var created_at: String?
    var updated_at: String?
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? Int
        self.chain = dictionary?["chain"] as? String
        self.type = dictionary?["type"] as? String
        self.title = dictionary?["title"] as? String
        self.created_at = dictionary?["created_at"] as? String
        self.updated_at = dictionary?[updated_at] as? String
    }
}
