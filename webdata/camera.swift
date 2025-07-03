//
//  camera.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation

struct Camera: ProtectFetchable {
    static let urlSuffix = "cameras"
    let name: String
    let id: String
}
