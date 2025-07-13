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
    private let perPage: Int = 20
    private var page = 1
    private var currentTask: Task<Void, Never>?
    
    init(state: ImageSearchUiState = ImageSearchUiState()) {
        self.state = state
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
            let newItems = try await FakeDataSource.fetchItems(page: page, perPage: perPage, query: state.query)
            await MainActor.run {
                self.state.items += newItems
                self.page += 1
                self.state.totalItems = FakeDataSource.total
                self.state.status = .loaded
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

struct FakeDataSource {
    static let total = 100
    static func fetchItems(page: Int, perPage: Int, query: String) async throws -> [Photo] {
        try? await Task.sleep(nanoseconds: 2000 * 1_000_000)
        
        let allItems = Array(1...total).map { i in
            Photo(id: i, title: "item \(i)", url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")!)
        }
        
        let startIndex = (page - 1) * perPage
        let endIndex = min(startIndex + perPage, allItems.count)
        let pageItems = (startIndex < endIndex) ? Array(allItems[startIndex..<endIndex]) : []
        return pageItems
    }
}
