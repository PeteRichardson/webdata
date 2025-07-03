//
//  protocols.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation

protocol ProtectServiceObject: Codable, Identifiable, CustomStringConvertible, Equatable {
    static var urlSuffix : String  { get }
    var description : String { get }
    var name: String { get }
}

extension ProtectServiceObject {
    static func parse(_ data: Data) throws -> [Self] {
        try JSONDecoder().decode([Self].self, from: data)
    }
    
    var description : String {
        return "\(self.name) [\(self.id)]"
    }
}
