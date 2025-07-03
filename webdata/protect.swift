//
//  protect.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation


enum MIMEType: String {
    case json = "application/json"
    case jpeg = "application/jpeg"
}


class ProtectService {
    let host = "udm.local"
    var base_url: URL {
        URL(string: "http://\(host)/proxy/protect/integration/v1")!
    }
    private var cachedCameras: [Camera]? = nil         // cache the camera values
    private var cachedLiveviews: [Liveview]? = nil     // cache the liveview values
    private var cachedViewports: [Viewport]? = nil     // cache the viewport values
    
    func cameras() async throws -> [Camera] {
        try await fetchAndCache(cache: &cachedCameras)
    }

    func liveviews() async throws -> [Liveview] {
        try await fetchAndCache(cache: &cachedLiveviews)
    }

    func viewports() async throws -> [Viewport] {
        try await fetchAndCache(cache: &cachedViewports)
    }
    
    private func fetchAndCache<T: ProtectFetchable>(cache: inout [T]?) async throws -> [T] {
        if let cached = cache {
            return cached
        }
        let data = try await fetchData(for: T.urlSuffix, accepting: .json)
        cache = try T.parse(data)
        return cache!
    }
    
    func fetchData(for path: String, accepting mimetype: MIMEType = .json) async throws -> Data {
        let url = base_url.appendingPathComponent(path)
        var request = URLRequest(url: url)
        let apiKey = try Keychain.LoadApiKey()
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue(mimetype.rawValue, forHTTPHeaderField: "accepts")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
         
        return data
    }
    
    func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(
                domain: "ProtectService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)]
            )
        }
    }
}
