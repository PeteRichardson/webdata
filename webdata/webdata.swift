//
//  main.swift
//  webdata
//
//  Created by Peter Richardson on 7/3/25.
//

import Foundation

struct Camera: Codable, Identifiable, CustomStringConvertible {
    static let cameraURLSuffix = "cameras"
    let name: String
    let id: String
    
    var description : String {
        return "\(name) [\(id)]"
    }
    
    static func parse(_ jsonData: Data) throws -> [Self] {
        try JSONDecoder().decode([Self].self, from: jsonData)
    }
}




struct ProtectService {
    let host = "udm.local"
    var base_url: URL {
        URL(string: "http://\(host)/proxy/protect/integration/v1")!
    }
    var _cameras: [Camera]? = nil
    
    mutating func cameras() async throws -> [Camera] {
        if let cached = _cameras {
            return cached
        }
        
        let cameras = try Camera.parse(try await fetchData(for: Camera.cameraURLSuffix, accepting: "application/json"))
        _cameras = cameras
        return cameras
    }
    
    func fetchData(for path: String, accepting mimetype: String = "*/*") async throws -> Data {
        let url = base_url.appendingPathComponent(Camera.cameraURLSuffix)
        var request = URLRequest(url: url)
        request.setValue("XXXXXXXXXXXXXXXXXXXX", forHTTPHeaderField: "X-API-KEY")
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
