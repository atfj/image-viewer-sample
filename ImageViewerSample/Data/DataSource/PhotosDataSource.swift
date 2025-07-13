//
//  PhotosDataSource.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

protocol PhotosDataSourceProtocol {
    func search(query: String, page: Int?, perPage: Int?) async throws -> PexelsSearchResponse
}

actor PhotosDataSource: PhotosDataSourceProtocol {
    let apiClient: ApiClientProtocol
    
    init(_ apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func search(query: String, page: Int? = nil, perPage: Int? = nil) async throws -> PexelsSearchResponse {
        let request = PixelsSearchRequest(query: query, perPage: perPage, page: page)
        return try await apiClient.request(of: request)
    }
}
