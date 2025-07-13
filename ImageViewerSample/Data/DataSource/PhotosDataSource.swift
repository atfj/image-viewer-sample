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

// MARK: Mock
actor MockPhotosDataSource: PhotosDataSourceProtocol {
    static var mock: PhotosDataSourceProtocol {
        MockPhotosDataSource()
    }
    
    func search(query: String, page: Int? = nil, perPage: Int? = nil) async throws -> PexelsSearchResponse {
        let items: [PexelsPhoto] = Array(1...5).map { i in
            let url = "https://www.pexels.com/photo/trees-during-day-3573351/"
            let imageUrl = "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png"
            return PexelsPhoto(
                id: i,
                width: 3066,
                height: 3968,
                url: url,
                photographer: "Lukas Rodriguez",
                photographerUrl: "https://www.pexels.com/@lukas-rodriguez-1845331",
                photographerId: 2,
                avgColor: "#374824",
                src: PexelsPhotoSrc(
                    original: imageUrl + "?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
                    large2x: imageUrl + "?auto=compress&cs=tinysrgb&h=650&w=940",
                    large: imageUrl + "?auto=compress&cs=tinysrgb&h=650&w=940",
                    medium: imageUrl + "?auto=compress&cs=tinysrgb&h=650&w=940",
                    small: imageUrl + "?auto=compress&cs=tinysrgb&h=650&w=940",
                    portrait: imageUrl + "?auto=compress&cs=tinysrgb&h=650&w=940",
                    landscape: imageUrl + "?auto=compress&cs=tinysrgb&h=650&w=940",
                    tiny: imageUrl + "?auto=compress&cs=tinysrgb&fit=crop&h=200&w=280"
                ),
                liked: false,
                alt: "Brown Rocks During Golden Hour"
            )
        }
        return PexelsSearchResponse(
            totalResults: 5,
            page: 1,
            perPage: 1,
            photos: items,
            nextPage: nil
        )
    }
}
