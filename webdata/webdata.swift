//
//  main.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation


enum MIMEType: String {
    case json = "application/json"
    case jpeg = "application/jpeg"
}


struct ProtectService {
    let host = "udm.local"
    var base_url: URL {
        URL(string: "http://\(host)/proxy/protect/integration/v1")!
    }
    var _cameras: [Camera]? = nil     // cache the camera values
    var _liveviews: [Liveview]? = nil     // cache the liveview values
    var _viewports: [Viewport]? = nil     // cache the viewport values

    // TODO: save a timestamp and check if it's been "too long" since the last GET
    //       Not really an issue for camview, which does one thing and quits, but
    //       if we add a REPL or use this in a long term app, might need a refresh.
    
    mutating func cameras() async throws -> [Camera] {
        if let cached = _cameras {
            return cached
        }
        
        let cameras = try Camera.parse(try await fetchData(for: Camera.urlSuffix, accepting: .json))
        _cameras = cameras
        return cameras
    }
    
    mutating func liveviews() async throws -> [Liveview] {
        if let cached = _liveviews {
            return cached
        }
        
        let liveviews = try Liveview.parse(try await fetchData(for: Liveview.urlSuffix, accepting: .json))
        _liveviews = liveviews
        return liveviews
    }

    mutating func viewports() async throws -> [Viewport] {
        if let cached = _viewports {
            return cached
        }
        
        let viewports = try Viewport.parse(try await fetchData(for: Viewport.urlSuffix, accepting: .json))
        _viewports = viewports
        return viewports
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


@main
struct WebDataApp {
    static func main() async {
        var ps = ProtectService()
        let cams = try? await ps.cameras()
        dump(cams)
        
        let liveviews = try? await ps.liveviews()
        dump(liveviews)

        let viewports = try? await ps.viewports()
        dump(viewports)

    }
}
