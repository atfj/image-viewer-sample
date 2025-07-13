//
//  ApiError.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

enum ApiError: Error {
    // Can't connect to the server (maybe offline?)
    case connectionError(error: URLError)
    // The server responded with a non 200 status code
    case serverError(statusCode: Int)
    // We got no data (0 bytes) back from the server
    case noDataError
    // The server response can't be converted from JSON to a Dictionary
    case jsonSerializationError(error: Error)
    // The Argo decoding Failed
    case jsonMappingError(converstionError: Error)
}
