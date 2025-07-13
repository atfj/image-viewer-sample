//
//  ContentView.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/8/25.
//

import SwiftUI

struct ImageSearchView: View {
    @StateObject var viewModel: ImageSearchViewModel
    
    private let items: [Photo] = Array(1...100).map { i in
        Photo(id: i, title: "item \(i)", url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")!)
    }
    
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 16)]
    
    init(viewModel: ImageSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state.status {
                case .idle:
                    Text("Type something to search...")
                case .searching:
                    ProgressView()
                case .searched:
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(viewModel.state.items) { item in
                                ImageThumbnail(url: item.url)
                            }
                        }
                    }
                case .empty:
                    Text("No results found")
                case .error:
                    Text("Failed to load images")
                }
            }
            .searchable(
                text: Binding(
                    get: { viewModel.state.query },
                    set: { viewModel.onQueryChanged($0) }
                ),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search by keyword"
            )
            .padding()
        }
    }
}

struct ImageThumbnail: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 100, height: 100)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
            case .failure:
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.secondary)
                    .frame(width: 100, height: 100)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 100, height: 100)
    }
}

#Preview("ImageThumbnail") {
    VStack(spacing: 16) {
        ImageThumbnail(url: nil)
        ImageThumbnail(url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280"))
        ImageThumbnail(url: URL(string: "https://invalid-url"))
    }
}

#Preview("Default") {
    let viewModel = ImageSearchViewModel()
    ImageSearchView(viewModel: viewModel)
}

#Preview("Empty") {
    let state = ImageSearchUiState(
        query: "test",
        items: [],
        totalItems: 0,
        status: .empty
    )
    let viewModel = ImageSearchViewModel(state: state)
    ImageSearchView(viewModel: viewModel)
}

#Preview("Loading") {
    let state = ImageSearchUiState(
        query: "test",
        items: [],
        totalItems: 0,
        status: .searching
    )
    let viewModel = ImageSearchViewModel(state: state)
    ImageSearchView(viewModel: viewModel)
}

#Preview("Loaded") {
    let items: [Photo] = Array(1...5).map { i in
        Photo(id: i, title: "item \(i)", url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")!)
    }
    let state = ImageSearchUiState(
        query: "test",
        items: items,
        totalItems: 10,
        status: .searched
    )
    let viewModel = ImageSearchViewModel(state: state)
    ImageSearchView(viewModel: viewModel)
}
