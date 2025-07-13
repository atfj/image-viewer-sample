//
//  MockPhotosDataSource.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/14/25.
//

import Foundation
@testable import ImageViewerSample

class MockPhotosDataSource: PhotosDataSourceProtocol {
    var response: PexelsSearchResponse?
    var error: Error?
    var lastQuery: String?
    var lastPage: Int?
    var lastPerPage: Int?

    func search(query: String, page: Int?, perPage: Int?) async throws -> PexelsSearchResponse {
        lastQuery = query
        lastPage = page
        lastPerPage = perPage
        if let error = error { throw error }
        if let response = response { return response }
        throw URLError(.badServerResponse)
    }
}
