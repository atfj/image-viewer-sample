//
//  Photo.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import Foundation

struct Photo: Identifiable {
    let id: Int
    let thumbnailUrl: URL?
    let previewUrl: URL?
}
