//
//  main.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation



@main
struct WebDataApp {
    static func main() async throws {
        var protect = ProtectService()

        let cams = try await protect.cameras()
        dump(cams)
        
        let liveviews = try await protect.liveviews()
        dump(liveviews)
        
        let viewports = try await protect.viewports()
        dump(viewports)
    }
}
