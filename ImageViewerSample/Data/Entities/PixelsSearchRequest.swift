//
//  PixelsSearchRequest.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

/// Represents a request to the Pexels photo search API.
///
/// This request structure encapsulates the parameters needed to perform a photo search,
/// including the search query, the number of results per page, and the page number.
/// It conforms to the `Request` protocol and specifies the endpoint path and query parameters
/// required by the Pexels API. The expected response type is `PexelsSearchResponse`.
struct PixelsSearchRequest: Request {
    
    typealias Response = PexelsSearchResponse
    
    let query: String
    
    let perPage: Int?
    
    let page: Int?
    
    var method: HttpMethod = .get
    
    var path: String {
        "v1/search"
    }
    
    var pathQueries: [URLQueryItem]? {
        var queries = [URLQueryItem(name: "query", value: query)]
        if let perPage = perPage {
            queries.append(URLQueryItem(name: "per_page", value: String(perPage)))
        }
        if let page = page {
            queries.append(URLQueryItem(name: "page", value: String(page)))
        }
        return queries
    }
}
