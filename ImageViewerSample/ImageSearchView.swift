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
    private let items: [Photo] = Array(1...100).map { i in
        Photo(id: i, title: "item \(i)", url: URL(string: "https://images.pexels.com/photos/3573351/pexels-photo-3573351.png?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280")!)
    }
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 16),
        count: 3
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(items) { item in
                        VStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                            Text(item.title)
                                .frame(width: 100)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ImageSearchView()
}
