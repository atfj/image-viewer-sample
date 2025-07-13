//
//  PexelsSearchResponse.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

/// Represents the response from the Pexels photo search API.
///
/// This structure contains metadata about the search results, such as the total number of results,
/// the current page, the number of results per page, and a list of photo objects matching the query.
/// It also includes a URL for fetching the next page of results, if available.
struct PexelsSearchResponse: Codable {
    let totalResults: Int
    let page: Int
    let perPage: Int
    let photos: [PexelsPhoto]
    let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case totalResults = "total_results"
        case page
        case perPage = "per_page"
        case photos
        case nextPage = "next_page"
    }
}

struct PexelsPhoto: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String
    let src: PexelsPhotoSrc
    let liked: Bool
    let alt: String

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}

struct PexelsPhotoSrc: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
