//
//  IVWEvent.swift
//  EasyTrackingAnalytics
//
//  Created by Avi Levin on 11/10/2020.
//

import Foundation

struct IVWEvent: Codable, Equatable {
    var event: String
    var code: String
    var trackOnce: Bool?
    var fromEvents: [String]?
    
    
    enum CodingKeys: String, CodingKey {
        case event = "event"
        case code = "code"
        case trackOnce = "track_once"
        case fromEvents = "from_events"
    }
    
}

public extension String {
    func isRegExMatched(to string: String) -> Bool {
        return self.lowercased().range(of: string.lowercased(),
                                       options: .regularExpression) != nil
    }
}

struct IVWEvents: Decodable {
    let events: [IVWEvent]
}
