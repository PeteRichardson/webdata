//
//  viewport.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation


struct Viewport: Codable, Identifiable, CustomStringConvertible {
    static let urlSuffix = "viewers"
    let name: String
    let id: String
    
    var description : String {
        return "\(name) [\(id)]"
    }
    
    // not specific to liveviews.  maybe extract to a protocol
    static func parse(_ data: Data) throws -> [Self] {
        try JSONDecoder().decode([Self].self, from: data)
    }
}
