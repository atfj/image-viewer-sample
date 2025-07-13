//
//  ImageViewerSampleApp.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/8/25.
//

import SwiftUI

@main
struct ImageViewerSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ImageSearchView(viewModel: ImageSearchViewModel())
        }
    }
}
