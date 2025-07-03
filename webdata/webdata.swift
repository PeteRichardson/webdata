//
//  main.swift
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
    
    static func parse(_ data: Data) throws -> [Self] {
        try JSONDecoder().decode([Self].self, from: data)
    }
}


struct ProtectService {
    let host = "udm.local"
    var base_url: URL {
        URL(string: "http://\(host)/proxy/protect/integration/v1")!
    }
    var _cameras: [Camera]? = nil     // cache the camera values
    // TODO: save a timestamp and check if it's been "too long" since the last GET
    //       Not really an issue for camview, which does one thing and quits, but
    //       if we add a REPL or use this in a long term app, might need a refresh.
    
    mutating func cameras() async throws -> [Camera] {
        if let cached = _cameras {
            return cached
        }
        
        let cameras = try Camera.parse(try await fetchData(for: Camera.urlSuffix, accepting: "application/json"))
        _cameras = cameras
        return cameras
    }
    
    func fetchData(for path: String, accepting mimetype: String = "*/*") async throws -> Data {
        let url = base_url.appendingPathComponent(Camera.urlSuffix)
        var request = URLRequest(url: url)
        let apiKey = try Keychain.LoadApiKey()
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("accepts", forHTTPHeaderField: mimetype)
        
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
    }
}
