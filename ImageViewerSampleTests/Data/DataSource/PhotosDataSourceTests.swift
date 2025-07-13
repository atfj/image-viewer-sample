//
//  PhotosDataSourceTests.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import XCTest
@testable import ImageViewerSample

final class PhotosDataSourceTests: XCTestCase {
    var mockApiClient: MockApiClient!
    var dataSource: PhotosDataSource!

    override func setUp() {
        super.setUp()
        mockApiClient = MockApiClient()
        dataSource = PhotosDataSource(mockApiClient)
    }

    func testSearch_Success() async throws {
        let photoSrc = PexelsPhotoSrc(
            original: "original_url",
            large2x: "large2x_url",
            large: "large_url",
            medium: "medium_url",
            small: "small_url",
            portrait: "portrait_url",
            landscape: "landscape_url",
            tiny: "tiny_url"
        )
        let photo = PexelsPhoto(
            id: 1,
            width: 100,
            height: 100,
            url: "photo_url",
            photographer: "John Doe",
            photographerUrl: "photographer_url",
            photographerId: 123,
            avgColor: "#FFFFFF",
            src: photoSrc,
            liked: false,
            alt: "alt text"
        )
        let response = PexelsSearchResponse(
            totalResults: 1,
            page: 1,
            perPage: 1,
            photos: [photo],
            nextPage: nil
        )
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(response)
        let encodedBody = String(data: encodedData, encoding: .utf8)!
        mockApiClient.setResponse(body: encodedBody, statusCode: 200)

        // Act
        let result = try await dataSource.search(query: "nature", page: 1, perPage: 1)

        // Assert
        XCTAssertEqual(result.totalResults, 1)
        XCTAssertEqual(result.photos.first?.id, 1)
        XCTAssertEqual(result.photos.first?.photographer, "John Doe")
    }
    
    func testSearch_Failure() async throws {
        // Arrange: Simulate a server error
        mockApiClient.setResponse(body: "", statusCode: 500)

        // Act & Assert
        do {
            _ = try await dataSource.search(query: "nature", page: 1, perPage: 1)
            XCTFail("Expected to throw, but succeeded")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
