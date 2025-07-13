//
//  MockApiClient.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation
import Combine
@testable import ImageViewerSample

class MockApiSession: ApiSessionProtocol {
    let body: String
    let statusCode: Int
    let urlError: URLError?

    init(body: String, statusCode: Int, urlError: URLError? = nil) {
        self.body = body
        self.statusCode = statusCode
        self.urlError = urlError
    }

    func data<R: Request>(for request: R) async throws -> (Data, URLResponse) {
        if let urlError = urlError {
            throw urlError
        } else {
            let responseData = body.data(using: .utf8)!
            let res = HTTPURLResponse(
                url: URL(string: "\(request.baseURL)\(request.path)")!,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )!
            return (responseData, res)
        }
    }
}

class MockApiClient: ApiClientProtocol {
    var session: ApiSessionProtocol = MockApiSession(body: "", statusCode: 404)

    func setResponse(body: String, statusCode: Int, urlError: URLError? = nil) {
        self.session = MockApiSession(body: body, statusCode: statusCode, urlError: urlError)
    }
}
