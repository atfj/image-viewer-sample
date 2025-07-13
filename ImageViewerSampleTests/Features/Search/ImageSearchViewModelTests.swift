//
//  ImageSearchViewModelTests.swift
//  ImageViewerSampleTests
//
//  Created by Atsuhiro Fujita on 7/14/25.
//

import XCTest
@testable import ImageViewerSample

final class ImageSearchViewModelTests: XCTestCase {

    var mockDataSource: MockPhotosDataSource!
    var viewModel: ImageSearchViewModel!

    override func setUp() async throws {
        mockDataSource = MockPhotosDataSource()
        viewModel = await ImageSearchViewModel(datasource: mockDataSource)
    }
    
    func testQueryChanged_UpdatesStateAndLoadsItems() async {
        let photoSrc = PexelsPhotoSrc(
            original: "https://original.com",
            large2x: "",
            large: "",
            medium: "",
            small: "",
            portrait: "",
            landscape: "",
            tiny: "https://tiny.com"
        )
        let photo = PexelsPhoto(
            id: 1,
            width: 100,
            height: 100,
            url: "",
            photographer: "",
            photographerUrl: "",
            photographerId: 0,
            avgColor: "",
            src: photoSrc,
            liked: false,
            alt: ""
        )
        let response = PexelsSearchResponse(
            totalResults: 1,
            page: 1,
            perPage: 20,
            photos: [photo],
            nextPage: nil
        )
        mockDataSource.response = response

        // Act
        await viewModel.send(.queryChanged("nature"))
        try? await Task.sleep(nanoseconds: 600 * 1_000_000) // Wait for debounce and async

        // Assert
        let state = await MainActor.run { viewModel.state }
        XCTAssertEqual(state.query, "nature")
        XCTAssertEqual(state.items.count, 1)
        XCTAssertEqual(state.status, .loaded)
        XCTAssertEqual(state.items.first?.id, 1)
    }
    
    func testLoadMoreItems_AppendsResults() async {
        let photoSrc = PexelsPhotoSrc(
            original: "https://original.com",
            large2x: "",
            large: "",
            medium: "",
            small: "",
            portrait: "",
            landscape: "",
            tiny: "https://tiny.com"
        )
        let photo1 = PexelsPhoto(
            id: 1, width: 100, height: 100, url: "", photographer: "", photographerUrl: "", photographerId: 0, avgColor: "", src: photoSrc, liked: false, alt: ""
        )
        let photo2 = PexelsPhoto(
            id: 2, width: 100, height: 100, url: "", photographer: "", photographerUrl: "", photographerId: 0, avgColor: "", src: photoSrc, liked: false, alt: ""
        )
        let response1 = PexelsSearchResponse(totalResults: 2, page: 1, perPage: 1, photos: [photo1], nextPage: nil)
        let response2 = PexelsSearchResponse(totalResults: 2, page: 2, perPage: 1, photos: [photo2], nextPage: nil)
        mockDataSource.response = response1

        // First search
        await viewModel.send(.queryChanged("nature"))
        try? await Task.sleep(nanoseconds: 600 * 1_000_000)
        let firstState = await MainActor.run { viewModel.state }
        XCTAssertEqual(firstState.items.count, 1)
        XCTAssertEqual(firstState.items.first?.id, 1)

        // Load more
        mockDataSource.response = response2
        await viewModel.send(.loadMoreItems)
        try? await Task.sleep(nanoseconds: 200 * 1_000_000)
        let loadState = await MainActor.run { viewModel.state }
        XCTAssertEqual(loadState.items.count, 2)
        XCTAssertEqual(loadState.items.last?.id, 2)
        XCTAssertEqual(loadState.status, .loaded)
    }
    
    func testSearch_EmptyResults_SetsEmptyStatus() async {
        let response = PexelsSearchResponse(totalResults: 0, page: 1, perPage: 20, photos: [], nextPage: nil)
        mockDataSource.response = response

        // Act
        await viewModel.send(.queryChanged("nothing"))
        try? await Task.sleep(nanoseconds: 600 * 1_000_000)

        // Assert
        let state = await MainActor.run { viewModel.state }
        XCTAssertEqual(state.status, .empty)
        XCTAssertEqual(state.items.count, 0)
    }

    func testSearch_Error_SetsErrorStatus() async {
        mockDataSource.error = URLError(.notConnectedToInternet)

        // Act
        await viewModel.send(.queryChanged("fail"))
        try? await Task.sleep(nanoseconds: 600 * 1_000_000)

        // Assert
        let state = await MainActor.run { viewModel.state }
        XCTAssertEqual(state.status, .error)
    }
}
