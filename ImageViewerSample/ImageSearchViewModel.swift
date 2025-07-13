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
        case searched
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
    private var currentTask: Task<Void, Never>?
    
    init(state: ImageSearchUiState = ImageSearchUiState()) {
        self.state = state
    }
    
    func onQueryChanged(_ query: String) {
        state.query = query
        currentTask?.cancel()
        
        search()
    }
    
    private func search() {
        currentTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500 * 1_000_000) // wait for 500 ms
            guard let self, !Task.isCancelled, !state.query.isEmpty else { return }
            
            // load items
            state.status = .searching
            try? await Task.sleep(nanoseconds: 2000 * 1_000_000)
            state.items = Array(1...100).map { i in
                Photo(id: i, title: "item \(i)", url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")!)
            }
            state.totalItems = state.items.count
            state.status = .searched
        }
    }
}
