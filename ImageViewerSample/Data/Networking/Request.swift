//
//  Request.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

typealias Parameters = [String: Any]

/// Protocol representing an API request.
///
/// Conforming types specify the expected response type, HTTP method, endpoint path,
/// authentication, query parameters, body parameters, and content type.
/// Provides a default implementation for building a `URLRequest`.
protocol Request {
    /// The expected response type for this request
    associatedtype Response: Decodable

    /// The HTTP method (GET, POST, etc.)
    var method: HttpMethod { get }
    /// The base URL for the API
    var baseURL: URL { get }
    /// The endpoint path (appended to the base URL)
    var path: String { get }
    /// The API key for authorization
    var key: String { get }
    /// The bearer token for authorization (if used)
    var token: String { get }
    /// Query items to be added to the URL
    var pathQueries: [URLQueryItem]? { get }
    /// Parameters to be sent in the request body
    var parameters: Parameters? { get }
    /// The content type of the request (e.g., JSON)
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
        if key.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
        request.httpBody = httpBody

        return request
    }
}

/// Use when there are nothing  API response, like 201 status.
struct NoResponse: Decodable {}
