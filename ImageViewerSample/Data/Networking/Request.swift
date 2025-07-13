//
//  Request.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

typealias Parameters = [String: Any]

protocol Request {
    associatedtype Response: Decodable

    var method: HttpMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var key: String { get }
    var token: String { get }
    var pathQueries: [URLQueryItem]? { get }
    var parameters: Parameters? { get }
    var contentType: ContentType { get }
}

extension Request {
    var baseURL: URL {
        return Bundle.main.baseURL
    }

    var key: String {
        return Bundle.main.apiKey
    }
    
    var token: String {
        return ""
    }

    var pathQueries: [URLQueryItem]? {
        return nil
    }

    var parameters: Parameters? {
        return nil
    }

    var contentType: ContentType {
        return .json
    }
    
    func buildURLRequest() -> URLRequest {
        let url = baseURL.appendingPathComponent(path, isDirectory: false)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        var httpBody: Data? = nil

        switch method {
        case .get:
            components?.queryItems = pathQueries
        case .post, .patch, .put:
            if let parameters = parameters {
                do {
                    let data = try JSONSerialization.data(withJSONObject: parameters)
                    httpBody = data
                } catch {
                    // MEMO: Need to handle error
                }
            }
        case .delete:
            break
        }

        var request = URLRequest(url: components?.url ?? url)
        request.httpMethod = method.rawValue

        switch contentType {
        case .json:
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
        default:
            fatalError("Unsupported content-type")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(key, forHTTPHeaderField: "X-API-KEY")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody

        return request
    }
}

/// Use when there are nothing  API response, like 201 status.
struct NoResponse: Decodable {}
