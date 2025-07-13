//
//  ContentView.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/8/25.
//

import SwiftUI

struct ImageSearchView: View {
    @StateObject var viewModel: ImageSearchViewModel
    
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
                case .loaded, .loadingMore:
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(viewModel.state.items) { item in
                                ImageThumbnail(
                                    thumbnailUrl: item.thumbnailUrl,
                                    previewUrl:item.previewUrl
                                )
                                .onAppear {
                                    let lastItem: Photo? = viewModel.state.items.last
                                    guard viewModel.state.status == .loaded else { return }
                                    guard viewModel.state.hasMoreItems else { return }
                                    guard item.id == lastItem?.id else { return }
                                    viewModel.loadMoreItems()
                                }
                            }
                        }
                        if (viewModel.state.status == .loadingMore) {
                            HStack {
                                  Spacer()
                                  ProgressView()
                                  Spacer()
                                }
                                .padding(.vertical)
                        }
                    }
                case .empty:
                    Text("No results found")
                case .error:
                    VStack(spacing: 16) {
                        Text("Failed to load images")
                        Button("Retry") {
                            viewModel.retry()
                        }
                    }
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
    let thumbnailUrl: URL?
    let previewUrl: URL?
    @State private var showFullScreen: Bool = false
    
    var body: some View {
        AsyncImage(url: thumbnailUrl) { phase in
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
                    .onTapGesture {
                        showFullScreen = true
                    }
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
        .fullScreenCover(isPresented: $showFullScreen) {
            ImagePreview(url: previewUrl)
        }
    }
}

#Preview("ImageThumbnail") {
    VStack(spacing: 16) {
        ImageThumbnail(thumbnailUrl: nil, previewUrl: nil)
        ImageThumbnail(
            thumbnailUrl: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280"),
            previewUrl: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png")
        )
        ImageThumbnail(
            thumbnailUrl: URL(string: "https://invalid-url"),
            previewUrl: nil
        )
    }
}

#Preview("Default") {
    let viewModel = ImageSearchViewModel(
        state: ImageSearchUiState(),
        datasource: MockPhotosDataSource.mock
    )
    ImageSearchView(viewModel: viewModel)
}

#Preview("Empty") {
    let state = ImageSearchUiState(
        query: "test",
        items: [],
        totalItems: 0,
        status: .empty
    )
    let viewModel = ImageSearchViewModel(
        state: state,
        datasource: MockPhotosDataSource.mock
    )
    ImageSearchView(viewModel: viewModel)
}

#Preview("Loading") {
    let state = ImageSearchUiState(
        query: "test",
        items: [],
        totalItems: 0,
        status: .searching
    )
    let viewModel = ImageSearchViewModel(
        state: state,
        datasource: MockPhotosDataSource.mock
    )
    ImageSearchView(viewModel: viewModel)
}

#Preview("Error") {
    let state = ImageSearchUiState(
        query: "test",
        items: [],
        totalItems: 0,
        status: .error
    )
    let viewModel = ImageSearchViewModel(
        state: state,
        datasource: MockPhotosDataSource.mock
    )
    ImageSearchView(viewModel: viewModel)
}

#Preview("Loaded") {
    let items: [Photo] = Array(1...5).map { i in
        Photo(
            id: i,
            thumbnailUrl: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280"),
            previewUrl: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")
        )
    }
    let state = ImageSearchUiState(
        query: "test",
        items: items,
        totalItems: 5,
        status: .loaded
    )
    let viewModel = ImageSearchViewModel(
        state: state,
        datasource: MockPhotosDataSource.mock
    )
    ImageSearchView(viewModel: viewModel)
}
