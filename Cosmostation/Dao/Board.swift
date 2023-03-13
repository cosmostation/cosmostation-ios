//
//  Board.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/03/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

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
