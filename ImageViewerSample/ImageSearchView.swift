//
//  ContentView.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/8/25.
//

import SwiftUI

struct Photo: Identifiable {
    let id: Int
    let title: String
    let url: URL
}

struct ImageSearchView: View {
    @State private var searchText: String = ""
    
    private let items: [Photo] = Array(1...100).map { i in
        Photo(id: i, title: "item \(i)", url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")!)
    }
    
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        ImageThumbnail(url: item.url)
                    }
                }
            }
            .searchable(
                text: $searchText,
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
                    .foregroundStyle(.gray)
                    .frame(width: 100, height: 100)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 100, height: 100)
    }
}

#Preview("Empty") {
    ImageThumbnail(url: nil)
}

#Preview("Success") {
    ImageThumbnail(url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280"))
}

#Preview("Failure") {
    ImageThumbnail(url: URL(string: "https://invalid-url"))
}

#Preview {
    ImageSearchView()
}
