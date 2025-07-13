//
//  PhotosDataSource.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

/// Protocol defining a data source for searching photos.
///
/// Implementers provide an async method to search for photos
/// with a query string and optional pagination parameters.
protocol PhotosDataSourceProtocol {
    /// Searches for photos matching the query.
    /// - Parameters:
    ///   - query: The search keyword.
    ///   - page: The page number for pagination (optional).
    ///   - perPage: The number of results per page (optional).
    /// - Returns: A `PexelsSearchResponse` containing the search results.
    func search(query: String, page: Int?, perPage: Int?) async throws -> PexelsSearchResponse
}

/// Concrete actor-based implementation of `PhotosDataSourceProtocol`.
///
/// Uses an API client to perform the search request asynchronously.
actor PhotosDataSource: PhotosDataSourceProtocol {
    let apiClient: ApiClientProtocol
    
    /// Initializes the data source with an API client.
    /// - Parameter apiClient: The API client to use (defaults to `ApiClient()`).
    init(_ apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    /// Searches for photos using the provided query and pagination.
    func search(query: String, page: Int? = nil, perPage: Int? = nil) async throws -> PexelsSearchResponse {
        let request = PixelsSearchRequest(query: query, perPage: perPage, page: page)
        return try await apiClient.request(of: request)
    }
}
