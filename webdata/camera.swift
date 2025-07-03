//
//  camera.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation

struct Camera: Codable, Identifiable, CustomStringConvertible {
    static let urlSuffix = "cameras"
    let name: String
    let id: String
    
    var description : String {
        return "\(name) [\(id)]"
    }
    
    // not specific to camera.  maybe extract to a protocol
    static func parse(_ data: Data) throws -> [Self] {
        try JSONDecoder().decode([Self].self, from: data)
    }
}
