//
//  ApiClient.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

/// Protocol defining an async data task for API requests.
protocol ApiSessionProtocol {
    func data<R: Request>(for request: R) async throws -> (Data, URLResponse)
}

/// Protocol for an API client that can send requests and decode responses.
protocol ApiClientProtocol {
    var session: ApiSessionProtocol { get }
    func request<R: Request>(of request: R) async throws -> R.Response
}

/// Default implementation for sending a request and decoding the response.
extension ApiClientProtocol {
    func request<R: Request>(of request: R) async throws -> R.Response {
        do {
            let (data, response) = try await session.data(for: request)
            let range = 200..<300
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.serverError(statusCode: 0)
            }
            guard range.contains(httpResponse.statusCode) else {
                throw ApiError.serverError(statusCode: httpResponse.statusCode)
            }
            if data.isEmpty {
                // If R.Response is NoResponse, this cast is safe
                return NoResponse() as! R.Response
            }
            do {
                let decoded = try JSONDecoder().decode(R.Response.self, from: data)
                return decoded
            } catch {
                throw ApiError.jsonMappingError(converstionError: error)
            }
        } catch let error as ApiError {
            throw error
        } catch let error as URLError {
            throw ApiError.connectionError(error: error)
        } catch {
            throw error
        }
    }
}

/// Concrete implementation of ApiSessionProtocol using URLSession.
class ApiSession: ApiSessionProtocol {
    let session: URLSession

    init(_ session: URLSession = .shared) {
        self.session = session
    }

    func data<R: Request>(for request: R) async throws -> (Data, URLResponse) {
        try await session.data(for: request.buildURLRequest())
    }
}

/// Concrete API client using APISession for network requests.
class ApiClient: ApiClientProtocol {
    let session: ApiSessionProtocol = ApiSession()
}
