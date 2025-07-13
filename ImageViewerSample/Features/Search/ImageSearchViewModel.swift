//
//  ImageSearchViewModel.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation
import Combine

struct ImageSearchUiState {
    enum Status: Equatable {
        case idle
        case searching
        case loaded
        case loadingMore
        case empty
        case error
    }
    
    var query: String = ""
    var items: [Photo] = []
    var totalItems: Int = 0
    var status: Status = .idle
    
    var hasMoreItems: Bool {
        totalItems > items.count
    }
}


@MainActor
class ImageSearchViewModel: ObservableObject {
    @Published private(set) var state = ImageSearchUiState()
    private let datasource: PhotosDataSourceProtocol
    private let perPage: Int = 20
    private var page = 1
    private var currentTask: Task<Void, Never>?
    
    init(state: ImageSearchUiState = ImageSearchUiState(), datasource: PhotosDataSourceProtocol = PhotosDataSource()) {
        self.state = state
        self.datasource = datasource
    }
    
    func onQueryChanged(_ query: String) {
        state.query = query
        currentTask?.cancel()
        
        search()
    }
    
    func loadMoreItems() {
        guard state.hasMoreItems else { return }
        currentTask?.cancel()
        state.status = .loadingMore
        currentTask = Task { [weak self] in
            await self?.loadItems()
        }
    }
    
    func retry() {
        currentTask?.cancel()
        state.status = .searching
        currentTask = Task { [weak self] in
            await self?.loadItems()
        }
    }
    
    private func search() {
        currentTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500 * 1_000_000) // wait for 500 ms
            guard let self, !Task.isCancelled, !state.query.isEmpty else { return }
            state.status = .searching
            
            // load items
            await loadItems()
        }
    }
    
    private func loadItems() async {
        do {
            let response = try await datasource.search(query: state.query, page: page, perPage: perPage)
            let newItems = response.photos.map { e in
                Photo(
                    id: e.id,
                    thumbnailUrl: URL(string: e.src.tiny),
                    previewUrl: URL(string: e.src.original)
                )
            }
            await MainActor.run {
                if response.totalResults == 0 {
                    self.state.status = .empty
                } else {
                    self.state.items += newItems
                    self.page += 1
                    self.state.totalItems = response.totalResults
                    self.state.status = .loaded
                }
            }
        } catch is CancellationError {
            // ignore
        } catch {
            await MainActor.run {
                self.state.status = .error
            }
        }
    }
}
