//
//  AdsInfos.swift
//  Cosmostation
//
//  Created by 권혁준 on 1/22/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

public struct AdsInfos: Codable {
    var ads: [AdsInfo]?
}

public struct AdsInfo: Codable {
    var id: String
    var priority: Int? = 1
    var startAt: String? = ""
    var endAt: String? = ""
    var images: AdsImage
    var linkUrl: String? = ""
    var title: String? = ""
    var view_detail: String? = ""
    var color: String? = "#FFFFFF"

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    
    func dateStringToLong(date: String?) -> Int64 {
        guard let s = date?.trimmingCharacters(in: .whitespacesAndNewlines),
              let date = Self.iso.date(from: s) else { return 0 }
        return Int64(date.timeIntervalSince1970 * 1000)
    }
}

public struct AdsImage: Codable {
    var `extension`: String? = ""
    var mobile: String? = ""
}
